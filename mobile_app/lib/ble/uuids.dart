// UUIDs BLE compartidos para Top Tournaments
class BleUuids {
  // Servicio principal (use 128-bit UUID para evitar colisiones)
  static const String SERVICE = '0000ff00-0000-1000-8000-00805f9b34fb';

  // Características notificables (3 métricas)
  static const String CHAR_METRIC_1 = '0000ff01-0000-1000-8000-00805f9b34fb';
  static const String CHAR_METRIC_2 = '0000ff02-0000-1000-8000-00805f9b34fb';
  static const String CHAR_METRIC_3 = '0000ff03-0000-1000-8000-00805f9b34fb';

  // CCCD estándar
  static const String CCCD = '00002902-0000-1000-8000-00805f9b34fb';
}
