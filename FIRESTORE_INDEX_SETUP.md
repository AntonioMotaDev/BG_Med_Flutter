# Configuración de Índice Firestore para FRAP

## Problema Identificado

Los registros FRAP no se pueden cargar/mostrar debido a un error de Firestore:

```
Listen for Query(target=Query(preHospitalRecords where userId==... order by -createdAt, -__name__);limitType=LIMIT_TO_FIRST) failed: Status{code=FAILED_PRECONDITION, description=The query requires an index.
```

## Solución

### Opción 1: Usar el enlace automático (Recomendado)

1. **Ejecutar la app en modo debug**
2. **Reproducir el error** navegando a la pantalla de registros FRAP
3. **Copiar el enlace del error** que aparece en los logs:
   ```
   https://console.firebase.google.com/v1/r/project/bg-medapp/firestore/indexes?create_composite=...
   ```
4. **Abrir el enlace en el navegador** 
5. **Hacer clic en "Create Index"**
6. **Esperar** a que se complete la creación (puede tomar unos minutos)

### Opción 2: Configuración manual

1. **Ir a Firebase Console**: https://console.firebase.google.com/
2. **Seleccionar proyecto**: `bg-medapp`
3. **Ir a Firestore Database** → **Indexes**
4. **Hacer clic en "Create Index"**
5. **Configurar el índice**:
   - **Collection ID**: `preHospitalRecords`
   - **Fields**:
     - Campo 1: `userId` (Ascending)
     - Campo 2: `createdAt` (Descending)
   - **Query scopes**: Collection
6. **Hacer clic en "Create"**

### Opción 3: Usando Firebase CLI

```bash
# En la carpeta del proyecto
firebase firestore:indexes

# O crear manualmente el archivo firestore.indexes.json:
{
  "indexes": [
    {
      "collectionGroup": "preHospitalRecords",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ]
}
```

## Verificación

Después de crear el índice:

1. **Esperar** a que el estado cambie de "Building" a "Enabled" (2-5 minutos)
2. **Reiniciar la app**
3. **Navegar** a la pantalla de registros FRAP
4. **Verificar** que los registros se cargan correctamente

## Configuración Temporal

Mientras se configura el índice, hemos implementado una **solución temporal** que:
- Remueve la cláusula `orderBy` de las consultas Firestore
- Ordena los resultados en memoria después de obtenerlos
- Permite que la app funcione sin el índice

## Restaurar Consultas Optimizadas

Una vez creado el índice, puedes revertir los cambios temporales en `frap_firestore_service.dart` para usar las consultas optimizadas con `orderBy` directamente en Firestore.

## Índices Adicionales Recomendados

Para optimizar las consultas por rango de fechas:

```json
{
  "collectionGroup": "preHospitalRecords",
  "queryScope": "COLLECTION", 
  "fields": [
    {
      "fieldPath": "userId",
      "order": "ASCENDING"
    },
    {
      "fieldPath": "createdAt",
      "order": "ASCENDING"
    }
  ]
}
```

## Notas Importantes

- Los índices pueden tardar varios minutos en construirse
- Durante la construcción, las consultas pueden fallar temporalmente
- Una vez completados, las consultas serán mucho más rápidas
- Firebase tiene límites de índices por proyecto (200 índices simples, 200 compuestos) 