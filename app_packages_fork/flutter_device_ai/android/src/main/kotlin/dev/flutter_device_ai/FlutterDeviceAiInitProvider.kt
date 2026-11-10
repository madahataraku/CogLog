package dev.flutter_device_ai

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri

/**
 * Creates the shared [GenerativeModel] during app process start, before Flutter
 * attaches plugins, so AICore has time to bind before the first status check.
 *
 * Manifest `initOrder` must be lower than ML Kit's `MlKitInitProvider` (99)
 * so that provider runs first.
 */
class FlutterDeviceAiInitProvider : ContentProvider() {
    override fun onCreate(): Boolean {
        SharedGenerativeModel.warm()
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
