package com.example.beadly

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.view.KeyEvent
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val volumeTapChannelName = "beadly/volume_buttons"
    private val volumeServiceChannelName = "beadly/volume_service"
    private val notificationPermissionRequestCode = 4201

    private var volumeTapChannel: MethodChannel? = null
    private var pendingServiceStartResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        volumeTapChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, volumeTapChannelName)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, volumeServiceChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> startVolumeService(result)
                    "stop" -> {
                        stopVolumeService()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startVolumeService(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            pendingServiceStartResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                notificationPermissionRequestCode
            )
            return
        }
        ContextCompat.startForegroundService(this, Intent(this, VolumeCounterService::class.java))
        result.success(true)
    }

    private fun stopVolumeService() {
        val intent = Intent(this, VolumeCounterService::class.java).apply {
            action = VolumeCounterService.ACTION_STOP
        }
        startService(intent)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == notificationPermissionRequestCode) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            if (granted) {
                ContextCompat.startForegroundService(this, Intent(this, VolumeCounterService::class.java))
            }
            pendingServiceStartResult?.success(granted)
            pendingServiceStartResult = null
        }
    }

    // Intercepts both volume buttons so they tap the bead counter instead of
    // changing the device's media volume, while the app is in the foreground.
    // (Screen-off counting is handled separately, by VolumeCounterService.)
    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.keyCode == KeyEvent.KEYCODE_VOLUME_UP ||
            event.keyCode == KeyEvent.KEYCODE_VOLUME_DOWN
        ) {
            if (event.action == KeyEvent.ACTION_DOWN) {
                volumeTapChannel?.invokeMethod("volumeKeyPressed", null)
            }
            return true
        }
        return super.dispatchKeyEvent(event)
    }
}
