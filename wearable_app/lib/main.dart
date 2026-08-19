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
    return const MaterialApp(home: WearableScreen());
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
            Text('Pasos: $pasos', style: const TextStyle(color: Colors.white)),
            Text('Ritmo: $ritmo bpm', style: const TextStyle(color: Colors.redAccent)),
            Text('Calorías: $calorias', style: const TextStyle(color: Colors.orange)),
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