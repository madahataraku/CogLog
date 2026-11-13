import Flutter
import UIKit
import Vision

/// Flutter bridge for Apple Vision text recognition on meter photos.
public class MeterReadingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "infra_meter_reading/vision_ocr",
      binaryMessenger: registrar.messenger()
    )
    let instance = MeterReadingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "recognizeText":
      guard
        let args = call.arguments as? [String: Any],
        let bytes = args["imageBytes"] as? FlutterStandardTypedData
      else {
        result(
          FlutterError(
            code: "BAD_ARGS",
            message: "imageBytes is required",
            details: nil
          )
        )
        return
      }
      recognize(imageBytes: bytes.data, withLayout: false, result: result)
    case "recognizeLayout":
      guard
        let args = call.arguments as? [String: Any],
        let bytes = args["imageBytes"] as? FlutterStandardTypedData
      else {
        result(
          FlutterError(
            code: "BAD_ARGS",
            message: "imageBytes is required",
            details: nil
          )
        )
        return
      }
      recognize(imageBytes: bytes.data, withLayout: true, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func recognize(
    imageBytes: Data,
    withLayout: Bool,
    result: @escaping FlutterResult
  ) {
    guard let image = UIImage(data: imageBytes), let cgImage = image.cgImage else {
      result(
        FlutterError(
          code: "DECODE_FAILED",
          message: "The image bytes could not be decoded.",
          details: nil
        )
      )
      return
    }

    let request = VNRecognizeTextRequest { request, error in
      if let error {
        result(
          FlutterError(
            code: "VISION_FAILED",
            message: error.localizedDescription,
            details: nil
          )
        )
        return
      }
      let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
      if withLayout {
        var tokens: [[String: Any]] = []
        for observation in observations {
          guard let candidate = observation.topCandidates(1).first else {
            continue
          }
          tokens.append(contentsOf: Self.layoutTokens(from: candidate))
        }
        result(tokens)
      } else {
        let lines = observations.compactMap { $0.topCandidates(1).first?.string }
        result(lines.joined(separator: "\n"))
      }
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    if #available(iOS 16.0, *) {
      request.recognitionLanguages = ["ja-JP", "en-US"]
    }

    let orientation = Self.cgImageOrientation(from: image.imageOrientation)
    let handler = VNImageRequestHandler(
      cgImage: cgImage,
      orientation: orientation,
      options: [:]
    )
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        result(
          FlutterError(
            code: "VISION_FAILED",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }
  }

  /// Splits a Vision string into whitespace-separated tokens with per-range boxes.
  private static func layoutTokens(
    from candidate: VNRecognizedText
  ) -> [[String: Any]] {
    let string = candidate.string
    let nsString = string as NSString
    var tokens: [[String: Any]] = []
    let fullRange = NSRange(location: 0, length: nsString.length)
    nsString.enumerateSubstrings(
      in: fullRange,
      options: [.byWords, .localized]
    ) { substring, substringRange, _, _ in
      guard let substring, !substring.isEmpty else {
        return
      }
      guard
        let swiftRange = Range(substringRange, in: string),
        let box = try? candidate.boundingBox(for: swiftRange)?.boundingBox
      else {
        return
      }
      tokens.append(
        [
          "text": substring,
          "left": box.origin.x,
          "top": 1.0 - box.origin.y - box.size.height,
          "width": box.size.width,
          "height": box.size.height,
        ]
      )
    }
    if tokens.isEmpty, !string.isEmpty {
      // Fallback when word enumeration yields nothing: keep the whole observation.
      // Bounding box for the full string may still fail; skip then.
      if let box = try? candidate.boundingBox(for: string.startIndex..<string.endIndex)?
        .boundingBox
      {
        tokens.append(
          [
            "text": string,
            "left": box.origin.x,
            "top": 1.0 - box.origin.y - box.size.height,
            "width": box.size.width,
            "height": box.size.height,
          ]
        )
      }
    }
    return tokens
  }

  /// Maps UIImage orientation to the CGImagePropertyOrientation Vision expects.
  private static func cgImageOrientation(
    from orientation: UIImage.Orientation
  ) -> CGImagePropertyOrientation {
    switch orientation {
    case .up: return .up
    case .down: return .down
    case .left: return .left
    case .right: return .right
    case .upMirrored: return .upMirrored
    case .downMirrored: return .downMirrored
    case .leftMirrored: return .leftMirrored
    case .rightMirrored: return .rightMirrored
    @unknown default: return .up
    }
  }
}
