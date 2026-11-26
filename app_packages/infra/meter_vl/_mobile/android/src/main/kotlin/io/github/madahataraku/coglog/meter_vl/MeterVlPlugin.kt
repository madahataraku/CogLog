package io.github.madahataraku.coglog.meter_vl

import android.content.Context
import com.google.ai.edge.litertlm.Backend
import com.google.ai.edge.litertlm.Content
import com.google.ai.edge.litertlm.Contents
import com.google.ai.edge.litertlm.Engine
import com.google.ai.edge.litertlm.EngineConfig
import com.google.ai.edge.litertlm.SpeculativeDecodingConfig
import com.google.ai.edge.litertlm.SpeculativeDecodingMode
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

/**
 * LiteRT-LM LFM VL meter-reading bridge.
 *
 * Model files live under [Context.getNoBackupFilesDir] so OS backup excludes them.
 */
class MeterVlPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  private lateinit var channel: MethodChannel
  private lateinit var prepareChannel: EventChannel
  private var appContext: Context? = null
  private var prepareEvents: EventChannel.EventSink? = null
  private val executor = Executors.newSingleThreadExecutor()
  private val preparing = AtomicBoolean(false)
  private var engine: Engine? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "infra_meter_vl")
    channel.setMethodCallHandler(this)
    prepareChannel = EventChannel(binding.binaryMessenger, "infra_meter_vl/prepare")
    prepareChannel.setStreamHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    prepareChannel.setStreamHandler(null)
    prepareEvents = null
    closeEngine()
    appContext = null
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    prepareEvents = events
  }

  override fun onCancel(arguments: Any?) {
    prepareEvents = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getAvailability" -> {
        executor.execute {
          val map = availabilityMap()
          runOnMain { result.success(map) }
        }
      }
      "prepareModel" -> {
        executor.execute { prepareModel(result) }
      }
      "generateWithImage" -> {
        val prompt = call.argument<String>("prompt") ?: ""
        val imageBytes = call.argument<ByteArray>("imageBytes") ?: ByteArray(0)
        executor.execute {
          try {
            val text = generate(prompt, imageBytes, requireReady = true)
            runOnMain { result.success(text) }
          } catch (error: Exception) {
            runOnMain {
              result.error("generic", safeMessage(error), null)
            }
          }
        }
      }
      "diagnoseGenerateWithImage" -> {
        val prompt = call.argument<String>("prompt") ?: ""
        val imageBytes = call.argument<ByteArray>("imageBytes") ?: ByteArray(0)
        executor.execute {
          try {
            val text = generate(prompt, imageBytes, requireReady = false)
            runOnMain { result.success(text) }
          } catch (error: Exception) {
            runOnMain {
              result.error("generic", safeMessage(error), null)
            }
          }
        }
      }
      else -> result.notImplemented()
    }
  }

  /** Configured LiteRT-LM backends (main GPU, vision CPU, MTP off). */
  private fun configuredBackendFields(): Map<String, String> =
    mapOf(
      "backend" to "gpu",
      "visionBackend" to "cpu",
    )

  private fun availabilityMap(): Map<String, String> {
    removeLegacyGemmaModelIfPresent()
    val model = modelFile()
    if (model == null || !model.isFile || model.length() == 0L) {
      return mapOf(
        "status" to "modelNotDownloaded",
        "reason" to "missingFile",
        "message" to "LFM VL meter model is not downloaded.",
      ) + configuredBackendFields()
    }
    return try {
      ensureEngine(model)
      mapOf(
        "status" to "ready",
        "reason" to "ready",
        "message" to "LFM VL meter model is ready.",
      ) + configuredBackendFields()
    } catch (_: Exception) {
      mapOf(
        "status" to "unavailable",
        "reason" to "initializeFailed",
        "message" to "LFM VL meter model failed to initialize.",
      ) + configuredBackendFields()
    }
  }

  private fun prepareModel(result: Result) {
    if (!preparing.compareAndSet(false, true)) {
      runOnMain { result.success(null) }
      return
    }
    try {
      if (appContext == null) {
        throw IOException("Application context is unavailable.")
      }
      removeLegacyGemmaModelIfPresent()
      val target = modelFile()!!
      if (target.isFile && target.length() > 0L && !isEngineStampCurrent()) {
        // Stamp-mismatched artifacts must be refreshed once.
        if (!target.delete()) {
          throw IOException("Could not clear outdated LFM VL model for refresh.")
        }
        clearEngineStamp()
        closeEngine()
      }
      if (!target.isFile || target.length() == 0L) {
        downloadModel(target)
        // Stamp means artifact generation current, independent of initialize().
        markEngineStampCurrent()
      }
      emitProgress(1.0)
      ensureEngine(target)
      runOnMain {
        prepareEvents?.endOfStream()
        result.success(null)
      }
    } catch (error: Exception) {
      if (isLikelyCorruptModelError(error)) {
        modelFile()?.delete()
        clearEngineStamp()
        closeEngine()
      }
      val code = mapPrepareCode(error)
      runOnMain {
        prepareEvents?.error(code, safeMessage(error), null)
        result.error(code, safeMessage(error), null)
      }
    } finally {
      preparing.set(false)
    }
  }

  private fun downloadModel(target: File) {
    val parent = target.parentFile ?: throw IOException("Model directory missing.")
    if (!parent.exists() && !parent.mkdirs()) {
      throw IOException("Could not create model directory.")
    }
    val partial = File(parent, "${target.name}.partial")
    // Interrupted downloads leave a truncated-on-open .partial; reclaim it
    // before free-space checks so a retry is not rejected as insufficient.
    if (partial.exists() && !partial.delete()) {
      throw IOException("Could not clear leftover partial model download.")
    }
    val free = parent.usableSpace
    if (free in 1 until MIN_FREE_BYTES) {
      throw InsufficientStorageException("Not enough free space for LFM VL model.")
    }
    try {
      val connection = (URL(MODEL_URL).openConnection() as HttpURLConnection).apply {
        connectTimeout = 30_000
        readTimeout = 60_000
        instanceFollowRedirects = true
        requestMethod = "GET"
      }
      try {
        val code = connection.responseCode
        if (code !in 200..299) {
          throw NetworkException("Model download HTTP $code.")
        }
        // HF redirect hops can omit or under-report Content-Length; fall back
        // so the guidance dialog gauge still advances with bytes read.
        val total = resolveDownloadTotalBytes(connection)
        if (parent.usableSpace in 1 until total) {
          throw InsufficientStorageException("Not enough free space for LFM VL model.")
        }
        connection.inputStream.use { input ->
          FileOutputStream(partial).use { output ->
            val buffer = ByteArray(64 * 1024)
            var readTotal = 0L
            var lastEmitted = -1
            while (true) {
              val read = input.read(buffer)
              if (read < 0) break
              output.write(buffer, 0, read)
              readTotal += read
              val progress = (readTotal.toDouble() / total.toDouble()).coerceIn(0.0, 0.99)
              val bucket = (progress * 100).toInt()
              if (bucket != lastEmitted) {
                lastEmitted = bucket
                emitProgress(progress)
              }
            }
            output.flush()
            if (readTotal < MIN_PLAUSIBLE_MODEL_BYTES) {
              throw NetworkException(
                "Model download finished with an implausibly small file.",
              )
            }
          }
        }
      } finally {
        connection.disconnect()
      }
      if (partial.length() < MIN_PLAUSIBLE_MODEL_BYTES) {
        throw NetworkException("Model download finished with an implausibly small file.")
      }
      if (target.exists() && !target.delete()) {
        throw IOException("Could not replace existing model file.")
      }
      if (!partial.renameTo(target)) {
        throw IOException("Could not finalize model file.")
      }
    } catch (error: InsufficientStorageException) {
      partial.delete()
      throw error
    } catch (error: NetworkException) {
      partial.delete()
      throw error
    } catch (error: IOException) {
      partial.delete()
      throw NetworkException(safeMessage(error), error)
    } catch (error: Exception) {
      partial.delete()
      throw error
    }
  }

  private fun generate(
    prompt: String,
    imageBytes: ByteArray,
    requireReady: Boolean,
  ): String {
    val model = modelFile()
    if (model == null || !model.isFile || model.length() == 0L) {
      if (requireReady) {
        throw IllegalStateException("LFM VL meter model is not ready.")
      }
      throw IllegalStateException("LFM VL meter model is not downloaded.")
    }
    val active = ensureEngine(model)
    active.createConversation().use { conversation ->
      val response =
        conversation.sendMessage(
          Contents.of(
            Content.ImageBytes(imageBytes),
            Content.Text(prompt),
          ),
        )
      return response.toString()
    }
  }

  private fun ensureEngine(model: File): Engine {
    engine?.let { return it }
    val cacheDir = model.parentFile?.resolve("cache")?.also { it.mkdirs() }
    val config =
      EngineConfig(
        modelPath = model.absolutePath,
        backend = Backend.GPU(),
        visionBackend = Backend.CPU(),
        cacheDir = cacheDir?.absolutePath,
        speculativeDecodingConfig =
          SpeculativeDecodingConfig(mode = SpeculativeDecodingMode.OFF),
      )
    val created = Engine(config)
    created.initialize()
    engine = created
    return created
  }

  private fun closeEngine() {
    try {
      engine?.close()
    } catch (_: Exception) {
      // Ignore close failures on detach.
    }
    engine = null
  }

  private fun modelFile(): File? {
    val context = appContext ?: return null
    return File(File(context.noBackupFilesDir, MODEL_DIR), MODEL_FILE_NAME)
  }

  private fun emitProgress(value: Double) {
    runOnMain { prepareEvents?.success(value) }
  }

  /**
   * Prefer a plausible Content-Length; otherwise [ESTIMATED_MODEL_BYTES].
   *
   * Hugging Face may leave Content-Length unset after redirects, or expose only
   * the tiny redirect body size. Either case would freeze the UI at 0% or jump
   * to ~100% after the first kilobyte.
   */
  private fun resolveDownloadTotalBytes(connection: HttpURLConnection): Long {
    val contentLength = connection.contentLengthLong
    if (contentLength >= MIN_PLAUSIBLE_MODEL_BYTES) {
      return contentLength
    }
    val linked =
      connection.getHeaderField("x-linked-size")?.toLongOrNull()
        ?: connection.getHeaderField("X-Linked-Size")?.toLongOrNull()
    if (linked != null && linked >= MIN_PLAUSIBLE_MODEL_BYTES) {
      return linked
    }
    return ESTIMATED_MODEL_BYTES
  }

  private fun runOnMain(block: () -> Unit) {
    val context = appContext
    if (context == null) {
      block()
      return
    }
    android.os.Handler(context.mainLooper).post(block)
  }

  private fun mapPrepareCode(error: Exception): String =
    when (error) {
      is InsufficientStorageException -> "insufficientStorage"
      is NetworkException -> "network"
      else -> "generic"
    }

  /** Never include metering values in error strings. */
  private fun safeMessage(error: Throwable): String {
    val raw = error.message?.trim().orEmpty()
    if (raw.isEmpty()) {
      return error.javaClass.simpleName
    }
    return raw.take(200)
  }

  private fun prefs() =
    appContext!!.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

  private fun isEngineStampCurrent(): Boolean =
    prefs().getString(ENGINE_STAMP_KEY, null) == ENGINE_STAMP_VALUE

  private fun markEngineStampCurrent() {
    prefs().edit().putString(ENGINE_STAMP_KEY, ENGINE_STAMP_VALUE).apply()
  }

  private fun clearEngineStamp() {
    prefs().edit().remove(ENGINE_STAMP_KEY).apply()
  }

  /**
   * True when initialize failed because the on-disk container looks unusable
   * (or lacks MTP). Device/backend GPU failures should return false so the
   * downloaded artifact is kept.
   */
  private fun isLikelyCorruptModelError(error: Throwable): Boolean {
    val text = safeMessage(error).lowercase()
    if (
      text.contains("gpu") ||
        text.contains("opencl") ||
        text.contains("delegate") ||
        text.contains("backend")
    ) {
      return false
    }
    return text.contains("corrupt") ||
      text.contains("invalid") ||
      text.contains("loader") ||
      text.contains("parse") ||
      text.contains("format") ||
      text.contains("header") ||
      text.contains("truncated") ||
      text.contains("not a valid") ||
      text.contains("speculative") ||
      text.contains("drafter") ||
      text.contains("mtp")
  }

  private class InsufficientStorageException(message: String) : IOException(message)

  private class NetworkException(message: String, cause: Throwable? = null) :
    IOException(message, cause)

  /** Deletes the previous Gemma LiteRT tree under noBackupFilesDir if present. */
  private fun removeLegacyGemmaModelIfPresent() {
    val ctx = appContext ?: return
    val legacy = File(ctx.noBackupFilesDir, LEGACY_MODEL_DIR)
    if (legacy.exists()) {
      legacy.deleteRecursively()
    }
  }

  companion object {
    private const val MODEL_DIR = "lfm_meter"
    private const val MODEL_FILE_NAME = "LFM2.5-VL-1.6B_int4_fixB.litertlm"
    // litert-community LFM2.5-VL-1.6B fixB (ungated, full-image vision graphs).
    private const val MODEL_URL =
      "https://huggingface.co/litert-community/LFM2.5-VL-1.6B/resolve/main/LFM2.5-VL-1.6B_int4_fixB.litertlm"
    private const val MIN_FREE_BYTES = 200L * 1024L * 1024L
    /** Current litert-community LFM VL `.litertlm` payload (~1.30 GB). */
    private const val ESTIMATED_MODEL_BYTES = 1_395_586_662L
    /** Reject tiny redirect-body Content-Length values as the download total. */
    private const val MIN_PLAUSIBLE_MODEL_BYTES = 100L * 1024L * 1024L
    private const val PREFS_NAME = "lfm_meter"
    private const val ENGINE_STAMP_KEY = "engine_stamp"
    /** Artifact generation id (not initialize success). Bump to force refresh. */
    private const val ENGINE_STAMP_VALUE = "litert-lfm25-vl-int4-fixB-v1"
    /** Previous Gemma LiteRT download directory (delete on prepare / availability). */
    private const val LEGACY_MODEL_DIR = "gemma_meter"
  }
}
