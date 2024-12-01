package com.example.exam_guardian

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import androidx.annotation.NonNull
import cl.puntito.simple_pip_mode.PipCallbackHelperActivityWrapper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.graphics.Rect
import android.util.Log
import android.content.pm.PackageManager
import android.app.ActivityManager

class MainActivity: PipCallbackHelperActivityWrapper() {
    private val CHANNEL = "simple_pip_mode"
    private lateinit var channel: MethodChannel
    private var lastPipState = false
    private var normalHeight: Int = 0
    
    companion object {
        private const val TAG = "PiPMode"
        private const val PIP_HEIGHT_RATIO_THRESHOLD = 0.72
        private const val PIP_CHECK_DELAY = 200L
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Store initial height
        window.decorView.post {
            normalHeight = window.decorView.height
            Log.d(TAG, "Initial window height: $normalHeight")
        }
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isInPictureInPictureMode" -> {
                    try {
                        val isInPip = checkPipMode()
                        Log.d(TAG, "Method channel check PiP mode: $isInPip")
                        result.success(isInPip)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error in method channel: ${e.message}")
                        result.error("PIP_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkPipMode(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val decorView = window.decorView
            val rect = Rect()
            decorView.getWindowVisibleDisplayFrame(rect)
            
            val currentHeight = rect.height().toFloat()
            val heightRatio = currentHeight / normalHeight
            
            Log.d(TAG, """
                Window analysis:
                - Normal height: $normalHeight
                - Current height: $currentHeight
                - Height ratio: $heightRatio
                - Is in PiP (system): $isInPictureInPictureMode
                - Window focus: ${hasWindowFocus()}
                - Previous PiP state: $lastPipState
            """.trimIndent())
            
            val isInPip = when {
                isInPictureInPictureMode -> {
                    Log.d(TAG, "System reports PiP mode")
                    true
                }
                heightRatio <= PIP_HEIGHT_RATIO_THRESHOLD && !hasWindowFocus() -> {
                    Log.d(TAG, "Height reduction and focus loss indicate PiP mode")
                    true
                }
                lastPipState && currentHeight < normalHeight -> {
                    Log.d(TAG, "Maintaining PiP state due to reduced height")
                    true
                }
                else -> false
            }
            
            if (isInPip != lastPipState) {
                lastPipState = isInPip
                Log.d(TAG, "PiP state changed to: $isInPip")
                channel.invokeMethod("onPipModeChanged", isInPip)
            }
            
            return isInPip
        }
        return false
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode)
        Log.d(TAG, "onPictureInPictureModeChanged: $isInPictureInPictureMode")
        checkPipMode()
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        Log.d(TAG, "Configuration changed")
        // Update normal height if we're not in PiP mode
        if (!isInPictureInPictureMode) {
            normalHeight = window.decorView.height
            Log.d(TAG, "Updated normal height: $normalHeight")
        }
        checkPipMode()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        Log.d(TAG, "Window focus changed: $hasFocus")
        if (!hasFocus) {
            android.os.Handler().postDelayed({
                checkPipMode()
            }, PIP_CHECK_DELAY)
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        Log.d(TAG, "User leave hint received")
        android.os.Handler().postDelayed({
            checkPipMode()
        }, 300)
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "Activity resumed")
        if (!isInPictureInPictureMode) {
            normalHeight = window.decorView.height
            Log.d(TAG, "Updated normal height on resume: $normalHeight")
        }
    }
}