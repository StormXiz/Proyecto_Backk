# ✅ Solución: Error "Failed to fetch" en get_categorias y get_roles

## 🐛 Problema

Al intentar buscar categorías o roles por ID, aparecía el error `"Failed to fetch"`.

## 🔧 Causa

Las vistas `categorias_view` y `roles_view` usan `GROUP BY` para contar emprendimientos y usuarios. MySQL no permite filtrar con `WHERE id = ?` directamente en vistas con agregaciones.

## ✅ Solución Implementada

Cuando se filtra por ID en categorías o roles, ahora se consulta la **tabla base** con agregación manual en lugar de la vista.

### Antes (❌ No funcionaba):
```sql
SELECT * FROM categorias_view WHERE id = ?
```

### Ahora (✅ Funciona):
```sql
SELECT c.id, c.nombre, c.descripcion, 
       COUNT(e.id) AS total_emprendimientos
FROM categorias c
LEFT JOIN emprendimientos e ON c.id = e.categoriaId
WHERE c.id = ?
GROUP BY c.id, c.nombre, c.descripcion
```

## 📝 Ejemplos de Uso

### ✅ Obtener todas las categorías:
```json
{
  "query_type": "get_categorias"
}
```

### ✅ Obtener categoría por ID:
```json
{
  "query_type": "get_categorias",
  "id": 1
}
```

### ✅ Obtener todos los roles:
```json
{
  "query_type": "get_roles"
}
```

### ✅ Obtener rol por ID:
```json
{
  "query_type": "get_roles",
  "id": 2
}
```

## 🎯 Resumen

- ✅ **get_usuarios** - Funciona con y sin ID
- ✅ **get_emprendimientos** - Funciona con y sin ID
- ✅ **get_categorias** - **ARREGLADO** - Ahora funciona con ID
- ✅ **get_roles** - **ARREGLADO** - Ahora funciona con ID

Todas las consultas ahora funcionan correctamente!
