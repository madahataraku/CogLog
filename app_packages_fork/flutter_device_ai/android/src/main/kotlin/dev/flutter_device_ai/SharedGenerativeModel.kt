package dev.flutter_device_ai

import android.content.Context
import android.os.SystemClock
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerationConfig
import com.google.mlkit.genai.prompt.GenerativeModel
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicReference

/**
 * Process-wide Gemini Nano client.
 *
 * Do **not** call [Generation.getClient] from a ContentProvider: an early failure
 * can leave GenAI static state unusable for the rest of the process (seen as
 * permanent `getClient` NPE with `modelReady=false` even after minutes).
 * Playground creates the client only after the Activity/ViewModel is up.
 */
internal object SharedGenerativeModel {
    @Volatile
    private var model: GenerativeModel? = null

    private val genAiExecutor = AtomicReference(
        Executors.newSingleThreadExecutor { runnable ->
            Thread(runnable, "flutter-device-ai-genai").apply { isDaemon = true }
        },
    )

    /** [SystemClock.elapsedRealtime] when the process first touched this holder. */
    @Volatile
    var processMarkedAtElapsedMs: Long = 0L
        private set

    /** [SystemClock.elapsedRealtime] when [model] was first created. */
    @Volatile
    var createdAtElapsedMs: Long = 0L
        private set

    /** Last failure from [get], for diagnostic notes. */
    @Volatile
    var lastError: String? = null
        private set

    /** Marks process start without calling GenAI. */
    @Synchronized
    fun markProcessStart() {
        if (processMarkedAtElapsedMs == 0L) {
            processMarkedAtElapsedMs = SystemClock.elapsedRealtime()
        }
    }

    private fun formatError(e: Throwable): String {
        val head = "${e.javaClass.name}: ${e.message ?: ""}".trim()
        val stack = e.stackTrace
            .take(6)
            .joinToString(" <- ") { "${it.className}.${it.methodName}:${it.lineNumber}" }
        return if (stack.isEmpty()) head else "$head | stack: $stack"
    }

    /**
     * Creates the client if needed. Safe to call after Application/Activity start.
     *
     * Uses an explicit [GenerationConfig] worker executor so construction does not
     * depend on [com.google.mlkit.common.sdkinternal.MlKitThreadPool] internals.
     *
     * @param appContext unused today; kept so call sites pass application context.
     */
    @Synchronized
    @Suppress("UNUSED_PARAMETER")
    fun get(appContext: Context): GenerativeModel {
        markProcessStart()
        model?.let { return it }
        return try {
            val config = GenerationConfig.Builder().apply {
                workerExecutor = genAiExecutor.get()
            }.build()
            Generation.getClient(config).also {
                model = it
                createdAtElapsedMs = SystemClock.elapsedRealtime()
                lastError = null
            }
        } catch (e: Throwable) {
            lastError = "getClient=${formatError(e)}"
            throw e
        }
    }

    /**
     * Best-effort construction after the app is up (plugin attach / first GenAI call).
     * Must not be invoked from a ContentProvider.
     */
    fun warm(appContext: Context) {
        markProcessStart()
        runCatching { get(appContext) }
    }

    /** Elapsed ms since construction, or 0 if not yet created. */
    fun ageMs(): Long {
        val created = createdAtElapsedMs
        if (created == 0L || model == null) return 0L
        return SystemClock.elapsedRealtime() - created
    }

    /** Elapsed ms since process mark, or 0 if never marked. */
    fun processAgeMs(): Long {
        val marked = processMarkedAtElapsedMs
        if (marked == 0L) return 0L
        return SystemClock.elapsedRealtime() - marked
    }

    fun isReady(): Boolean = model != null
}
