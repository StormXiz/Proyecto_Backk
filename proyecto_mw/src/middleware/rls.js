/**
 * Row-Level Security (RLS) Filter
 * Construye filtros de seguridad basados en el rol del usuario
 */

export default function buildRlsFilter(user) {
    // Si el usuario es admin, puede ver todo
    if (user.roles.includes('ADMIN')) {
        return {
            whereClause: {}, // Sin filtros = ve todo
            isAdmin: true
        };
    }

    // Usuario normal solo ve sus propios registros
    return {
        whereClause: { usuarioId: user.id },
        isAdmin: false
    };
}

/**
 * Verifica si un usuario es dueño de un registro específico
 */
export async function verifyOwnership(prisma, table, recordId, userId) {
    try {
        let record;

        switch (table) {
            case 'emprendimiento':
                record = await prisma.emprendimiento.findUnique({
                    where: { id: recordId },
                    select: { usuarioId: true }
                });
                break;
            case 'mentoria':
                // Mentoria pertenece a un emprendimiento, verificamos el dueño del emprendimiento
                record = await prisma.mentoria.findUnique({
                    where: { id: recordId },
                    select: { 
                        emprendimiento: {
                            select: { usuarioId: true }
                        }
                    }
                });
                return record ? record.emprendimiento.usuarioId === userId : false;
            case 'resena':
                record = await prisma.resena.findUnique({
                    where: { id: recordId },
                    select: { usuarioId: true }
                });
                break;
            default:
                return false;
        }

        if (!record) {
            return false; // Registro no existe
        }

        return record.usuarioId === userId; // ¿Es el dueño?
    } catch (error) {
        console.error('Error verificando propiedad:', error);
        return false;
    }
}
