import fp from 'fastify-plugin';
import jwt from '@fastify/jwt';
import dotenv from 'dotenv';
dotenv.config();

async function authPlugin(fastify, options) {
    // Registrar @fastify/jwt
    await fastify.register(jwt, {
        secret: process.env.JWT_SECRET || 'secret_key_change_me'
    });

    // Decorator para autenticación
    fastify.decorate('authenticate', async function (request, reply) {
        try {
            await request.jwtVerify();
        } catch (error) {
            reply.status(401).send({
                error: 'Unauthorized',
                message: 'Token inválido o no proporcionado'
            });
        }
    });

    // Decorator para verificar rol de admin
    fastify.decorate('requireAdmin', async function (request, reply) {
        try {
            const user = request.user;
            if (!user || !user.roles.includes('ADMIN')) {
                reply.status(403).send({
                    error: 'Forbidden',
                    message: 'No tienes permiso para acceder a este recurso. Se requiere rol ADMIN.'
                });
            }
        } catch (error) {
            reply.status(401).send({
                error: 'Unauthorized',
                message: 'Token inválido'
            });
        }
    });
}

export default fp(authPlugin);
