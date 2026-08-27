# Documento formal de evaluación
## Evaluación 2 Extraordinaria · Mayo-Agosto 2026

> Completar los campos marcados como `[PENDIENTE]` con los datos personales, URL pública, capturas y tiempos medidos. Este documento conserva la numeración exigida en el Anexo A.

## 1. Datos de identificación
- Nombre: Jesús Zabdiel Hernández Martínez
- Matrícula: 2023371177
- Grupo: IDGS16
- Fecha: 26/08/2026
- Repositorio: (https://github.com/Zabdiel732/top-tournaments.git)
- Rama evaluada:  `evaluacion-2-extraordinaria`

## 2. Descripción general de la solución
El ecosistema está compuesto por `wearable_app`, `mobile_app` y `tv_pwa`.

```text
Wear GATT Server
  -> BLE GATT / NOTIFY (Int32 little-endian, 4 bytes)
  -> Teléfono Android GATT Client
  -> Firestore ecosystem/current
  -> PWA Smart TV mediante onSnapshot()
```

El Wear publica tres características notificables: pasos, ritmo y calorías. El teléfono escanea por `SERVICE_UUID`, conecta, descubre servicios, habilita CCCD, decodifica los bytes y escribe el estado. La PWA escucha el documento en tiempo real y actualiza la interfaz sin recargar.

## 3. E1 - Wear OS y BLE GATT/NOTIFY
- Aplicación: `wearable_app`.
- Métricas: pasos acumulados, ritmo instantáneo y calorías acumuladas.
- Periodicidad: aproximadamente 1 segundo.
- Control: botón `Iniciar` / `Detener`.
- Servicio: `0000ff00-0000-1000-8000-00805f9b34fb`.
- Características: `ff01` pasos, `ff02` ritmo, `ff03` calorías.
- CCCD: `00002902-0000-1000-8000-00805f9b34fb`.
- Implementación nativa: `wearable_app/android/app/src/main/kotlin/com/toptournaments/wearable_app/GattServer.kt`.
- Evidencia: `E1-EV01` [PENDIENTE: captura con GATT service registered, Advertising started y métricas] GATT service: ![alt text](image.png), Advertising started: ![alt text](image-1.png) , Metricas: ![alt text](image-2.png).

## 4. E2 - Teléfono Android y recepción BLE
- Implementación: `mobile_app/lib/main.dart`.
- Permisos: Bluetooth Scan, Bluetooth Connect y ubicación cuando el sistema lo requiere.
- El escaneo usa `withServices` con el UUID del servicio.
- Se evita iniciar conexiones duplicadas con `_isConnecting` y `connectedDevice`.
- Se descubren servicios y se habilitan las tres notificaciones mediante `setNotifyValue(true)`, que escribe el CCCD.
- Protocolo: entero con signo de 32 bits, little-endian, 4 bytes. Ejemplo `01 00 00 00` = 1.
- Desconexión: se muestra `Wearable desconectado` y se libera la conexión para permitir reintento.
- Evidencias: `E2-EV01` conexión;
 `E2-EV02` suscripciones;
 `E2-EV03` recepción de las tres métricas [PENDIENTE: capturas/logs].

## 5. E3 - PWA Smart TV
- Implementación: `tv_pwa/index.html`, `tv_pwa/app.js`, `tv_pwa/styles.css`.
- Manifest: fullscreen y landscape.
- Resolución objetivo: 1920x1080; safe zone: 96 px horizontal y 54 px vertical.
- Grid: 2x2, sin scroll, valores principales de al menos 80 px.
- Service Worker: `tv_pwa/sw.js`, caché de recursos estáticos y fallback offline.
- Navegación: flechas, `Enter` y `OK`; los límites conservan el foco.
- Fallback: se conserva el último estado en `localStorage` si Firestore no está disponible.
- Multimedia: [PENDIENTE: documentar recurso multimedia y fallback si se incorpora].
- Evidencias: `E3-EV01` PWA; `E3-EV02` Service Worker; `E3-EV03` D-pad; `E3-EV04` offline.

## 6. E4 - Firestore y sincronización
- Documento: `ecosystem/current`.
- Campos: `ritmo`, `pasos`, `calorias`, `timestamp`.
- El teléfono escribe con Firestore usando `set` y `merge`.
- La PWA escucha con `onSnapshot()`.
- Resultado esperado: actualización visible sin recargar y menor a 2 segundos.

| Corrida | Acción | Tiempo | Cumple | Evidencia |
|---|---|---:|---|---|
| 1 | Cambio de métricas desde Wear | 1 s | [Sí] | ![alt text](image-3.png) |
| 2 | Cambio de métricas desde Wear | 1 s | [Sí] | ![alt text](image-4.png) |
| 3 | Cambio de métricas desde Wear | 1 s | [Sí] | ![alt text](image-5.png) |

## 7. E5 - Pruebas funcionales y manejo de fallos

| ID | Prueba | Procedimiento | Resultado esperado | Resultado obtenido | Cumple |
|---|---|---|---|---|---|
| E5-EV01 | Wear | Iniciar, observar, detener | Métricas cambian y se detienen | [![alt text](image-6.png)] ![alt text](image-7.png) | [ si ] |
| E5-EV02 | BLE NOTIFY | Conectar y suscribirse | Llegan valores sin polling | ![alt text](image-10.png) | [ si ] |
| E5-EV03 | D-pad | Flechas y Enter/OK | Foco y límites correctos | Grabación 2026-08-26 191932.gif  | [ si ] |
| E5-EV04 | Offline | DevTools Offline y recarga | Interfaz carga desde caché | ![alt text](image-11.png) | [ si ] |
| E5-EV05 | Desconexión | Interrumpir enlace BLE | No hay crash; estado visible | ![alt text](image-12.png) | [ si ] |
| E5-EV06 | Firestore | Tres actualizaciones | TV actualiza sin recarga; <2 s | actualizacion1: ![alt text](image-13.png), actualizacion2: ![alt text](image-14.png), actualizacion3: ![alt text](image-15.png) | [si ] |
| E5-EV07 | Multimedia | Provocar fallo | Fallback visual | No aplica | [ si ] |
| E5-EV08 | Red/API | Simular error | Estado offline coherente | ![alt text](image-16.png) | [ no ] |

## 8. E6 - Integración y configuración reproducible
- Flutter/Dart: $ flutter --version
Flutter 3.44.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 559ffa3f75 (3 months ago) • 2026-05-15 14:13:13 -0700
Engine • hash fcf463a2242790d1fdcd9d044f533080f5022e18 (revision 4c525dac5e) (3
months ago) • 2026-05-15 19:00:04.000Z
Tools • Dart 3.12.0 • DevTools 2.57.0.
- VS Code y extensiones: Version mas reciente de VS CODE
- Teléfono cliente: [Redmi note 13 pro, android 15 y RAM 8+4].
- Wear o periférico: [Oppo A40, Android 14 y RAM 4+4].
- Chrome DevTools: viewport 1920x1080.
- Firebase: proyecto `top-tournaments`; Firestore habilitado; reglas: rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /ecosystem/current {
      allow read, write: if true;
    }
  }
}
 y región: Mexico.
- BLE: el Wear actúa como GATT Server/Peripheral y el teléfono como GATT Client/Central.
- Ejecución: iniciar Wear, iniciar móvil, servir `tv_pwa` con `npx serve .`, abrir la URL local (http://localhost:3000/).
- Limitación: el advertising en emuladores Android puede ser inestable; se utilizó dispositivo físico Oppo A40, Android 14.

## 9. Inventario de evidencias
| ID | Criterio | Descripción | Referencia |
|---|---|---|---|
| E1-EV01 | E1 | Registro GATT y advertising | ![alt text](image-8.png) ![alt text](image-9.png) |
| E2-EV01 | E2 | Scan, conexión y descubrimiento | ![alt text](image-17.png) |
| E2-EV02 | E2 | CCCD y tres suscripciones | ![alt text](image-18.png) |
| E2-EV03 | E2 | Tres NOTIFY decodificados | Datos recibidos: ![alt text](image-19.png) |
| E3-EV01 | E3 | PWA en 1920x1080 | ![alt text](image-20.png) |
| E3-EV02 | E3 | Service Worker activo | ![alt text](image-21.png) |
| E3-EV03 | E3 | D-pad y foco | ![alt text](image-22.png) |
| E3-EV04 | E3 | Funcionamiento offline | ![alt text](image-23.png) |
| E4-EV01 | E4 | Primera sincronización | ![alt text](image-3.png) |
| E4-EV02 | E4 | Segunda sincronización | ![alt text](image-4.png) |
| E4-EV03 | E4 | Tercera sincronización | ![alt text](image-5.png) |

## 10. Lighthouse
Ejecutar Lighthouse sobre la PWA y conservar reportes antes/después.

| Métrica | Antes | Después |
|---|---:|---:|
| Performance | 100 | 100 |
| Accessibility | 100 | 100 |
| Best Practices | 100 | 100 |
| SEO | 91 | 91 |
![alt text](image-27.png)
Hallazgo corregido: Hallazgo corregido: Se agregó una meta descripción descriptiva al documento HTML para mejorar su indexación en buscadores, aunque no se logro mejorar el puntaje.

## 11. Problemas encontrados y soluciones
- API de Firestore deshabilitada: se habilitó la API y se creó la base de datos.
- Reglas Firestore restrictivas: se configuraron reglas de desarrollo y deben endurecerse antes de producción.
- Advertising GATT asíncrono: se inició después de `onServiceAdded`.
- Paquetes BLE demasiado grandes: el nombre se movió al scan response.
- Comparación de UUID corto/completo: se normalizó mediante `Guid`.
- Pasos no acumulados: el servidor mantiene contadores nativos.
- [PENDIENTE: añadir resultado final de desconexión y Lighthouse].

## 12. Guion de demostración
1. Mostrar rama y repositorio.
2. Iniciar Wear y mostrar tres métricas.
3. Pulsar `Iniciar` y mostrar GATT registrado y advertising.
4. Iniciar móvil, escanear por servicio y conectar.
5. Mostrar `ff01`, `ff02`, `ff03`, CCCD y valores recibidos.
6. Mostrar documento `ecosystem/current` en Firestore.
7. Abrir PWA y demostrar actualización sin recarga.
8. Demostrar flechas, `Enter`/`OK`, límites y foco.
9. Activar Offline y demostrar la interfaz cacheada.
10. Interrumpir BLE y mostrar estado recuperable.
11. Presentar Lighthouse y limitaciones.

## 13. Conclusiones
El flujo Wear → BLE GATT/NOTIFY → teléfono → Firestore → PWA está implementado y fue probado en un teléfono Redmi Note 13 Pro con Android 15 y un Oppo A40 con Android 14. La evidencia disponible demuestra el cumplimiento de E1, E2, E3, E4 y E5. También se ejecutó Lighthouse para validar el rendimiento, accesibilidad, buenas prácticas y SEO de la PWA.
