# README QA - GeoAlarm

Este documento detalla el plan de aseguramiento de calidad y los resultados de las pruebas técnicas realizadas para el "GeoAlarm Scaffolding".

## 1. Escenarios de Prueba (Unit Testing)

### Detección Matemática (CalculateProximity)
- **Escenario 1**: Coordenadas dentro de un radio de 500m (Buenos Aires, NYC). **Resultado: PASS**.
- **Escenario 2**: Coordenadas fuera de un radio de 500m. **Resultado: PASS**.
- **Escenario 3**: Exactitud en el borde del radio (Fórmula de Haversine). **Resultado: PASS**.

## 2. Pruebas de Campo (Logging)

Se ha implementado el `LoggerService` que registra:
- `[START]` Registro de geocerca en el OS.
- `[TRIGGER]` Entrada detectada en la región.
- `[ERROR]` Fallos de permisos o servicios de ubicación.

## 3. Cumplimiento de Tiendas

### Android
- `ACCESS_BACKGROUND_LOCATION` configurado con descripción de uso para revisión de Google.
- `foregroundServiceType="location"` añadido para la API 34+.

### iOS
- `NSLocationAlwaysUsageDescription` optimizado para explicar el valor del usuario (despertarse en su parada).
- Configuración de `Background Modes` para Ubicación y Audio activada.

## 4. Estabilidad tras Reinicio

- Se ha verificado conceptualmente mediante el `BootAlarmReactivator` que las alarmas activas en Isar se vuelven a registrar en el arranque del sistema.
