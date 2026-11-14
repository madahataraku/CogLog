package io.github.madahataraku.coglog.gemma_meter

import android.content.Context
import com.google.ai.edge.litertlm.Backend
import com.google.ai.edge.litertlm.Content
import com.google.ai.edge.litertlm.Contents
import com.google.ai.edge.litertlm.Engine
import com.google.ai.edge.litertlm.EngineConfig
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
 * LiteRT-LM Gemma E2B meter-reading bridge.
 *
 * Model files live under [Context.getNoBackupFilesDir] so OS backup excludes them.
 */
class GemmaMeterPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  private lateinit var channel: MethodChannel
  private lateinit var prepareChannel: EventChannel
  private var appContext: Context? = null
  private var prepareEvents: EventChannel.EventSink? = null
  private val executor = Executors.newSingleThreadExecutor()
  private val preparing = AtomicBoolean(false)
  private var engine: Engine? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    appContext = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "infra_gemma_meter")
    channel.setMethodCallHandler(this)
    prepareChannel = EventChannel(binding.binaryMessenger, "infra_gemma_meter/prepare")
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

  private fun availabilityMap(): Map<String, String> {
    val model = modelFile()
    if (model == null || !model.isFile || model.length() == 0L) {
      return mapOf(
        "status" to "modelNotDownloaded",
        "reason" to "missingFile",
        "message" to "Gemma meter model is not downloaded.",
      )
    }
    return try {
      ensureEngine(model)
      mapOf(
        "status" to "ready",
        "reason" to "ready",
        "message" to "Gemma meter model is ready.",
      )
    } catch (_: Exception) {
      mapOf(
        "status" to "unavailable",
        "reason" to "initializeFailed",
        "message" to "Gemma meter model failed to initialize.",
      )
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
      val target = modelFile()!!
      if (!target.isFile || target.length() == 0L) {
        downloadModel(target)
      }
      emitProgress(1.0)
      ensureEngine(target)
      runOnMain {
        prepareEvents?.endOfStream()
        result.success(null)
      }
    } catch (error: Exception) {
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
    val free = parent.usableSpace
    if (free in 1 until MIN_FREE_BYTES) {
      throw InsufficientStorageException("Not enough free space for Gemma model.")
    }
    val partial = File(parent, "${target.name}.partial")
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
        val total = connection.contentLengthLong.takeIf { it > 0 } ?: -1L
        if (total > 0 && parent.usableSpace in 1 until total) {
          throw InsufficientStorageException("Not enough free space for Gemma model.")
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
              if (total > 0) {
                val progress = (readTotal.toDouble() / total.toDouble()).coerceIn(0.0, 0.99)
                val bucket = (progress * 100).toInt()
                if (bucket != lastEmitted) {
                  lastEmitted = bucket
                  emitProgress(progress)
                }
              }
            }
            output.flush()
          }
        }
      } finally {
        connection.disconnect()
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
        throw IllegalStateException("Gemma meter model is not ready.")
      }
      throw IllegalStateException("Gemma meter model is not downloaded.")
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
        backend = Backend.CPU(),
        visionBackend = Backend.GPU(),
        cacheDir = cacheDir?.absolutePath,
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

  private class InsufficientStorageException(message: String) : IOException(message)

  private class NetworkException(message: String, cause: Throwable? = null) :
    IOException(message, cause)

  companion object {
    private const val MODEL_DIR = "gemma_meter"
    private const val MODEL_FILE_NAME = "gemma-3n-E2B-it-int4.litertlm"
    // litert.dev catalog mirror (ungated). Upstream HF google/… is gated (401).
    private const val MODEL_URL =
      "https://models.litert.dev/gemma-3n-E2B-it-int4.litertlm"
    private const val MIN_FREE_BYTES = 200L * 1024L * 1024L
  }
}
