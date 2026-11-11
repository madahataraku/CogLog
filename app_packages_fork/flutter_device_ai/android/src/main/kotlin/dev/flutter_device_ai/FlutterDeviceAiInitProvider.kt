package dev.flutter_device_ai

import android.content.ContentProvider
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri

/**
 * Records process start only.
 *
 * Intentionally does **not** call [com.google.mlkit.genai.prompt.Generation.getClient]:
 * early getClient failures during ContentProvider init have left GenAI unusable for
 * the whole process (`modelReady=false`, repeated getClient NPE). Client creation
 * happens on the first GenAI MethodChannel call (availability / generate), like
 * Nano Playground creating the client from a ViewModel after Activity start.
 *
 * Manifest `initOrder` stays below ML Kit's `MlKitInitProvider` (99).
 */
class FlutterDeviceAiInitProvider : ContentProvider() {
    override fun onCreate(): Boolean {
        SharedGenerativeModel.markProcessStart()
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
