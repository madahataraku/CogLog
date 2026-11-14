import Flutter
import Foundation
import UIKit
#if canImport(LiteRTLM)
import LiteRTLM
#endif

/// Flutter bridge for LiteRT-LM Gemma E2B meter reading.
///
/// Model files are stored under Application Support/`gemma_meter` with
/// `NSURLIsExcludedFromBackupKey` so OS backup excludes them.
public class GemmaMeterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let modelDirName = "gemma_meter"
  private static let modelFileName = "gemma-3n-E2B-it-int4.litertlm"
  /// litert.dev catalog mirror (ungated). Upstream HF google/… is gated (401).
  private static let modelURLString =
    "https://models.litert.dev/gemma-3n-E2B-it-int4.litertlm"
  private static let minFreeBytes: Int64 = 200 * 1024 * 1024

  private let queue = DispatchQueue(label: "io.github.madahataraku.coglog.gemma_meter")
  private var prepareEvents: FlutterEventSink?
  private var preparing = false
  #if canImport(LiteRTLM)
  private var engine: Engine?
  #endif

  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let channel = FlutterMethodChannel(name: "infra_gemma_meter", binaryMessenger: messenger)
    let instance = GemmaMeterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    FlutterEventChannel(name: "infra_gemma_meter/prepare", binaryMessenger: messenger)
      .setStreamHandler(instance)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    prepareEvents = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    prepareEvents = nil
    return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "getAvailability":
      queue.async {
        let map = self.availabilityMap()
        DispatchQueue.main.async { result(map) }
      }
    case "prepareModel":
      queue.async { self.prepareModel(result: result) }
    case "generateWithImage", "diagnoseGenerateWithImage":
      let prompt = args["prompt"] as? String ?? ""
      let imageBytes = (args["imageBytes"] as? FlutterStandardTypedData)?.data ?? Data()
      let requireReady = call.method == "generateWithImage"
      queue.async {
        do {
          let text = try self.generate(
            prompt: prompt,
            imageBytes: imageBytes,
            requireReady: requireReady
          )
          DispatchQueue.main.async { result(text) }
        } catch {
          DispatchQueue.main.async {
            result(
              FlutterError(
                code: "generic",
                message: Self.safeMessage(error),
                details: nil
              )
            )
          }
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func availabilityMap() -> [String: String] {
    #if canImport(LiteRTLM)
    guard let model = try? modelFileURL(), FileManager.default.fileExists(atPath: model.path) else {
      return [
        "status": "modelNotDownloaded",
        "reason": "missingFile",
        "message": "Gemma meter model is not downloaded.",
      ]
    }
    do {
      try ensureEngine(modelPath: model.path)
      return [
        "status": "ready",
        "reason": "ready",
        "message": "Gemma meter model is ready.",
      ]
    } catch {
      return [
        "status": "unavailable",
        "reason": "initializeFailed",
        "message": "Gemma meter model failed to initialize.",
      ]
    }
    #else
    return [
      "status": "unavailable",
      "reason": "liteRtlmMissing",
      "message":
        "LiteRTLM Swift package is not linked. Add https://github.com/google-ai-edge/LiteRT-LM from 0.19.0.",
    ]
    #endif
  }

  private func prepareModel(result: @escaping FlutterResult) {
    #if canImport(LiteRTLM)
    if preparing {
      DispatchQueue.main.async { result(nil) }
      return
    }
    preparing = true
    defer { preparing = false }
    do {
      let target = try modelFileURL()
      if !FileManager.default.fileExists(atPath: target.path) {
        try downloadModel(to: target)
      }
      emitProgress(1.0)
      try ensureEngine(modelPath: target.path)
      DispatchQueue.main.async {
        self.prepareEvents?(FlutterEndOfEventStream)
        result(nil)
      }
    } catch {
      let code = Self.mapPrepareCode(error)
      DispatchQueue.main.async {
        self.prepareEvents?(
          FlutterError(code: code, message: Self.safeMessage(error), details: nil)
        )
        result(FlutterError(code: code, message: Self.safeMessage(error), details: nil))
      }
    }
    #else
    let message =
      "LiteRTLM Swift package is not linked. Add https://github.com/google-ai-edge/LiteRT-LM from 0.19.0."
    DispatchQueue.main.async {
      self.prepareEvents?(
        FlutterError(code: "generic", message: message, details: nil)
      )
      result(FlutterError(code: "generic", message: message, details: nil))
    }
    #endif
  }

  #if canImport(LiteRTLM)
  private func generate(prompt: String, imageBytes: Data, requireReady: Bool) throws -> String {
    _ = requireReady
    let model = try modelFileURL()
    guard FileManager.default.fileExists(atPath: model.path) else {
      throw NSError(
        domain: "GemmaMeter",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Gemma meter model is not downloaded."]
      )
    }
    try ensureEngine(modelPath: model.path)
    guard let engine else {
      throw NSError(
        domain: "GemmaMeter",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Gemma meter engine is unavailable."]
      )
    }
    // Official multimodal samples use imageFile; write bytes to a temp path.
    let tempImage = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension("img")
    try imageBytes.write(to: tempImage)
    defer { try? FileManager.default.removeItem(at: tempImage) }
    let conversation = try awaitSync { try await engine.createConversation() }
    let message = Message(contents: [
      Content.imageFile(tempImage.path),
      Content.text(prompt),
    ])
    let response = try awaitSync { try await conversation.sendMessage(message) }
    return response.toString
  }

  private func ensureEngine(modelPath: String) throws {
    if engine != nil { return }
    let cacheDir = (modelPath as NSString).deletingLastPathComponent + "/cache"
    try FileManager.default.createDirectory(
      atPath: cacheDir,
      withIntermediateDirectories: true
    )
    let config = try EngineConfig(
      modelPath: modelPath,
      backend: .cpu(),
      visionBackend: .cpu(),
      cacheDir: cacheDir
    )
    let created = Engine(engineConfig: config)
    try awaitSync { try await created.initialize() }
    engine = created
  }

  private func awaitSync<T>(_ body: @escaping () async throws -> T) throws -> T {
    let box = ResultBox<T>()
    let semaphore = DispatchSemaphore(value: 0)
    Task {
      do {
        box.value = .success(try await body())
      } catch {
        box.value = .failure(error)
      }
      semaphore.signal()
    }
    semaphore.wait()
    switch box.value {
    case .success(let value):
      return value
    case .failure(let error):
      throw error
    case .none:
      throw NSError(
        domain: "GemmaMeter",
        code: 3,
        userInfo: [NSLocalizedDescriptionKey: "Async bridge failed."]
      )
    }
  }

  private final class ResultBox<T>: @unchecked Sendable {
    var value: Result<T, Error>?
  }
  #else
  private func generate(prompt: String, imageBytes: Data, requireReady: Bool) throws -> String {
    throw NSError(
      domain: "GemmaMeter",
      code: 4,
      userInfo: [
        NSLocalizedDescriptionKey:
          "LiteRTLM Swift package is not linked. Add https://github.com/google-ai-edge/LiteRT-LM from 0.19.0."
      ]
    )
  }
  #endif

  private func downloadModel(to target: URL) throws {
    let fm = FileManager.default
    let parent = target.deletingLastPathComponent()
    try fm.createDirectory(at: parent, withIntermediateDirectories: true)
    try excludeFromBackup(parent)

    let attrs = try fm.attributesOfFileSystem(forPath: parent.path)
    let free = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
    if free > 0 && free < Self.minFreeBytes {
      throw PrepareError.insufficientStorage
    }

    guard let remote = URL(string: Self.modelURLString) else {
      throw PrepareError.network("Invalid model URL.")
    }
    let partial = parent.appendingPathComponent(Self.modelFileName + ".partial")
    if fm.fileExists(atPath: partial.path) {
      try? fm.removeItem(at: partial)
    }

    let semaphore = DispatchSemaphore(value: 0)
    var downloadError: Error?
    let session = URLSession(
      configuration: .default,
      delegate: ProgressDelegate { [weak self] progress in
        self?.emitProgress(min(progress, 0.99))
      },
      delegateQueue: nil
    )
    let task = session.downloadTask(with: remote) { tempURL, response, error in
      defer { semaphore.signal() }
      if let error {
        downloadError = PrepareError.network(error.localizedDescription)
        return
      }
      guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
        downloadError = PrepareError.network("Model download HTTP failure.")
        return
      }
      guard let tempURL else {
        downloadError = PrepareError.network("Model download produced no file.")
        return
      }
      do {
        if fm.fileExists(atPath: partial.path) {
          try fm.removeItem(at: partial)
        }
        try fm.moveItem(at: tempURL, to: partial)
        if fm.fileExists(atPath: target.path) {
          try fm.removeItem(at: target)
        }
        try fm.moveItem(at: partial, to: target)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableTarget = target
        try mutableTarget.setResourceValues(values)
      } catch {
        downloadError = error
      }
    }
    task.resume()
    semaphore.wait()
    session.finishTasksAndInvalidate()
    if let downloadError {
      try? fm.removeItem(at: partial)
      throw downloadError
    }
  }

  private func modelFileURL() throws -> URL {
    let bases = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    guard let base = bases.first else {
      throw PrepareError.generic("Application Support is unavailable.")
    }
    let dir = base.appendingPathComponent(Self.modelDirName, isDirectory: true)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    try excludeFromBackup(dir)
    return dir.appendingPathComponent(Self.modelFileName)
  }

  private func excludeFromBackup(_ url: URL) throws {
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    var mutable = url
    try mutable.setResourceValues(values)
  }

  private func emitProgress(_ value: Double) {
    DispatchQueue.main.async { self.prepareEvents?(value) }
  }

  private static func mapPrepareCode(_ error: Error) -> String {
    if let prepare = error as? PrepareError {
      switch prepare {
      case .insufficientStorage:
        return "insufficientStorage"
      case .network:
        return "network"
      case .generic:
        return "generic"
      }
    }
    let ns = error as NSError
    if ns.domain == NSURLErrorDomain {
      return "network"
    }
    return "generic"
  }

  private static func safeMessage(_ error: Error) -> String {
    let raw = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
    if raw.isEmpty {
      return String(describing: type(of: error))
    }
    return String(raw.prefix(200))
  }

  private enum PrepareError: LocalizedError {
    case insufficientStorage
    case network(String)
    case generic(String)

    var errorDescription: String? {
      switch self {
      case .insufficientStorage:
        return "Not enough free space for Gemma model."
      case .network(let message):
        return message
      case .generic(let message):
        return message
      }
    }
  }
}

private final class ProgressDelegate: NSObject, URLSessionDownloadDelegate {
  private let onProgress: (Double) -> Void

  init(onProgress: @escaping (Double) -> Void) {
    self.onProgress = onProgress
  }

  func urlSession(
    _ session: URLSession,
    downloadTask: URLSessionDownloadTask,
    didWriteData bytesWritten: Int64,
    totalBytesWritten: Int64,
    totalBytesExpectedToWrite: Int64
  ) {
    guard totalBytesExpectedToWrite > 0 else { return }
    onProgress(Double(totalBytesWritten) / Double(totalBytesExpectedToWrite))
  }

  func urlSession(
    _ session: URLSession,
    downloadTask: URLSessionDownloadTask,
    didFinishDownloadingTo location: URL
  ) {
    // Completion handled in the download task callback.
  }
}
