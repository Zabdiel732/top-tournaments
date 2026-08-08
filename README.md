# Top Tournaments - Ecosistema Multi-Dispositivo

**Estudiante**: Jesús Zabdiel Hernández Martínez  
**Asignatura**: Desarrollo para Dispositivos Inteligentes (Mayo-Agosto 2026)

## Instrucciones para Ejecución Simultánea (Demo 5 Minutos)

### 1. Módulo Wear OS (Smartwatch)
```bash
cd wearable_app
flutter run -d wear_os_emulator
cd mobile_app
flutter run -d phone_emulator
cd tv_pwa
npx http-server -p 8080
# Abrir Chrome en http://localhost:8080 y activar modo TV (1920x1080)
---

## 🚀 Paso 6: Ejecución y Demo Simultánea

Para la presentación en vivo de 5 minutos, debes iniciar los tres módulos en paralelo en tu equipo[cite: 2]:

```bash
# Terminal 1: Iniciar Wear OS
cd wearable_app && flutter run

# Terminal 2: Iniciar App Móvil
cd mobile_app && flutter run

# Terminal 3: Servir PWA
cd tv_pwa && npx http-server -p 8080
