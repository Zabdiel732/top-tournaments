# TV PWA — Top Tournaments

Instrucciones para ejecutar la PWA (Smart TV) y conectar con Firebase Firestore.

1) Instalar dependencias y servir localmente

```bash
cd tv_pwa
npm install   # si no lo hiciste
npx serve .   # abre http://localhost:3000
```

2) Configurar Firebase

- El archivo `index.html` ya incluye la configuración web de Firebase en la constante `firebaseConfig`.
- No subas credenciales a GitHub. Para cambiar el proyecto, edita `index.html` y actualiza `firebaseConfig` con tus valores.
- Activa Cloud Firestore en la consola de Firebase (modo prueba para desarrollo).

3) Verificar Service Worker y modo Offline

- Abre Chrome en la URL de la PWA.
- Abre DevTools → Application → Service Workers: verifica que `sw.js` esté registrado.
- En DevTools → Network marca `Offline` y recarga; la interfaz base debe cargar desde cache.

4) Pruebas básicas

- La PWA escucha el documento `ecosystem/current` en Firestore y actualiza los valores `ritmo` y `pasos`.
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
