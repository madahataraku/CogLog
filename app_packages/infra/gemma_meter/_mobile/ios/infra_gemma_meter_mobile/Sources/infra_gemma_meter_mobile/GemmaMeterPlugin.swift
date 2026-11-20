import CoreML
import Flutter
import Foundation
import UIKit
#if canImport(CoreMLLLM)
import CoreMLLLM
#endif

/// Flutter bridge for Core ML Gemma E2B meter reading on iOS.
///
/// Downloads the CoreMLLLM chunk layout into Documents/Models/`gemma4-e2b`
/// from Hugging Face `mlboydaisuke/gemma-4-E2B-coreml` (`n1024`): SWA
/// `chunk{1..4}`, hardlinked `prefill_chunk{1..4}` weights, PLE / embeds /
/// RoPE, still-image `vision.mlmodelc`. `vision_video` / `audio` are omitted.
/// The model directory is excluded from OS backup.
public class GemmaMeterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let modelFolderName = "gemma4-e2b"
  /// Shipping still-image `vision.mlmodelc` is ANE-oriented.
  private static let configuredVisionBackend = "ane"
  private static let persistedBackendKey = "gemmaMeter.activeBackend"
  private static let loadSucceededKey = "gemmaMeter.loadSucceeded"

  private static let manifest: DownloadManifest = {
    do {
      return try DownloadManifest.load()
    } catch {
      // Fail closed with an empty manifest; prepare will error clearly.
      return DownloadManifest(repo: "", revision: "n1024", files: [])
    }
  }()

  private static var modelRepo: String { manifest.repo }
  private static var modelRevision: String { manifest.revision }
  private static var downloadFiles: [DownloadManifestFile] { manifest.files }

  /// Sum of bundle file sizes from the shared manifest.
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
  /// Last successful main-model compute path (`ane` or `gpu`); empty until load.
  private var activeBackend = ""
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
        "backend": "",
        "visionBackend": Self.configuredVisionBackend,
      ]
    }
    // Ready only after a successful load (this process or persisted).
    let loadedThisProcess = llm != nil
    let loadSucceededPreviously = UserDefaults.standard.bool(forKey: Self.loadSucceededKey)
    let backend = loadedThisProcess
      ? activeBackend
      : (UserDefaults.standard.string(forKey: Self.persistedBackendKey) ?? "")
    if loadedThisProcess || loadSucceededPreviously {
      return [
        "status": "ready",
        "reason": "ready",
        "message": "Gemma meter Core ML model is ready.",
        "backend": backend,
        "visionBackend": Self.configuredVisionBackend,
      ]
    }
    return [
      "status": "unavailable",
      "reason": "loadFailed",
      "message": "Gemma meter Core ML model is on disk but has not loaded successfully.",
      "backend": "",
      "visionBackend": Self.configuredVisionBackend,
    ]
    #else
    return [
      "status": "unavailable",
      "reason": "missingDependency",
      "message":
        "CoreMLLLM Swift package is not linked. Add https://github.com/john-rocky/CoreML-LLM.",
      "backend": "",
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
      markLoadFailed()
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

  /// Loads the chunked bundle, preferring ANE and falling back to GPU.
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
    do {
      let preferred = UserDefaults.standard.string(forKey: Self.persistedBackendKey)
      let (created, backend) = try await Self.loadWithComputeUnitFallback(
        from: directory,
        preferredBackend: preferred
      )
      llm = created
      activeBackend = backend
      UserDefaults.standard.set(backend, forKey: Self.persistedBackendKey)
      UserDefaults.standard.set(true, forKey: Self.loadSucceededKey)
      return created
    } catch {
      markLoadFailed()
      throw error
    }
  }

  private func markLoadFailed() {
    llm = nil
    activeBackend = ""
    UserDefaults.standard.set(false, forKey: Self.loadSucceededKey)
  }

  /// Tries ANE then GPU (or GPU first when that was last successful).
  private static func loadWithComputeUnitFallback(
    from directory: URL,
    preferredBackend: String?
  ) async throws -> (CoreMLLLM, String) {
    let order: [(MLComputeUnits, String)] =
      preferredBackend == "gpu"
      ? [(.cpuAndGPU, "gpu"), (.cpuAndNeuralEngine, "ane")]
      : [(.cpuAndNeuralEngine, "ane"), (.cpuAndGPU, "gpu")]
    var lastError: Error?
    for (units, label) in order {
      do {
        let model = try await CoreMLLLM.load(from: directory, computeUnits: units)
        return (model, label)
      } catch {
        lastError = error
        // Only continue to GPU when ANE failed with an execution-plan style error.
        if label == "ane", isNeuralEnginePlanFailure(error) {
          continue
        }
        // Preferred GPU failed: still try ANE once before giving up.
        if label == "gpu", preferredBackend == "gpu" {
          continue
        }
        throw error
      }
    }
    throw lastError
      ?? NSError(
        domain: "GemmaMeter",
        code: 4,
        userInfo: [NSLocalizedDescriptionKey: "Gemma Core ML load failed."]
      )
  }

  /// True when Core ML rejected the ANE execution plan (often stateful KV).
  private static func isNeuralEnginePlanFailure(_ error: Error) -> Bool {
    var current: Error? = error
    for _ in 0..<8 {
      guard let err = current else { return false }
      let ns = err as NSError
      if ns.code == -14 {
        return true
      }
      let domain = ns.domain.lowercased()
      let text = planFailureHaystack(ns)
      if domain.contains("coreml"), matchesExecutionPlanText(text) {
        return true
      }
      if matchesExecutionPlanText(text) {
        return true
      }
      current = ns.userInfo[NSUnderlyingErrorKey] as? Error
    }
    return false
  }

  private static func planFailureHaystack(_ error: NSError) -> String {
    var parts: [String] = [
      error.localizedDescription,
      error.localizedFailureReason ?? "",
      String(describing: error.userInfo),
    ]
    if let underlying = error.userInfo[NSUnderlyingErrorKey] as? NSError {
      parts.append(underlying.localizedDescription)
      parts.append(String(describing: underlying.userInfo))
    }
    return parts.joined(separator: " ").lowercased()
  }

  private static func matchesExecutionPlanText(_ text: String) -> Bool {
    text.contains("execution plan")
      || text.contains("model.mil")
      || text.contains("error code: -14")
      || text.contains("code=-14")
      || text.contains("code = -14")
  }

  private func downloadIfNeeded() async throws {
    if hasCompleteModelBundle() {
      emitProgress(1)
      return
    }
    // Partial/corrupt installs must not stay "ready".
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
          remotePath: file.remotePath ?? file.path,
          localPath: file.path,
          estimatedSize: file.estimatedSize,
          revision: pinnedRevision
        )
      }
      try Self.linkPrefillWeights(in: self.modelDirectoryURL())
    } catch {
      try? removeIncompleteModelDirectory()
      throw error
    }
    guard hasCompleteModelBundle() else {
      try? removeIncompleteModelDirectory()
      throw PrepareError.generic("Gemma Core ML download finished without required files.")
    }
  }

  /// Hardlinks decode `chunk{i}` weights into `prefill_chunk{i}` (CoreMLLLM legacy).
  /// Copy fallback is intentionally omitted so prepare fails closed on ~2× disk use.
  private static func linkPrefillWeights(in directory: URL?) throws {
    guard let directory else {
      throw PrepareError.generic("Documents directory is unavailable.")
    }
    let fm = FileManager.default
    for i in 1...4 {
      let src = directory
        .appendingPathComponent("chunk\(i).mlmodelc/weights/weight.bin")
      let dstDir = directory
        .appendingPathComponent("prefill_chunk\(i).mlmodelc/weights", isDirectory: true)
      let dst = dstDir.appendingPathComponent("weight.bin")
      guard fm.fileExists(atPath: src.path) else {
        throw PrepareError.generic("Missing decode weight for prefill hardlink: chunk\(i).")
      }
      try fm.createDirectory(at: dstDir, withIntermediateDirectories: true)
      if fm.fileExists(atPath: dst.path) {
        try fm.removeItem(at: dst)
      }
      do {
        try fm.linkItem(at: src, to: dst)
      } catch {
        throw PrepareError.generic(
          "Prefill hardlink failed for chunk\(i): \(Self.safeMessage(error))"
        )
      }
      guard Self.shareSameInode(src, dst) else {
        throw PrepareError.generic(
          "Prefill weight for chunk\(i) is not a hardlink to decode weights."
        )
      }
    }
  }

  /// True when both paths refer to the same inode (hardlink).
  private static func shareSameInode(_ a: URL, _ b: URL) -> Bool {
    let fm = FileManager.default
    guard
      let aAttrs = try? fm.attributesOfItem(atPath: a.path),
      let bAttrs = try? fm.attributesOfItem(atPath: b.path),
      let aInode = aAttrs[.systemFileNumber] as? NSNumber,
      let bInode = bAttrs[.systemFileNumber] as? NSNumber
    else {
      return false
    }
    return aInode == bInode
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
  private func downloadRemoteFile(
    remotePath: String,
    localPath: String,
    estimatedSize: Int64,
    revision: String
  ) async throws {
    guard let directory = modelDirectoryURL() else {
      throw PrepareError.generic("Documents directory is unavailable.")
    }
    let encodedPath = remotePath
      .split(separator: "/")
      .map { $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? String($0) }
      .joined(separator: "/")
    let encodedRevision =
      revision.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? revision
    let urlString =
      "https://huggingface.co/\(Self.modelRepo)/resolve/\(encodedRevision)/\(encodedPath)"
    guard let url = URL(string: urlString) else {
      throw PrepareError.generic("Invalid model URL for \(remotePath).")
    }
    let destination = directory.appendingPathComponent(localPath)
    try FileManager.default.createDirectory(
      at: destination.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    let baseDownloaded = downloadedBytes
    let estimatedForFile = estimatedSize
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
              throwing: PrepareError.network("Empty download for \(remotePath).")
            )
            return
          }
          if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            continuation.resume(
              throwing: PrepareError.network(
                "Model download HTTP \(http.statusCode) for \(remotePath)."
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

  /// Manifest paths plus hardlinked prefill weights required for ChunkedEngine.
  private static var requiredRelativePaths: [String] {
    var paths = downloadFiles.map(\.path)
    for i in 1...4 {
      paths.append("prefill_chunk\(i).mlmodelc/weights/weight.bin")
    }
    return paths
  }

  private func hasCompleteModelBundle() -> Bool {
    guard let directory = modelDirectoryURL() else { return false }
    let fm = FileManager.default
    // Chunked SWA path requires chunk1 (and peers) for CoreMLLLM ChunkedEngine.
    guard fm.fileExists(atPath: directory.appendingPathComponent("chunk1.mlmodelc").path)
    else {
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
    // Prefill weights must share inodes with decode (no silent ~2× copies).
    for i in 1...4 {
      let decode = directory
        .appendingPathComponent("chunk\(i).mlmodelc/weights/weight.bin")
      let prefill = directory
        .appendingPathComponent("prefill_chunk\(i).mlmodelc/weights/weight.bin")
      guard Self.shareSameInode(decode, prefill) else { return false }
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
    markLoadFailed()
    UserDefaults.standard.removeObject(forKey: Self.persistedBackendKey)
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
    /// Local path under Documents/Models/gemma4-e2b/.
    let path: String
    /// HF path when different from [path] (e.g. `swa/chunk1...`).
    let remotePath: String?
    let estimatedSize: Int64
  }

  private struct DownloadManifest: Decodable {
    let repo: String
    let revision: String
    let files: [DownloadManifestFile]

    static func load() throws -> DownloadManifest {
      guard let url = Self.manifestJSONURL() else {
        throw PrepareError.generic("iOS download manifest is missing.")
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
