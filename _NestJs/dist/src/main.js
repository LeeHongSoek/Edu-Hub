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
    const app = await core_1.NestFactory.create(app_module_1.AppModule, {
        bodyParser: true,
    });
    app.enableCors();
    app.setGlobalPrefix('api');
    const loggerEnabled = process.env.API_REQUEST_LOGGER !== 'false';
    if (loggerEnabled) {
        const workspaceRoot = (0, path_1.resolve)(__dirname, '..', '..', '..');
        const logsDir = (0, path_1.resolve)(workspaceRoot, 'logs');
        const logPath = (0, path_1.resolve)(logsDir, 'api-requests.log');
        try {
            (0, fs_1.mkdirSync)(logsDir, { recursive: true });
        }
        catch (err) { }
        app.use((req, res, next) => {
            const startTime = Date.now();
            const chunks = [];
            const originalWrite = res.write;
            const originalEnd = res.end;
            res.write = function (chunk, ...args) {
                if (chunk)
                    chunks.push(Buffer.from(chunk));
                return originalWrite.apply(res, [chunk, ...args]);
            };
            res.end = function (chunk, ...args) {
                if (chunk)
                    chunks.push(Buffer.from(chunk));
                return originalEnd.apply(res, [chunk, ...args]);
            };
            res.on('finish', () => {
                let url = req.originalUrl ?? req.url ?? '';
                if (!url.startsWith('/api')) {
                    url = `/api${url.startsWith('/') ? '' : '/'}${url}`;
                }
                if (url.includes('favicon.ico') || url.includes('sockjs-node'))
                    return;
                let responseBody = null;
                try {
                    const resBodyStr = Buffer.concat(chunks).toString('utf8');
                    responseBody = resBodyStr ? JSON.parse(resBodyStr) : null;
                }
                catch {
                    responseBody = '[Non-JSON Data]';
                }
                const logEntry = {
                    timestamp: new Date().toISOString(),
                    method: req.method,
                    url,
                    statusCode: res.statusCode,
                    duration: `${Date.now() - startTime}ms`,
                    payload: {
                        request: req.body || {},
                        response: responseBody
                    }
                };
                const hasRequest = logEntry.payload.request && Object.keys(logEntry.payload.request).length > 0;
                const tabSize = 8;
                try {
                    const logHeader = `[API통신_헤더] ${logEntry.method} ${url} (${logEntry.statusCode}) - ${logEntry.duration}\n`;
                    const logReqData = hasRequest ? `[API통신_데이터_요청]\n${JSON.stringify(logEntry.payload.request, null, tabSize)}\n` : '';
                    const logResData = `[API통신_데이터_응답]\n${JSON.stringify(logEntry.payload.response, null, tabSize)}\n`;
                    (0, fs_1.appendFileSync)(logPath, logHeader + logReqData + logResData);
                }
                catch { }
                console.log(`\n[API통신_헤더] ${logEntry.method} ${url} (${logEntry.statusCode}) - ${logEntry.duration}`);
                if (hasRequest) {
                    console.log(`[API통신_데이터_요청]\n${JSON.stringify(logEntry.payload.request, null, tabSize)}`);
                }
                console.log(`[API통신_데이터_응답]\n${JSON.stringify(logEntry.payload.response, null, tabSize)}`);
                console.log('-'.repeat(60));
            });
            next();
        });
    }
    const port = process.env.PORT ?? 4000;
    await app.listen(port);
    console.log(`🚀 애플리케이션 실행 중: http://localhost:${port} 🚀`);
}
bootstrap().catch((err) => {
    console.error('서버 부트스트랩 중 치명적 오류 발생:', err);
    process.exit(1);
});
//# sourceMappingURL=main.js.map