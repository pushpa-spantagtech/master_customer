package com.seventaxi.customer

import android.graphics.Color
import android.graphics.BitmapFactory
import android.graphics.RectF
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.pdf.PdfDocument
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import java.io.OutputStream

/** A4 document drawn with native text, never a capture of Flutter widgets. */
internal object TripPdfWriter {
    fun write(rows: List<Map<String, String>>, refId: String, images: Map<String, ByteArray>, output: OutputStream) {
        val document = PdfDocument()
        var page: PdfDocument.Page? = null
        var pageNumber = 0
        var y = 0f
        val ink = Color.rgb(30, 38, 48)
        val muted = Color.rgb(95, 105, 115)
        val accent = Color.rgb(210, 35, 40)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        fun text(value: String, x: Float, baseline: Float, size: Float, color: Int, bold: Boolean = false) {
            paint.textSize = size
            paint.color = color
            paint.typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
            page!!.canvas.drawText(value, x, baseline, paint)
        }
        fun finishPage() {
            val current = page ?: return
            paint.color = Color.LTGRAY
            current.canvas.drawLine(40f, 798f, 555f, 798f, paint)
            text("SevenTaxi • Trip details", 40f, 815f, 9f, muted)
            text("Page $pageNumber", 505f, 815f, 9f, muted)
            document.finishPage(current)
            page = null
        }
        fun newPage() {
            finishPage()
            pageNumber++
            // ISO A4 in PDF points (210 × 297 mm), with print-safe margins.
            page = document.startPage(PdfDocument.PageInfo.Builder(595, 842, pageNumber).create())
            page!!.canvas.drawColor(Color.WHITE)
            text("SEVENTAXI", 40f, 55f, 22f, accent, true)
            text("TRIP DETAILS", 40f, 78f, 11f, muted, true)
            paint.color = accent
            page!!.canvas.drawRect(40f, 91f, 555f, 94f, paint)
            y = 110f
        }
        @Suppress("DEPRECATION")
        fun layout(value: String, width: Int, bold: Boolean, color: Int): StaticLayout {
            val style = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
                textSize = 11f
                this.color = color
                typeface = if (bold) Typeface.DEFAULT_BOLD else Typeface.DEFAULT
            }
            return StaticLayout(value, style, width, Layout.Alignment.ALIGN_NORMAL, 1.15f, 0f, false)
        }
        fun drawPart(block: StaticLayout, x: Float, first: Int, last: Int) {
            if (first >= last) return
            val top = block.getLineTop(first)
            val height = block.getLineTop(last) - top
            val canvas = page!!.canvas
            canvas.save()
            canvas.clipRect(x, y, x + block.width, y + height)
            canvas.translate(x, y - top)
            block.draw(canvas)
            canvas.restore()
        }
        try {
            newPage()
            val allRows = listOf(mapOf("label" to "Trip reference", "value" to refId)) + rows
            for ((index, row) in allRows.withIndex()) {
                if (row["photos"] == "true") {
                    if (y + 116 > 782) newPage()
                    val keys = listOf("driver", "vehicle").filter { row.containsKey(it) }
                    for ((photoIndex, key) in keys.withIndex()) {
                        val x = 48f + photoIndex * 255f
                        val bounds = RectF(x, y, x + 236f, y + 84f)
                        paint.color = Color.rgb(246, 247, 249)
                        page!!.canvas.drawRoundRect(bounds, 6f, 6f, paint)
                        val bytes = images[key]
                        val bitmap = bytes?.let { BitmapFactory.decodeByteArray(it, 0, it.size) }
                        if (bitmap != null) {
                            try {
                                val scale = minOf(224f / bitmap.width, 76f / bitmap.height)
                                val width = bitmap.width * scale
                                val height = bitmap.height * scale
                                val left = bounds.centerX() - width / 2
                                val top = bounds.centerY() - height / 2
                                page!!.canvas.drawBitmap(bitmap, null,
                                    RectF(left, top, left + width, top + height),
                                    Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG))
                            } finally {
                                bitmap.recycle()
                            }
                        } else {
                            text("Photo unavailable", x + 65f, y + 46f, 10f, muted)
                        }
                        text(row[key].orEmpty(), x, y + 99f, 9f, muted)
                    }
                    y += 116f
                    continue
                }
                val section = row["section"]
                if (section != null) {
                    val heading = layout(section, 491, true, accent)
                    val nextIsPhotos = allRows.getOrNull(index + 1)?.get("photos") == "true"
                    if (y + heading.height + (if (nextIsPhotos) 170 else 60) > 782) newPage()
                    y += 10
                    paint.color = Color.rgb(246, 247, 249)
                    page!!.canvas.drawRect(40f, y - 5, 555f, y + heading.height + 5, paint)
                    drawPart(heading, 52f, 0, heading.lineCount)
                    y += heading.height + 14
                    continue
                }
                val total = row["total"] == "true"
                val label = layout(row["label"].orEmpty(), 155, total, muted)
                val value = layout(row["value"].orEmpty(), 336, total, ink)
                val height = maxOf(label.height, value.height)
                if (y + height + 12 > 782 && height <= 660) newPage()
                var labelLine = 0
                var valueLine = 0
                // Oversized addresses are continued at line boundaries, never truncated.
                while (labelLine < label.lineCount || valueLine < value.lineCount) {
                    val available = 782 - y - 12
                    fun end(block: StaticLayout, start: Int): Int {
                        var end = start
                        while (end < block.lineCount && block.getLineTop(end + 1) - block.getLineTop(start) <= available) end++
                        return end
                    }
                    val labelEnd = end(label, labelLine)
                    val valueEnd = end(value, valueLine)
                    if ((labelLine < label.lineCount && labelEnd == labelLine) ||
                        (valueLine < value.lineCount && valueEnd == valueLine)) {
                        newPage()
                        continue
                    }
                    val partHeight = maxOf(label.getLineTop(labelEnd) - label.getLineTop(labelLine),
                        value.getLineTop(valueEnd) - value.getLineTop(valueLine))
                    if (total) {
                        paint.color = Color.rgb(255, 243, 215)
                        page!!.canvas.drawRect(40f, y - 4, 555f, y + partHeight + 5, paint)
                    }
                    drawPart(label, 48f, labelLine, labelEnd)
                    drawPart(value, 211f, valueLine, valueEnd)
                    y += partHeight + 9
                    labelLine = labelEnd
                    valueLine = valueEnd
                    if (labelLine < label.lineCount || valueLine < value.lineCount) newPage()
                }
            }
            finishPage()
            document.writeTo(output)
        } finally {
            page?.let { document.finishPage(it) }
            document.close()
        }
    }
}
