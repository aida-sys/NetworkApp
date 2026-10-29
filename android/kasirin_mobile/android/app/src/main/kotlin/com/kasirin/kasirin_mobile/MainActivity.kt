package com.kasirin.kasirin_mobile

import android.app.Activity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import java.io.IOException

class MainActivity : FlutterActivity() {
    private val saveRequestCode = 7412
    private var pendingSaveResult: MethodChannel.Result? = null
    private var pendingRequestContent: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kasirin/payment")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openUrl" -> openUrl(call.argument<String>("url"), result)
                    "savePosRequest" -> savePosRequest(
                        call.argument<String>("filename"),
                        call.argument<String>("content"),
                        result,
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun openUrl(rawUrl: String?, result: MethodChannel.Result) {
        val uri = rawUrl?.let(Uri::parse)
        if (uri == null || uri.scheme != "https") {
            result.error("invalid_url", "URL must use HTTPS", null)
            return
        }
        try {
            startActivity(Intent(Intent.ACTION_VIEW, uri))
            result.success(null)
        } catch (error: Exception) {
            result.error("open_failed", error.message, null)
        }
    }

    private fun savePosRequest(
        filename: String?,
        content: String?,
        result: MethodChannel.Result,
    ) {
        if (pendingSaveResult != null) {
            result.error("save_busy", "A file save is already in progress", null)
            return
        }
        if (filename.isNullOrBlank() || content.isNullOrBlank()) {
            result.error("invalid_request", "Request file data is missing", null)
            return
        }
        pendingSaveResult = result
        pendingRequestContent = content
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, filename)
        }
        try {
            startActivityForResult(intent, saveRequestCode)
        } catch (error: Exception) {
            pendingSaveResult = null
            pendingRequestContent = null
            result.error("save_failed", error.message, null)
        }
    }

    @Deprecated("Deprecated in Android SDK, retained for document picker result")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != saveRequestCode) return
        val result = pendingSaveResult ?: return
        val content = pendingRequestContent
        pendingSaveResult = null
        pendingRequestContent = null
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }
        try {
            val uri = data.data!!
            val output = contentResolver.openOutputStream(uri)
                ?: throw IOException("Tidak dapat membuka file tujuan.")
            output.use { it.write((content ?: "").toByteArray(Charsets.UTF_8)) }
            result.success(uri.toString())
        } catch (error: Exception) {
            result.error("save_failed", error.message, null)
        }
    }
}
