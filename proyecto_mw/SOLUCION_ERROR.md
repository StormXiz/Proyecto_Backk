# 🚨 SOLUCIÓN AL ERROR - Access Denied

## ❌ Error Actual:
```
"Error al ejecutar la herramienta: Access denied for user 'mcp_agent'@'%' to database 'emprendimientos'"
```

## ✅ SOLUCIÓN (2 pasos):

### Paso 1: Ejecutar el Script SQL

**Abre MySQL Workbench:**

1. Conecta con usuario `root` y contraseña `lukion67`
2. Ve a `File` → `Open SQL Script`
3. Selecciona: `database/data.sql`
4. Presiona el rayo ⚡ para ejecutar TODO el script
5. Espera a que termine (verás mensajes de éxito)

**O copia y pega manualmente** el contenido completo de `database/data.sql` en una nueva query tab y ejecútalo.

### Paso 2: Reiniciar MCP Inspector

1. Desconecta el MCP Inspector
2. Vuelve a conectar
3. Prueba la herramienta `db_readonly`

---

## 🎯 Nueva Funcionalidad: Búsqueda por ID

Ahora puedes buscar registros específicos por ID:

### Obtener todos los usuarios:
```json
{
  "query_type": "get_usuarios"
}
```

### Obtener un usuario específico por ID:
```json
{
  "query_type": "get_usuarios",
  "id": 1
}
```

### Obtener un emprendimiento específico:
```json
{
  "query_type": "get_emprendimientos",
  "id": 5
}
```

### Obtener una categoría específica:
```json
{
  "query_type": "get_categorias",
  "id": 2
}
```

### Obtener un rol específico:
```json
{
  "query_type": "get_roles",
  "id": 1
}
```

---

## ✅ Verificación

Después de ejecutar el script SQL, verifica:

```sql
-- Ver las vistas creadas
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Ver permisos del usuario mcp_agent
SHOW GRANTS FOR 'mcp_agent'@'localhost';
```

Deberías ver:
- 8 vistas (usuarios_view, emprendimientos_view, etc.)
- Permisos SELECT en todas las vistas

---

## 🎯 Resumen de Cambios

1. ✅ Agregado parámetro opcional `id` a todas las consultas
2. ✅ Ahora puedes obtener todos los registros O uno específico por ID
3. ✅ Si no pasas `id`, obtienes todos los registros
4. ✅ Si pasas `id`, obtienes solo ese registro (o `null` si no existe)

**IMPORTANTE**: El error desaparecerá solo después de ejecutar `database/data.sql` en MySQL Workbench.
