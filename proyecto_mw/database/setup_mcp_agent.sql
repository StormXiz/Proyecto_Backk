-- =============================================================================
-- CONFIGURACIÓN MCP AGENT - Base de datos: emprendimientos
-- Script para dar acceso de solo lectura al usuario mcp_agent
-- =============================================================================

-- Usar la base de datos
USE emprendimientos;

-- =============================================================================
-- 1. CREAR USUARIO MCP AGENT
-- =============================================================================

-- Eliminar usuario si existe
DROP USER IF EXISTS 'mcp_agent'@'localhost';
DROP USER IF EXISTS 'mcp_agent'@'%';

-- Crear usuario con contraseña
CREATE USER 'mcp_agent'@'localhost' IDENTIFIED BY 'Agent_Secret_Pass_123!';
CREATE USER 'mcp_agent'@'%' IDENTIFIED BY 'Agent_Secret_Pass_123!';

-- =============================================================================
-- 2. OTORGAR PERMISOS DE SOLO LECTURA (SELECT)
-- =============================================================================

-- Dar permisos SELECT en TODAS las tablas de la base de datos emprendimientos
GRANT SELECT ON emprendimientos.* TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.* TO 'mcp_agent'@'%';

-- =============================================================================
-- 3. APLICAR CAMBIOS
-- =============================================================================

FLUSH PRIVILEGES;

-- =============================================================================
-- 4. VERIFICAR PERMISOS (Opcional - para debugging)
-- =============================================================================

-- Ver los permisos otorgados
SHOW GRANTS FOR 'mcp_agent'@'localhost';
SHOW GRANTS FOR 'mcp_agent'@'%';

-- =============================================================================
-- FIN DEL SCRIPT
-- =============================================================================
