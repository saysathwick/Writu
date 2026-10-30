package com.phito.atelier

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "atelier/home_widget"
    private var pendingNoteId: String? = null
    private var channel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pendingNoteId = noteIdFrom(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "save" -> {
                    val args = call.arguments as? Map<*, *>
                    val prefs = getSharedPreferences(NoteHomeWidgetProvider.PREFS, MODE_PRIVATE)
                    prefs.edit().apply {
                        putString("note_id", args?.get("note_id") as? String ?: "")
                        putString("title", args?.get("title") as? String ?: "U-write")
                        putString("body", args?.get("body") as? String ?: "")
                        putInt("ink", (args?.get("ink") as? Number)?.toInt() ?: 0xFF1C1410.toInt())
                        putInt("paper", (args?.get("paper") as? Number)?.toInt() ?: 0xFFF5E28A.toInt())
                        putInt("muted", (args?.get("muted") as? Number)?.toInt() ?: 0xFF7A6A28.toInt())
                        putString("style", args?.get("style") as? String ?: "handwritten")
                        putInt("tilt", (args?.get("tilt") as? Number)?.toInt() ?: -2)
                        apply()
                    }
                    NoteHomeWidgetProvider.refresh(this)
                    result.success(true)
                }
                "pin" -> {
                    val manager = AppWidgetManager.getInstance(this)
                    val provider = ComponentName(this, NoteHomeWidgetProvider::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                        manager.isRequestPinAppWidgetSupported
                    ) {
                        manager.requestPinAppWidget(provider, null, null)
                        result.success(true)
                    } else {
                        result.error(
                            "UNSUPPORTED",
                            "This launcher cannot pin widgets. Add U-write from the widget picker.",
                            null,
                        )
                    }
                }
                "consumeLaunch" -> {
                    val id = pendingNoteId
                    pendingNoteId = null
                    result.success(id)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val id = noteIdFrom(intent)
        if (id != null) {
            channel?.invokeMethod("opened", id)
        }
    }

    private fun noteIdFrom(intent: Intent?): String? {
        val data = intent?.data ?: return null
        if (data.scheme != "atelier" || data.host != "note") return null
        return data.pathSegments.firstOrNull()
    }
}
