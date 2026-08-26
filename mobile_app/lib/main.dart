import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ble/client.dart';


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
  int metric1 = 0;
  int metric2 = 0;
  int metric3 = 0;

  // R4: Escritura reactiva en Firestore (envía las 3 métricas)
  Future<void> syncWithTV(int ritmo, int pasos, int calorias) async {
    await FirebaseFirestore.instance.collection('ecosystem').doc('current').set({
      'ritmo': ritmo,
      'pasos': pasos,
      'calorias': calorias,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void initState() {
    super.initState();
    // Subscribir a streams del cliente BLE
    BleClient.instance.connectionStateStream.listen((s) {
      setState(() { connectionState = s; });
    });
    BleClient.instance.metric1Stream.listen((v) {
      setState(() { metric1 = v; });
      syncWithTV(metric2, metric1, metric3);
    });
    BleClient.instance.metric2Stream.listen((v) {
      setState(() { metric2 = v; });
      syncWithTV(metric2, metric1, metric3);
    });
    BleClient.instance.metric3Stream.listen((v) {
      setState(() { metric3 = v; });
      syncWithTV(metric2, metric1, metric3);
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() { connectionState = 'Buscando dispositivos...'; });
                      // Solicitar permisos
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

                      await BleClient.instance.startScanAndConnect();
                    },
                    child: const Text('Conectar Wearable'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await BleClient.instance.disconnect();
                    },
                    child: const Text('Desconectar'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}