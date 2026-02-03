-- ============================================================================
-- SOLUCIÓN RÁPIDA: Permisos para mcp_agent
-- Ejecuta este script en MySQL Workbench para arreglar el error de permisos
-- ============================================================================

USE emprendimientos;

-- Otorgar permisos SELECT en las tablas base necesarias
GRANT SELECT ON emprendimientos.categorias TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.categorias TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.roles TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.roles TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.emprendimientos TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.emprendimientos TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos._RolToUsuario TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos._RolToUsuario TO 'mcp_agent'@'%';

-- Aplicar cambios
FLUSH PRIVILEGES;

-- Verificar que los permisos se aplicaron correctamente
SELECT 'Permisos otorgados exitosamente!' AS Status;

SHOW GRANTS FOR 'mcp_agent'@'localhost';
SHOW GRANTS FOR 'mcp_agent'@'%';
