-- =============================================================================
-- PERMISOS ADICIONALES PARA mcp_agent
-- Ejecuta SOLO este script si ya ejecutaste data.sql antes
-- =============================================================================

USE emprendimientos;

-- Permisos en tablas base (necesarios para consultas con filtro por ID)
GRANT SELECT ON emprendimientos.categorias TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.categorias TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.roles TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.roles TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.emprendimientos TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.emprendimientos TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos._RolToUsuario TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos._RolToUsuario TO 'mcp_agent'@'%';

FLUSH PRIVILEGES;

-- Verificar permisos
SHOW GRANTS FOR 'mcp_agent'@'localhost';
SHOW GRANTS FOR 'mcp_agent'@'%';
