# TV PWA — Top Tournaments

Instrucciones para ejecutar la PWA (Smart TV) y conectar con Firebase Firestore.

1) Servir localmente

```bash
cd tv_pwa
npx serve .   # abre la URL indicada, por ejemplo http://localhost:3000
```

2) Configurar Firebase

- `app.js` inicializa Firebase y escucha `ecosystem/current` con `onSnapshot()`.
- La clave web de Firebase identifica la aplicación; la protección real depende de reglas Firestore y no debe confundirse con una credencial privada.
- Activa Cloud Firestore y la API Firestore en la consola de Firebase.

3) Verificar Service Worker y modo Offline

- Abre Chrome en la URL de la PWA.
- Abre DevTools → Application → Service Workers: verifica que `sw.js` esté registrado.
- En DevTools → Network marca `Offline` y recarga; la interfaz base debe cargar desde cache.

4) Pruebas básicas

- La PWA escucha el documento `ecosystem/current` en Firestore y actualiza `ritmo`, `pasos` y `calorias` sin recargar.
- Las flechas mueven el foco entre las cuatro tarjetas; `Enter`/`OK` selecciona la tarjeta enfocada.
- Si Firestore no está disponible, se conserva el último dato en `localStorage` y se muestra el estado offline.
- Para probar, ejecuta la app móvil y escribe en Firestore el documento `ecosystem/current`.

```
// Estructura del documento ejemplo
{
  ritmo: 78,
  pasos: 123,
  timestamp: <serverTimestamp>
}
```

5) Evidencias a capturar

- Captura del Service Worker activo.
- Captura de la PWA funcionando con Network → Offline.
- Captura del documento Firestore actualizado y la PWA reflejando los cambios.
