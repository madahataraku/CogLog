package dev.flutter_device_ai

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.common.GenAiException
import com.google.mlkit.genai.prompt.GenerateContentRequest
import com.google.mlkit.genai.prompt.GenerateContentResponse
import com.google.mlkit.genai.prompt.GenerativeModel
import com.google.mlkit.genai.prompt.ImagePart
import com.google.mlkit.genai.prompt.PromptPrefix
import com.google.mlkit.genai.prompt.TextPart
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Android backend: Gemini Nano through Google AICore, using the ML Kit GenAI
 * Prompt API (`genai-prompt` 1.0.0-beta2, same as Gemini Nano Playground).
 * The Prompt API is stateless, so conversations are kept here and replayed
 * on every turn.
 */
class FlutterDeviceAiPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var downloadChannel: EventChannel
    private var context: Context? = null

    private var eventSink: EventChannel.EventSink? = null
    private val main = Handler(Looper.getMainLooper())
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    private val sessions = mutableMapOf<String, Conversation>()

    private class Turn(val role: String, val text: String)

    private class Conversation(val system: String?) {
        val history = mutableListOf<Turn>()
        val pendingText = mutableListOf<String>()
        val pendingImages = mutableListOf<Bitmap>()
        var job: Job? = null
    }

    companion object {
        private const val AICORE_PACKAGE = "com.google.android.aicore"
        /** Settle time after process mark / client create before checkStatus (mlkit#1071). */
        private const val MIN_SETTLE_BEFORE_STATUS_MS = 2_000L
        private val CLIENT_RETRY_DELAYS_MS = longArrayOf(500L, 1_000L, 2_000L)
        private val STATUS_RETRY_DELAYS_MS = longArrayOf(1_000L, 2_000L, 4_000L)
        private const val STACK_FRAME_LIMIT = 8
        private const val THROWABLE_TEXT_LIMIT = 1500
        /**
         * Numeric value of `GenAiException.ErrorCode.NOT_SUPPORTED` (genai-common beta4+).
         * beta2 pulls genai-common beta3, which does not expose the named constant.
         */
        private const val ERROR_NOT_SUPPORTED = 16
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "flutter_device_ai")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "flutter_device_ai/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })

        downloadChannel = EventChannel(binding.binaryMessenger, "flutter_device_ai/download")
        downloadChannel.setStreamHandler(object : EventChannel.StreamHandler {
            private var job: Job? = null

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                job?.cancel()
                job = scope.launch { runDownload(events) }
            }

            override fun onCancel(arguments: Any?) {
                job?.cancel()
                job = null
            }
        })

        // ContentProvider では getClient しない。エンジン接続後に初めて温める（Playground 相当）。
        SharedGenerativeModel.warm(binding.applicationContext)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        downloadChannel.setStreamHandler(null)
        scope.cancel()
        sessions.clear()
        context = null
        // Do not close SharedGenerativeModel: recreating it reintroduces mlkit#1071.
    }

    // --- helpers ----------------------------------------------------------------

    private fun requireAppContext(): Context =
        context ?: throw IllegalStateException("FlutterDeviceAiPlugin is not attached")

    private fun client(): GenerativeModel = SharedGenerativeModel.get(requireAppContext())

    /** Retries [Generation.getClient] after MlKit init; records failures in diagnostics. */
    private suspend fun clientWithRetry(): GenerativeModel {
        if (SharedGenerativeModel.isReady()) return client()
        var last: Throwable? = null
        for ((index, waitMs) in CLIENT_RETRY_DELAYS_MS.withIndex()) {
            try {
                return client()
            } catch (e: Throwable) {
                last = e
                if (index < CLIENT_RETRY_DELAYS_MS.lastIndex) delay(waitMs)
            }
        }
        throw last ?: IllegalStateException("Generation.getClient failed without exception")
    }

    private fun aiCorePackageInfo(): android.content.pm.PackageInfo? {
        val ctx = context ?: return null
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                ctx.packageManager.getPackageInfo(AICORE_PACKAGE, PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                ctx.packageManager.getPackageInfo(AICORE_PACKAGE, 0)
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun aiCoreInstalled(): Boolean = aiCorePackageInfo() != null

    private fun aiCoreVersionLabel(): String {
        val info = aiCorePackageInfo() ?: return "AICore installed: false"
        val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
        return "AICore installed: true, versionName=${info.versionName ?: "?"}, versionCode=$versionCode"
    }

    private fun availabilityMap(status: String, reason: String, message: String) =
        mapOf("status" to status, "reason" to reason, "message" to message)

    /** Waits until process/client settle time has elapsed (mlkit#1071). */
    private suspend fun awaitSettle() {
        val processAge = SharedGenerativeModel.processAgeMs()
        if (processAge in 1 until MIN_SETTLE_BEFORE_STATUS_MS) {
            delay(MIN_SETTLE_BEFORE_STATUS_MS - processAge)
        }
        val clientAge = SharedGenerativeModel.ageMs()
        if (clientAge in 1 until MIN_SETTLE_BEFORE_STATUS_MS) {
            delay(MIN_SETTLE_BEFORE_STATUS_MS - clientAge)
        }
    }

    /**
     * Ensures the client exists (with MlKit init + retries), settles, then retries
     * checkStatus on raw NPE without recreating the client.
     */
    private suspend fun checkStatusWithRetry(): Int {
        val generative = clientWithRetry()
        awaitSettle()
        var lastNpe: NullPointerException? = null
        for ((index, waitMs) in STATUS_RETRY_DELAYS_MS.withIndex()) {
            try {
                return generative.checkStatus()
            } catch (e: NullPointerException) {
                lastNpe = e
                if (index < STATUS_RETRY_DELAYS_MS.lastIndex) delay(waitMs)
            }
        }
        throw lastNpe ?: NullPointerException("checkStatus failed without exception")
    }

    /** Retries generateContent on the same raw AICore bind NPE. */
    private suspend fun generateContentWithRetry(
        request: GenerateContentRequest,
    ): GenerateContentResponse {
        val generative = clientWithRetry()
        awaitSettle()
        var lastNpe: NullPointerException? = null
        for ((index, waitMs) in STATUS_RETRY_DELAYS_MS.withIndex()) {
            try {
                return generative.generateContent(request)
            } catch (e: NullPointerException) {
                lastNpe = e
                if (index < STATUS_RETRY_DELAYS_MS.lastIndex) delay(waitMs)
            }
        }
        throw lastNpe ?: NullPointerException("generateContent failed without exception")
    }

    private suspend fun availability(): Map<String, Any> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return availabilityMap("unavailable", "osTooOld", "Android 8.0 (API 26) or newer is required.")
        }
        if (!aiCoreInstalled()) {
            return availabilityMap(
                "unavailable", "systemComponentMissing",
                "Google AICore is not installed. Install or update it from the Play Store."
            )
        }
        return try {
            when (checkStatusWithRetry()) {
                FeatureStatus.AVAILABLE ->
                    availabilityMap("available", "ready", "Gemini Nano is ready.")
                FeatureStatus.DOWNLOADABLE ->
                    availabilityMap("downloadable", "modelNotReady", "Gemini Nano must be downloaded first.")
                FeatureStatus.DOWNLOADING ->
                    availabilityMap("downloading", "modelNotReady", "Gemini Nano is downloading.")
                else ->
                    availabilityMap("unavailable", "deviceNotEligible", "This device does not support Gemini Nano.")
            }
        } catch (e: Exception) {
            availabilityMap(
                "unavailable",
                "unknown",
                "Could not query AICore: ${formatThrowable(e)}"
            )
        }
    }

    /** Class name + message (+ cause chain + short stack) so null messages stay diagnosable. */
    private fun formatThrowable(e: Throwable): String {
        val parts = mutableListOf<String>()
        var current: Throwable? = e
        var depth = 0
        while (current != null && depth < 5) {
            val msg = current.message
            parts += if (msg.isNullOrBlank()) {
                current.javaClass.name
            } else {
                "${current.javaClass.name}: $msg"
            }
            current = current.cause
            depth++
        }
        val summary = parts.joinToString(" | cause: ")
        val stack = e.stackTrace
            .take(STACK_FRAME_LIMIT)
            .joinToString(" <- ") { "${it.className}.${it.methodName}:${it.lineNumber}" }
        val text = if (stack.isEmpty()) summary else "$summary | stack: $stack"
        return if (text.length <= THROWABLE_TEXT_LIMIT) {
            text
        } else {
            text.take(THROWABLE_TEXT_LIMIT - 1) + "…"
        }
    }

    private fun post(block: () -> Unit) = main.post(block)

    private fun errorCode(e: Throwable): Pair<String, String> = when (e) {
        is CancellationException -> "CANCELLED" to "Generation cancelled."
        is GenAiException -> when (e.errorCode) {
            GenAiException.ErrorCode.CANCELLED -> "CANCELLED" to "Generation cancelled."
            GenAiException.ErrorCode.BUSY ->
                "SESSION_BUSY" to "${e.javaClass.name}: ${e.message ?: "The model is busy."}"
            GenAiException.ErrorCode.NOT_AVAILABLE,
            GenAiException.ErrorCode.NEEDS_SYSTEM_UPDATE,
            GenAiException.ErrorCode.AICORE_INCOMPATIBLE,
            GenAiException.ErrorCode.NOT_ENOUGH_DISK_SPACE ->
                "UNAVAILABLE" to
                    "Gemini Nano is not available: ${formatThrowable(e)} (code ${e.errorCode})"
            ERROR_NOT_SUPPORTED ->
                "UNSUPPORTED" to "${e.javaClass.name}: ${e.message ?: "Not supported on this device."}"
            else ->
                "GENERATION_FAILED" to
                    "${formatThrowable(e)} (GenAI code ${e.errorCode})"
        }
        else -> "GENERATION_FAILED" to formatThrowable(e)
    }

    private fun sendEvent(sessionId: String, type: String, extra: Map<String, Any?> = emptyMap()) {
        eventSink?.success(mapOf("sessionId" to sessionId, "type" to type) + extra)
    }

    // --- method channel ------------------------------------------------------------

    override fun onMethodCall(call: MethodCall, result: Result) {
        val id = call.argument<String>("sessionId") ?: ""
        when (call.method) {
            "getAvailability" -> scope.launch {
                val snapshot = withContext(Dispatchers.IO) { availability() }
                result.success(snapshot)
            }

            "getPlatformInfo" -> {
                val usable = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && aiCoreInstalled()
                result.success(
                    mapOf(
                        "backend" to if (usable) "androidMlKitGenAi" else "unsupported",
                        "supportsToolCalling" to false,
                        "supportsStructuredOutput" to false,
                        "supportsVision" to usable,
                        "supportsModelDownload" to usable,
                        "supportsPlayStoreRedirect" to true,
                        "supportsExactTokenCounts" to usable,
                        "isConfigured" to true,
                        "diagnosticNotes" to buildString {
                            append("Android SDK ${Build.VERSION.SDK_INT}")
                            append(", genai-prompt 1.0.0-beta2")
                            append(", modelReady=${SharedGenerativeModel.isReady()}")
                            append(", clientAgeMs=${SharedGenerativeModel.ageMs()}")
                            append(", processAgeMs=${SharedGenerativeModel.processAgeMs()}")
                            SharedGenerativeModel.lastError?.let { append(", warmError=$it") }
                            append(", ${aiCoreVersionLabel()}")
                        }
                    )
                )
            }

            "openAICorePlayStore" -> result.success(openPlayStore())

            "createSession" -> {
                sessions[id] = Conversation(call.argument<String>("systemInstruction")?.takeIf { it.isNotEmpty() })
                result.success(null)
            }

            "sessionAddQuery" -> {
                val convo = sessions[id] ?: return notFound(id, result)
                convo.pendingText.add(call.argument<String>("text") ?: "")
                result.success(null)
            }

            "sessionAddImage" -> {
                val convo = sessions[id] ?: return notFound(id, result)
                val bytes = call.argument<ByteArray>("imageBytes")
                val bitmap = bytes?.let { BitmapFactory.decodeByteArray(it, 0, it.size) }
                if (bitmap == null) {
                    result.error("UNSUPPORTED", "The image bytes could not be decoded.", null)
                } else {
                    // beta2 accepts a single ImagePart per request; keep the latest bitmap.
                    convo.pendingImages.clear()
                    convo.pendingImages.add(bitmap)
                    result.success(null)
                }
            }

            "sessionGetResponse" -> respond(id, call, result)
            "sessionStartStream" -> stream(id, call, result)

            "sessionCountTokens" -> scope.launch {
                val convo = sessions[id] ?: return@launch notFound(id, result)
                try {
                    val text = call.argument<String>("text")
                    val tokens = withContext(Dispatchers.IO) {
                        val request = if (text != null) {
                            GenerateContentRequest.builder(TextPart(text)).build()
                        } else {
                            buildRequest(convo, call.argument<Map<String, Any?>>("config"), peek = true)
                        }
                        client().countTokens(request).totalTokens
                    }
                    result.success(tokens)
                } catch (e: Exception) {
                    val (code, message) = errorCode(e)
                    result.error(code, message, null)
                }
            }

            "sessionStopGeneration" -> {
                sessions[id]?.job?.cancel()
                result.success(null)
            }

            "sessionClose" -> {
                sessions.remove(id)?.job?.cancel()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun notFound(id: String, result: Result) =
        result.error("SESSION_NOT_FOUND", "Session $id does not exist.", null)

    private fun openPlayStore(): Boolean {
        val ctx = context ?: return false
        val uris = listOf(
            "market://details?id=$AICORE_PACKAGE",
            "https://play.google.com/store/apps/details?id=$AICORE_PACKAGE"
        )
        for (uri in uris) {
            try {
                ctx.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(uri)).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                return true
            } catch (_: Exception) {
            }
        }
        return false
    }

    // --- generation -----------------------------------------------------------------

    /** Renders the conversation (and the pending turn) as one beta2 request. */
    private fun buildRequest(
        convo: Conversation,
        config: Map<String, Any?>?,
        peek: Boolean = false,
    ): GenerateContentRequest {
        val prompt = StringBuilder()
        for (turn in convo.history) prompt.append(turn.role).append(": ").append(turn.text).append('\n')
        val hasHistory = convo.history.isNotEmpty()
        val pending = convo.pendingText.joinToString("\n")
        if (hasHistory) prompt.append("User: ").append(pending).append("\nAssistant:") else prompt.append(pending)

        val textPart = TextPart(prompt.toString())
        val image = convo.pendingImages.lastOrNull()
        val builder = if (image != null) {
            GenerateContentRequest.builder(ImagePart(image), textPart)
        } else {
            GenerateContentRequest.builder(textPart)
        }
        // beta2 has no SystemInstruction; map system text to PromptPrefix.
        convo.system?.let { builder.promptPrefix = PromptPrefix(it) }
        (config?.get("temperature") as? Number)?.let { builder.temperature = it.toFloat() }
        (config?.get("topK") as? Number)?.let { builder.topK = it.toInt() }
        (config?.get("maxTokens") as? Number)?.let { builder.maxOutputTokens = it.toInt() }
        builder.candidateCount = 1
        return builder.build()
    }

    private fun commitTurn(convo: Conversation, answer: String) {
        convo.history.add(Turn("User", convo.pendingText.joinToString("\n")))
        convo.history.add(Turn("Assistant", answer))
        convo.pendingText.clear()
        convo.pendingImages.clear()
    }

    private fun respond(id: String, call: MethodCall, result: Result) {
        val convo = sessions[id] ?: return notFound(id, result)
        if (convo.job?.isActive == true) {
            return result.error("SESSION_BUSY", "Session $id is still generating.", null)
        }
        if (convo.pendingText.isEmpty()) {
            return result.error("EMPTY_TURN", "Nothing to answer: add a query first.", null)
        }
        val config = call.argument<Map<String, Any?>>("config")
        val started = System.currentTimeMillis()
        convo.job = scope.launch(Dispatchers.IO) {
            try {
                val response = generateContentWithRetry(buildRequest(convo, config))
                val text = response.candidates.firstOrNull()?.text.orEmpty()
                commitTurn(convo, text)
                val payload = mapOf(
                    "text" to text,
                    "tokenCount" to maxOf(1, text.length / 4),
                    "generationTimeMs" to (System.currentTimeMillis() - started).toInt()
                )
                post { result.success(payload) }
            } catch (e: Throwable) {
                val (code, message) = errorCode(e)
                post { result.error(code, message, null) }
            }
        }
    }

    private fun stream(id: String, call: MethodCall, result: Result) {
        val convo = sessions[id] ?: return notFound(id, result)
        if (convo.job?.isActive == true) {
            return result.error("SESSION_BUSY", "Session $id is still generating.", null)
        }
        if (convo.pendingText.isEmpty()) {
            return result.error("EMPTY_TURN", "Nothing to answer: add a query first.", null)
        }
        val config = call.argument<Map<String, Any?>>("config")
        convo.job = scope.launch(Dispatchers.IO) {
            val full = StringBuilder()
            try {
                client().generateContentStream(buildRequest(convo, config)).collect { response ->
                    val piece = response.candidates.firstOrNull()?.text.orEmpty()
                    // Some builds emit the text so far instead of a delta.
                    val delta = if (full.isNotEmpty() && piece.startsWith(full)) piece.substring(full.length) else piece
                    if (delta.isNotEmpty()) {
                        full.append(delta)
                        sendEvent(id, "chunk", mapOf("text" to delta))
                    }
                }
                commitTurn(convo, full.toString())
                sendEvent(id, "done")
            } catch (e: Throwable) {
                val (code, message) = errorCode(e)
                sendEvent(id, "error", mapOf("code" to code, "message" to message))
            }
        }
        result.success(null)
    }

    // --- model download ----------------------------------------------------------------

    private suspend fun runDownload(events: EventChannel.EventSink?) {
        fun emit(map: Map<String, Any?>) = post { events?.success(map) }
        try {
            withContext(Dispatchers.IO) {
                val current = availability()
                when (current["status"]) {
                    "available" -> {
                        emit(mapOf("status" to "available", "progress" to 1.0))
                        return@withContext
                    }
                    "unavailable" -> {
                        emit(mapOf("status" to "unavailable", "errorMessage" to current["message"]))
                        return@withContext
                    }
                }
                var total = 0L
                client().download().collect { status ->
                    when (status) {
                        is DownloadStatus.DownloadStarted -> {
                            total = status.bytesToDownload
                            emit(mapOf("status" to "downloading", "progress" to 0.0, "totalBytes" to total))
                        }
                        is DownloadStatus.DownloadProgress -> {
                            val done = status.totalBytesDownloaded
                            emit(
                                mapOf(
                                    "status" to "downloading",
                                    "progress" to if (total > 0) done.toDouble() / total else null,
                                    "bytesDownloaded" to done,
                                    "totalBytes" to total
                                )
                            )
                        }
                        is DownloadStatus.DownloadCompleted ->
                            emit(mapOf("status" to "available", "progress" to 1.0))
                        is DownloadStatus.DownloadFailed ->
                            emit(mapOf("status" to "unavailable", "errorMessage" to formatThrowable(status.e)))
                    }
                }
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Throwable) {
            emit(mapOf("status" to "unavailable", "errorMessage" to formatThrowable(e)))
        }
        post { events?.endOfStream() }
    }
}
