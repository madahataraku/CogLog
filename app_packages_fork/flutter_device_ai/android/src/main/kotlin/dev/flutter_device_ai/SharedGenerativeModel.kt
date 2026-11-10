package dev.flutter_device_ai

import android.os.SystemClock
import com.google.mlkit.genai.prompt.Generation
import com.google.mlkit.genai.prompt.GenerativeModel

/**
 * Process-wide Gemini Nano client.
 *
 * AICore can throw a raw [NullPointerException] when [GenerativeModel.checkStatus]
 * runs immediately after construction (mlkit#1071). Keeping one early-created
 * instance and waiting before the first status call matches Gemini Nano Playground.
 */
internal object SharedGenerativeModel {
    @Volatile
    private var model: GenerativeModel? = null

    /** [SystemClock.elapsedRealtime] when [model] was first created. */
    @Volatile
    var createdAtElapsedMs: Long = 0L
        private set

    /** Creates the client if needed and returns it. */
    @Synchronized
    fun get(): GenerativeModel {
        model?.let { return it }
        return Generation.getClient().also {
            model = it
            createdAtElapsedMs = SystemClock.elapsedRealtime()
        }
    }

    /** Best-effort early construction (ContentProvider / plugin attach). */
    fun warm() {
        runCatching { get() }
    }

    /** Elapsed ms since construction, or 0 if not yet created. */
    fun ageMs(): Long {
        val created = createdAtElapsedMs
        if (created == 0L || model == null) return 0L
        return SystemClock.elapsedRealtime() - created
    }
}
