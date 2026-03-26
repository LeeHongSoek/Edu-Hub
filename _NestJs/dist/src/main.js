"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const fs_1 = require("fs");
const path_1 = require("path");
BigInt.prototype.toJSON = function () {
    return this.toString();
};
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.enableCors();
    const loggerEnabled = process.env.API_REQUEST_LOGGER !== 'false';
    if (loggerEnabled) {
        const workspaceRoot = (0, path_1.resolve)(__dirname, '..', '..', '..');
        const logsDir = (0, path_1.resolve)(workspaceRoot, 'logs');
        const logPath = (0, path_1.resolve)(logsDir, 'api-requests.log');
        try {
            (0, fs_1.mkdirSync)(logsDir, { recursive: true });
        }
        catch (err) {
            console.error('[API-REQUEST-LOGGER] Failed to create logs dir:', err);
        }
        try {
            (0, fs_1.appendFileSync)(logPath, JSON.stringify({
                timestamp: new Date().toISOString(),
                type: 'LOGGER_INIT',
                message: 'Nest API request logger initialized',
            }) + '\n');
        }
        catch {
        }
        app.use((req, res, next) => {
            const startTime = Date.now();
            res.on('finish', () => {
                const url = req.originalUrl ?? req.url ?? '';
                if (url.includes('favicon.ico') || url.includes('sockjs-node'))
                    return;
                const logEntry = {
                    timestamp: new Date().toISOString(),
                    type: 'API_REQUEST',
                    method: req.method,
                    url,
                    statusCode: res.statusCode,
                    duration: `${Date.now() - startTime}ms`,
                };
                try {
                    (0, fs_1.appendFileSync)(logPath, JSON.stringify(logEntry) + '\n');
                }
                catch {
                }
                console.log(`[API] ${logEntry.method} ${logEntry.url} (${logEntry.statusCode}) ${logEntry.duration}`);
            });
            next();
        });
    }
    const port = process.env.PORT ?? 4000;
    await app.listen(port);
    console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap().catch((err) => {
    console.error('Fatal bootstrap error:', err);
    process.exit(1);
});
//# sourceMappingURL=main.js.map