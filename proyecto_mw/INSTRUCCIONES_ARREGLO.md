# SOLUCIÓN - Error de Permisos en Categorías y Roles

## Error Actual:
```
Error al ejecutar la herramienta: SELECT command denied to user 'mcp_agent'@'localhost' for table 'categorias'
```

## Causa del Problema:
El usuario `mcp_agent` tiene permisos para consultar las **vistas** (categorias_view, roles_view), pero NO tiene permisos para consultar las **tablas base** (categorias, roles). 

Cuando filtras por ID, el servidor MCP consulta directamente las tablas base en lugar de las vistas, por eso falla.

---

## SOLUCIÓN (2 minutos):

### Paso 1: Abrir MySQL Workbench

1. Abre **MySQL Workbench**
2. Conéctate con el usuario **root** y contraseña **lukion67**

### Paso 2: Ejecutar el Script SQL

1. Ve a **File** → **Open SQL Script**
2. Navega a: `/Users/storm/Desktop/CuartoCiclo/MIDDLEWARE/MiddlewareAP/proyecto_mw/database/fix_permissions_now.sql`
3. Presiona el botón del **rayo** ⚡ para ejecutar el script
4. Deberías ver el mensaje: "Permisos otorgados exitosamente!"

**O simplemente copia y pega esto en una nueva query:**

```sql
USE emprendimientos;

GRANT SELECT ON emprendimientos.categorias TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.categorias TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.roles TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.roles TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.emprendimientos TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.emprendimientos TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos._RolToUsuario TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos._RolToUsuario TO 'mcp_agent'@'%';

FLUSH PRIVILEGES;
```

### Paso 3: Reiniciar el MCP Server

1. En la terminal donde está corriendo el MCP Inspector, presiona **Ctrl + C** para detenerlo
2. Vuelve a ejecutar:
   ```bash
   npx @modelcontextprotocol/inspector node src/mcp-server.js
   ```

### Paso 4: Probar

Ahora prueba consultar categorías o roles por ID:

```json
{
  "query_type": "get_categorias",
  "id": 1
}
```

```json
{
  "query_type": "get_roles",
  "id": 1
}
```

---

## Verificación

Para verificar que los permisos están correctos, ejecuta en MySQL:

```sql
SHOW GRANTS FOR 'mcp_agent'@'localhost';
```

Deberías ver permisos SELECT en:
- Todas las vistas (usuarios_view, emprendimientos_view, etc.)
- Las tablas base (categorias, roles, emprendimientos, _RolToUsuario)

---

## Backup Creado

Se creó un backup del proyecto en:
```
/Users/storm/Desktop/CuartoCiclo/MIDDLEWARE/MiddlewareAP/proyecto_mw_backup_hola
```

Si algo sale mal, puedes restaurar desde ahí.
