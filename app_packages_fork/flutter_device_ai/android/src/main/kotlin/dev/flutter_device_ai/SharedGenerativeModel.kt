package dev.flutter_device_ai

import android.content.Context
import android.os.SystemClock
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerativeModel

/**
 * Process-wide Gemini Nano client.
 *
 * Create the client only on the first GenAI API call (availability / generate /
 * download), matching Gemini Nano Playground (Hilt inject into ViewModel after
 * Activity start). Do not call [Generation.getClient] from a ContentProvider or
 * from [io.flutter.embedding.engine.plugins.FlutterPlugin.onAttachedToEngine]:
 * early failures have left permanent `getClient` NPEs (`modelReady=false`).
 */
internal object SharedGenerativeModel {
    @Volatile
    private var model: GenerativeModel? = null

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
            .take(8)
            .joinToString(" <- ") { "${it.className}.${it.methodName}:${it.lineNumber}" }
        return if (stack.isEmpty()) head else "$head | stack: $stack"
    }

    /**
     * Creates the client if needed via plain [Generation.getClient] (Playground).
     *
     * @param appContext kept for call-site consistency; GenAI resolves context via MlKit.
     */
    @Synchronized
    @Suppress("UNUSED_PARAMETER")
    fun get(appContext: Context): GenerativeModel {
        markProcessStart()
        model?.let { return it }
        return try {
            // Same entry as Nano Playground / ML Kit samples — no custom GenerationConfig.
            Generation.getClient().also {
                model = it
                createdAtElapsedMs = SystemClock.elapsedRealtime()
                lastError = null
            }
        } catch (e: Throwable) {
            lastError = "getClient=${formatError(e)}"
            throw e
        }
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
