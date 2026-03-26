"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const fs_1 = require("fs");
const path_1 = require("path");
const express = __importStar(require("express"));
BigInt.prototype.toJSON = function () {
    return this.toString();
};
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.use(express.json());
    app.use(express.urlencoded({ extended: true }));
    app.enableCors();
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
                const url = req.originalUrl ?? req.url ?? '';
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
                    type: 'API_REQUEST',
                    method: req.method,
                    url,
                    statusCode: res.statusCode,
                    duration: `${Date.now() - startTime}ms`,
                    payload: {
                        request: req.body,
                        response: responseBody
                    }
                };
                try {
                    (0, fs_1.appendFileSync)(logPath, '[API통신] ' + logEntry.method + url + '(' + logEntry.statusCode + ') - ' + logEntry.duration + '\n');
                    (0, fs_1.appendFileSync)(logPath, '[API통신_데이터]\n' + JSON.stringify(logEntry.payload, null, 2) + '\n');
                }
                catch { }
                console.log(`\n[API통신] ${logEntry.method} ${url} (${logEntry.statusCode}) - ${logEntry.duration}`);
                console.log(`[API통신_데이터]\n${JSON.stringify(logEntry.payload, null, 2)}`);
                console.log('-'.repeat(60));
            });
            next();
        });
    }
    const port = process.env.PORT ?? 4000;
    await app.listen(port);
    console.log(`🚀 애플리케이션 실행 중: http://localhost:${port}`);
}
bootstrap().catch((err) => {
    console.error('서버 부트스트랩 중 치명적 오류 발생:', err);
    process.exit(1);
});
//# sourceMappingURL=main.js.map