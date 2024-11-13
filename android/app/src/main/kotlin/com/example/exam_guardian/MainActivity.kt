package com.example.exam_guardian

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import android.content.res.Configuration
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "com.example.app/pip"
    private val EVENT_CHANNEL = "com.example.app/pip_events"
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        println("🔄 Configuring Flutter Engine")
        
        // Setup Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPipSupported" -> {
                    println("📱 Checking PiP support")
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                }
                "isInPipMode" -> {
                    result.success(isInPictureInPictureMode)
                }
                "enterPipMode" -> {
                    println("🎯 Attempting to enter PiP mode")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        try {
                            val pipBuilder = PictureInPictureParams.Builder()
                            pipBuilder.setAspectRatio(Rational(16, 9))
                            enterPictureInPictureMode(pipBuilder.build())
                            println("✅ Entered PiP mode successfully")
                            result.success(true)
                        } catch (e: Exception) {
                            println("❌ Error entering PiP mode: ${e.message}")
                            result.error("PIP_ERROR", e.message, null)
                        }
                    } else {
                        result.error("PIP_ERROR", "PiP not supported on this device", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Setup Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        println("🖥️ PiP mode ${if(isInPictureInPictureMode) "enabled" else "disabled"}")
        eventSink?.success(isInPictureInPictureMode)
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val pipBuilder = PictureInPictureParams.Builder()
                pipBuilder.setAspectRatio(Rational(16, 9))
                enterPictureInPictureMode(pipBuilder.build())
            } catch (e: Exception) {
                print("Error entering PiP mode: ${e.message}")
            }
        }
    }

    override fun onStop() {
        super.onStop()
        if (isInPictureInPictureMode) {
            eventSink?.success(true)
        }
    }
}