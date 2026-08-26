Guía: usar un teléfono Android con nRF Connect como peripheral (advertising)
=====================================================================

Objetivo: demostrar advertising + GATT Server (3 características notificables) usando un teléfono Android con la app "nRF Connect" como peripheral, y recibir NOTIFY en la app `mobile_app`.

Requisitos
- Un teléfono Android (dispositivo A) con Google Play (para instalar nRF Connect).
- Tu teléfono de pruebas (dispositivo B) o emulador donde ejecutar `mobile_app`.
- El ordenador con ADB y Flutter configurados.
- Rama Git: `extraordinario` (ya creada).

Pasos en el dispositivo A (nRF Connect) — crear peripheral
1. Instala "nRF Connect for Mobile" desde Google Play.
2. Abre la app → ve a la sección "Advertiser" o "Peripheral" (según versión).
3. Crea un nuevo peripheral / advertisement y configúralo así:
   - Service UUID: `0000ff00-0000-1000-8000-00805f9b34fb`
   - Característica 1: `0000ff01-0000-1000-8000-00805f9b34fb` — Propiedades: Notify — Tamaño: 4 bytes (Int32 LE)
   - Característica 2: `0000ff02-0000-1000-8000-00805f9b34fb` — Propiedades: Notify — Tamaño: 4 bytes
   - Característica 3: `0000ff03-0000-1000-8000-00805f9b34fb` — Propiedades: Notify — Tamaño: 4 bytes
   - Descriptor CCCD: `00002902-0000-1000-8000-00805f9b34fb` (si la app lo solicita, añádelo)
4. Inicia el advertising (Start). Guarda el perfil si quieres repetirlo.

Pasos en el ordenador / dispositivo B (cliente)
1. Conecta el dispositivo B por USB y verifica ADB:
```powershell
adb devices
```
2. Concede permisos (Android 12+) a la app `mobile_app` (paquete `com.toptournaments.mobile_app`):
```powershell
adb -s <serial_B> shell pm grant com.toptournaments.mobile_app android.permission.BLUETOOTH_SCAN
adb -s <serial_B> shell pm grant com.toptournaments.mobile_app android.permission.BLUETOOTH_CONNECT
adb -s <serial_B> shell pm grant com.toptournaments.mobile_app android.permission.ACCESS_FINE_LOCATION
```
3. Ejecuta la app cliente en el dispositivo B (o emulador):
```powershell
cd "c:\Users\jesus\Desktop\Top Tournaments\mobile_app"
flutter run -d <device_id_B>
```
4. En la app presiona `Conectar Wearable`. La app escaneará filtrando por el Service UUID y se conectará al peripheral nRF Connect.

Capturar evidencias (logs + vídeo)
- Registra pantalla del dispositivo B mostrando la UI con métricas actualizándose.
- Captura logcat para guardar eventos BLE y mensajes debug:
```powershell
adb -s <device_id_B> logcat > evidencias/logcat_mobile_app.txt
# (Ctrl+C para parar, o redirige con timeout y luego comprime)
```
- Filtra en tiempo real por nuestras líneas debug (si usas Windows):
```powershell
adb -s <device_id_B> logcat | findstr "TopTournamentsBLE"
```

Checklist de evidencia (para el documento formal)
- E1-EV01: Wear OS / peripheral inicia advertising (captura de nRF Connect mostrando SERVICE UUID).
- E2-EV02: mobile_app detecta advertising y conecta (video + logcat mostrando conexión y descubrimiento).
- E2-EV03: mobile_app recibe NOTIFY en las 3 características (video UI + logcat con valores decodificados Int32 LE).
- E4-EV01: mobile_app escribe en Firestore (captura consola Firebase / onSnapshot en PWA si ya está preparada).

Notas reproducibles
- Si el emulador Android no detecta advertising, usa un teléfono físico como cliente B.
- Incluye en el documento la nota: "Se usó nRF Connect como peripheral por limitaciones del Android Emulator para advertising/GATT server".

Soporte
- Si quieres, puedo preparar un pequeño script PowerShell para automatizar la captura de `adb logcat` y la grabación rápida.

*** Fin de la guía NRF ***
