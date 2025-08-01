# Sistema de Conversión FRAP - Documentación Técnica

## Tabla de Contenidos
1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Modelos de Datos](#modelos-de-datos)
4. [Servicios de Conversión](#servicios-de-conversión)
5. [Validación de Datos](#validación-de-datos)
6. [Migración y Sincronización](#migración-y-sincronización)
7. [Monitoreo de Performance](#monitoreo-de-performance)
8. [Guías de Uso](#guías-de-uso)
9. [Testing](#testing)
10. [Troubleshooting](#troubleshooting)

## Resumen Ejecutivo

El Sistema de Conversión FRAP es una solución robusta diseñada para manejar la conversión de datos entre modelos locales (Hive) y modelos de nube (Firestore) en la aplicación BG_Med. Este sistema garantiza la integridad de los datos durante las conversiones y proporciona herramientas completas para migración, sincronización y monitoreo.

### Características Principales
- ✅ **Conversión Bidireccional**: Local ↔ Nube
- ✅ **Validación Robusta**: Validación exhaustiva de datos en cada conversión
- ✅ **Migración Automática**: Sistema de migración gradual con progreso en tiempo real
- ✅ **Logging Detallado**: Sistema completo de logs para debugging
- ✅ **Monitoreo de Performance**: Métricas detalladas de rendimiento
- ✅ **Manejo de Errores**: Sistema robusto de manejo de errores y recuperación
- ✅ **Testing Completo**: Suite completa de tests unitarios e integración

## Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                    SISTEMA DE CONVERSIÓN FRAP               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────┐  │
│  │   Modelo Local  │◄──►│ Servicio Unif.  │◄──►│ Modelo  │  │
│  │     (Hive)      │    │                 │    │  Nube   │  │
│  │                 │    │  ┌───────────┐  │    │(Firest.)│  │
│  │ • Frap          │    │  │Conversion │  │    │         │  │
│  │ • Patient       │    │  │ Mapping   │  │    │• FrapFS │  │
│  │ • Insumo        │    │  └───────────┘  │    │         │  │
│  │ • PersonalMed   │    │                 │    │         │  │
│  │ • EscalasObs    │    │  ┌───────────┐  │    │         │  │
│  └─────────────────┘    │  │Data Valid.│  │    │         │  │
│                         │  └───────────┘  │    │         │  │
│                         │                 │    │         │  │
│                         │  ┌───────────┐  │    │         │  │
│                         │  │Migration  │  │    │         │  │
│                         │  │ Service   │  │    │         │  │
│                         │  └───────────┘  │    │         │  │
│                         └─────────────────┘    └─────────┘  │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                     CAPAS DE SOPORTE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Logging   │  │ Performance │  │Form Adapters│        │
│  │             │  │   Monitor   │  │             │        │
│  │• Conversion │  │             │  │• UI/Data    │        │
│  │• Validation │  │• Metrics    │  │  Bridge     │        │
│  │• Migration  │  │• Stats      │  │• Origin     │        │
│  │• Errors     │  │• Alerts     │  │  Detection  │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Modelos de Datos

### Comparación de Modelos

| Campo/Sección | Modelo Local (Frap) | Modelo Nube (FrapFirestore) | Notas |
|---------------|---------------------|------------------------------|-------|
| **Campos Básicos** |
| id | String | String? | |
| createdAt | DateTime | DateTime | |
| updatedAt | DateTime | DateTime | |
| userId | ❌ | ✅ String | Solo en nube |
| isSynced | ✅ bool | ❌ | Solo en local |

| **Datos del Paciente** |
| patient | ✅ Patient (tipado) | ❌ | Solo en local |
| patientInfo | ❌ | ✅ Map<String, dynamic> | Solo en nube |

| **Historia y Examen** |
| clinicalHistory | ✅ ClinicalHistory | ✅ Map<String, dynamic> | Tipado vs Map |
| physicalExam | ✅ PhysicalExam | ✅ Map<String, dynamic> | Tipado vs Map |

| **Campos Específicos Locales** |
| consentimientoServicio | ✅ String | ❌ | Solo en local |
| insumos | ✅ List<Insumo> | ❌ | Solo en local |
| personalMedico | ✅ List<PersonalMedico> | ❌ | Solo en local |
| escalasObstetricas | ✅ EscalasObstetricas? | ❌ | Solo en local |

| **Secciones Comunes** |
| serviceInfo | ✅ Map<String, dynamic> | ✅ Map<String, dynamic> | Común |
| management | ✅ Map<String, dynamic> | ✅ Map<String, dynamic> | Común |
| medications | ✅ Map<String, dynamic> | ✅ Map<String, dynamic> | Común |
| gynecoObstetric | ✅ Map<String, dynamic> | ✅ Map<String, dynamic> | Común |

### Modelo Local (Estándar)

El modelo local `Frap` es considerado el **estándar** del sistema por las siguientes razones:

1. **Tipado Fuerte**: Usa objetos tipados para mejor validación
2. **Completitud**: Incluye todos los campos necesarios para la aplicación
3. **Optimización Local**: Optimizado para almacenamiento local con Hive
4. **Control de Sincronización**: Incluye el campo `isSynced` para control

### Modelo Nube (Flexibilidad)

El modelo `FrapFirestore` está optimizado para:

1. **Flexibilidad**: Usa `Map<String, dynamic>` para evolución de esquema
2. **Escalabilidad**: Optimizado para Firestore
3. **Multi-usuario**: Incluye `userId` para separación de datos

## Servicios de Conversión

### FrapUnifiedService

Servicio principal que orquesta todas las operaciones de conversión y sincronización.

```dart
// Uso básico
final unifiedService = FrapUnifiedService(
  localService: frapLocalService,
  cloudService: frapFirestoreService,
);

// Guardar con sincronización automática
final result = await unifiedService.saveFrapRecord(frapData);

// Obtener registros unificados
final records = await unifiedService.getAllRecords();

// Sincronizar registros pendientes
final syncResult = await unifiedService.syncPendingRecords();
```

### FrapDataValidator

Servicio de validación que garantiza la integridad de los datos.

```dart
// Validar datos del paciente
final patientResult = FrapDataValidator.validatePatientData(patientData);
if (!patientResult.isValid) {
  print('Errores: ${patientResult.errors}');
  print('Advertencias: ${patientResult.warnings}');
}

// Validar insumos
final insumosResult = FrapDataValidator.validateInsumosData(insumosData);
final cleanedInsumos = insumosResult.cleanedData?['insumos'];
```

### FrapMigrationService

Servicio de migración automática con progreso en tiempo real.

```dart
final migrationService = FrapMigrationService(
  localService: localService,
  cloudService: cloudService,
);

// Escuchar progreso de migración
migrationService.progressStream.listen((progress) {
  print('Progreso: ${progress.percentage.toStringAsFixed(1)}%');
  print('Mensaje: ${progress.message}');
});

// Migrar nube a local
final result = await migrationService.migrateCloudToLocal();
print('Migrados: ${result.migratedRecords}/${result.totalRecords}');
```

## Validación de Datos

### Tipos de Validación

1. **Validación de Campos Requeridos**
   ```dart
   // Ejemplo: firstName es requerido
   if (patientData['firstName'] == null || 
       patientData['firstName'].toString().trim().isEmpty) {
     errors.add('Nombre del paciente es requerido');
   }
   ```

2. **Validación de Rangos**
   ```dart
   // Ejemplo: edad debe estar entre 0 y 150
   final age = int.tryParse(patientData['age'].toString());
   if (age == null || age < 0 || age > 150) {
     errors.add('Edad debe ser un número válido entre 0 y 150');
   }
   ```

3. **Validación de Formatos**
   ```dart
   // Ejemplo: formato de teléfono
   static bool _isValidPhone(String phone) {
     final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
     return phoneRegex.hasMatch(phone) && phone.length >= 7;
   }
   ```

### Resultado de Validación

```dart
class ValidationResult {
  final bool isValid;           // ¿Es válido?
  final List<String> errors;    // Errores críticos
  final List<String> warnings; // Advertencias
  final Map<String, dynamic>? cleanedData; // Datos limpiados
}
```

## Migración y Sincronización

### Modelo de Transición

El `FrapTransitionModel` actúa como puente entre modelos:

```dart
// Crear desde modelo local
final transition = FrapTransitionModel.fromLocal(localRecord);

// Crear desde modelo nube
final transition = FrapTransitionModel.fromCloud(cloudRecord);

// Migrar a estándar local
final localRecord = transition.migrateToLocalStandard();

// Migrar a formato nube
final cloudRecord = transition.migrateToCloudStandard();
```

### Estados de Migración

```dart
enum MigrationStatus {
  notStarted,    // No iniciada
  pending,       // Pendiente
  inProgress,    // En progreso
  completed,     // Completada
  failed,        // Fallida
}
```

### Estrategias de Conversión

1. **Nube → Local**: Prioriza la integridad y completitud
2. **Local → Nube**: Optimiza para flexibilidad y escalabilidad
3. **Manejo de Campos Faltantes**: Usa valores por defecto seguros
4. **Detección de Conflictos**: Compara por timestamp y datos críticos

## Monitoreo de Performance

### FrapPerformanceMonitor

Sistema completo de monitoreo de performance:

```dart
// Medir operación automáticamente
final result = await FrapPerformanceMonitor.measureOperation(
  'conversion_cloud_to_local',
  () async => convertCloudToLocal(cloudRecord),
  metadata: {'recordId': cloudRecord.id},
);

// Obtener estadísticas
final stats = FrapPerformanceMonitor.getPerformanceStats();
final conversionStats = FrapPerformanceMonitor.getConversionStats();
final syncStats = FrapPerformanceMonitor.getSyncStats();

// Detectar operaciones lentas
final slowOps = FrapPerformanceMonitor.detectSlowOperations(
  threshold: Duration(seconds: 5),
);
```

### Métricas Disponibles

1. **Estadísticas Generales**
   - Número total de operaciones
   - Tasa de éxito
   - Tiempo promedio, mínimo, máximo
   - Percentil 95

2. **Estadísticas de Conversión**
   - Conversiones nube→local vs local→nube
   - Tiempo promedio por tipo
   - Total de tiempo de conversión

3. **Estadísticas de Sincronización**
   - Sincronizaciones exitosas vs fallidas
   - Registros sincronizados por operación
   - Tiempo promedio de sincronización

## Guías de Uso

### Implementar Nueva Conversión

1. **Agregar Mapeo en FrapConversionMapping**
   ```dart
   static Map<String, String> newFieldMapping = {
     'localField': 'cloudField',
     // ...
   };
   ```

2. **Actualizar Validador**
   ```dart
   static ValidationResult validateNewData(Map<String, dynamic> data) {
     // Implementar validación
   }
   ```

3. **Actualizar Conversión en FrapUnifiedService**
   ```dart
   // Agregar lógica de conversión específica
   ```

### Usar Adaptadores de Formulario

```dart
// Detectar origen de datos
final origin = FrapFormAdapters.detectDataOrigin(data);

// Adaptar datos según origen
final adaptedData = FrapFormAdapters.adaptFrapRecord(record);

// Usar en formularios
final insumos = FrapFormAdapters.adaptInsumos(
  record.insumos, 
  isFromCloud: false
);
```

### Integrar en UI

```dart
class MyFormDialog extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    // Usar adaptadores para manejar datos híbridos
    final adaptedData = FrapFormAdapters.adaptFrapRecord(widget.record);
    
    return Form(
      child: Column(
        children: [
          // Campos de formulario usando adaptedData
        ],
      ),
    );
  }
}
```

## Testing

### Estructura de Tests

```
test/
├── core/
│   └── services/
│       ├── frap_conversion_test.dart      # Tests de conversión
│       ├── frap_data_validator_test.dart  # Tests de validación
│       └── frap_migration_test.dart       # Tests de migración
└── integration/
    └── frap_full_flow_test.dart          # Tests de integración
```

### Ejecutar Tests

```bash
# Tests unitarios
flutter test test/core/services/frap_conversion_test.dart

# Tests de integración
flutter test test/integration/

# Todos los tests
flutter test
```

### Cobertura de Tests

- ✅ Validación de datos
- ✅ Conversión bidireccional
- ✅ Migración automática
- ✅ Manejo de errores
- ✅ Performance
- ✅ Integración completa

## Troubleshooting

### Problemas Comunes

#### 1. Error de Conversión: "Campo faltante"

**Síntoma**: `ValidationResult` indica campos faltantes
**Solución**:
```dart
// Verificar mapeo en FrapConversionMapping
final missing = FrapFormAdapters.getMissingFields(data, DataOrigin.local);
print('Campos faltantes: $missing');
```

#### 2. Performance Lenta en Sincronización

**Síntoma**: Sincronización toma mucho tiempo
**Diagnóstico**:
```dart
final slowOps = FrapPerformanceMonitor.detectSlowOperations();
final stats = FrapPerformanceMonitor.getSyncStats();
```
**Solución**: Optimizar queries, usar batch operations

#### 3. Datos Inconsistentes Después de Migración

**Síntoma**: Datos no coinciden después de conversión
**Diagnóstico**:
```dart
// Verificar logs de conversión
FrapConversionLogger.logRecordComparison(local, cloud);
```
**Solución**: Revisar lógica de conversión en `FrapTransitionModel`

### Logs de Debug

```dart
// Habilitar logs detallados en desarrollo
import 'dart:developer' as developer;

// Filtrar logs de conversión
developer.log('', name: 'FrapConversion');
```

### Exportar Datos para Análisis

```dart
// Exportar estadísticas de performance
final stats = FrapPerformanceMonitor.exportStats();
print(jsonEncode(stats)); // Para análisis externo
```

---

## Conclusión

El Sistema de Conversión FRAP proporciona una base sólida para manejar la conversión de datos entre modelos locales y de nube. Su diseño modular, validación robusta y monitoreo completo garantizan la integridad de los datos y facilitan el mantenimiento y la evolución del sistema.

Para soporte adicional o preguntas específicas, consulte el código fuente o contacte al equipo de desarrollo. 