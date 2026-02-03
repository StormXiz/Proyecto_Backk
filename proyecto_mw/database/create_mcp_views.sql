-- ============================================
-- SCRIPT COMPLETO PARA CONFIGURAR MCP AGENT
-- Base de datos: emprendimientos
-- ============================================

USE emprendimientos;

-- 1. ELIMINAR USUARIO SI EXISTE
DROP USER IF EXISTS 'mcp_agent'@'localhost';
DROP USER IF EXISTS 'mcp_agent'@'%';

-- 2. CREAR USUARIO MCP
CREATE USER 'mcp_agent'@'localhost' IDENTIFIED BY 'Agent_Secret_Pass_123!';
CREATE USER 'mcp_agent'@'%' IDENTIFIED BY 'Agent_Secret_Pass_123!';

-- 3. ELIMINAR VISTAS SI EXISTEN
DROP VIEW IF EXISTS emprendimientos_view;
DROP VIEW IF EXISTS usuarios_view;
DROP VIEW IF EXISTS categorias_view;
DROP VIEW IF EXISTS roles_view;
DROP VIEW IF EXISTS mentorias_view;
DROP VIEW IF EXISTS resenas_view;
DROP VIEW IF EXISTS tutores_view;
DROP VIEW IF EXISTS colaboradores_view;

-- 4. CREAR VISTAS (VIEWS) PARA ACCESO SEGURO

-- Vista de Usuarios
CREATE VIEW usuarios_view AS
SELECT 
    u.id,
    u.nombre,
    u.apellido,
    u.email,
    u.cedula,
    u.telefono,
    u.fechaRegistro,
    GROUP_CONCAT(r.nombre) as roles
FROM usuarios u
LEFT JOIN _RolToUsuario ru ON u.id = ru.B
LEFT JOIN roles r ON ru.A = r.id
GROUP BY u.id;

-- Vista de Emprendimientos
CREATE VIEW emprendimientos_view AS
SELECT 
    e.id,
    e.nombre,
    e.descripcion,
    e.estado,
    e.fechaCreacion,
    e.usuarioId,
    u.nombre as usuario_nombre,
    u.email as usuario_email,
    e.categoriaId,
    c.nombre as categoria_nombre
FROM emprendimientos e
JOIN usuarios u ON e.usuarioId = u.id
JOIN categorias c ON e.categoriaId = c.id;

-- Vista de Categorías
CREATE VIEW categorias_view AS
SELECT 
    c.id,
    c.nombre,
    c.descripcion,
    COUNT(e.id) as total_emprendimientos
FROM categorias c
LEFT JOIN emprendimientos e ON c.id = e.categoriaId
GROUP BY c.id;

-- Vista de Roles
CREATE VIEW roles_view AS
SELECT 
    r.id,
    r.nombre,
    COUNT(ru.B) as total_usuarios
FROM roles r
LEFT JOIN _RolToUsuario ru ON r.id = ru.A
GROUP BY r.id;

-- Vista de Mentorías
CREATE VIEW mentorias_view AS
SELECT 
    m.id,
    m.tema,
    m.fechaProgramada,
    m.estado,
    m.notas,
    m.tutorId,
    t.nombre as tutor_nombre,
    m.emprendimientoId,
    e.nombre as emprendimiento_nombre
FROM mentorias m
JOIN usuarios t ON m.tutorId = t.id
JOIN emprendimientos e ON m.emprendimientoId = e.id;

-- Vista de Reseñas
CREATE VIEW resenas_view AS
SELECT 
    r.id,
    r.calificacion,
    r.comentario,
    r.fecha,
    r.usuarioId,
    u.nombre as usuario_nombre,
    r.emprendimientoId,
    e.nombre as emprendimiento_nombre
FROM resenas r
JOIN usuarios u ON r.usuarioId = u.id
JOIN emprendimientos e ON r.emprendimientoId = e.id;

-- Vista de Tutores
CREATE VIEW tutores_view AS
SELECT 
    u.id,
    u.nombre,
    u.apellido,
    u.email,
    u.telefono,
    COUNT(DISTINCT m.id) as total_mentorias
FROM usuarios u
JOIN _RolToUsuario ru ON u.id = ru.B
JOIN roles r ON ru.A = r.id
LEFT JOIN mentorias m ON u.id = m.tutorId
WHERE r.nombre = 'MENTOR'
GROUP BY u.id;

-- Vista de Colaboradores
CREATE VIEW colaboradores_view AS
SELECT 
    u.id,
    u.nombre,
    u.apellido,
    u.email,
    u.telefono
FROM usuarios u
JOIN _RolToUsuario ru ON u.id = ru.B
JOIN roles r ON ru.A = r.id
WHERE r.nombre = 'COLABORADOR';

-- 5. OTORGAR PERMISOS SOLO A LAS VISTAS
GRANT SELECT ON emprendimientos.usuarios_view TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.usuarios_view TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.emprendimientos_view TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.emprendimientos_view TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.categorias_view TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.categorias_view TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.roles_view TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.roles_view TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.mentorias_view TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.mentorias_view TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.resenas_view TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.resenas_view TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.tutores_view TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.tutores_view TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.colaboradores_view TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.colaboradores_view TO 'mcp_agent'@'%';

-- 6. APLICAR CAMBIOS
FLUSH PRIVILEGES;

-- 7. VERIFICAR PERMISOS
SHOW GRANTS FOR 'mcp_agent'@'localhost';
SHOW GRANTS FOR 'mcp_agent'@'%';

-- 8. VERIFICAR VISTAS CREADAS
SHOW FULL TABLES WHERE Table_type = 'VIEW';
