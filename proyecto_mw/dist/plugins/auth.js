import jwt from 'jsonwebtoken';
export const authenticate = async (request, reply) => {
    try {
        const token = request.headers.authorization?.split(' ')[1];
        if (!token) {
            return reply.code(401).send({ message: 'Token no proporcionado' });
        }
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key_change_me');
        request.user = decoded;
    }
    catch (err) {
        return reply.code(401).send({ message: 'Token inválido o expirado' });
    }
};
export const authorize = (allowedRoles) => {
    return async (request, reply) => {
        const userRoles = request.user?.roles || [];
        // Check direct match
        let hasRole = userRoles.some(role => allowedRoles.includes(role));
        // Map synonyms for checking: ESTUDIANTE -> EMPRENDEDOR, TUTOR -> MENTOR
        if (!hasRole) {
            const effectiveRoles = userRoles.map(r => {
                if (r === 'ESTUDIANTE')
                    return 'EMPRENDEDOR';
                if (r === 'TUTOR')
                    return 'MENTOR';
                return r;
            });
            hasRole = effectiveRoles.some(role => allowedRoles.includes(role));
        }
        if (!hasRole) {
            return reply.code(403).send({ message: `Acceso denegado. Requiere uno de los roles: ${allowedRoles.join(', ')}` });
        }
    };
};
