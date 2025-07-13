# PLAN DE ACCIÓN PARA UNIFICAR MODELOS FRAP LOCAL Y NUBE

## **FASE 1: ANÁLISIS Y PREPARACIÓN**

### 1.1 Inventario de Cambios Necesarios
- **Modelo Patient**: Expandir de 4 campos a 14 campos
- **Modelo ClinicalHistory**: Expandir de 3 campos a 13 campos  
- **Modelo PhysicalExam**: Expandir de 6 campos a 12 campos
- **Modelo Frap**: Agregar 11 nuevas secciones completas

### 1.2 Impacto en Base de Datos Local
- **Hive**: Necesita regenerar adaptadores para todos los modelos modificados
- **Migración de datos**: Estrategia para preservar registros existentes
- **Compatibilidad**: Mantener funcionalidad durante transición

## **FASE 2: MODIFICACIÓN DE MODELOS LOCALES**

### 2.1 Actualizar `lib/core/models/patient.dart`
**Cambios necesarios:**
- Agregar campos: `firstName`, `paternalLastName`, `maternalLastName`, `phone`, `street`, `exteriorNumber`, `interiorNumber`, `neighborhood`, `city`, `insurance`, `responsiblePerson`, `currenCondition`
- Mantener campos existentes: `name`, `age`, `gender`, `address` (para compatibilidad)
- Actualizar `@HiveField` annotations
- Regenerar `patient.g.dart`

### 2.2 Actualizar `lib/core/models/clinical_history.dart`
**Cambios necesarios:**
- Agregar campos: `currentSymptoms`, `pain`, `painScale`, `dosage`, `frequency`, `route`, `time`, `previousSurgeries`, `hospitalizations`, `transfusions`
- Mantener campos existentes: `allergies`, `medications`, `previousIllnesses`
- Actualizar `@HiveField` annotations
- Regenerar `clinical_history.g.dart`

### 2.3 Actualizar `lib/core/models/physical_exam.dart`
**Cambios necesarios:**
- Agregar campos: `bloodPressure`, `heartRate`, `respiratoryRate`, `temperature`, `oxygenSaturation`, `neurological`
- Mantener campos existentes: `vitalSigns`, `head`, `neck`, `thorax`, `abdomen`, `extremities`
- Actualizar `@HiveField` annotations
- Regenerar `physical_exam.g.dart`

### 2.4 Actualizar `lib/core/models/frap.dart`
**Cambios necesarios:**
- Agregar nuevas secciones como `Map<String, dynamic>`:
  - `serviceInfo`
  - `registryInfo`
  - `management`
  - `medications`
  - `gynecoObstetric`
  - `attentionNegative`
  - `pathologicalHistory`
  - `priorityJustification`
  - `injuryLocation`
  - `receivingUnit`
  - `patientReception`
- Agregar campo `updatedAt`
- Actualizar `@HiveField` annotations
- Regenerar `frap.g.dart`

## **FASE 3: ESTRATEGIA DE MIGRACIÓN DE DATOS**

### 3.1 Migración de Pacientes Existentes
```dart
// Estrategia: Parsear nombre y dirección existentes
// Ejemplo: "Juan Pérez López" → firstName: "Juan", paternalLastName: "Pérez", maternalLastName: "López"
// Ejemplo: "Calle 123, Colonia Centro, Ciudad" → street: "Calle 123", neighborhood: "Colonia Centro", city: "Ciudad"
```

### 3.2 Migración de Historia Clínica
```dart
// Mantener datos existentes en campos correspondientes
// Nuevos campos se inicializan vacíos
```

### 3.3 Migración de Examen Físico
```dart
// Mantener datos existentes en campos correspondientes
// Nuevos campos se inicializan vacíos
```

### 3.4 Migración de Registros FRAP
```dart
// Nuevas secciones se inicializan como Map vacío {}
// Preservar datos existentes en secciones actuales
```

## **FASE 4: ACTUALIZACIÓN DE SERVICIOS**

### 4.1 Actualizar `lib/core/services/frap_local_service.dart`
- Modificar métodos de conversión entre modelos
- Actualizar lógica de migración de datos
- Asegurar compatibilidad con registros existentes

### 4.2 Actualizar `lib/features/frap/presentation/providers/frap_unified_provider.dart`
- Simplificar `getDetailedInfo()` para usar campos directos
- Eliminar mapeos manuales complejos
- Unificar lógica de acceso a datos

## **FASE 5: ACTUALIZACIÓN DE INTERFACES**

### 5.1 Actualizar Formularios de Entrada
- Modificar diálogos para usar nuevos campos
- Mantener compatibilidad con datos existentes
- Agregar validaciones para nuevos campos

### 5.2 Actualizar Pantalla de Detalles
- Simplificar lógica de visualización
- Usar campos directos en lugar de mapeos complejos
- Mostrar todas las secciones disponibles

## **FASE 6: REGENERACIÓN Y MIGRACIÓN**

### 6.1 Regenerar Adaptadores Hive
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 6.2 Script de Migración de Datos
- Crear script para migrar registros existentes
- Preservar todos los datos actuales
- Inicializar nuevos campos apropiadamente

### 6.3 Validación de Integridad
- Verificar que todos los datos se preservaron
- Confirmar que nuevos campos funcionan correctamente
- Probar sincronización local-nube

## **FASE 7: PRUEBAS Y VALIDACIÓN**

### 7.1 Pruebas de Compatibilidad
- Verificar que registros antiguos se muestran correctamente
- Confirmar que nuevos registros usan todos los campos
- Probar sincronización bidireccional

### 7.2 Pruebas de Rendimiento
- Verificar que la app mantiene rendimiento
- Confirmar que Hive maneja el volumen de datos
- Probar operaciones CRUD completas

## **BENEFICIOS ESPERADOS**

1. **Unificación completa**: Mismos campos en local y nube
2. **Sincronización perfecta**: Sin pérdida de datos
3. **Mantenimiento simplificado**: Una sola estructura de datos
4. **Funcionalidad completa**: Todas las características disponibles offline
5. **Escalabilidad**: Fácil agregar nuevos campos en el futuro

## **RIESGOS Y CONSIDERACIONES**

1. **Migración de datos**: Riesgo de pérdida de información
2. **Tamaño de base de datos**: Aumento significativo en almacenamiento local
3. **Rendimiento**: Posible impacto en operaciones de lectura/escritura
4. **Compatibilidad**: Asegurar que versiones anteriores funcionen

