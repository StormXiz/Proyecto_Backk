import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import mysql from "mysql2/promise";
import dotenv from "dotenv";
dotenv.config();

// Configuración de la base de datos MCP
const DB_CONFIG = {
    host: process.env.DB_HOST || 'localhost',
    user: 'mcp_agent',
    password: 'Agent_Secret_Pass_123!',
    database: process.env.DB_NAME || 'emprendimientos'
};

const server = new Server({
    name: "Emprendimientos MCP Server",
    version: "1.0.0",
    description: "Servidor MCP para consultas de emprendimientos",
},
    { capabilities: { tools: {} } })

// Definir lo que la IA puede hacer (funcionalidades)
server.setRequestHandler(ListToolsRequestSchema, async (request) => {
    return {
        tools: [
            {
                name: "db_readonly",
                description: "Consulta segura de información de emprendimientos. Permite obtener usuarios, emprendimientos, categorías y roles",
                inputSchema: {
                    type: "object",
                    properties: {
                        query_type: {
                            type: "string",
                            enum: ["get_usuarios", "get_emprendimientos", "get_categorias", "get_roles"],
                            description: "Tipo de consulta: 'get_usuarios', 'get_emprendimientos', 'get_categorias', 'get_roles'"
                        },
                        id: {
                            type: "integer",
                            description: "ID opcional para filtrar un registro específico"
                        }
                    },
                    required: ["query_type"]
                }
            }
        ]
    }
})


//Ejecutar las herramientas
server.setRequestHandler(CallToolRequestSchema, async (request) => {
    if (request.params.name !== 'db_readonly') throw new Error("Tool not found");

    // Validación Estricta - Crear la regla de validación
    const inputSchema = z.object({
        query_type: z.enum(["get_usuarios", "get_emprendimientos", "get_categorias", "get_roles"]),
        id: z.number().int().positive().optional()
    })

    try {
        // Validación Estricta - Validar la entrada
        const { query_type, id } = inputSchema.parse(request.params.arguments);

        const connection = await mysql.createConnection(DB_CONFIG);

        try {
            let result;
            
            if (query_type === "get_usuarios") {
                if (id) {
                    const [rows] = await connection.execute(
                        "SELECT * FROM usuarios_view WHERE id = ?",
                        [id]
                    );
                    result = rows[0] || null;
                } else {
                    const [rows] = await connection.execute(
                        "SELECT * FROM usuarios_view ORDER BY fechaRegistro DESC"
                    );
                    result = rows;
                }
            } else if (query_type === "get_emprendimientos") {
                if (id) {
                    const [rows] = await connection.execute(
                        "SELECT * FROM emprendimientos_view WHERE id = ?",
                        [id]
                    );
                    result = rows[0] || null;
                } else {
                    const [rows] = await connection.execute(
                        "SELECT * FROM emprendimientos_view ORDER BY fechaCreacion DESC LIMIT 50"
                    );
                    result = rows;
                }
            } else if (query_type === "get_categorias") {
                if (id) {
                    // Consultar tabla base con agregación manual
                    const [rows] = await connection.execute(
                        `SELECT c.id, c.nombre, c.descripcion, 
                                COUNT(e.id) AS total_emprendimientos
                         FROM categorias c
                         LEFT JOIN emprendimientos e ON c.id = e.categoriaId
                         WHERE c.id = ?
                         GROUP BY c.id, c.nombre, c.descripcion`,
                        [id]
                    );
                    result = rows[0] || null;
                } else {
                    const [rows] = await connection.execute(
                        "SELECT * FROM categorias_view ORDER BY nombre"
                    );
                    result = rows;
                }
            } else if (query_type === "get_roles") {
                if (id) {
                    // Consultar tabla base con agregación manual
                    const [rows] = await connection.execute(
                        `SELECT r.id, r.nombre,
                                COUNT(ru.B) AS total_usuarios
                         FROM roles r
                         LEFT JOIN _RolToUsuario ru ON r.id = ru.A
                         WHERE r.id = ?
                         GROUP BY r.id, r.nombre`,
                        [id]
                    );
                    result = rows[0] || null;
                } else {
                    const [rows] = await connection.execute(
                        "SELECT * FROM roles_view ORDER BY nombre"
                    );
                    result = rows;
                }
            }

            return {
                content: [{
                    type: "text",
                    text: JSON.stringify(result, null, 2)
                }
                ]
            }
        } finally {
            connection.end();
        }
    } catch (error) {
        return {
            content: [{
                type: "text",
                text: "Error al ejecutar la herramienta: " + error.message,
                isError: true
            }
            ]
        }
    }
})

async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("Emprendimientos MCP Server started");
}

main().catch(console.error);