import Flutter
import Foundation
import UIKit
#if canImport(CoreMLLLM)
import CoreMLLLM
#endif

/// Flutter bridge for Core ML Gemma E2B meter reading on iOS.
///
/// Downloads a lean monolithic bundle (text `model.mlpackage` + still-image
/// `vision.mlpackage` + tokenizer) into Documents/Models/`gemma4-e2b` from
/// Hugging Face `smdesai/gemma-4-E2B-coreml`. Chunked / video / audio / PLE
/// sidecars are omitted so CoreMLLLM takes the monolithic load path.
/// The model directory is excluded from OS backup.
public class GemmaMeterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let modelFolderName = "gemma4-e2b"
  /// Preferred text backend label before a successful load probe.
  private static let preferredBackend = "ane"
  /// Lean `vision.mlpackage` is selected on CoreMLLLM's GPU path.
  private static let configuredVisionBackend = "gpu"

  private static let manifest: DownloadManifest = {
    do {
      return try DownloadManifest.load()
    } catch {
      // Fail closed with an empty manifest; prepare will error clearly.
      return DownloadManifest(repo: "", revision: "main", files: [])
    }
  }()

  private static var modelRepo: String { manifest.repo }
  private static var modelRevision: String { manifest.revision }
  private static var downloadFiles: [(path: String, estimatedSize: Int64)] {
    manifest.files.map { ($0.path, $0.estimatedSize) }
  }

  /// Sum of lean-bundle file sizes from the shared manifest.
  private static var estimatedDownloadBytes: Int64 {
    downloadFiles.reduce(0) { $0 + $1.estimatedSize }
  }

  /// Download payload plus room for `MLModel.compileModel` outputs (~1x).
  private static var minFreeBytes: Int64 {
    estimatedDownloadBytes * 2 + 500_000_000
  }

  private let queue = DispatchQueue(label: "io.github.madahataraku.coglog.gemma_meter")
  private var prepareEvents: FlutterEventSink?
  private var preparing = false
  private var lastEmittedProgressBucket = -1
  private let downloadBytesLock = NSLock()
  private var downloadedBytesValue: Int64 = 0
  /// Last successful main-model compute path (`ane` or `gpu`).
  private var activeBackend = GemmaMeterPlugin.preferredBackend
  #if canImport(CoreMLLLM)
  private var llm: CoreMLLLM?
  #endif

  private var downloadedBytes: Int64 {
    get {
      downloadBytesLock.lock()
      defer { downloadBytesLock.unlock() }
      return downloadedBytesValue
    }
    set {
      downloadBytesLock.lock()
      downloadedBytesValue = newValue
      downloadBytesLock.unlock()
    }
  }

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
        "backend": activeBackend,
        "visionBackend": Self.configuredVisionBackend,
      ]
    }
    return [
      "status": "ready",
      "reason": "ready",
      "message": "Gemma meter Core ML model is ready.",
      "backend": activeBackend,
      "visionBackend": Self.configuredVisionBackend,
    ]
    #else
    return [
      "status": "unavailable",
      "reason": "missingDependency",
      "message":
        "CoreMLLLM Swift package is not linked. Add https://github.com/john-rocky/CoreML-LLM.",
      "backend": Self.preferredBackend,
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
      try awaitSync {
        try await self.downloadIfNeeded()
        // Warm-load so ANE→GPU fallback is settled before the first read.
        _ = try await self.loadLLMIfNeeded()
      }
      try excludeDownloadedModelFromBackup()
      emitProgress(1)
      preparing = false
      DispatchQueue.main.async {
        self.prepareEvents?(FlutterEndOfEventStream)
        result(nil)
      }
    } catch {
      preparing = false
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
      "CoreMLLLM Swift package is not linked. Add https://github.com/john-rocky/CoreML-LLM."
    DispatchQueue.main.async {
      self.prepareEvents?(
        FlutterError(code: "generic", message: message, details: nil)
      )
      result(FlutterError(code: "generic", message: message, details: nil))
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
    try awaitSync {
      try await self.loadLLMIfNeeded()
    }
  }

  /// Loads the monolithic bundle, preferring ANE and falling back to GPU.
  private func loadLLMIfNeeded() async throws -> CoreMLLLM {
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
    let (created, backend) = try await Self.loadWithComputeUnitFallback(from: directory)
    llm = created
    activeBackend = backend
    return created
  }

  /// Tries `.cpuAndNeuralEngine`, then `.cpuAndGPU` on execution-plan failures.
  private static func loadWithComputeUnitFallback(from directory: URL) async throws -> (
    CoreMLLLM, String
  ) {
    do {
      let model = try await CoreMLLLM.load(
        from: directory,
        computeUnits: .cpuAndNeuralEngine
      )
      return (model, "ane")
    } catch {
      guard isNeuralEnginePlanFailure(error) else { throw error }
      let model = try await CoreMLLLM.load(
        from: directory,
        computeUnits: .cpuAndGPU
      )
      return (model, "gpu")
    }
  }

  /// True when Core ML rejected the ANE execution plan (often stateful KV).
  private static func isNeuralEnginePlanFailure(_ error: Error) -> Bool {
    let message = safeMessage(error).lowercased()
    return message.contains("execution plan")
      || message.contains("model.mil")
      || message.contains("error code: -14")
      || message.contains("code=-14")
  }

  private func downloadIfNeeded() async throws {
    if hasCompleteModelBundle() {
      emitProgress(1)
      return
    }
    // Partial/corrupt/chunked installs must not stay "ready".
    try removeIncompleteModelDirectory()
    try ensureModelsDirectoryExcludedFromBackup()
    try ensureFreeSpace()
    lastEmittedProgressBucket = -1
    downloadedBytes = 0
    let progressTask = Task { [weak self] in
      while !Task.isCancelled {
        guard let self else { return }
        let done = self.downloadedBytes
        let fromDisk: Int64
        if let directory = self.modelDirectoryURL() {
          fromDisk = Self.allocatedByteCount(at: directory)
        } else {
          fromDisk = 0
        }
        let bytes = max(done, fromDisk)
        let fraction = min(
          Double(bytes) / Double(max(Self.estimatedDownloadBytes, 1)),
          0.99
        )
        self.emitProgressBucketed(fraction)
        try? await Task.sleep(nanoseconds: 200_000_000)
      }
    }
    defer { progressTask.cancel() }
    do {
      // Pin every file in this prepare to one commit so a moving branch
      // cannot mix revisions mid-download.
      let pinnedRevision = try await resolvePinnedRevision()
      for file in Self.downloadFiles {
        try await downloadRemoteFile(
          relativePath: file.path,
          revision: pinnedRevision
        )
      }
    } catch {
      try? removeIncompleteModelDirectory()
      throw error
    }
    guard hasCompleteModelBundle() else {
      try? removeIncompleteModelDirectory()
      throw PrepareError.generic("Gemma Core ML download finished without required files.")
    }
  }

  /// Resolves [modelRevision] (e.g. `main`) to a commit SHA for this prepare.
  private func resolvePinnedRevision() async throws -> String {
    let encodedRevision =
      Self.modelRevision.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
      ?? Self.modelRevision
    guard !Self.modelRepo.isEmpty,
      let url = URL(
        string:
          "https://huggingface.co/api/models/\(Self.modelRepo)/revision/\(encodedRevision)"
      )
    else {
      throw PrepareError.generic("Model manifest repo is missing.")
    }
    let (data, response): (Data, URLResponse)
    do {
      (data, response) = try await URLSession.shared.data(from: url)
    } catch {
      throw PrepareError.network(Self.safeMessage(error))
    }
    if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
      throw PrepareError.network("Model revision HTTP \(http.statusCode).")
    }
    guard
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let sha = json["sha"] as? String,
      !sha.isEmpty
    else {
      throw PrepareError.network("Model revision SHA missing.")
    }
    return sha
  }

  /// Downloads one HF resolve path into the model directory.
  private func downloadRemoteFile(relativePath: String, revision: String) async throws {
    guard let directory = modelDirectoryURL() else {
      throw PrepareError.generic("Documents directory is unavailable.")
    }
    let encodedPath = relativePath
      .split(separator: "/")
      .map { $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0) }
      .joined(separator: "/")
    let encodedRevision =
      revision.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? revision
    let urlString =
      "https://huggingface.co/\(Self.modelRepo)/resolve/\(encodedRevision)/\(encodedPath)"
    guard let url = URL(string: urlString) else {
      throw PrepareError.generic("Invalid model URL for \(relativePath).")
    }
    let destination = directory.appendingPathComponent(relativePath)
    try FileManager.default.createDirectory(
      at: destination.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    let baseDownloaded = downloadedBytes
    let estimatedForFile =
      Self.downloadFiles.first(where: { $0.path == relativePath })?.estimatedSize ?? 0
    do {
      let fileBytes: Int64 = try await withCheckedThrowingContinuation { continuation in
        final class ObservationBox {
          var observation: NSKeyValueObservation?
        }
        let box = ObservationBox()
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
          box.observation?.invalidate()
          box.observation = nil
          if let error {
            continuation.resume(
              throwing: PrepareError.network(Self.safeMessage(error))
            )
            return
          }
          guard let location else {
            continuation.resume(
              throwing: PrepareError.network("Empty download for \(relativePath).")
            )
            return
          }
          if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            continuation.resume(
              throwing: PrepareError.network(
                "Model download HTTP \(http.statusCode) for \(relativePath)."
              )
            )
            return
          }
          do {
            if FileManager.default.fileExists(atPath: destination.path) {
              try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: location, to: destination)
            let size =
              (try? FileManager.default.attributesOfItem(atPath: destination.path)[.size]
                as? NSNumber)?.int64Value ?? 0
            continuation.resume(returning: size)
          } catch {
            continuation.resume(throwing: error)
          }
        }
        // Drive gauge while the large weight.bin files transfer.
        box.observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
          guard let self else { return }
          let inFlight = Int64(Double(max(estimatedForFile, 1)) * progress.fractionCompleted)
          self.downloadedBytes = baseDownloaded + inFlight
        }
        task.resume()
      }
      downloadedBytes = baseDownloaded + max(fileBytes, 0)
    } catch let prepare as PrepareError {
      throw prepare
    } catch {
      throw PrepareError.network(Self.safeMessage(error))
    }
  }

  private static func allocatedByteCount(at directory: URL) -> Int64 {
    let fm = FileManager.default
    guard
      let enumerator = fm.enumerator(
        at: directory,
        includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
        options: [.skipsHiddenFiles]
      )
    else {
      return 0
    }
    var total: Int64 = 0
    for case let fileURL as URL in enumerator {
      guard
        let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
        values.isRegularFile == true
      else {
        continue
      }
      total += Int64(values.fileSize ?? 0)
    }
    return total
  }

  /// Emits at most once per whole-percent bucket (matches Android).
  private func emitProgressBucketed(_ value: Double) {
    let bucket = Int((value * 100).rounded(.down))
    guard bucket != lastEmittedProgressBucket else { return }
    lastEmittedProgressBucket = bucket
    emitProgress(value)
  }

  private func isModelDownloaded() -> Bool {
    hasCompleteModelBundle()
  }

  /// Required files for lean monolithic + vision (CoreMLLLM monolithic path).
  private static let requiredRelativePaths: [String] = downloadFiles.map(\.path)

  private func hasCompleteModelBundle() -> Bool {
    guard let directory = modelDirectoryURL() else { return false }
    let fm = FileManager.default
    // chunk1 would force CoreMLLLM onto ChunkedEngine; treat as incomplete.
    if fm.fileExists(atPath: directory.appendingPathComponent("chunk1.mlmodelc").path)
      || fm.fileExists(atPath: directory.appendingPathComponent("chunk1.mlpackage").path)
    {
      return false
    }
    for relative in Self.requiredRelativePaths {
      let url = directory.appendingPathComponent(relative)
      guard fm.fileExists(atPath: url.path) else { return false }
      if let attrs = try? fm.attributesOfItem(atPath: url.path),
        let size = attrs[.size] as? NSNumber,
        size.int64Value <= 0
      {
        return false
      }
    }
    return true
  }

  private func modelsRootURL() -> URL? {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
      .appendingPathComponent("Models", isDirectory: true)
  }

  private func modelDirectoryURL() -> URL? {
    modelsRootURL()?.appendingPathComponent(Self.modelFolderName, isDirectory: true)
  }

  private func removeIncompleteModelDirectory() throws {
    let fm = FileManager.default
    guard let modelDir = modelDirectoryURL(), fm.fileExists(atPath: modelDir.path) else {
      return
    }
    try fm.removeItem(at: modelDir)
  }

  private func ensureModelsDirectoryExcludedFromBackup() throws {
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
    try ensureModelsDirectoryExcludedFromBackup()
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

  private struct DownloadManifestFile: Decodable {
    let path: String
    let estimatedSize: Int64
  }

  private struct DownloadManifest: Decodable {
    let repo: String
    let revision: String
    let files: [DownloadManifestFile]

    static func load() throws -> DownloadManifest {
      guard let url = Self.manifestJSONURL() else {
        throw PrepareError.generic("iOS monolithic download manifest is missing.")
      }
      let data = try Data(contentsOf: url)
      return try JSONDecoder().decode(DownloadManifest.self, from: data)
    }

    private static func manifestJSONURL() -> URL? {
      let name = "ios_monolithic_download_manifest"
      let pluginBundle = Bundle(for: GemmaMeterPlugin.self)
      if let url = pluginBundle.url(forResource: name, withExtension: "json") {
        return url
      }
      if let bundleURL = pluginBundle.url(
        forResource: "infra_gemma_meter_mobile_manifest",
        withExtension: "bundle"
      ),
        let resourceBundle = Bundle(url: bundleURL),
        let url = resourceBundle.url(forResource: name, withExtension: "json")
      {
        return url
      }
      #if SWIFT_PACKAGE
      if let url = Bundle.module.url(forResource: name, withExtension: "json") {
        return url
      }
      #endif
      return nil
    }
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
