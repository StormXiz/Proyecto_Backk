import Fastify from 'fastify';
import prismaPlugin from './plugins/prisma.js';
import authPlugin from './plugins/auth.js';
import cors from '@fastify/cors';
import fastifySwagger from '@fastify/swagger';
import fastifySwaggerUi from '@fastify/swagger-ui';
import userRoutes from './routes/usuarios.routes.js';
import emprendimientoRoutes from './routes/emprendimientos.routes.js';
import rolesRoutes from './routes/roles.routes.js';
import categoriasRoutes from './routes/categorias.routes.js';
import authRoutes from './routes/auth.routes.js';
import mentoriasRoutes from './routes/mentorias.routes.js';
import resenasRoutes from './routes/resenas.routes.js';
import tutoresRoutes from './routes/tutores.routes.js';
import colaboradoresRoutes from './routes/colaboradores.routes.js';

export async function buildApp() {
    const app = Fastify({
        logger: true,
    });

    // Register CORS
    await app.register(cors, {
        origin: "*"
    });

    // Register Plugins
    await app.register(prismaPlugin);
    await app.register(authPlugin);

    // Register Swagger
    await app.register(fastifySwagger, {
        openapi: {
            info: {
                title: 'Centro de Co-creación UID API',
                description: 'API REST para la gestión de emprendimientos y usuarios del centro.',
                version: '1.0.0'
            },
            servers: [
                { url: 'http://localhost:3001' }
            ],
            components: {
                securitySchemes: {
                    bearerAuth: {
                        type: 'http',
                        scheme: 'bearer',
                        bearerFormat: 'JWT'
                    }
                }
            },
            security: [{ bearerAuth: [] }]
        }
    });

    await app.register(fastifySwaggerUi, {
        routePrefix: '/documentation',
        uiConfig: {
            docExpansion: 'list',
            deepLinking: false
        }
    });

    app.get('/health', async () => {
        return { status: 'ok' };
    });

    // API Routes
    await app.register(authRoutes, { prefix: '/api/auth' });
    await app.register(userRoutes, { prefix: '/api/usuarios' });
    await app.register(emprendimientoRoutes, { prefix: '/api/emprendimientos' });
    await app.register(rolesRoutes, { prefix: '/api/roles' });
    await app.register(categoriasRoutes, { prefix: '/api/categorias' });
    await app.register(mentoriasRoutes, { prefix: '/api/mentorias' });
    await app.register(resenasRoutes, { prefix: '/api/resenas' });
    await app.register(tutoresRoutes, { prefix: '/api/tutores' });
    await app.register(colaboradoresRoutes, { prefix: '/api/colaboradores' });

    return app;
}
