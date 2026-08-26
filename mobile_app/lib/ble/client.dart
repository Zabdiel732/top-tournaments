import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'uuids.dart';

class BleClient {
  BleClient._privateConstructor();
  static final BleClient instance = BleClient._privateConstructor();

  final FlutterBluePlus _fb = FlutterBluePlus.instance;
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSub;

  final _connectionState = StreamController<String>.broadcast();
  final _metric1 = StreamController<int>.broadcast();
  final _metric2 = StreamController<int>.broadcast();
  final _metric3 = StreamController<int>.broadcast();

  Stream<String> get connectionStateStream => _connectionState.stream;
  Stream<int> get metric1Stream => _metric1.stream;
  Stream<int> get metric2Stream => _metric2.stream;
  Stream<int> get metric3Stream => _metric3.stream;

  bool get isConnected => _connectedDevice != null;

  Future<void> startScanAndConnect({Duration timeout = const Duration(seconds:5)}) async {
    if (isConnected) {
      _connectionState.add('Ya conectado a ${_connectedDevice!.name}');
      return;
    }

    _connectionState.add('Escaneando...');

    try {
      // Filtrar por SERVICE UUID
      final targetUuid = Guid(BleUuids.SERVICE);
      await _fb.startScan(withServices: [targetUuid], timeout: timeout);

      _scanSub = _fb.scanResults.listen((results) async {
        for (var r in results) {
          final d = r.device;
          // Evitar duplicados y conectarse al primero válido
          if (d.id.id.isNotEmpty) {
            await _fb.stopScan();
            _scanSub?.cancel();
            await _connectToDevice(d);
            return;
          }
        }
      });
    } catch (e) {
      _connectionState.add('Error escaneo: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (isConnected) return;
    _connectionState.add('Conectando a ${device.name.isNotEmpty ? device.name : device.id.id}');
    try {
      await device.connect(timeout: const Duration(seconds:10));
      _connectedDevice = device;
      _connectionState.add('Conectado. Descubriendo servicios...');
      final services = await device.discoverServices();

      for (var s in services) {
        if (s.uuid.toString().toLowerCase() == BleUuids.SERVICE) {
          for (var c in s.characteristics) {
            final cuuid = c.uuid.toString().toLowerCase();
            if (cuuid == BleUuids.CHAR_METRIC_1) {
              await _subscribeCharacteristic(c, _metric1);
            } else if (cuuid == BleUuids.CHAR_METRIC_2) {
              await _subscribeCharacteristic(c, _metric2);
            } else if (cuuid == BleUuids.CHAR_METRIC_3) {
              await _subscribeCharacteristic(c, _metric3);
            }
          }
        }
      }

      _connectedDevice?.state.listen((st) {
        if (st == BluetoothDeviceState.disconnected) {
          _connectionState.add('Desconectado');
          _cleanupConnection();
        }
      });

      _connectionState.add('Suscrito a notificaciones');
    } catch (e) {
      _connectionState.add('Error conexión: $e');
      _cleanupConnection();
    }
  }

  Future<void> _subscribeCharacteristic(BluetoothCharacteristic c, StreamController<int> out) async {
    try {
      await c.setNotifyValue(true);
      c.value.listen((bytes) {
        if (bytes.isEmpty) return;
        final val = _decodeInt32LE(bytes);
        out.add(val);
      });
    } catch (e) {
      _connectionState.add('Error subcripción ${c.uuid}: $e');
    }
  }

  int _decodeInt32LE(List<int> bytes) {
    final b = Uint8List.fromList(bytes);
    final bd = ByteData.sublistView(b);
    try {
      return bd.getInt32(0, Endian.little);
    } catch (_) {
      // Si el payload es menor, intentar leer como unsigned byte
      if (b.isNotEmpty) return b[0];
      return 0;
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (_) {}
    }
    _cleanupConnection();
  }

  void _cleanupConnection() {
    _connectedDevice = null;
    _connectionState.add('Desconectado');
  }

  void dispose() {
    _scanSub?.cancel();
    _connectionState.close();
    _metric1.close();
    _metric2.close();
    _metric3.close();
  }
}
