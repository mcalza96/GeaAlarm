# Guía de Generación de APK - GeoAlarm

Esta guía detalla los pasos para generar un APK optimizado para pruebas de campo en Android.

## 1. Requisitos Previos
- Flutter SDK instalado y configurado en el PATH.
- Android SDK instalado.
- Dispositivo Android con "Depuración USB" y "Fuentes Desconocidas" habilitadas.

## 2. Comando de Compilación
Ejecuta el siguiente comando en la raíz del proyecto para generar APKs específicos por arquitectura (más ligeros):

```bash
flutter build apk --release --split-per-abi
```

## 3. Ubicación del Archivo
Una vez que la compilación termine, los archivos APK se encontrarán en:
`build/app/outputs/flutter-apk/`

Verás archivos como:
- `app-armeabi-v7a-release.apk` (Para móviles antiguos/gama media)
- `app-arm64-v8a-release.apk` (Para móviles modernos de 64 bits)
- `app-x86_64-release.apk` (Para emuladores o dispositivos específicos)

## 4. Instalación
1. Copia el archivo `.apk` correspondiente a tu celular (vía USB o servicio de archivos).
2. Abre el archivo en el móvil y acepta la instalación de "Fuentes Desconocidas" si se solicita.
3. Asegúrate de otorgar todos los permisos de ubicación ("Permitir todo el tiempo") al abrir la app.

## 5. Checklist de Verificación de Campo
- [ ] ¿Suena la alarma con la pantalla bloqueada?
- [ ] ¿El log en "Developer Mode" registra la entrada a la geocerca?
- [ ] ¿La notificación es visible en el panel superior?
- [ ] ¿El consumo de batería es aceptable tras 30 min de viaje?
