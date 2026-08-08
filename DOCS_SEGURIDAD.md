# Documentación de Seguridad - Top Tournaments

## 1. Validación de Origin en BroadcastChannel
Para mitigar ataques de Cross-Site Scripting (XSS) e inyección de datos, las comunicaciones locales entre ventanas verifican estrictamente el atributo `event.origin`:
```javascript
const channel = new BroadcastChannel('top_tournaments_sync');
channel.onmessage = (event) => {
  if (event.origin !== window.location.origin) return;
  // Procesar payload validado
};
### 5.2 `PLAN_PRUEBAS.md` (`SA.5`)[cite: 2]
```bash
cat << 'EOF' > PLAN_PRUEBAS.md
# Plan y Reporte de Pruebas - Nivel SA (10 Casos)

| ID | Módulo | Caso de Prueba | Resultado Esperado | Estatus |
|---|---|---|---|---|
| P2.5 | Móvil | Carga de datos reales desde la API | Muestra registros correctamente o mensaje de error en red | Aprobado |
| P2.6 | Wearable | Transmisión BLE NOTIFY | Emite datos cada segundo sin pérdida de paquetes | Aprobado |
| P3.1 | Smart TV | Navegación Flecha Derecha D-pad | Cambia el foco de la tarjeta 0 a la tarjeta 1 | Aprobado |
| P3.2 | Smart TV | Navegación Flecha Abajo D-pad | Cambia el foco de la tarjeta 0 a la tarjeta 2 | Aprobado |
| P3.3 | Smart TV | Acción Tecla Enter / OK | Dispara el evento de selección y resalta el elemento | Aprobado |
| P3.4 | Smart TV | Manejo de bordes del Grid | El foco no se rompe ni desparece al llegar al límite | Aprobado |
| PWA.1| Smart TV | Ejecución Modo Offline | Carga interfaz desde caché vía Service Worker | Aprobado |
| BLE.1| Móvil | Desconexión repentina BLE | Muestra estado "Desconectado" sin crashear la app | Aprobado |
| SAF.1| Smart TV | Cumplimiento Safe Zone 5% | Todo el contenido visible sin tocar bordes en 1080p | Aprobado |
| ALT.1| Móvil | Umbral de Alerta FC > 140 bpm | Despliega banner rojo indicando alerta crítica | Aprobado |
