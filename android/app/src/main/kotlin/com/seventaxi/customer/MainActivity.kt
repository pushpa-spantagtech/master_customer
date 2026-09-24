package com.seventaxi.customer

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.pdf.PdfDocument
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.OutputStream
import java.util.concurrent.Executors
import kotlin.math.ceil

class MainActivity: FlutterActivity() {
    private var permissionResult: MethodChannel.Result? = null
    private val pdfExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
            "com.seventaxi.customer/trip_pdf").setMethodCallHandler { call, result ->
            when (call.method) {
                "prepare" -> {
                    if (Build.VERSION.SDK_INT in 23..28 &&
                        checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                        if (permissionResult != null) {
                            result.error("BUSY", "A storage permission request is already open.", null)
                        } else {
                            permissionResult = result
                            requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), 7421)
                        }
                    } else result.success(null)
                }
                "save" -> {
                    val image = call.argument<ByteArray>("image")
                    val header = call.argument<ByteArray>("header")
                    val padding = call.argument<Number>("padding")?.toFloat() ?: 32f
                    val refId = call.argument<String>("refId")
                    if (image == null || header == null || refId.isNullOrBlank()) {
                        result.error("INVALID_INPUT", "Trip reference or PDF image is missing.", null)
                    } else {
                        pdfExecutor.execute {
                            try {
                                val name = refId.replace(Regex("[\\\\/:*?\"<>|\\p{Cntrl}]"), "_")
                                    .trim().trim('.').take(120).ifBlank { "trip" } + ".pdf"
                                val savedName = savePdf(image, header, padding, name)
                                runOnUiThread {
                                    Toast.makeText(applicationContext, "PDF saved to Downloads: $savedName", Toast.LENGTH_LONG).show()
                                    result.success(savedName)
                                }
                            } catch (error: Exception) {
                                runOnUiThread {
                                    result.error("SAVE_FAILED", "Could not save PDF to Downloads. Check storage space and permission, then retry.", null)
                                }
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 7421) {
            val pending = permissionResult
            permissionResult = null
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                pending?.success(null)
            } else {
                pending?.error("PERMISSION_DENIED", "Storage permission is needed to save PDFs in Downloads. Allow it in app settings and try again.", null)
            }
        }
    }

    private fun writePdf(image: ByteArray, header: ByteArray, padding: Float, output: OutputStream) {
        val bitmap = BitmapFactory.decodeByteArray(image, 0, image.size)
            ?: throw IllegalArgumentException("Invalid trip image")
        try {
            val headerBitmap = BitmapFactory.decodeByteArray(header, 0, header.size)
                ?: throw IllegalArgumentException("Invalid trip header")
            try {
                val document = PdfDocument()
                try {
                    // A continuous receipt page keeps the exact UI without cutting rows.
                    val width = 595
                    val scale = width.toFloat() / headerBitmap.width
                    val margin = padding * scale
                    val headerHeight = headerBitmap.height * scale
                    val bodyHeight = bitmap.height * (width - 2 * margin) / bitmap.width
                    val height = ceil((headerHeight + bodyHeight + 2 * margin).toDouble()).toInt()
                    val page = document.startPage(PdfDocument.PageInfo.Builder(width, height, 1).create())
                    page.canvas.drawColor(android.graphics.Color.WHITE)
                    val paint = Paint(Paint.FILTER_BITMAP_FLAG)
                    page.canvas.drawBitmap(headerBitmap, null, RectF(0f, 0f, width.toFloat(), headerHeight), paint)
                    page.canvas.drawBitmap(bitmap, null, RectF(margin, headerHeight + margin, width - margin, headerHeight + margin + bodyHeight), paint)
                    document.finishPage(page)
                    document.writeTo(output)
                } finally {
                    document.close()
                }
            } finally {
                headerBitmap.recycle()
            }
        } finally {
            bitmap.recycle()
        }
    }

    private fun savePdf(image: ByteArray, header: ByteArray, padding: Float, name: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, name)
                put(MediaStore.Downloads.MIME_TYPE, "application/pdf")
                put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
            val uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IllegalStateException("Downloads unavailable")
            try {
                (contentResolver.openOutputStream(uri) ?: throw IllegalStateException("Cannot open Downloads file")).use {
                    writePdf(image, header, padding, it)
                }
                check(contentResolver.update(uri, ContentValues().apply {
                    put(MediaStore.Downloads.IS_PENDING, 0)
                }, null, null) == 1)
                contentResolver.query(uri, arrayOf(MediaStore.Downloads.DISPLAY_NAME), null, null, null)?.use {
                    if (it.moveToFirst()) return it.getString(0)
                }
                return name
            } catch (error: Exception) {
                contentResolver.delete(uri, null, null)
                throw error
            }
        }
        @Suppress("DEPRECATION")
        val directory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        check(directory.isDirectory || directory.mkdirs())
        var file = File(directory, name)
        var index = 1
        // Preserve previous downloads instead of overwriting them.
        while (!file.createNewFile()) {
            file = File(directory, "${name.removeSuffix(".pdf")} (${index++}).pdf")
        }
        try {
            file.outputStream().use { writePdf(image, header, padding, it) }
            MediaScannerConnection.scanFile(applicationContext, arrayOf(file.absolutePath), arrayOf("application/pdf"), null)
            return file.name
        } catch (error: Exception) {
            file.delete()
            throw error
        }
    }

    override fun onDestroy() {
        permissionResult?.error("CANCELLED", "PDF download cancelled. Please try again.", null)
        permissionResult = null
        pdfExecutor.shutdown()
        super.onDestroy()
    }
}
