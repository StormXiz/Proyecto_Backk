#!/bin/bash

# ============================================================================
# SCRIPT DE CONFIGURACIÓN AUTOMÁTICA - MCP AGENT
# ============================================================================

echo "🔧 Configurando usuario MCP Agent..."
echo ""

# Ejecutar el script SQL
mysql -u root -p'lukion67' << 'EOF'
USE emprendimientos;

DROP USER IF EXISTS 'mcp_agent'@'localhost';
DROP USER IF EXISTS 'mcp_agent'@'%';

CREATE USER 'mcp_agent'@'localhost' IDENTIFIED BY 'Agent_Secret_Pass_123!';
CREATE USER 'mcp_agent'@'%' IDENTIFIED BY 'Agent_Secret_Pass_123!';

GRANT SELECT ON emprendimientos.* TO 'mcp_agent'@'localhost';
GRANT SELECT ON emprendimientos.* TO 'mcp_agent'@'%';

FLUSH PRIVILEGES;

SELECT '✅ Usuario mcp_agent creado exitosamente' AS Status;
SELECT '✅ Permisos otorgados' AS Status;

SHOW GRANTS FOR 'mcp_agent'@'localhost';
SHOW GRANTS FOR 'mcp_agent'@'%';
EOF

echo ""
echo "✅ Configuración completada!"
echo ""
echo "🔍 Verificando conexión con mcp_agent..."
mysql -u mcp_agent -p'Agent_Secret_Pass_123!' emprendimientos -e "SELECT 'Conexión exitosa!' AS Test;"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ¡TODO LISTO! El usuario mcp_agent puede conectarse."
    echo "🚀 Reinicia el MCP Inspector ahora."
else
    echo ""
    echo "❌ Error: No se pudo conectar con mcp_agent"
    echo "Por favor, ejecuta manualmente el script SQL en MySQL Workbench"
fi
