import buildRlsFilter, { verifyOwnership } from '../middleware/rls.js';

export default async function emprendimientosRoutes(fastify, opts) {
    // Aplicar autenticación a todas las rutas
    fastify.addHook('onRequest', fastify.authenticate);

    const createEmprendimientoSchema = {
        description: 'Registrar nuevo emprendimiento',
        tags: ['Emprendimientos'],
        body: {
            type: 'object',
            required: ['nombre', 'categoriaId'],
            properties: {
                nombre: { type: 'string' },
                descripcion: { type: 'string' },
                categoriaId: { type: 'number' }
            }
        },
        response: {
            201: {
                description: 'Emprendimiento registrado',
                type: 'object',
                properties: {
                    id: { type: 'number' },
                    nombre: { type: 'string' },
                    estado: { type: 'string' },
                    usuarioId: { type: 'number' }
                }
            }
        }
    };

    fastify.post('/', {
        schema: createEmprendimientoSchema
    }, async (request, reply) => {
        const { nombre, descripcion, categoriaId } = request.body;
        // El usuarioId viene del token JWT, no del body
        const userId = request.user.id;

        const emprendimiento = await fastify.prisma.emprendimiento.create({
            data: {
                nombre,
                descripcion,
                usuarioId: userId,
                categoriaId,
                estado: 'EN_REVISION'
            }
        });

        return reply.code(201).send(emprendimiento);
    });

    const getEmprendimientosSchema = {
        description: 'Obtener emprendimientos (con RLS aplicado)',
        tags: ['Emprendimientos'],
        response: {
            200: {
                type: 'object',
                properties: {
                    message: { type: 'string' },
                    userId: { type: 'number' },
                    rlsFilter: { type: 'string' },
                    count: { type: 'number' },
                    emprendimientos: {
                        type: 'array',
                        items: {
                            type: 'object',
                            properties: {
                                id: { type: 'number' },
                                nombre: { type: 'string' },
                                descripcion: { type: 'string' },
                                estado: { type: 'string' }
                            }
                        }
                    }
                }
            }
        }
    };

    fastify.get('/', { schema: getEmprendimientosSchema }, async (request, reply) => {
        const user = request.user;
        const { whereClause, isAdmin } = buildRlsFilter(user);

        const emprendimientos = await fastify.prisma.emprendimiento.findMany({
            where: whereClause,
            include: {
                usuario: {
                    select: { nombre: true, email: true }
                },
                categoria: true
            }
        });

        return {
            message: 'Emprendimientos obtenidos con RLS',
            userId: user.id,
            rlsFilter: isAdmin ? 'ADMIN - ve todos' : `usuarioId = ${user.id}`,
            count: emprendimientos.length,
            emprendimientos
        };
    });

    // PUT - Actualizar emprendimiento
    fastify.put('/:id', {
        schema: {
            description: 'Actualizar emprendimiento (solo dueño o admin)',
            tags: ['Emprendimientos'],
            params: {
                type: 'object',
                properties: {
                    id: { type: 'number' }
                }
            },
            body: {
                type: 'object',
                properties: {
                    nombre: { type: 'string' },
                    descripcion: { type: 'string' },
                    categoriaId: { type: 'number' }
                }
            }
        }
    }, async (request, reply) => {
        const { id } = request.params;
        const { nombre, descripcion, categoriaId } = request.body;
        const user = request.user;
        const isAdmin = user.roles.includes('ADMIN');

        // Verificar propiedad si no es admin
        if (!isAdmin) {
            const isOwner = await verifyOwnership(fastify.prisma, 'emprendimiento', Number(id), user.id);
            if (!isOwner) {
                return reply.code(403).send({
                    error: 'Forbidden',
                    message: 'No tienes permiso para actualizar este emprendimiento'
                });
            }
        }

        const emprendimiento = await fastify.prisma.emprendimiento.update({
            where: { id: Number(id) },
            data: {
                nombre,
                descripcion,
                categoriaId
            }
        });

        return {
            message: 'Emprendimiento actualizado exitosamente',
            emprendimiento
        };
    });

    fastify.delete('/:id', {
        schema: {
            description: 'Eliminar emprendimiento (solo dueño o admin)',
            tags: ['Emprendimientos'],
            params: {
                type: 'object',
                properties: {
                    id: { type: 'number' }
                }
            },
            response: {
                200: {
                    type: 'object',
                    properties: {
                        message: { type: 'string' }
                    }
                },
                403: {
                    type: 'object',
                    properties: {
                        error: { type: 'string' },
                        message: { type: 'string' }
                    }
                }
            }
        }
    }, async (request, reply) => {
        const { id } = request.params;
        const user = request.user;
        const isAdmin = user.roles.includes('ADMIN');

        // Verificar propiedad si no es admin
        if (!isAdmin) {
            const isOwner = await verifyOwnership(fastify.prisma, 'emprendimiento', Number(id), user.id);
            if (!isOwner) {
                return reply.code(403).send({
                    error: 'Forbidden',
                    message: 'No tienes permiso para eliminar este emprendimiento'
                });
            }
        }

        await fastify.prisma.emprendimiento.delete({
            where: { id: Number(id) }
        });

        return { message: 'Emprendimiento eliminado exitosamente' };
    });
}
