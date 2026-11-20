import Flutter
import Foundation
#if canImport(LiteRTLM)
import LiteRTLM
#endif

/// Flutter bridge for LiteRT-LM Gemma E2B meter reading on iOS.
///
/// Downloads the same ungated Hugging Face `litert-community` `.litertlm`
/// used on Android into Documents/Models/`gemma_meter/`, excluded from OS
/// backup. Engine: main GPU, vision GPU, speculative decoding (MTP) on.
public class GemmaMeterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let modelFolderName = "gemma_meter"
  private static let modelFileName = "gemma-4-E2B-it.litertlm"
  private static let modelURL =
    "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm"
  /// Current litert-community E2B `.litertlm` payload (~2.59 GB).
  private static let estimatedModelBytes: Int64 = 2_588_147_712
  /// Reject truncated / redirect-body downloads as complete artifacts.
  private static let minPlausibleModelBytes: Int64 = 100 * 1024 * 1024
  /// Legacy CoreMLLLM chunk tree (pre LiteRT-LM migration).
  private static let legacyCoreMLFolderName = "gemma4-e2b"
  /// URLSession peak ≈ one model copy in tmp/Documents + LiteRT cache margin.
  private static var minFreeBytes: Int64 {
    estimatedModelBytes + 500_000_000
  }

  private static let configuredBackend = "gpu"
  private static let configuredVisionBackend = "gpu"
  /// Bumped when on-disk `.litertlm` must be refreshed (e.g. MTP-capable build).
  private static let engineStampKey = "gemmaMeter.engineStamp"
  private static let engineStampValue = "litert-mtp-gpu-v1"

  private let queue = DispatchQueue(label: "io.github.madahataraku.coglog.gemma_meter")
  private var prepareEvents: FlutterEventSink?
  private var preparing = false
  private var lastEmittedProgressBucket = -1
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

  private func configuredBackendFields() -> [String: String] {
    [
      "backend": Self.configuredBackend,
      "visionBackend": Self.configuredVisionBackend,
    ]
  }

  private func availabilityMap() -> [String: String] {
    #if canImport(LiteRTLM)
    // Best-effort: reclaim the old CoreMLLLM tree so both models are not kept.
    removeLegacyCoreMLModelIfPresent()
    guard isModelDownloaded() else {
      return [
        "status": "modelNotDownloaded",
        "reason": "missingFile",
        "message": "Gemma meter model is not downloaded.",
      ].merging(configuredBackendFields()) { _, new in new }
    }
    // Mirror Android: ready only after Engine.initialize() succeeds this process.
    do {
      _ = try ensureEngine()
      return [
        "status": "ready",
        "reason": "ready",
        "message": "Gemma meter model is ready.",
      ].merging(configuredBackendFields()) { _, new in new }
    } catch {
      return [
        "status": "unavailable",
        "reason": "initializeFailed",
        "message": "Gemma meter model failed to initialize.",
      ].merging(configuredBackendFields()) { _, new in new }
    }
    #else
    return [
      "status": "unavailable",
      "reason": "missingDependency",
      "message":
        "LiteRTLM Swift package is not linked. Add https://github.com/google-ai-edge/LiteRT-LM.",
    ].merging(configuredBackendFields()) { _, new in new }
    #endif
  }

  private func prepareModel(result: @escaping FlutterResult) {
    #if canImport(LiteRTLM)
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
      removeLegacyCoreMLModelIfPresent()
      try downloadIfNeeded()
      try excludeDownloadedModelFromBackup()
      _ = try ensureEngine()
      emitProgress(1)
      preparing = false
      DispatchQueue.main.async {
        self.prepareEvents?(FlutterEndOfEventStream)
        result(nil)
      }
    } catch {
      preparing = false
      // Keep a plausible on-disk artifact across device-specific init failures;
      // only reclaim truncated / clearly invalid files for retry.
      if isModelDownloaded() {
        markLoadFailed()
      } else {
        try? removeIncompleteModel()
      }
      let code = Self.mapPrepareCode(error)
      let message = Self.safeMessage(error)
      DispatchQueue.main.async {
        self.prepareEvents?(
          FlutterError(code: code, message: message, details: nil)
        )
        result(FlutterError(code: code, message: message, details: nil))
      }
    }
    #else
    let message =
      "LiteRTLM Swift package is not linked. Add https://github.com/google-ai-edge/LiteRT-LM."
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
    if !isModelDownloaded() {
      throw NSError(
        domain: "GemmaMeter",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Gemma meter model is not downloaded."]
      )
    }
    if requireReady {
      // Mirror Android: require a successful initialize path.
      _ = try ensureEngine()
    }
    let active = try ensureEngine()
    return try awaitSync {
      // Engine is an actor; createConversation must be awaited.
      let conversation = try await active.createConversation()
      let response = try await conversation.sendMessage(
        Message(of: .imageData(imageBytes), .text(prompt))
      )
      return response.toString
    }
  }

  private func ensureEngine() throws -> Engine {
    if let engine {
      return engine
    }
    guard let model = modelFileURL(),
      FileManager.default.fileExists(atPath: model.path)
    else {
      throw NSError(
        domain: "GemmaMeter",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Gemma meter model is not downloaded."]
      )
    }
    let cacheDir = model.deletingLastPathComponent().appendingPathComponent(
      "cache",
      isDirectory: true
    )
    try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    let config = try EngineConfig(
      modelPath: model.path,
      backend: .gpu,
      visionBackend: .gpu,
      cacheDir: cacheDir.path,
      speculativeDecodingConfig: SpeculativeDecodingConfig(mode: .on)
    )
    let created = Engine(engineConfig: config)
    do {
      // Engine is an actor; initialize must be awaited from outside.
      try awaitSync {
        try await created.initialize()
      }
    } catch {
      markLoadFailed()
      // Reclaim truncated or container-corrupt artifacts so prepare can re-fetch.
      // Keep a plausible file when failure looks device/backend-specific (GPU).
      if !isModelDownloaded() || Self.isLikelyCorruptModelError(error) {
        try? removeIncompleteModel()
        clearEngineStamp()
      }
      throw error
    }
    engine = created
    markEngineStampCurrent()
    return created
  }

  private func markLoadFailed() {
    engine = nil
  }

  private func downloadIfNeeded() throws {
    if isModelDownloaded() {
      if isEngineStampCurrent() {
        emitProgress(1)
        return
      }
      // Pre-MTP / stamp-mismatched artifacts must be refreshed once.
      try removeIncompleteModel()
    }
    // Incomplete / undersized leftovers must not block a fresh download.
    try removeIncompleteModel()
    try ensureModelDirectoryExcludedFromBackup()
    try ensureFreeSpace()
    lastEmittedProgressBucket = -1
    do {
      try downloadModelFile()
    } catch {
      try? removeIncompleteModel()
      throw error
    }
    guard isModelDownloaded() else {
      try? removeIncompleteModel()
      throw PrepareError.generic("Gemma meter download finished without a valid model file.")
    }
  }

  private func isEngineStampCurrent() -> Bool {
    UserDefaults.standard.string(forKey: Self.engineStampKey) == Self.engineStampValue
  }

  private func markEngineStampCurrent() {
    UserDefaults.standard.set(Self.engineStampValue, forKey: Self.engineStampKey)
  }

  private func clearEngineStamp() {
    UserDefaults.standard.removeObject(forKey: Self.engineStampKey)
  }

  /// True when initialize failed because the on-disk container looks unusable.
  private static func isLikelyCorruptModelError(_ error: Error) -> Bool {
    let text = safeMessage(error).lowercased()
    if isLikelyBackendError(text) {
      return false
    }
    return text.contains("corrupt")
      || text.contains("invalid")
      || text.contains("loader")
      || text.contains("parse")
      || text.contains("format")
      || text.contains("header")
      || text.contains("truncated")
      || text.contains("not a valid")
      || text.contains("speculative")
      || text.contains("drafter")
      || text.contains("mtp")
  }

  private static func isLikelyBackendError(_ text: String) -> Bool {
    text.contains("gpu")
      || text.contains("metal")
      || text.contains("opencl")
      || text.contains("delegate")
      || text.contains("backend")
  }

  private func downloadModelFile() throws {
    guard let directory = modelDirectoryURL() else {
      throw PrepareError.generic("Documents directory is unavailable.")
    }
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    guard let url = URL(string: Self.modelURL) else {
      throw PrepareError.generic("Invalid model URL.")
    }
    let destination = directory.appendingPathComponent(Self.modelFileName)
    let partial = directory.appendingPathComponent("\(Self.modelFileName).partial")
    let fm = FileManager.default
    if fm.fileExists(atPath: partial.path) {
      try fm.removeItem(at: partial)
    }

    try awaitSync {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        final class ObservationBox {
          var observation: NSKeyValueObservation?
        }
        let box = ObservationBox()
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
          box.observation?.invalidate()
          box.observation = nil
          if let error {
            continuation.resume(throwing: PrepareError.network(Self.safeMessage(error)))
            return
          }
          guard let location else {
            continuation.resume(throwing: PrepareError.network("Empty model download."))
            return
          }
          if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            continuation.resume(
              throwing: PrepareError.network("Model download HTTP \(http.statusCode).")
            )
            return
          }
          do {
            if fm.fileExists(atPath: partial.path) {
              try fm.removeItem(at: partial)
            }
            try fm.moveItem(at: location, to: partial)
            let size =
              (try? fm.attributesOfItem(atPath: partial.path)[.size] as? NSNumber)?
              .int64Value ?? 0
            if size < Self.minPlausibleModelBytes {
              try? fm.removeItem(at: partial)
              continuation.resume(
                throwing: PrepareError.network(
                  "Model download finished with an implausibly small file."
                )
              )
              return
            }
            if fm.fileExists(atPath: destination.path) {
              try fm.removeItem(at: destination)
            }
            try fm.moveItem(at: partial, to: destination)
            continuation.resume(returning: ())
          } catch {
            continuation.resume(throwing: error)
          }
        }
        box.observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
          guard let self else { return }
          let capped = min(max(progress.fractionCompleted, 0), 0.99)
          self.emitProgressBucketed(capped)
        }
        task.resume()
      }
    }
  }

  private func emitProgressBucketed(_ value: Double) {
    let bucket = Int((value * 100).rounded(.down))
    guard bucket != lastEmittedProgressBucket else { return }
    lastEmittedProgressBucket = bucket
    emitProgress(value)
  }

  private func isModelDownloaded() -> Bool {
    guard let model = modelFileURL() else { return false }
    guard FileManager.default.fileExists(atPath: model.path) else { return false }
    let size =
      (try? FileManager.default.attributesOfItem(atPath: model.path)[.size] as? NSNumber)?
      .int64Value ?? 0
    return size >= Self.minPlausibleModelBytes
  }

  private func modelsRootURL() -> URL? {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
      .appendingPathComponent("Models", isDirectory: true)
  }

  private func modelDirectoryURL() -> URL? {
    modelsRootURL()?.appendingPathComponent(Self.modelFolderName, isDirectory: true)
  }

  private func modelFileURL() -> URL? {
    modelDirectoryURL()?.appendingPathComponent(Self.modelFileName)
  }

  private func legacyCoreMLDirectoryURL() -> URL? {
    modelsRootURL()?.appendingPathComponent(Self.legacyCoreMLFolderName, isDirectory: true)
  }

  /// Deletes Documents/Models/gemma4-e2b from the CoreMLLLM era if still present.
  private func removeLegacyCoreMLModelIfPresent() {
    let fm = FileManager.default
    guard let legacy = legacyCoreMLDirectoryURL(), fm.fileExists(atPath: legacy.path) else {
      return
    }
    try? fm.removeItem(at: legacy)
    // Drop CoreML-era readiness prefs so they cannot resurrect as ready.
    UserDefaults.standard.removeObject(forKey: "gemmaMeter.loadSucceeded")
    UserDefaults.standard.removeObject(forKey: "gemmaMeter.activeBackend")
    UserDefaults.standard.removeObject(forKey: "gemmaMeter.litertLoadSucceeded")
  }

  private func removeIncompleteModel() throws {
    let fm = FileManager.default
    guard let modelDir = modelDirectoryURL(), fm.fileExists(atPath: modelDir.path) else {
      markLoadFailed()
      clearEngineStamp()
      return
    }
    try fm.removeItem(at: modelDir)
    markLoadFailed()
    clearEngineStamp()
  }

  private func ensureModelDirectoryExcludedFromBackup() throws {
    let fm = FileManager.default
    guard let modelsRoot = modelsRootURL() else {
      throw PrepareError.generic("Documents directory is unavailable.")
    }
    try fm.createDirectory(at: modelsRoot, withIntermediateDirectories: true)
    try excludeFromBackup(modelsRoot)
    if let modelDir = modelDirectoryURL() {
      try fm.createDirectory(at: modelDir, withIntermediateDirectories: true)
      try excludeFromBackup(modelDir)
    }
  }

  private func excludeDownloadedModelFromBackup() throws {
    try ensureModelDirectoryExcludedFromBackup()
  }

  private func ensureFreeSpace() throws {
    guard
      let modelsRoot = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    else {
      throw PrepareError.generic("Documents directory is unavailable.")
    }
    let free = Self.availableBytes(at: modelsRoot)
    if free > 0 && free < Self.minFreeBytes {
      throw PrepareError.insufficientStorage
    }
  }

  /// Best-effort free space for a user-started download.
  private static func availableBytes(at url: URL) -> Int64 {
    var candidates: [Int64] = []
    let keys: Set<URLResourceKey> = [
      .volumeAvailableCapacityForImportantUsageKey,
      .volumeAvailableCapacityForOpportunisticUsageKey,
      .volumeAvailableCapacityKey,
    ]
    if let values = try? url.resourceValues(forKeys: keys) {
      if let important = values.volumeAvailableCapacityForImportantUsage, important > 0 {
        candidates.append(important)
      }
      if let opportunistic = values.volumeAvailableCapacityForOpportunisticUsage,
        opportunistic > 0
      {
        candidates.append(opportunistic)
      }
      if let capacity = values.volumeAvailableCapacity, capacity > 0 {
        candidates.append(Int64(capacity))
      }
    }
    if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: url.path),
      let free = (attrs[.systemFreeSize] as? NSNumber)?.int64Value,
      free > 0
    {
      candidates.append(free)
    }
    return candidates.max() ?? 0
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
          "LiteRTLM Swift package is not linked. Add https://github.com/google-ai-edge/LiteRT-LM."
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
    // Avoid classifying bare "timed out" or incidental "http" as network
    // (prepare may fail after a finished download during warm-load).
    if message.contains("network") || message.contains("offline")
      || message.contains("http ") || message.contains("http:")
    {
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
