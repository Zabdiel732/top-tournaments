package com.toptournaments.wearable_app

import android.bluetooth.*
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Context
import android.os.ParcelUuid
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.*
import kotlin.concurrent.fixedRateTimer

class GattServer(private val context: Context) {
    companion object {
        private const val TAG = "GattServer"
        private const val SERVICE_UUID = "0000ff00-0000-1000-8000-00805f9b34fb"
        private const val CHAR1_UUID = "0000ff01-0000-1000-8000-00805f9b34fb"
        private const val CHAR2_UUID = "0000ff02-0000-1000-8000-00805f9b34fb"
        private const val CHAR3_UUID = "0000ff03-0000-1000-8000-00805f9b34fb"
        private const val CCCD_UUID = "00002902-0000-1000-8000-00805f9b34fb"
    }

    private val btManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val btAdapter: BluetoothAdapter? = btManager.adapter
    private var gattServer: BluetoothGattServer? = null
    private val connectedDevices = mutableSetOf<BluetoothDevice>()
    private var timerRef: java.util.Timer? = null

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            super.onConnectionStateChange(device, status, newState)
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                connectedDevices.add(device)
                Log.i(TAG, "Device connected: ${'$'}{device.address}")
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                connectedDevices.remove(device)
                Log.i(TAG, "Device disconnected: ${'$'}{device.address}")
            }
        }
    }

    fun startServer() {
        if (btAdapter == null) {
            Log.e(TAG, "Bluetooth adapter is null")
            return
        }

        if (gattServer != null) return

        gattServer = btManager.openGattServer(context, gattServerCallback)
        val service = BluetoothGattService(UUID.fromString(SERVICE_UUID), BluetoothGattService.SERVICE_TYPE_PRIMARY)

        val char1 = BluetoothGattCharacteristic(UUID.fromString(CHAR1_UUID), BluetoothGattCharacteristic.PROPERTY_NOTIFY, BluetoothGattCharacteristic.PERMISSION_READ)
        val desc1 = BluetoothGattDescriptor(UUID.fromString(CCCD_UUID), BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE)
        char1.addDescriptor(desc1)

        val char2 = BluetoothGattCharacteristic(UUID.fromString(CHAR2_UUID), BluetoothGattCharacteristic.PROPERTY_NOTIFY, BluetoothGattCharacteristic.PERMISSION_READ)
        val desc2 = BluetoothGattDescriptor(UUID.fromString(CCCD_UUID), BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE)
        char2.addDescriptor(desc2)

        val char3 = BluetoothGattCharacteristic(UUID.fromString(CHAR3_UUID), BluetoothGattCharacteristic.PROPERTY_NOTIFY, BluetoothGattCharacteristic.PERMISSION_READ)
        val desc3 = BluetoothGattDescriptor(UUID.fromString(CCCD_UUID), BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE)
        char3.addDescriptor(desc3)

        service.addCharacteristic(char1)
        service.addCharacteristic(char2)
        service.addCharacteristic(char3)

        gattServer?.addService(service)

        // Start advertising
        try {
            val advertiser = btAdapter.bluetoothLeAdvertiser
            val settings = AdvertiseSettings.Builder().setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY).setConnectable(true).setTimeout(0).build()
            val data = AdvertiseData.Builder().addServiceUuid(ParcelUuid(UUID.fromString(SERVICE_UUID))).setIncludeDeviceName(true).build()
            advertiser.startAdvertising(settings, data, advertiseCallback)
        } catch (e: Exception) {
            Log.w(TAG, "Advertising not available: ${'$'}e")
        }

        // Start periodic metric generation and notify connected clients
        timerRef = fixedRateTimer("metrics", initialDelay = 0L, period = 1000L) {
            val pasos = Random().nextInt(3) + 1
            val ritmo = 70 + Random().nextInt(40)
            val calorias = 1 + Random().nextInt(3)
            notifyAllClients(CHAR1_UUID, intToLittleEndian(pasos))
            notifyAllClients(CHAR2_UUID, intToLittleEndian(ritmo))
            notifyAllClients(CHAR3_UUID, intToLittleEndian(calorias))
        }
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
            super.onStartSuccess(settingsInEffect)
            Log.i(TAG, "Advertising started")
        }

        override fun onStartFailure(errorCode: Int) {
            super.onStartFailure(errorCode)
            Log.w(TAG, "Advertising failed: ${'$'}errorCode")
        }
    }

    fun stopServer() {
        timerRef?.cancel()
        timerRef = null
        try {
            btAdapter?.bluetoothLeAdvertiser?.stopAdvertising(advertiseCallback)
        } catch (e: Exception) {
            // ignore
        }
        gattServer?.close()
        gattServer = null
        connectedDevices.clear()
        Log.i(TAG, "GATT server stopped")
    }

    private fun notifyAllClients(charUuid: String, value: ByteArray) {
        val characteristic = gattServer?.getService(UUID.fromString(SERVICE_UUID))?.getCharacteristic(UUID.fromString(charUuid))
        characteristic?.value = value
        for (device in connectedDevices) {
            gattServer?.notifyCharacteristicChanged(device, characteristic, false)
        }
    }

    private fun intToLittleEndian(value: Int): ByteArray {
        val buffer = ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN)
        buffer.putInt(value)
        return buffer.array()
    }
}
