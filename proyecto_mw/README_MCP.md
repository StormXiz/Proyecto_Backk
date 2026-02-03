# Guía Rápida - MCP Server Emprendimientos

## Configuración Completada

El MCP server está configurado para consultar las vistas de la base de datos `emprendimientos`.

## Paso 1: Ejecutar el Script SQL

Abre MySQL Workbench y ejecuta el archivo:
```
database/data.sql
```

Este script creará:
- Usuario `mcp_agent` con permisos de solo lectura
- 8 vistas seguras (usuarios_view, emprendimientos_view, etc.)
- Triggers de auditoría para emprendimientos, mentorías y reseñas
- Tabla `audit_logs` para registro de cambios

## Paso 2: Iniciar el MCP Server

```bash
npm run mcp
```

Deberías ver:
```
Emprendimientos MCP Server started
```

## Paso 3: Configurar MCP Inspector

1. **Transport Type**: STDIO
2. **Command**: `node`
3. **Arguments**: `src/mcp-server.js`
4. **Working Directory**: Ruta completa al proyecto

## Herramientas Disponibles

### `db_readonly`

Consulta segura de información de emprendimientos.

**Tipos de consulta disponibles:**

1. **`get_usuarios`** - Obtiene todos los usuarios con sus roles
   ```json
   {
     "query_type": "get_usuarios"
   }
   ```

2. **`get_emprendimientos`** - Obtiene emprendimientos (máximo 50)
   ```json
   {
     "query_type": "get_emprendimientos"
   }
   ```

3. **`get_categorias`** - Obtiene categorías con conteo de emprendimientos
   ```json
   {
     "query_type": "get_categorias"
   }
   ```

4. **`get_roles`** - Obtiene roles con conteo de usuarios
   ```json
   {
     "query_type": "get_roles"
   }
   ```

## Verificación

Para verificar que todo funciona:

1. Ejecuta el script SQL en MySQL Workbench
2. Verifica que se crearon las vistas:
   ```sql
   SHOW FULL TABLES WHERE Table_type = 'VIEW';
   ```
3. Verifica permisos del usuario mcp_agent:
   ```sql
   SHOW GRANTS FOR 'mcp_agent'@'localhost';
   ```
4. Inicia el MCP server: `npm run mcp`
5. Conecta desde MCP Inspector
6. Prueba la herramienta `db_readonly` con `query_type: "get_usuarios"`

## Características

- **Solo lectura**: El usuario mcp_agent solo puede hacer SELECT
- **Vistas seguras**: Acceso controlado a través de vistas
- **Auditoría**: Todos los cambios en emprendimientos, mentorías y reseñas se registran
- **Validación estricta**: Usa Zod para validar entradas

## Notas

- El servidor usa las **vistas** definidas en `data.sql`, no las tablas directas
- Todos los cambios en emprendimientos, mentorías y reseñas se registran en `audit_logs`
- El usuario `mcp_agent` NO puede modificar datos, solo consultarlos
