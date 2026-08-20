import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  
  // R4: Escritura reactiva en Firestore
  Future<void> syncWithTV(int ritmo, int pasos) async {
    await FirebaseFirestore.instance.collection('ecosystem').doc('current').set({
      'ritmo': ritmo,
      'pasos': pasos,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // R2: Suscripción a notificaciones BLE
  void subscribeToWearable(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen((value) {
      // Parsear los bytes recibidos (ejemplo simplificado)
      int ritmoCardiaco = value.isNotEmpty ? value[0] : 0;
      
      setState(() {
        connectionState = "Conectado recibiendo datos...";
      });
      
      syncWithTV(ritmoCardiaco, 100); // Enviar a Firestore
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
        textTheme: const TextTheme(bodyText2: TextStyle(color: Colors.white)),
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

                  // Escanear durante 5s y conectar al primer dispositivo encontrado
                  final flutterBlue = FlutterBluePlus.instance;
                  BluetoothDevice? target;
                  try {
                    await flutterBlue.startScan(timeout: const Duration(seconds: 5));
                    flutterBlue.scanResults.listen((results) async {
                      for (var r in results) {
                        final d = r.device;
                        if (d.name.isNotEmpty) {
                          target = d;
                          break;
                        }
                      }
                      if (target != null) {
                        await flutterBlue.stopScan();
                        setState(() { connectionState = 'Conectando a ${target!.name}'; });
                        await target!.connect(timeout: const Duration(seconds: 10));
                        setState(() { connectionState = 'Descubriendo servicios...'; });
                        final services = await target!.discoverServices();
                        for (var s in services) {
                          for (var c in s.characteristics) {
                            if (c.properties.notify) {
                              setState(() { connectionState = 'Suscribiendo a característica'; });
                              subscribeToWearable(c);
                              return;
                            }
                          }
                        }
                        setState(() { connectionState = 'Conectado pero sin característica NOTIFY encontrada'; });
                      }
                    });
                  } catch (e) {
                    setState(() { connectionState = 'Error BLE: $e'; });
                  } finally {
                    await flutterBlue.stopScan();
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