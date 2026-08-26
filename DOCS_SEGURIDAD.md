# Documentación de Seguridad
## 1. Comunicaciones entre componentes
La solución no utiliza `BroadcastChannel`; el teléfono y la PWA se sincronizan exclusivamente mediante Firebase Cloud Firestore. La PWA restringe sus conexiones mediante CSP y no expone canales de comunicación entre ventanas.

## 2. Datos y finalidad
Datos recabados: métricas de actividad (`pasos`, `ritmo`, `calorias`) y la marca de tiempo de actualización. No se requiere nombre ni UID para el flujo técnico. La finalidad es mostrar el estado del ecosistema Wear-Teléfono-Smart TV durante la evaluación.

## 3. Conservación y protección
Los datos se almacenan en Firestore en el documento `ecosystem/current` y se conservan únicamente durante las pruebas, salvo que el responsable determine otro periodo. Firestore utiliza comunicaciones cifradas en tránsito. No se publican tokens, claves privadas, archivos `.env`, certificados ni keystores en el repositorio.

## 4. Aviso de privacidad
Responsable: Jesús Zabdiel Hernández Martínez, Querétaro, México. Los datos se tratarán exclusivamente para la demostración académica y estadísticas de actividad del prototipo. La persona titular puede solicitar acceso, rectificación, cancelación u oposición (derechos ARCO) contactando al responsable del proyecto. Para producción se debe implementar autenticación, reglas restringidas y un mecanismo formal de atención de solicitudes.
