package com.github.zjiyuform.ailevon

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.download/media"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "moveToDownloads" -> {
                        val sourcePath = call.argument<String>("sourcePath")
                        val fileName = call.argument<String>("fileName")
                        if (sourcePath != null && fileName != null) {
                            val success = moveFileToDownloads(sourcePath, fileName)
                            result.success(success)
                        } else {
                            result.error("INVALID_ARGS", "Missing sourcePath or fileName", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun moveFileToDownloads(sourcePath: String, fileName: String): Boolean {
        val sourceFile = File(sourcePath)
        if (!sourceFile.exists()) return false

        val resolver = contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, getMimeType(fileName))
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            } else {
                // Android 9 及以下需配合 WRITE_EXTERNAL_STORAGE 权限
                put(MediaStore.Downloads.DATA, "${Environment.getExternalStorageDirectory()}/Download/$fileName")
            }
        }

        var targetUri: Uri? = null
        try {
            targetUri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            targetUri?.let { uri ->
                resolver.openOutputStream(uri)?.use { outputStream ->
                    FileInputStream(sourceFile).use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                // 写入成功，删除原文件
                sourceFile.delete()
                return true
            }
        } catch (e: Exception) {
            e.printStackTrace()
            // 如果写入失败，尝试删除已插入的空条目
            targetUri?.let { resolver.delete(it, null, null) }
        }
        return false
    }

    private fun getMimeType(fileName: String): String {
        return when {
            fileName.endsWith(".txt") -> "text/plain"
            fileName.endsWith(".png") -> "image/png"
            fileName.endsWith(".jpg") || fileName.endsWith(".jpeg") -> "image/jpeg"
            fileName.endsWith(".pdf") -> "application/pdf"
            fileName.endsWith(".epub") -> "application/epub+zip"
            else -> "application/octet-stream"
        }
    }
}