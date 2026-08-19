import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class WearableBleServer extends ChangeNotifier {
  // UUIDs constantes
  static const String serviceUUID = "0000180D-0000-1000-8000-00805F9B34FB";
  
  bool _isGenerating = false;
  Timer? _timer;

  int _heartRate = 110;
  int _steps = 1200;
  int _matchSeconds = 0;

  bool get isGenerating => _isGenerating;
  int get heartRate => _heartRate;
  int get steps => _steps;
  int get matchSeconds => _matchSeconds;

  void toggleGeneration() {
    _isGenerating = !_isGenerating;
    if (_isGenerating) {
      // Simulación de datos cada segundo
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _heartRate = 100 + Random().nextInt(50);
        _steps += Random().nextInt(5);
        _matchSeconds++;
        notifyListeners(); // Activa la notificación BLE 
      });
    } else {
      _timer?.cancel();
    }
    notifyListeners();
  }
}