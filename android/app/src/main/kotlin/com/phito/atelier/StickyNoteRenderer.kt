package com.phito.atelier

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.graphics.Typeface
import android.util.TypedValue

object StickyNoteRenderer {
    fun render(
        context: Context,
        widthDp: Int,
        heightDp: Int,
        title: String,
        body: String,
        paper: Int,
        ink: Int,
        muted: Int,
        style: String,
        tilt: Int,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val width = (widthDp * density).toInt().coerceAtLeast(280)
        val height = (heightDp * density).toInt().coerceAtLeast(280)
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.TRANSPARENT)

        val pad = 18f * density
        val rect = RectF(pad, pad + 8f * density, width - pad, height - pad)
        canvas.save()
        canvas.rotate(tilt.toFloat(), rect.centerX(), rect.centerY())

        val shadow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(50, 0, 0, 0)
        }
        val shadowRect = RectF(
            rect.left + 4f * density,
            rect.top + 6f * density,
            rect.right + 4f * density,
            rect.bottom + 6f * density,
        )
        canvas.drawRoundRect(shadowRect, 18f, 18f, shadow)

        val paperPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = paper }
        canvas.drawRoundRect(rect, 18f, 18f, paperPaint)

        if (style == "journal" || style == "typewriter") {
            val line = Paint().apply {
                color = Color.argb(28, Color.red(ink), Color.green(ink), Color.blue(ink))
                strokeWidth = 1.5f
            }
            var y = rect.top + 56f * density
            while (y < rect.bottom - 20f * density) {
                canvas.drawLine(rect.left + 16f * density, y, rect.right - 16f * density, y, line)
                y += 22f * density
            }
        }

        val tape = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(140, 243, 230, 176)
        }
        val tapeRect = RectF(
            rect.centerX() - 28f * density,
            rect.top - 8f * density,
            rect.centerX() + 28f * density,
            rect.top + 14f * density,
        )
        canvas.save()
        canvas.rotate(6f, tapeRect.centerX(), tapeRect.centerY())
        canvas.drawRoundRect(tapeRect, 3f, 3f, tape)
        canvas.restore()

        val fold = Path().apply {
            moveTo(rect.right - 28f * density, rect.bottom)
            lineTo(rect.right, rect.bottom)
            lineTo(rect.right, rect.bottom - 28f * density)
            close()
        }
        val foldPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = darken(paper, 0.12f)
        }
        canvas.drawPath(fold, foldPaint)

        val handwritten = style == "handwritten" || style == "playful" || style == "artistic"
        val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = ink
            textSize = TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_SP,
                if (handwritten) 20f else 17f,
                context.resources.displayMetrics,
            )
            typeface = Typeface.create(
                if (handwritten) Typeface.SERIF else Typeface.SANS_SERIF,
                if (handwritten) Typeface.ITALIC else Typeface.BOLD,
            )
        }
        val bodyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = muted
            textSize = TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_SP,
                if (handwritten) 15f else 13f,
                context.resources.displayMetrics,
            )
            typeface = Typeface.create(
                if (handwritten || style == "journal") Typeface.SERIF else Typeface.SANS_SERIF,
                if (handwritten) Typeface.ITALIC else Typeface.NORMAL,
            )
        }

        val textLeft = rect.left + 18f * density
        val textMax = rect.width() - 36f * density
        var textY = rect.top + 42f * density
        textY = drawWrapped(canvas, title, titlePaint, textLeft, textY, textMax, 2)
        textY += 10f * density
        drawWrapped(canvas, body, bodyPaint, textLeft, textY, textMax, 6)

        canvas.restore()
        return bitmap
    }

    private fun drawWrapped(
        canvas: Canvas,
        text: String,
        paint: Paint,
        x: Float,
        startY: Float,
        maxWidth: Float,
        maxLines: Int,
    ): Float {
        val words = text.replace('\n', ' ').split(' ').filter { it.isNotEmpty() }
        if (words.isEmpty()) return startY
        var line = ""
        var y = startY
        var lines = 0
        for (word in words) {
            val trial = if (line.isEmpty()) word else "$line $word"
            if (paint.measureText(trial) > maxWidth && line.isNotEmpty()) {
                canvas.drawText(line, x, y, paint)
                y += paint.textSize * 1.35f
                line = word
                lines++
                if (lines >= maxLines) return y
            } else {
                line = trial
            }
        }
        if (line.isNotEmpty() && lines < maxLines) {
            canvas.drawText(line, x, y, paint)
            y += paint.textSize * 1.35f
        }
        return y
    }

    private fun darken(color: Int, amount: Float): Int {
        val r = (Color.red(color) * (1 - amount)).toInt()
        val g = (Color.green(color) * (1 - amount)).toInt()
        val b = (Color.blue(color) * (1 - amount)).toInt()
        return Color.argb(Color.alpha(color), r, g, b)
    }
}
