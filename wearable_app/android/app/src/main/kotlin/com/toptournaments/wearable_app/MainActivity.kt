package com.toptournaments.wearable_app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "toptournaments/gatt"
	private var gattServerManager: GattServer? = null

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
