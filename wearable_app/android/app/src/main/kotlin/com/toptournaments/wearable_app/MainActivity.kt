package com.toptournaments.wearable_app

import android.os.Bundle
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "toptournaments/gatt"
	private var gattServerManager: GattServer? = null
	private val bluetoothPermissionRequestCode = 1001

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
			val permissions = arrayOf(
				Manifest.permission.BLUETOOTH_CONNECT,
				Manifest.permission.BLUETOOTH_ADVERTISE,
			)
			val missing = permissions.filter {
				checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
			}
			if (missing.isNotEmpty()) {
				requestPermissions(missing.toTypedArray(), bluetoothPermissionRequestCode)
			}
		}
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"startGattServer" -> {
					if (gattServerManager == null) {
						gattServerManager = GattServer(this)
					}
					gattServerManager?.startServer()
					result.success(true)
				}
				"stopGattServer" -> {
					gattServerManager?.stopServer()
					result.success(true)
				}
				else -> result.notImplemented()
			}
		}
	}
}
