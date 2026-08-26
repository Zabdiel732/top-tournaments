import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Nota: El GATT Server nativo en Android se controla mediante MethodChannel 'toptournaments/gatt'.

void main() => runApp(const WearableApp());

class WearableApp extends StatelessWidget {
  const WearableApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F2027),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
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
  static const platform = MethodChannel('toptournaments/gatt');

  void _toggleSimulation() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        // Iniciar GATT Server nativo
        try {
          platform.invokeMethod('startGattServer');
        } catch (e) {
          // ignore
        }
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          // Actualizamos solo los valores (evitar trabajo pesado en main thread)
          pasos += Random().nextInt(3);
          ritmo = 70 + Random().nextInt(40);
          calorias += 1;
          // Solicitar rebuild ligero
          if (mounted) setState(() {});
        });
      } else {
        // Detener GATT Server nativo
        try {
          platform.invokeMethod('stopGattServer');
        } catch (e) {
          // ignore
        }
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Diseño responsivo para pantallas circulares 384x384
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final diameter = size.shortestSide; // ideal para círculo
    final padding = diameter * 0.06; // margen interior
    final titleSize = (diameter * 0.06).clamp(12.0, 20.0);
    final valueSize = (diameter * 0.12).clamp(16.0, 36.0);
    final labelSize = (diameter * 0.045).clamp(12.0, 24.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: Center(
        child: ClipOval(
          child: Container(
            width: diameter,
            height: diameter,
            color: Colors.black,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header (logo + title)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', width: diameter * 0.07, height: diameter * 0.07),
                      const SizedBox(width: 8),
                      Text('Top Tournaments', style: TextStyle(color: Colors.white, fontSize: titleSize)),
                    ],
                  ),

                  // Métricas principales en centro
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Pasos', style: TextStyle(color: Colors.white70, fontSize: labelSize)),
                        const SizedBox(height: 4),
                        Text('$pasos', style: TextStyle(color: Colors.white, fontSize: valueSize, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text('Ritmo', style: TextStyle(color: Colors.white70, fontSize: labelSize)),
                                Text('$ritmo bpm', style: TextStyle(color: const Color(0xFFFFC107), fontSize: labelSize, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(width: diameter * 0.08),
                            Column(
                              children: [
                                Text('Calorías', style: TextStyle(color: Colors.white70, fontSize: labelSize)),
                                Text('$calorias', style: TextStyle(color: const Color(0xFF203A43), fontSize: labelSize, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botón inferior
                  SizedBox(
                    width: diameter * 0.6,
                    child: ElevatedButton(
                      onPressed: _toggleSimulation,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
                      child: Text(isRunning ? 'Detener' : 'Iniciar', style: TextStyle(fontSize: labelSize)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}