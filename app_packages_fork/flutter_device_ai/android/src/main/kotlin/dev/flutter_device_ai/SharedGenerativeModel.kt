package dev.flutter_device_ai

import android.content.Context
import android.os.SystemClock
import com.google.mlkit.common.MlKit
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerativeModel

/**
 * Process-wide Gemini Nano client.
 *
 * AICore can throw a raw [NullPointerException] when [GenerativeModel.checkStatus]
 * runs immediately after construction (mlkit#1071). Playground avoids this by
 * creating the client after the app is up; we also call [MlKit.initialize]
 * before [Generation.getClient] so MlKitContext is available when possible.
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

    /** Last failure from [warm] / [get], for diagnostic notes. */
    @Volatile
    var lastError: String? = null
        private set

    /** Marks process start (ContentProvider) without calling GenAI yet. */
    @Synchronized
    fun markProcessStart() {
        if (processMarkedAtElapsedMs == 0L) {
            processMarkedAtElapsedMs = SystemClock.elapsedRealtime()
        }
    }

    private fun formatError(e: Throwable): String =
        "${e.javaClass.name}: ${e.message ?: ""}".trim()

    /**
     * Ensures ML Kit context exists when possible, then creates the client if needed.
     *
     * [MlKit.initialize] failures are recorded but do not abort client creation
     * (the ContentProvider may already have initialized ML Kit).
     *
     * @throws Throwable when [Generation.getClient] fails.
     */
    @Synchronized
    fun get(appContext: Context): GenerativeModel {
        markProcessStart()
        model?.let { return it }
        val context = appContext.applicationContext
        val initError = runCatching { MlKit.initialize(context) }.exceptionOrNull()
        return try {
            Generation.getClient().also {
                model = it
                createdAtElapsedMs = SystemClock.elapsedRealtime()
                lastError = null
            }
        } catch (e: Throwable) {
            lastError = buildString {
                if (initError != null) {
                    append("init=${formatError(initError)}")
                    append(" | ")
                }
                append("getClient=${formatError(e)}")
            }
            throw e
        }
    }

    /**
     * Best-effort early construction.
     *
     * Relies on [get] to populate [lastError] (including init + getClient);
     * does not overwrite that combined message.
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
