import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble/uuids.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MobileApp());
}

class MobileApp extends StatefulWidget {
  const MobileApp({super.key});
  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  String connectionState = "Desconectado";
  BluetoothDevice? connectedDevice;
  bool _isConnecting = false;
  int pasos = 0;
  int ritmo = 0;
  int calorias = 0;
  
  // R4: Escritura reactiva en Firestore
  Future<void> syncWithTV(int ritmo, int pasos) async {
    await FirebaseFirestore.instance.collection('ecosystem').doc('current').set({
      'ritmo': ritmo,
      'pasos': pasos,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // R2: Suscripción a notificaciones BLE
  Future<void> subscribeToWearable(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    debugPrint('TopTournamentsBLE: subscribed to ${characteristic.uuid}');
    characteristic.lastValueStream.listen((value) async {
      if (value.isEmpty) return;
      // Decodificar Int32 little-endian
      int parsed = 0;
      try {
        parsed = value.length >= 4
            ? (value[0] & 0xFF) | ((value[1] & 0xFF) << 8) | ((value[2] & 0xFF) << 16) | ((value[3] & 0xFF) << 24)
            : value[0];
      } catch (e) {
        parsed = value[0];
      }

      final cuuid = characteristic.uuid.toString().toLowerCase();
      debugPrint('TopTournamentsBLE: notify from $cuuid -> $parsed');
      setState(() {
        connectionState = "Conectado recibiendo datos...";
        if (cuuid == BleUuids.CHAR_METRIC_1) {
          pasos = parsed;
        } else if (cuuid == BleUuids.CHAR_METRIC_2) {
          ritmo = parsed;
        } else if (cuuid == BleUuids.CHAR_METRIC_3) {
          calorias = parsed;
        }
      });

      // Enviar conjunto de métricas a Firestore (si alguna es 0, se usa el valor actual)
      await FirebaseFirestore.instance.collection('ecosystem').doc('current').set({
        'ritmo': ritmo,
        'pasos': pasos,
        'calorias': calorias,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F2027)),
        primaryColor: const Color(0xFF0F2027),
        scaffoldBackgroundColor: const Color(0xFF0F2027),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F2027)),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFFC107), foregroundColor: Colors.black)),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Image.asset('assets/images/logo.png', width:36, height:36),
            const SizedBox(width:12),
            const Text('Top Tournaments Hub')
          ]),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Estado BLE: $connectionState'),
              const SizedBox(height: 12),
              Text('Pasos: $pasos', style: const TextStyle(color: Colors.white, fontSize: 18)),
              Text('Ritmo: $ritmo', style: const TextStyle(color: Color(0xFFFFC107), fontSize: 18)),
              Text('Calorías: $calorias', style: const TextStyle(color: Color(0xFF203A43), fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  setState(() { connectionState = 'Buscando dispositivos...'; });
                  // Solicitar permisos necesarios
                  if (await Permission.bluetoothScan.request().isDenied) {
                    setState(() { connectionState = 'Permiso de escaneo denegado'; });
                    return;
                  }
                  if (await Permission.bluetoothConnect.request().isDenied) {
                    setState(() { connectionState = 'Permiso de conexión denegado'; });
                    return;
                  }
                  if (await Permission.location.request().isDenied) {
                    setState(() { connectionState = 'Permiso de ubicación denegado'; });
                    return;
                  }

                  // Esperar resultados reales antes de detener el escaneo.
                  if (_isConnecting || connectedDevice != null) {
                    setState(() { connectionState = 'Ya existe una conexión activa'; });
                    return;
                  }
                  _isConnecting = true;
                  StreamSubscription<List<ScanResult>>? scanSubscription;
                  try {
                    final foundDevice = Completer<BluetoothDevice>();
                    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
                      for (var r in results) {
                        // comprobar si el advertising contiene el service UUID
                        final adv = r.advertisementData;
                        if (adv.serviceUuids.contains(Guid(BleUuids.SERVICE))) {
                          if (!foundDevice.isCompleted) {
                            foundDevice.complete(r.device);
                          }
                          break;
                        }
                      }
                    });
                    await FlutterBluePlus.startScan(
                      withServices: [Guid(BleUuids.SERVICE)],
                      timeout: const Duration(seconds: 10),
                    );
                    final found = await foundDevice.future.timeout(
                      const Duration(seconds: 10),
                      onTimeout: () => throw TimeoutException('No se encontró el servicio BLE esperado'),
                    );
                    await FlutterBluePlus.stopScan();
                    setState(() { connectionState = 'Conectando a ${found.platformName.isNotEmpty ? found.platformName : found.remoteId.str}'; });
                    await found.connect(license: License.nonprofit);
                    connectedDevice = found;
                    found.connectionState.listen((state) {
                      if (!mounted || state != BluetoothConnectionState.disconnected) return;
                      setState(() {
                        connectionState = 'Wearable desconectado';
                        connectedDevice = null;
                      });
                    });
                    setState(() { connectionState = 'Descubriendo servicios...'; });
                    final services = await found.discoverServices();
                    for (final service in services) {
                      debugPrint('TopTournamentsBLE: discovered service ${service.uuid}');
                    }
                    int subscribedCount = 0;
                    for (var s in services) {
                      if (s.uuid.toString().toLowerCase() == BleUuids.SERVICE) {
                        for (var c in s.characteristics) {
                          final cuuid = c.uuid.toString().toLowerCase();
                          if ((cuuid == BleUuids.CHAR_METRIC_1 || cuuid == BleUuids.CHAR_METRIC_2 || cuuid == BleUuids.CHAR_METRIC_3) && c.properties.notify) {
                            await subscribeToWearable(c);
                            subscribedCount++;
                          }
                        }
                      }
                    }
                    setState(() {
                      connectionState = subscribedCount == 3
                          ? 'Conectado recibiendo datos...'
                        : 'Servicio FF00 no encontrado o faltan NOTIFY ($subscribedCount/3)';
                    });
                  } catch (e) {
                    setState(() { connectionState = 'Error BLE: $e'; });
                  } finally {
                    await scanSubscription?.cancel();
                    if (FlutterBluePlus.isScanningNow) {
                      await FlutterBluePlus.stopScan();
                    }
                    _isConnecting = false;
                  }
                },
                child: const Text('Conectar Wearable'),
              )
            ],
          ),
        ),
      ),
    );
  }
}