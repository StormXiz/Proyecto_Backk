import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import mysql from "mysql2/promise";
import dotenv from "dotenv";
dotenv.config();

// Configuración de la base de datos MCP (usuario de solo lectura)
const DB_CONFIG = {
    host: process.env.DB_HOST,
    user: 'mcp_agent',
    password: 'Agent_Secret_Pass_123!',
    database: process.env.DB_NAME
};

const server = new Server({
    name: "Emprendimientos MCP Server",
    version: "2.0.0",
    description: "Servidor MCP completo para gestión de emprendimientos",
},
    { capabilities: { tools: {} } }
);

// Definir TODAS las herramientas disponibles
server.setRequestHandler(ListToolsRequestSchema, async (request) => {
    return {
        tools: [
            // USUARIOS
            {
                name: "get_usuarios",
                description: "Obtener lista de todos los usuarios",
                inputSchema: {
                    type: "object",
                    properties: {},
                    required: []
                }
            },
            {
                name: "get_usuario_by_id",
                description: "Obtener un usuario específico por ID",
                inputSchema: {
                    type: "object",
                    properties: {
                        id: { type: "integer", description: "ID del usuario" }
                    },
                    required: ["id"]
                }
            },
            // EMPRENDIMIENTOS
            {
                name: "get_emprendimientos",
                description: "Obtener lista de emprendimientos",
                inputSchema: {
                    type: "object",
                    properties: {
                        usuario_id: { type: "integer", description: "Filtrar por ID de usuario (opcional)" }
                    }
                }
            },
            {
                name: "get_emprendimiento_by_id",
                description: "Obtener un emprendimiento específico por ID",
                inputSchema: {
                    type: "object",
                    properties: {
                        id: { type: "integer", description: "ID del emprendimiento" }
                    },
                    required: ["id"]
                }
            },
            // CATEGORÍAS
            {
                name: "get_categorias",
                description: "Obtener lista de todas las categorías",
                inputSchema: {
                    type: "object",
                    properties: {},
                    required: []
                }
            },
            // ROLES
            {
                name: "get_roles",
                description: "Obtener lista de todos los roles",
                inputSchema: {
                    type: "object",
                    properties: {},
                    required: []
                }
            },
            // MENTORÍAS
            {
                name: "get_mentorias",
                description: "Obtener lista de mentorías",
                inputSchema: {
                    type: "object",
                    properties: {
                        tutor_id: { type: "integer", description: "Filtrar por ID de tutor (opcional)" },
                        emprendimiento_id: { type: "integer", description: "Filtrar por ID de emprendimiento (opcional)" }
                    }
                }
            },
            // RESEÑAS
            {
                name: "get_resenas",
                description: "Obtener lista de reseñas",
                inputSchema: {
                    type: "object",
                    properties: {
                        emprendimiento_id: { type: "integer", description: "Filtrar por ID de emprendimiento (opcional)" }
                    }
                }
            },
            // TUTORES
            {
                name: "get_tutores",
                description: "Obtener lista de tutores (usuarios con rol MENTOR)",
                inputSchema: {
                    type: "object",
                    properties: {},
                    required: []
                }
            },
            // COLABORADORES
            {
                name: "get_colaboradores",
                description: "Obtener lista de colaboradores",
                inputSchema: {
                    type: "object",
                    properties: {},
                    required: []
                }
            },
            // ESTADÍSTICAS
            {
                name: "get_estadisticas_usuario",
                description: "Obtener estadísticas de un usuario (emprendimientos, mentorías, reseñas)",
                inputSchema: {
                    type: "object",
                    properties: {
                        usuario_id: { type: "integer", description: "ID del usuario" }
                    },
                    required: ["usuario_id"]
                }
            },
            {
                name: "get_estadisticas_generales",
                description: "Obtener estadísticas generales del sistema",
                inputSchema: {
                    type: "object",
                    properties: {},
                    required: []
                }
            }
        ]
    };
});

// Ejecutar las herramientas
server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const connection = await mysql.createConnection(DB_CONFIG);

    try {
        let result;

        switch (request.params.name) {
            // ========== USUARIOS ==========
            case "get_usuarios": {
                const [rows] = await connection.execute(
                    `SELECT * FROM usuarios_view ORDER BY fechaRegistro DESC`
                );
                result = rows;
                break;
            }

            case "get_usuario_by_id": {
                const schema = z.object({ id: z.number().int().positive() });
                const { id } = schema.parse(request.params.arguments);

                const [rows] = await connection.execute(
                    `SELECT * FROM usuarios_view WHERE id = ?`,
                    [id]
                );
                result = rows[0] || null;
                break;
            }

            // ========== EMPRENDIMIENTOS ==========
            case "get_emprendimientos": {
                const schema = z.object({ usuario_id: z.number().int().positive().optional() });
                const args = schema.parse(request.params.arguments || {});

                let query = `SELECT * FROM emprendimientos_view`;
                const params = [];

                if (args.usuario_id) {
                    query += ` WHERE usuarioId = ?`;
                    params.push(args.usuario_id);
                }

                query += ` ORDER BY fechaCreacion DESC LIMIT 50`;

                const [rows] = await connection.execute(query, params);
                result = rows;
                break;
            }

            case "get_emprendimiento_by_id": {
                const schema = z.object({ id: z.number().int().positive() });
                const { id } = schema.parse(request.params.arguments);

                const [rows] = await connection.execute(
                    `SELECT * FROM emprendimientos_view WHERE id = ?`,
                    [id]
                );
                result = rows[0] || null;
                break;
            }

            // ========== CATEGORÍAS ==========
            case "get_categorias": {
                const [rows] = await connection.execute(
                    `SELECT * FROM categorias_view ORDER BY nombre`
                );
                result = rows;
                break;
            }

            // ========== ROLES ==========
            case "get_roles": {
                const [rows] = await connection.execute(
                    `SELECT * FROM roles_view ORDER BY nombre`
                );
                result = rows;
                break;
            }

            // ========== MENTORÍAS ==========
            case "get_mentorias": {
                const schema = z.object({
                    tutor_id: z.number().int().positive().optional(),
                    emprendimiento_id: z.number().int().positive().optional()
                });
                const args = schema.parse(request.params.arguments || {});

                let query = `SELECT * FROM mentorias_view WHERE 1=1`;
                const params = [];

                if (args.tutor_id) {
                    query += ` AND tutorId = ?`;
                    params.push(args.tutor_id);
                }
                if (args.emprendimiento_id) {
                    query += ` AND emprendimientoId = ?`;
                    params.push(args.emprendimiento_id);
                }

                query += ` ORDER BY fechaProgramada DESC LIMIT 50`;

                const [rows] = await connection.execute(query, params);
                result = rows;
                break;
            }

            // ========== RESEÑAS ==========
            case "get_resenas": {
                const schema = z.object({ emprendimiento_id: z.number().int().positive().optional() });
                const args = schema.parse(request.params.arguments || {});

                let query = `SELECT * FROM resenas_view`;
                const params = [];

                if (args.emprendimiento_id) {
                    query += ` WHERE emprendimientoId = ?`;
                    params.push(args.emprendimiento_id);
                }

                query += ` ORDER BY fecha DESC LIMIT 50`;

                const [rows] = await connection.execute(query, params);
                result = rows;
                break;
            }

            // ========== TUTORES ==========
            case "get_tutores": {
                const [rows] = await connection.execute(
                    `SELECT * FROM tutores_view ORDER BY nombre`
                );
                result = rows;
                break;
            }

            // ========== COLABORADORES ==========
            case "get_colaboradores": {
                const [rows] = await connection.execute(
                    `SELECT * FROM colaboradores_view ORDER BY nombre`
                );
                result = rows;
                break;
            }

            // ========== ESTADÍSTICAS ==========
            case "get_estadisticas_usuario": {
                const schema = z.object({ usuario_id: z.number().int().positive() });
                const { usuario_id } = schema.parse(request.params.arguments);

                const [rows] = await connection.execute(
                    `SELECT 
                        (SELECT COUNT(*) FROM emprendimientos WHERE usuarioId = ?) as total_emprendimientos,
                        (SELECT COUNT(*) FROM mentorias m 
                         JOIN emprendimientos e ON m.emprendimientoId = e.id 
                         WHERE e.usuarioId = ?) as total_mentorias_recibidas,
                        (SELECT COUNT(*) FROM resenas WHERE usuarioId = ?) as total_resenas_dadas,
                        (SELECT AVG(r.calificacion) FROM resenas r
                         JOIN emprendimientos e ON r.emprendimientoId = e.id
                         WHERE e.usuarioId = ?) as calificacion_promedio
                    `,
                    [usuario_id, usuario_id, usuario_id, usuario_id]
                );
                result = rows[0];
                break;
            }

            case "get_estadisticas_generales": {
                const [rows] = await connection.execute(
                    `SELECT 
                        (SELECT COUNT(*) FROM usuarios) as total_usuarios,
                        (SELECT COUNT(*) FROM emprendimientos) as total_emprendimientos,
                        (SELECT COUNT(*) FROM mentorias) as total_mentorias,
                        (SELECT COUNT(*) FROM resenas) as total_resenas,
                        (SELECT COUNT(*) FROM categorias) as total_categorias,
                        (SELECT AVG(calificacion) FROM resenas) as calificacion_promedio_general
                    `
                );
                result = rows[0];
                break;
            }

            default:
                throw new Error(`Herramienta no encontrada: ${request.params.name}`);
        }

        return {
            content: [{
                type: "text",
                text: JSON.stringify(result, null, 2)
            }]
        };
    } catch (error) {
        return {
            content: [{
                type: "text",
                text: `Error: ${error.message}`,
                isError: true
            }]
        };
    } finally {
        await connection.end();
    }
});

async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.log("🤖 MCP Server v2.0 started - Emprendimientos Full Access");
}

main().catch(console.error);
