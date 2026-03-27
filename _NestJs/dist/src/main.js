"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const fs_1 = require("fs");
const path_1 = require("path");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("./common/prisma/prisma.service");
BigInt.prototype.toJSON = function () {
    return this.toString();
};
const SQL_CONSOLE_PAGE = 'sql-console';
const SQL_CONSOLE_DEFAULT_QUERY = [
    'SELECT',
    '  q.question_id,',
    '  q.title,',
    '  g.name AS group_name,',
    '  u.username AS creator_name',
    'FROM questions q',
    'LEFT JOIN groups g ON g.group_id = q.group_id',
    'LEFT JOIN users u ON u.user_no = q.creator_no',
    'ORDER BY q.question_id DESC',
    'LIMIT 20;',
].join('\n');
const READ_QUERY_REGEX = /^\s*(select|show|desc|describe|explain|with)\b/i;
const MUTATION_QUERY_REGEX = /^\s*(insert|update|delete|replace|create|alter|drop|truncate|rename|grant|revoke|set|use)\b/i;
function normalizeSqlQuery(query) {
    return typeof query === 'string' ? query.trim() : '';
}
function validateSqlQuery(query) {
    if (!query) {
        return 'SQL 문을 입력해 주세요.';
    }
    const sanitized = query.replace(/;+\s*$/, '');
    if (!sanitized) {
        return '실행 가능한 SQL 문이 비어 있습니다.';
    }
    if (sanitized.includes(';')) {
        return '한 번에 하나의 SQL 문만 실행할 수 있습니다.';
    }
    return null;
}
function classifySqlQuery(query) {
    if (READ_QUERY_REGEX.test(query)) {
        return 'read';
    }
    if (MUTATION_QUERY_REGEX.test(query)) {
        return 'mutation';
    }
    return 'mutation';
}
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule, {
        bodyParser: true,
    });
    app.enableCors();
    app.setGlobalPrefix('api');
    const prisma = app.get(prisma_service_1.PrismaService);
    const [{ default: AdminJS, ComponentLoader }, AdminJSExpress, AdminJSPrisma] = await Promise.all([
        import('adminjs'),
        import('@adminjs/express'),
        import('@adminjs/prisma'),
    ]);
    AdminJS.registerAdapter({
        Database: AdminJSPrisma.Database,
        Resource: AdminJSPrisma.Resource,
    });
    const resourceNames = client_1.Prisma.dmmf.datamodel.models
        .map((model) => model.name)
        .filter((name) => !['ClassStudent', 'QuestionTag', 'ExamQuestion', 'UserQuestionBookItem'].includes(name));
    const adminEmail = process.env.ADMINJS_EMAIL || 'admin@edu-hub.com';
    const adminPassword = process.env.ADMINJS_PASSWORD || 'admin1234';
    const adminCookieSecret = process.env.ADMINJS_COOKIE_SECRET || 'edu-hub-admin-cookie-secret-change-me';
    const componentLoader = new ComponentLoader();
    const sqlConsoleComponent = componentLoader.add('SqlConsolePage', (0, path_1.resolve)(process.cwd(), 'src', 'adminjs', 'sql-console-page.jsx'));
    const admin = new AdminJS({
        rootPath: '/api/admin',
        loginPath: '/api/admin/login',
        logoutPath: '/api/admin/logout',
        componentLoader,
        resources: resourceNames.map((name) => ({
            resource: {
                model: AdminJSPrisma.getModelByName(name),
                client: prisma,
            },
            options: {
                navigation: 'MySQL DB',
            },
        })),
        branding: {
            companyName: 'Edu Hub DB Admin',
        },
        pages: {
            [SQL_CONSOLE_PAGE]: {
                icon: 'Terminal',
                component: sqlConsoleComponent,
                handler: async (request) => {
                    if (request.method?.toLowerCase() !== 'post') {
                        return {
                            ok: true,
                            mode: 'idle',
                            defaultQuery: SQL_CONSOLE_DEFAULT_QUERY,
                            helperText: '단일 SQL만 실행됩니다. SELECT/SHOW 계열은 결과 테이블, 그 외는 영향 건수로 표시됩니다.',
                        };
                    }
                    const query = normalizeSqlQuery(request.payload?.query);
                    const validationError = validateSqlQuery(query);
                    if (validationError) {
                        return {
                            ok: false,
                            error: validationError,
                            query,
                        };
                    }
                    try {
                        const mode = classifySqlQuery(query);
                        if (mode === 'read') {
                            const rows = await prisma.$queryRawUnsafe(query);
                            const columns = Array.from(rows.reduce((set, row) => {
                                Object.keys(row).forEach((key) => set.add(key));
                                return set;
                            }, new Set()));
                            return {
                                ok: true,
                                mode,
                                query,
                                columns,
                                rows,
                                rowCount: rows.length,
                            };
                        }
                        const affectedRows = await prisma.$executeRawUnsafe(query);
                        return {
                            ok: true,
                            mode,
                            query,
                            affectedRows,
                        };
                    }
                    catch (error) {
                        return {
                            ok: false,
                            query,
                            error: error instanceof Error ? error.message : 'SQL 실행 중 알 수 없는 오류가 발생했습니다.',
                        };
                    }
                },
            },
        },
    });
    if (process.env.NODE_ENV !== 'production') {
        const adminTmpDir = (0, path_1.resolve)(process.cwd(), '.adminjs');
        if ((0, fs_1.existsSync)(adminTmpDir)) {
            (0, fs_1.rmSync)(adminTmpDir, { recursive: true, force: true });
        }
        void admin.watch().catch((error) => {
            console.error('AdminJS component watch failed:', error);
        });
    }
    const adminRouter = AdminJSExpress.buildAuthenticatedRouter(admin, {
        authenticate: async (email, password) => {
            if (email === adminEmail && password === adminPassword) {
                return { email };
            }
            return null;
        },
        cookieName: 'edu-hub-admin',
        cookiePassword: adminCookieSecret,
    }, null, {
        secret: adminCookieSecret,
        resave: false,
        saveUninitialized: false,
    });
    app.use('/admin', (req, res) => {
        const suffix = req.originalUrl.replace(/^\/admin/, '') || '';
        res.redirect(302, `/api/admin${suffix}`);
    });
    app.use(admin.options.rootPath, adminRouter);
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
                    const logHeader = `[API통신_헤더] <${logEntry.method}> ${url} (${logEntry.statusCode}) - ${logEntry.duration}\n`;
                    const logReqData = hasRequest ? `[API통신_데이터_요청]\n${JSON.stringify(logEntry.payload.request, null, tabSize)}\n` : '';
                    const logResData = `[API통신_데이터_응답]\n${JSON.stringify(logEntry.payload.response, null, tabSize)}\n`;
                    (0, fs_1.appendFileSync)(logPath, logHeader + logReqData + logResData);
                }
                catch { }
                console.log(`\n[API통신_헤더] <${logEntry.method}> ${url} (${logEntry.statusCode}) - ${logEntry.duration}`);
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