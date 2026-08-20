import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// Nota: Para actuar como periférico BLE, necesitarás configurar un paquete como 'flutter_ble_peripheral'
// Aquí se implementa la lógica visual y de simulación de datos exigida.

void main() => runApp(const WearableApp());

class WearableApp extends StatelessWidget {
  const WearableApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F2027),
        textTheme: const TextTheme(bodyText2: TextStyle(color: Colors.white)),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F2027)),
      ),
      home: const WearableScreen(),
    );
  }
}

class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key});
  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> {
  bool isRunning = false;
  int pasos = 0;
  int ritmo = 70;
  int calorias = 0;
  Timer? _timer;

  void _toggleSimulation() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            pasos += Random().nextInt(3);
            ritmo = 70 + Random().nextInt(40);
            calorias += 1;
            // Aquí llamarías a tu método BLE para enviar los datos (GATT NOTIFY)
            // blePeripheral.sendData(characteristicUUID, data);
          });
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header with logo
            Padding(
              padding: const EdgeInsets.only(bottom:16.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset('assets/images/logo.png', width:28, height:28),
                const SizedBox(width:8),
                const Text('Top Tournaments', style: TextStyle(color: Colors.white, fontSize:16))
              ]),
            ),
            Text('Pasos: $pasos', style: const TextStyle(color: Colors.white, fontSize:18)),
            Text('Ritmo: $ritmo bpm', style: const TextStyle(color: Color(0xFFFFC107), fontSize:18)),
            Text('Calorías: $calorias', style: const TextStyle(color: Color(0xFF203A43), fontSize:18)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _toggleSimulation,
              child: Text(isRunning ? 'Detener' : 'Iniciar'),
            ),
          ],
        ),
      ),
    );
  }
}