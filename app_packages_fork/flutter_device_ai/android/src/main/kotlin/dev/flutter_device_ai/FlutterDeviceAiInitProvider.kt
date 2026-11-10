package dev.flutter_device_ai

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import com.google.mlkit.common.MlKit

/**
 * Marks process start and initializes ML Kit during app startup, before Flutter
 * attaches plugins. Defers [Generation.getClient] warm to a background attempt
 * so MlKitContext is ready (mlkit#1071 / MlKitContext init).
 *
 * Manifest `initOrder` must be lower than ML Kit's `MlKitInitProvider` (99)
 * so that provider runs first when present.
 */
class FlutterDeviceAiInitProvider : ContentProvider() {
    override fun onCreate(): Boolean {
        SharedGenerativeModel.markProcessStart()
        val ctx = context?.applicationContext ?: return true
        runCatching { MlKit.initialize(ctx) }
        // Warm after ML Kit init; failures are kept in SharedGenerativeModel.lastError.
        SharedGenerativeModel.warm(ctx)
        return true
    }

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?,
    ): Cursor? = null

    override fun getType(uri: Uri): String? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(
        uri: Uri,
        values: ContentValues?,
        selection: String?,
        selectionArgs: Array<out String>?,
    ): Int = 0
}
