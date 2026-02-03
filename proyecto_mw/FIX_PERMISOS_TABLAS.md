# SOLUCIÓN RÁPIDA - Permisos en Tablas Base

## Error Actual:
```
"Error al ejecutar la herramienta: SELECT command denied to user 'mcp_agent'@'localhost' for table 'categorias'"
```

## Causa:
El usuario `mcp_agent` solo tiene permisos en las **vistas**, pero cuando filtras por ID, el servidor consulta las **tablas base** directamente.

## SOLUCIÓN (30 segundos):

### Opción 1: Ejecutar Script Rápido

**Abre MySQL Workbench y ejecuta:**

```bash
database/add_table_permissions.sql
```

O copia y pega esto:

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

### Opción 2: Re-ejecutar data.sql Completo

Si prefieres, ejecuta de nuevo `database/data.sql` completo (ya está actualizado con los nuevos permisos).

---

## Después de ejecutar:

1. **Reinicia MCP Inspector**
2. **Prueba de nuevo:**

```json
{
  "query_type": "get_categorias",
  "id": 1
}
```

```json
{
  "query_type": "get_roles",
  "id": 2
}
```

## Ahora debería funcionar!

Los permisos adicionales permiten que `mcp_agent` consulte las tablas base cuando filtras por ID.

---

## Resumen de Permisos:

**Vistas (para listar todos):**
- usuarios_view
- emprendimientos_view
- categorias_view
- roles_view
- mentorias_view
- resenas_view
- tutores_view
- colaboradores_view

**Tablas base (para filtrar por ID):**
- categorias
- roles
- emprendimientos
- _RolToUsuario

¡Listo!
