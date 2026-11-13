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

    let sevenSeg = FlutterMethodChannel(
      name: "infra_meter_reading/seven_segment",
      binaryMessenger: registrar.messenger()
    )
    let runner = SevenSegmentCoreMlRunner()
    sevenSeg.setMethodCallHandler { call, result in
      guard call.method == "predict" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let args = call.arguments as? [String: Any],
        let typed = args["inputFloat32"] as? FlutterStandardTypedData
      else {
        result(FlutterError(code: "BAD_ARGS", message: "inputFloat32 required", details: nil))
        return
      }
      do {
        result(try runner.predict(inputFloat32: typed.data))
      } catch {
        result(FlutterError(code: "COREML_FAILED", message: error.localizedDescription, details: nil))
      }
    }
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

  /// Splits a Vision string on whitespace only, keeping `:`, `：`, `/` inside tokens.
  private static func layoutTokens(
    from candidate: VNRecognizedText
  ) -> [[String: Any]] {
    let string = candidate.string
    var tokens: [[String: Any]] = []
    var start = string.startIndex
    while start < string.endIndex {
      while start < string.endIndex, string[start].isWhitespace {
        start = string.index(after: start)
      }
      guard start < string.endIndex else {
        break
      }
      var end = start
      while end < string.endIndex, !string[end].isWhitespace {
        end = string.index(after: end)
      }
      let range = start..<end
      let substring = String(string[range])
      if let box = try? candidate.boundingBox(for: range)?.boundingBox {
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
      start = end
    }
    if tokens.isEmpty {
      let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty,
        let box = try? candidate.boundingBox(
          for: string.startIndex..<string.endIndex
        )?.boundingBox
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
