package com.phito.atelier

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews

class NoteHomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val title = prefs.getString("title", "Remember") ?: "Remember"
        val body = prefs.getString("body", "A sticky thought.") ?: "A sticky thought."
        val noteId = prefs.getString("note_id", "") ?: ""
        val paper = prefs.getInt("paper", Color.parseColor("#F5E28A"))
        val ink = prefs.getInt("ink", Color.parseColor("#3D3415"))
        val muted = prefs.getInt("muted", Color.parseColor("#7A6A28"))
        val style = prefs.getString("style", "handwritten") ?: "handwritten"
        val tilt = prefs.getInt("tilt", -2)

        appWidgetIds.forEach { widgetId ->
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val widthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, 180)
                .coerceAtLeast(140)
            val heightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 180)
                .coerceAtLeast(140)

            val sticky = StickyNoteRenderer.render(
                context = context,
                widthDp = widthDp,
                heightDp = heightDp,
                title = title,
                body = body,
                paper = paper,
                ink = ink,
                muted = muted,
                style = style,
                tilt = tilt,
            )

            val views = RemoteViews(context.packageName, R.layout.note_widget).apply {
                setImageViewBitmap(R.id.sticky_image, sticky)
                val launch = Intent(context, MainActivity::class.java).apply {
                    data = Uri.parse("atelier://note/$noteId")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pending = PendingIntent.getActivity(
                    context,
                    widgetId,
                    launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                setOnClickPendingIntent(R.id.widget_root, pending)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    companion object {
        const val PREFS = "atelier_widget"

        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                android.content.ComponentName(context, NoteHomeWidgetProvider::class.java),
            )
            if (ids.isNotEmpty()) {
                NoteHomeWidgetProvider().onUpdate(context, manager, ids)
            }
        }
    }
}
