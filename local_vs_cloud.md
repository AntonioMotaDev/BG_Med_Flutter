# PLAN DE ACCIÓN PARA RESOLVER DUPLICACIÓN DE REGISTROS FRAP

## **PROBLEMA IDENTIFICADO**
- Registros duplicados entre almacenamiento local y nube
- Falta de lógica para detectar y unificar registros idénticos
- Almacenamiento local innecesario de registros ya sincronizados
- Botón de sincronización no limpia registros locales duplicados

## **FASE 1: ANÁLISIS DEL PROBLEMA ACTUAL**

### 1.1 Identificar Causas de Duplicación
- **SyncId inconsistente**: El algoritmo actual puede generar IDs diferentes para el mismo registro
- **Falta de detección de duplicados**: No hay comparación inteligente entre registros
- **Sincronización unidireccional**: Solo sube datos, no limpia local
- **Timing de sincronización**: Registros se crean en ambos lugares antes de sincronizar

### 1.2 Analizar Lógica Actual de Unificación
```dart
// Problema en frap_unified_provider.dart
// El syncId se genera de forma diferente para local vs nube
// No hay verificación de contenido real del registro
```

## **FASE 2: MEJORAR ALGORITMO DE DETECCIÓN DE DUPLICADOS**

### 2.1 Crear Función de Comparación Inteligente
```dart
// Nueva función para comparar registros por contenido
bool _areRecordsEquivalent(UnifiedFrapRecord local, UnifiedFrapRecord cloud) {
  // Comparar datos críticos del paciente
  // Comparar fechas de creación (con tolerancia de tiempo)
  // Comparar contenido de secciones principales
  // Retornar true si son el mismo registro
}
```

### 2.2 Mejorar Generación de SyncId
```dart
// Hacer el syncId más robusto y consistente
String _generateRobustSyncId(UnifiedFrapRecord record) {
  // Usar datos más específicos del paciente
  // Incluir timestamp más preciso
  // Normalizar strings para evitar diferencias de formato
}
```

### 2.3 Implementar Detección por Múltiples Criterios
- **Criterio 1**: SyncId exacto
- **Criterio 2**: Datos del paciente + fecha (con tolerancia)
- **Criterio 3**: Contenido similar en secciones principales
- **Criterio 4**: Timestamp de creación cercano

## **FASE 3: MODIFICAR LÓGICA DE UNIFICACIÓN**

### 3.1 Actualizar `_combineRecords()` en `frap_unified_provider.dart`
```dart
void _combineRecords() {
  // 1. Detectar duplicados usando nueva lógica
  // 2. Priorizar registros de la nube sobre locales
  // 3. Marcar registros locales duplicados para eliminación
  // 4. Crear lista unificada sin duplicados
}
```

### 3.2 Implementar Sistema de Marcado de Duplicados
```dart
class UnifiedFrapRecord {
  // Agregar campo para marcar duplicados
  final bool isDuplicate;
  final String? duplicateOf; // ID del registro original
}
```

## **FASE 4: CREAR SERVICIO DE LIMPIEZA DE DUPLICADOS**

### 4.1 Nuevo Servicio: `lib/core/services/frap_cleanup_service.dart`
```dart
class FrapCleanupService {
  // Detectar registros locales duplicados
  Future<List<String>> findDuplicateLocalRecords();
  
  // Eliminar registros locales duplicados
  Future<bool> removeDuplicateLocalRecords(List<String> duplicateIds);
  
  // Verificar integridad después de limpieza
  Future<bool> verifyDataIntegrity();
}
```

### 4.2 Integrar con Provider Unificado
```dart
// Agregar métodos al UnifiedFrapNotifier
Future<void> cleanupDuplicateRecords();
Future<void> syncAndCleanup();
```

## **FASE 5: MODIFICAR BOTÓN DE SINCRONIZACIÓN**

### 5.1 Actualizar Lógica del Botón de Sincronización
```dart
// En lugar de solo sincronizar, hacer:
// 1. Sincronizar registros locales a nube
// 2. Detectar duplicados
// 3. Eliminar registros locales duplicados
// 4. Actualizar lista unificada
```

### 5.2 Agregar Confirmación de Usuario
```dart
// Mostrar diálogo informativo:
// "Se encontraron X registros duplicados. ¿Desea eliminarlos del almacenamiento local?"
// Opciones: "Sí, eliminar duplicados" | "No, mantener todo"
```

## **FASE 6: IMPLEMENTAR ESTRATEGIA DE SINCRONIZACIÓN INTELIGENTE**

### 6.1 Crear Estados de Sincronización
```dart
enum SyncStatus {
  notSynced,    // Solo local
  synced,       // Solo nube
  duplicate,    // Existe en ambos
  conflict      // Diferentes versiones
}
```

### 6.2 Implementar Resolución de Conflictos
```dart
// Si hay conflictos (mismos datos, diferentes versiones):
// 1. Comparar timestamps de modificación
// 2. Mantener la versión más reciente
// 3. Eliminar la versión antigua
```

## **FASE 7: MEJORAR INTERFAZ DE USUARIO**

### 7.1 Actualizar Indicadores Visuales
- Mostrar estado de sincronización en cada registro
- Indicar cuáles son duplicados
- Mostrar progreso de limpieza

### 7.2 Agregar Estadísticas de Limpieza
```dart
// Mostrar en pantalla:
// "Registros locales: X"
// "Registros en nube: Y"
// "Duplicados detectados: Z"
// "Espacio liberado: W MB"
```

## **FASE 8: IMPLEMENTAR VERIFICACIÓN DE INTEGRIDAD**

### 8.1 Crear Sistema de Logs
```dart
// Registrar todas las operaciones de limpieza:
// - Registros eliminados
// - Registros preservados
// - Errores encontrados
// - Espacio liberado
```

### 8.2 Implementar Rollback
```dart
// En caso de error durante limpieza:
// 1. Detener proceso
// 2. Restaurar estado anterior
// 3. Notificar al usuario
// 4. Generar reporte de error
```

## **FASE 9: OPTIMIZACIÓN DE RENDIMIENTO**

### 9.1 Implementar Limpieza Incremental
```dart
// En lugar de procesar todo de una vez:
// 1. Procesar en lotes pequeños
// 2. Mostrar progreso
// 3. Permitir cancelación
// 4. Continuar desde donde se quedó
```

### 9.2 Cache de Detección de Duplicados
```dart
// Evitar recalcular duplicados:
// 1. Cachear resultados de comparación
// 2. Invalidar cache cuando cambien datos
// 3. Usar índices para búsquedas rápidas
```

## **FASE 10: PRUEBAS Y VALIDACIÓN**

### 10.1 Escenarios de Prueba
- Registros idénticos en local y nube
- Registros similares pero no idénticos
- Registros con conflictos de datos
- Gran volumen de registros
- Interrupciones durante sincronización

### 10.2 Métricas de Validación
- Reducción de almacenamiento local
- Velocidad de sincronización
- Precisión de detección de duplicados
- Integridad de datos preservados

## **BENEFICIOS ESPERADOS**

1. **Eliminación de duplicados**: Almacenamiento local más limpio
2. **Sincronización confiable**: Sin pérdida de datos
3. **Mejor rendimiento**: Menos datos que procesar
4. **Transparencia**: Usuario sabe qué se está eliminando
5. **Escalabilidad**: Sistema maneja grandes volúmenes

## **RIESGOS Y MITIGACIONES**

1. **Pérdida accidental de datos**: Implementar confirmación y rollback
2. **Falsos positivos**: Múltiples criterios de detección
3. **Rendimiento lento**: Procesamiento incremental
4. **Conflictos de red**: Manejo de errores robusto

