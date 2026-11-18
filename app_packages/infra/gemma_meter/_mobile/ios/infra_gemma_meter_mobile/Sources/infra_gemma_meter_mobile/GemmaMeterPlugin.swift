import Flutter
import Foundation
import UIKit
#if canImport(CoreMLLLM)
import CoreMLLLM
#endif

/// Flutter bridge for Core ML Gemma E2B meter reading on iOS.
///
/// Model files download into Documents/Models/`gemma4-e2b` via CoreMLLLM's
/// `ModelDownloader` (Hugging Face `mlboydaisuke/gemma-4-E2B-coreml`).
/// The model directory is excluded from OS backup.
public class GemmaMeterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let minFreeBytes: Int64 = 6 * 1024 * 1024 * 1024
  private static let configuredBackend = "ane"
  private static let configuredVisionBackend = "ane"

  private let queue = DispatchQueue(label: "io.github.madahataraku.coglog.gemma_meter")
  private var prepareEvents: FlutterEventSink?
  private var preparing = false
  #if canImport(CoreMLLLM)
  private var llm: CoreMLLLM?
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
    #if canImport(CoreMLLLM)
    guard isModelDownloaded() else {
      return [
        "status": "modelNotDownloaded",
        "reason": "missingFile",
        "message": "Gemma meter Core ML model is not downloaded.",
        "backend": Self.configuredBackend,
        "visionBackend": Self.configuredVisionBackend,
      ]
    }
    return [
      "status": "ready",
      "reason": "ready",
      "message": "Gemma meter Core ML model is ready.",
      "backend": Self.configuredBackend,
      "visionBackend": Self.configuredVisionBackend,
    ]
    #else
    return [
      "status": "unavailable",
      "reason": "missingDependency",
      "message":
        "CoreMLLLM Swift package is not linked. Add https://github.com/john-rocky/CoreML-LLM.",
      "backend": Self.configuredBackend,
      "visionBackend": Self.configuredVisionBackend,
    ]
    #endif
  }

  private func prepareModel(result: @escaping FlutterResult) {
    #if canImport(CoreMLLLM)
    if preparing {
      DispatchQueue.main.async {
        result(
          FlutterError(
            code: "generic",
            message: "Gemma meter prepare is already running.",
            details: nil
          )
        )
      }
      return
    }
    preparing = true
    emitProgress(0)
    do {
      try ensureFreeSpace()
      try awaitSync {
        try await self.downloadIfNeeded()
      }
      try excludeDownloadedModelFromBackup()
      emitProgress(1)
      preparing = false
      DispatchQueue.main.async { result(nil) }
    } catch {
      preparing = false
      DispatchQueue.main.async {
        result(
          FlutterError(
            code: Self.mapPrepareCode(error),
            message: Self.safeMessage(error),
            details: nil
          )
        )
      }
    }
    #else
    DispatchQueue.main.async {
      result(
        FlutterError(
          code: "generic",
          message:
            "CoreMLLLM Swift package is not linked. Add https://github.com/john-rocky/CoreML-LLM.",
          details: nil
        )
      )
    }
    #endif
  }

  #if canImport(CoreMLLLM)
  private func generate(prompt: String, imageBytes: Data, requireReady: Bool) throws -> String {
    if requireReady && !isModelDownloaded() {
      throw NSError(
        domain: "GemmaMeter",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Gemma meter Core ML model is not downloaded."]
      )
    }
    if !isModelDownloaded() {
      throw NSError(
        domain: "GemmaMeter",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Gemma meter Core ML model is not downloaded."]
      )
    }
    let loaded = try ensureLLM()
    guard let cgImage = Self.cgImage(from: imageBytes) else {
      throw NSError(
        domain: "GemmaMeter",
        code: 5,
        userInfo: [NSLocalizedDescriptionKey: "Image bytes could not be decoded."]
      )
    }
    return try awaitSync {
      try await loaded.generate(prompt, image: cgImage, maxTokens: 256)
    }
  }

  private func ensureLLM() throws -> CoreMLLLM {
    if let llm {
      return llm
    }
    guard let directory = modelDirectoryURL(),
      FileManager.default.fileExists(atPath: directory.path)
    else {
      throw NSError(
        domain: "GemmaMeter",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Gemma meter Core ML model is not downloaded."]
      )
    }
    let created = try awaitSync {
      try await CoreMLLLM.load(from: directory, computeUnits: .cpuAndNeuralEngine)
    }
    llm = created
    return created
  }

  private func downloadIfNeeded() async throws {
    UserDefaults.standard.set(true, forKey: ModelDownloader.includeMultimodalKey)
    let downloader = ModelDownloader.shared
    let model = ModelDownloader.ModelInfo.gemma4e2b
    if downloader.isDownloaded(model) {
      emitProgress(1)
      return
    }
    let progressTask = Task { [weak self] in
      while !Task.isCancelled {
        let value = await MainActor.run { ModelDownloader.shared.progress }
        self?.emitProgress(min(max(value, 0), 0.99))
        try? await Task.sleep(nanoseconds: 200_000_000)
      }
    }
    defer { progressTask.cancel() }
    _ = try await downloader.download(model)
  }

  private func isModelDownloaded() -> Bool {
    ModelDownloader.shared.isDownloaded(ModelDownloader.ModelInfo.gemma4e2b)
  }

  private func modelDirectoryURL() -> URL? {
    let models = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
      .appendingPathComponent("Models", isDirectory: true)
    return models?.appendingPathComponent(
      ModelDownloader.ModelInfo.gemma4e2b.folderName,
      isDirectory: true
    )
  }

  private func excludeDownloadedModelFromBackup() throws {
    let fm = FileManager.default
    guard
      let modelsRoot = fm.urls(for: .documentDirectory, in: .userDomainMask).first?
      .appendingPathComponent("Models", isDirectory: true)
    else {
      return
    }
    if fm.fileExists(atPath: modelsRoot.path) {
      try excludeFromBackup(modelsRoot)
    }
    if let modelDir = modelDirectoryURL(), fm.fileExists(atPath: modelDir.path) {
      try excludeFromBackup(modelDir)
    }
  }

  private func ensureFreeSpace() throws {
    guard
      let modelsRoot = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    else {
      throw PrepareError.generic("Documents directory is unavailable.")
    }
    let attrs = try FileManager.default.attributesOfFileSystem(forPath: modelsRoot.path)
    let free = (attrs[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
    if free > 0 && free < Self.minFreeBytes {
      throw PrepareError.insufficientStorage
    }
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

  private static func cgImage(from data: Data) -> CGImage? {
    guard let image = UIImage(data: data) else { return nil }
    return image.cgImage
  }
  #else
  private func generate(prompt: String, imageBytes: Data, requireReady: Bool) throws -> String {
    throw NSError(
      domain: "GemmaMeter",
      code: 4,
      userInfo: [
        NSLocalizedDescriptionKey:
          "CoreMLLLM Swift package is not linked. Add https://github.com/john-rocky/CoreML-LLM."
      ]
    )
  }
  #endif

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
    let message = ns.localizedDescription.lowercased()
    if message.contains("space") || message.contains("storage") {
      return "insufficientStorage"
    }
    if message.contains("network") || message.contains("offline") || message.contains("http") {
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
        return "Not enough free space for Gemma Core ML model."
      case .network(let message):
        return message
      case .generic(let message):
        return message
      }
    }
  }
}
