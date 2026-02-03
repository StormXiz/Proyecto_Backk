export default async function rolesRoutes(fastify, opts) {

    const createRoleSchema = {
        description: 'Crear un nuevo rol',
        tags: ['Roles'],
        body: {
            type: 'object',
            required: ['nombre'],
            properties: {
                nombre: { type: 'string', enum: ['ADMIN', 'EMPRENDEDOR', 'MENTOR', 'CLIENTE', 'ESTUDIANTE', 'TUTOR', 'COLABORADOR'] }
            }
        },
        response: {
            201: {
                description: 'Rol creado',
                type: 'object',
                properties: {
                    id: { type: 'number' },
                    nombre: { type: 'string' }
                }
            }
        }
    };

    fastify.post('/', {
        schema: createRoleSchema,
        preHandler: [fastify.authenticate, fastify.requireAdmin]
    }, async (request, reply) => {
        const { nombre } = request.body;
        const role = await fastify.prisma.rol.create({
            data: { nombre }
        });
        return reply.code(201).send(role);
    });

    const getRolesSchema = {
        description: 'Obtener lista de roles',
        tags: ['Roles'],
        response: {
            200: {
                type: 'array',
                items: {
                    type: 'object',
                    properties: {
                        id: { type: 'number' },
                        nombre: { type: 'string' }
                    }
                }
            }
        }
    };

    fastify.get('/', { schema: getRolesSchema }, async (request, reply) => {
        const roles = await fastify.prisma.rol.findMany();
        return roles;
    });
}
