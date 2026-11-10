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
 * creating the client after the app is up; we also require [MlKit.initialize]
 * before [Generation.getClient] so MlKitContext is never null.
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

    /**
     * Ensures ML Kit context exists, then creates the client if needed.
     *
     * @throws Throwable when [Generation.getClient] fails after ML Kit init.
     */
    @Synchronized
    fun get(appContext: Context): GenerativeModel {
        markProcessStart()
        model?.let { return it }
        val context = appContext.applicationContext
        // Safe if MlKitInitProvider already ran; required if it did not.
        runCatching { MlKit.initialize(context) }
        return try {
            Generation.getClient().also {
                model = it
                createdAtElapsedMs = SystemClock.elapsedRealtime()
                lastError = null
            }
        } catch (e: Throwable) {
            lastError = "${e.javaClass.name}: ${e.message ?: ""}".trim()
            throw e
        }
    }

    /** Best-effort early construction. Records [lastError] on failure. */
    fun warm(appContext: Context) {
        markProcessStart()
        runCatching { get(appContext) }
            .onFailure { e ->
                lastError = "${e.javaClass.name}: ${e.message ?: ""}".trim()
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
