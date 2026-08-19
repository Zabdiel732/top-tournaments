import 'dart:async';
import 'package:flutter/foundation.dart';

enum BleState { buscando, conectado, error, desconectado }

class ActivityProvider extends ChangeNotifier {
  BleState _state = BleState.desconectado;
  int _heartRate = 0;
  int _steps = 0;
  int _matchSeconds = 0;
  bool _hasCriticalAlert = false;

  BleState get state => _state;
  int get heartRate => _heartRate;
  int get steps => _steps;
  int get matchSeconds => _matchSeconds;
  bool get hasCriticalAlert => _hasCriticalAlert;

  void simulateBleConnection() {
    _state = BleState.buscando;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      _state = BleState.conectado;
      notifyListeners();

      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_state != BleState.conectado) {
          timer.cancel();
          return;
        }
        _heartRate = 120 + (timer.tick % 30);
        _steps += 2;
        _matchSeconds = timer.tick;
        _hasCriticalAlert = _heartRate > 140; 
        notifyListeners();
      });
    });
  }
}