-- Script para configurar usuario MCP con permisos de solo lectura
-- Base de datos: centro_emprendimientos

-- Eliminar usuario si existe (para empezar limpio)
DROP USER IF EXISTS 'mcp_agent'@'localhost';
DROP USER IF EXISTS 'mcp_agent'@'%';

-- Crear usuario MCP
CREATE USER 'mcp_agent'@'localhost' IDENTIFIED BY 'Agent_Secret_Pass_123!';
CREATE USER 'mcp_agent'@'%' IDENTIFIED BY 'Agent_Secret_Pass_123!';

-- Otorgar permisos de solo lectura (SELECT) en la base de datos centro_emprendimientos
GRANT SELECT ON centro_emprendimientos.* TO 'mcp_agent'@'localhost';
GRANT SELECT ON centro_emprendimientos.* TO 'mcp_agent'@'%';

-- Aplicar cambios
FLUSH PRIVILEGES;

-- Verificar permisos
SHOW GRANTS FOR 'mcp_agent'@'localhost';
SHOW GRANTS FOR 'mcp_agent'@'%';
