import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
      home: Scaffold(
        appBar: AppBar(title: const Text('Top Tournaments Hub')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Estado BLE: $connectionState'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Lógica de FlutterBluePlus para escanear y conectar
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