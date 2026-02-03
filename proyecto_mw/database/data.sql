-- =============================================================================
-- PROYECTO: emprendimientos - Acceso Seguro (Vistas) + Auditoría + Usuario MCP
-- MySQL 8.0+
-- =============================================================================

CREATE DATABASE IF NOT EXISTS emprendimientos;
USE emprendimientos;

-- =============================================================================
-- USUARIO: mcp_agent (solo lectura mediante vistas)
-- =============================================================================
DROP USER IF EXISTS 'mcp_agent'@'localhost';
DROP USER IF EXISTS 'mcp_agent'@'%';

CREATE USER 'mcp_agent'@'localhost' IDENTIFIED BY 'Agent_Secret_Pass_123!';
CREATE USER 'mcp_agent'@'%' IDENTIFIED BY 'Agent_Secret_Pass_123!';

-- =============================================================================
-- TABLA: audit_logs (auditoría de cambios en tablas clave)
-- =============================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(64) NOT NULL,
    record_id BIGINT NOT NULL,
    operation ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    old_data JSON NULL,
    new_data JSON NULL,
    db_user VARCHAR(128) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_table_name (table_name),
    INDEX idx_operation (operation),
    INDEX idx_created_at (created_at)
);

-- =============================================================================
-- VISTAS SEGURAS (drop + create)
-- =============================================================================
DROP VIEW IF EXISTS emprendimientos_view;
DROP VIEW IF EXISTS usuarios_view;
DROP VIEW IF EXISTS categorias_view;
DROP VIEW IF EXISTS roles_view;
DROP VIEW IF EXISTS mentorias_view;
DROP VIEW IF EXISTS resenas_view;
DROP VIEW IF EXISTS tutores_view;
DROP VIEW IF EXISTS colaboradores_view;

CREATE VIEW usuarios_view AS
SELECT 
    u.id,
    u.nombre,
    u.apellido,
    u.email,
    u.cedula,
    u.telefono,
    u.fechaRegistro,
    GROUP_CONCAT(r.nombre ORDER BY r.nombre SEPARATOR ', ') AS roles
FROM usuarios u
LEFT JOIN _RolToUsuario ru ON u.id = ru.B
LEFT JOIN roles r ON ru.A = r.id
GROUP BY 
    u.id, u.nombre, u.apellido, u.email, u.cedula, u.telefono, u.fechaRegistro;

CREATE VIEW emprendimientos_view AS
SELECT 
    e.id,
    e.nombre,
    e.descripcion,
    e.estado,
    e.fechaCreacion,
    e.usuarioId,
    u.nombre AS usuario_nombre,
    u.email AS usuario_email,
    e.categoriaId,
    c.nombre AS categoria_nombre
FROM emprendimientos e
JOIN usuarios u ON e.usuarioId = u.id
JOIN categorias c ON e.categoriaId = c.id;

CREATE VIEW categorias_view AS
SELECT 
    c.id,
    c.nombre,
    c.descripcion,
    COUNT(e.id) AS total_emprendimientos
FROM categorias c
LEFT JOIN emprendimientos e ON c.id = e.categoriaId
GROUP BY c.id, c.nombre, c.descripcion;

CREATE VIEW roles_view AS
SELECT 
    r.id,
    r.nombre,
    COUNT(ru.B) AS total_usuarios
FROM roles r
LEFT JOIN _RolToUsuario ru ON r.id = ru.A
GROUP BY r.id, r.nombre;

CREATE VIEW mentorias_view AS
SELECT 
    m.id,
    m.tema,
    m.fechaProgramada,
    m.estado,
    m.notas,
    m.tutorId,
    t.nombre AS tutor_nombre,
    m.emprendimientoId,
    e.nombre AS emprendimiento_nombre
FROM mentorias m
JOIN usuarios t ON m.tutorId = t.id
JOIN emprendimientos e ON m.emprendimientoId = e.id;

CREATE VIEW resenas_view AS
SELECT 
    r.id,
    r.calificacion,
    r.comentario,
    r.fecha,
    r.usuarioId,
    u.nombre AS usuario_nombre,
    r.emprendimientoId,
    e.nombre AS emprendimiento_nombre
FROM resenas r
JOIN usuarios u ON r.usuarioId = u.id
JOIN emprendimientos e ON r.emprendimientoId = e.id;

CREATE VIEW tutores_view AS
SELECT 
    u.id,
    u.nombre,
    u.apellido,
    u.email,
    u.telefono,
    COUNT(DISTINCT m.id) AS total_mentorias
FROM usuarios u
JOIN _RolToUsuario ru ON u.id = ru.B
JOIN roles r ON ru.A = r.id
LEFT JOIN mentorias m ON u.id = m.tutorId
WHERE r.nombre = 'MENTOR'
GROUP BY u.id, u.nombre, u.apellido, u.email, u.telefono;

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

-- =============================================================================
-- TRIGGERS DE AUDITORÍA (tablas principales)
-- =============================================================================
DELIMITER //

-- emprendimientos
DROP TRIGGER IF EXISTS trg_emp_after_insert //
CREATE TRIGGER trg_emp_after_insert
AFTER INSERT ON emprendimientos
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, new_data, db_user)
    VALUES (
        'emprendimientos',
        NEW.id,
        'INSERT',
        JSON_OBJECT(
            'id', NEW.id,
            'nombre', NEW.nombre,
            'descripcion', NEW.descripcion,
            'estado', NEW.estado,
            'fechaCreacion', NEW.fechaCreacion,
            'usuarioId', NEW.usuarioId,
            'categoriaId', NEW.categoriaId
        ),
        USER()
    );
END //

DROP TRIGGER IF EXISTS trg_emp_after_update //
CREATE TRIGGER trg_emp_after_update
AFTER UPDATE ON emprendimientos
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, old_data, new_data, db_user)
    VALUES (
        'emprendimientos',
        NEW.id,
        'UPDATE',
        JSON_OBJECT(
            'id', OLD.id,
            'nombre', OLD.nombre,
            'descripcion', OLD.descripcion,
            'estado', OLD.estado,
            'fechaCreacion', OLD.fechaCreacion,
            'usuarioId', OLD.usuarioId,
            'categoriaId', OLD.categoriaId
        ),
        JSON_OBJECT(
            'id', NEW.id,
            'nombre', NEW.nombre,
            'descripcion', NEW.descripcion,
            'estado', NEW.estado,
            'fechaCreacion', NEW.fechaCreacion,
            'usuarioId', NEW.usuarioId,
            'categoriaId', NEW.categoriaId
        ),
        USER()
    );
END //

DROP TRIGGER IF EXISTS trg_emp_after_delete //
CREATE TRIGGER trg_emp_after_delete
AFTER DELETE ON emprendimientos
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, old_data, db_user)
    VALUES (
        'emprendimientos',
        OLD.id,
        'DELETE',
        JSON_OBJECT(
            'id', OLD.id,
            'nombre', OLD.nombre,
            'descripcion', OLD.descripcion,
            'estado', OLD.estado,
            'fechaCreacion', OLD.fechaCreacion,
            'usuarioId', OLD.usuarioId,
            'categoriaId', OLD.categoriaId
        ),
        USER()
    );
END //

-- mentorias
DROP TRIGGER IF EXISTS trg_ment_after_insert //
CREATE TRIGGER trg_ment_after_insert
AFTER INSERT ON mentorias
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, new_data, db_user)
    VALUES (
        'mentorias',
        NEW.id,
        'INSERT',
        JSON_OBJECT(
            'id', NEW.id,
            'tema', NEW.tema,
            'fechaProgramada', NEW.fechaProgramada,
            'estado', NEW.estado,
            'notas', NEW.notas,
            'tutorId', NEW.tutorId,
            'emprendimientoId', NEW.emprendimientoId
        ),
        USER()
    );
END //

DROP TRIGGER IF EXISTS trg_ment_after_update //
CREATE TRIGGER trg_ment_after_update
AFTER UPDATE ON mentorias
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, old_data, new_data, db_user)
    VALUES (
        'mentorias',
        NEW.id,
        'UPDATE',
        JSON_OBJECT(
            'id', OLD.id,
            'tema', OLD.tema,
            'fechaProgramada', OLD.fechaProgramada,
            'estado', OLD.estado,
            'notas', OLD.notas,
            'tutorId', OLD.tutorId,
            'emprendimientoId', OLD.emprendimientoId
        ),
        JSON_OBJECT(
            'id', NEW.id,
            'tema', NEW.tema,
            'fechaProgramada', NEW.fechaProgramada,
            'estado', NEW.estado,
            'notas', NEW.notas,
            'tutorId', NEW.tutorId,
            'emprendimientoId', NEW.emprendimientoId
        ),
        USER()
    );
END //

DROP TRIGGER IF EXISTS trg_ment_after_delete //
CREATE TRIGGER trg_ment_after_delete
AFTER DELETE ON mentorias
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, old_data, db_user)
    VALUES (
        'mentorias',
        OLD.id,
        'DELETE',
        JSON_OBJECT(
            'id', OLD.id,
            'tema', OLD.tema,
            'fechaProgramada', OLD.fechaProgramada,
            'estado', OLD.estado,
            'notas', OLD.notas,
            'tutorId', OLD.tutorId,
            'emprendimientoId', OLD.emprendimientoId
        ),
        USER()
    );
END //

-- resenas
DROP TRIGGER IF EXISTS trg_res_after_insert //
CREATE TRIGGER trg_res_after_insert
AFTER INSERT ON resenas
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, new_data, db_user)
    VALUES (
        'resenas',
        NEW.id,
        'INSERT',
        JSON_OBJECT(
            'id', NEW.id,
            'calificacion', NEW.calificacion,
            'comentario', NEW.comentario,
            'fecha', NEW.fecha,
            'usuarioId', NEW.usuarioId,
            'emprendimientoId', NEW.emprendimientoId
        ),
        USER()
    );
END //

DROP TRIGGER IF EXISTS trg_res_after_update //
CREATE TRIGGER trg_res_after_update
AFTER UPDATE ON resenas
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, old_data, new_data, db_user)
    VALUES (
        'resenas',
        NEW.id,
        'UPDATE',
        JSON_OBJECT(
            'id', OLD.id,
            'calificacion', OLD.calificacion,
            'comentario', OLD.comentario,
            'fecha', OLD.fecha,
            'usuarioId', OLD.usuarioId,
            'emprendimientoId', OLD.emprendimientoId
        ),
        JSON_OBJECT(
            'id', NEW.id,
            'calificacion', NEW.calificacion,
            'comentario', NEW.comentario,
            'fecha', NEW.fecha,
            'usuarioId', NEW.usuarioId,
            'emprendimientoId', NEW.emprendimientoId
        ),
        USER()
    );
END //

DROP TRIGGER IF EXISTS trg_res_after_delete //
CREATE TRIGGER trg_res_after_delete
AFTER DELETE ON resenas
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, record_id, operation, old_data, db_user)
    VALUES (
        'resenas',
        OLD.id,
        'DELETE',
        JSON_OBJECT(
            'id', OLD.id,
            'calificacion', OLD.calificacion,
            'comentario', OLD.comentario,
            'fecha', OLD.fecha,
            'usuarioId', OLD.usuarioId,
            'emprendimientoId', OLD.emprendimientoId
        ),
        USER()
    );
END //

DELIMITER ;

-- =============================================================================
-- PERMISOS: solo SELECT sobre vistas
-- =============================================================================
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'mcp_agent'@'localhost';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'mcp_agent'@'%';

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

-- Permisos adicionales en tablas base (necesarios para consultas con ID)
GRANT SELECT ON emprendimientos.categorias TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.categorias TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.roles TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.roles TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos.emprendimientos TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.emprendimientos TO 'mcp_agent'@'%';

GRANT SELECT ON emprendimientos._RolToUsuario TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos._RolToUsuario TO 'mcp_agent'@'%';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'mcp_agent'@'localhost';
SHOW GRANTS FOR 'mcp_agent'@'%';
SHOW FULL TABLES WHERE Table_type = 'VIEW';
