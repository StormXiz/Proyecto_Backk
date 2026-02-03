import { buildApp } from './app.js';
import dotenv from 'dotenv';
import { testConnection } from './config/database.js';

dotenv.config();

const start = async () => {
    const app = await buildApp();
    try {
        // Test database connection
        await testConnection();

        const port = Number(process.env.PORT) || 3001;
        await app.listen({ port, host: '0.0.0.0' });
        console.log(`Server running at: http://localhost:${port}`);
        console.log(`API Documentation: http://localhost:${port}/documentation`);
    } catch (err) {
        app.log.error(err);
        process.exit(1);
    }
};

start();
