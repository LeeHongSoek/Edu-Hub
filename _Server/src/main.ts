import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { appendFileSync, existsSync, mkdirSync, rmSync } from 'fs';
import { resolve } from 'path';
import type { NextFunction, Request, Response } from 'express';
import { Prisma } from '@prisma/client';
import { PrismaService } from './common/prisma/prisma.service';

(BigInt.prototype as any).toJSON = function () {
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

function normalizeSqlQuery(query: unknown): string {
  return typeof query === 'string' ? query.trim() : '';
}

function validateSqlQuery(query: string): string | null {
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

function classifySqlQuery(query: string): 'read' | 'mutation' {
  if (READ_QUERY_REGEX.test(query)) {
    return 'read';
  }

  if (MUTATION_QUERY_REGEX.test(query)) {
    return 'mutation';
  }

  return 'mutation';
}

function toPrismaModelName(delegateName: string): string {
  return delegateName.charAt(0).toUpperCase() + delegateName.slice(1);
}

async function bootstrap() {
  const frontendOrigin = process.env.FRONTEND_ORIGIN || 'http://127.0.0.1:0'; // 실제론 0 이 되어선 안됀다.

  const app = await NestFactory.create(AppModule, {
    bodyParser: true,
  });
  const expressApp = app.getHttpAdapter().getInstance();

  app.enableCors();
  expressApp.set('trust proxy', 1);

  app.use((req: Request, res: Response, next: NextFunction) => {
    if (req.method === 'GET' && req.path === '/') {
      return res.redirect(302, frontendOrigin);
    }

    next();
  });

  app.setGlobalPrefix('api');

  const prisma = app.get<PrismaService>(PrismaService);
  const [{ default: AdminJS, ComponentLoader }, AdminJSExpress, AdminJSPrisma] = await Promise.all([
    import('adminjs'),
    import('@adminjs/express'),
    import('@adminjs/prisma'),
  ]);

  AdminJS.registerAdapter({
    Database: AdminJSPrisma.Database,
    Resource: AdminJSPrisma.Resource,
  });

  const excludedResourceNames = new Set([
    'ClassStudent',
    'QuestionTag',
    'ExamQuestion',
    'QuestionBookItem',
  ]);

  const resourceNames = Object.keys(prisma)
    .filter((key) => !key.startsWith('$') && !key.startsWith('_'))
    .map(toPrismaModelName)
    .filter((name) => !excludedResourceNames.has(name))
    .filter((name) => {
      try {
        return Boolean(AdminJSPrisma.getModelByName(name));
      } catch {
        return false;
      }
    });

  const adminEmail = process.env.ADMINJS_EMAIL || 'lhs0806@gmail.com';
  const adminPassword = process.env.ADMINJS_PASSWORD || 'Leehs1181!';
  const adminCookieSecret = process.env.ADMINJS_COOKIE_SECRET || 'edu-hub-admin-cookie-secret-change-me';
  const componentLoader = new ComponentLoader();
  const sqlConsoleComponent = componentLoader.add(
    'SqlConsolePage',
    resolve(process.cwd(), 'src', 'adminjs', 'sql-console-page.jsx'),
  );

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
              const rows = (await prisma.$queryRawUnsafe(query)) as Record<string, unknown>[];
              const columns = Array.from(
                rows.reduce((set, row) => {
                  Object.keys(row).forEach((key) => set.add(key));
                  return set;
                }, new Set<string>()),
              );

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
          } catch (error) {
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
    const adminTmpDir = resolve(process.cwd(), '.adminjs');

    // Avoid serving a stale empty custom-component bundle in development.
    if (existsSync(adminTmpDir)) {
      rmSync(adminTmpDir, { recursive: true, force: true });
    }

    void admin.watch().catch((error) => {
      console.error('AdminJS component watch failed:', error);
    });
  }

  app.use('/api/admin', (req: Request, res: Response, next: NextFunction) => {
    const originalEnd = res.end;

    res.end = function (chunk: any, ...args: any[]) {
      const setCookie = res.getHeader('set-cookie');
      const location = res.getHeader('location');

      console.log('[AdminJS] response', {
        method: req.method,
        url: req.originalUrl,
        host: req.headers.host,
        origin: req.headers.origin,
        referer: req.headers.referer,
        forwardedProto: req.headers['x-forwarded-proto'],
        forwardedHost: req.headers['x-forwarded-host'],
        cookie: req.headers.cookie,
        statusCode: res.statusCode,
        location,
        setCookie,
      });

      return originalEnd.apply(res, [chunk, ...args]);
    };

    next();
  });

  const adminRouter = AdminJSExpress.buildAuthenticatedRouter(
    admin,
    {
      authenticate: async (email: string, password: string) => {
        if (email === adminEmail && password === adminPassword) {
          console.log('[AdminJS] login success', { email });
          return { email };
        }

        console.warn('[AdminJS] login failed', { email });
        return null;
      },
      cookieName: 'edu-hub-admin',
      cookiePassword: adminCookieSecret,
    },
    null,
    {
      secret: adminCookieSecret,
      proxy: true,
      name: 'edu-hub-admin-session',
      rolling: true,
      resave: false,
      saveUninitialized: true,
      cookie: {
        httpOnly: true,
        sameSite: 'lax',
        secure: false,
        maxAge: 1000 * 60 * 60 * 8,
      },
    },
  );
  app.use('/admin', (req: Request, res: Response) => {
    const suffix = req.originalUrl.replace(/^\/admin/, '') || '';
    res.redirect(302, `/api/admin${suffix}`);
  });
  app.use(admin.options.rootPath, adminRouter);


  const loggerEnabled = process.env.API_REQUEST_LOGGER !== 'false';

  if (loggerEnabled) {
    const workspaceRoot = resolve(__dirname, '..', '..', '..');
    const logsDir = resolve(workspaceRoot, 'logs');
    const logPath = resolve(logsDir, 'api-back.log');

    try { mkdirSync(logsDir, { recursive: true }); } catch (err) { }

    app.use((req: Request, res: Response, next: NextFunction) => {
      const startTime = Date.now();
      const chunks: Buffer[] = [];

      const originalWrite = res.write;
      const originalEnd = res.end;

      res.write = function (chunk: any, ...args: any[]) {
        if (chunk) chunks.push(Buffer.from(chunk));
        return originalWrite.apply(res, [chunk, ...args]);
      };

      res.end = function (chunk: any, ...args: any[]) {
        if (chunk) chunks.push(Buffer.from(chunk));
        return originalEnd.apply(res, [chunk, ...args]);
      };

      res.on('finish', () => {
        const url = req.originalUrl ?? req.url ?? '';
        if (url.includes('favicon.ico') || url.includes('sockjs-node')) return;

        let responseBody: any = null;
        try {
          const resBodyStr = Buffer.concat(chunks).toString('utf8');
          responseBody = resBodyStr ? JSON.parse(resBodyStr) : null;
        } catch {
          responseBody = '[Non-JSON Data]';
        }

        const logEntry = {
          timestamp: new Date().toISOString(),
          method: req.method,
          url,
          statusCode: res.statusCode,
          duration: `${Date.now() - startTime}ms`,
          payload: {
            // [포인트] finish 이벤트 시점에는 req.body가 확실히 채워져 있습니다.
            request: req.body || {},
            response: responseBody
          }
        };

        /**
         * ---------------------------------------------------------
         *        ✨🌟✨  긴급 해결 마법 ✨🌟✨
         * 
         *        데이터가 제대로 안 찍히는 그 순간...
         * 
         *   🔥 개발자 도구 (F12) 를 열고
         *   📡 Network 탭으로 이동한 뒤
         *   💾 "캐시 사용 안함" 체크박스를 ON!
         * 
         *   → 새로고침 (Ctrl + F5) 하면
         *      모든 데이터가 화려하게 부활합니다! ✨
         * 
         *     캐시여, 물러가라! 데이터여, 나타나라! 
         * 
         */


        // 요청 데이터(Body)가 존재하는지 확인 (빈 객체 {} 가 아닐 때)
        const hasRequest = logEntry.payload.request && Object.keys(logEntry.payload.request).length > 0;

        const tabSize = 8;
        try {
          const logHeader = `[API통신_헤더<back>] <${logEntry.method}> ${url} (${logEntry.statusCode}) - ${logEntry.duration}ms [${new Date().toLocaleString()}]\n`;

          // 요청 데이터가 있을 때만 요청 로그 생성, 없으면 빈 문자열
          const logReqData = hasRequest ? `[API통신_데이터_요청<back>]\n${JSON.stringify(logEntry.payload.request, null, tabSize)}\n` : '';

          const logResData = `[API통신_데이터_응답<back>]\n${JSON.stringify(logEntry.payload.response, null, tabSize)}\n`;

          const logContent = logHeader + logReqData + logResData;

          appendFileSync(logPath, logContent);
          if (
            !logHeader.includes('/api/sys-logs') &&
            !logHeader.includes('/api/user-logs')
          ) {
            const now = new Date();
            const local = new Date(now.getTime() - now.getTimezoneOffset() * 60000);
            const createdAt = local
              .toISOString()
              .slice(0, 19)
              .replace('T', ' ');
            void prisma
              .$executeRaw(
                Prisma.sql`INSERT INTO sys_logs (content, created_at) VALUES (${logContent}, ${createdAt})`,
              )
              .catch(() => { });
          }
        } catch { }

        // // 콘솔 출력
        console.log(`\n[API통신_헤더<back>] <${logEntry.method}> ${url} (${logEntry.statusCode}) - ${logEntry.duration} [${new Date().toLocaleString()}]`);

        // if (logEntry.payload.request.length > 0) {
        //   console.table(logEntry.payload.request);
        // }
        // console.table(logEntry.payload.response);

        // // 요청 데이터가 있을 때만 콘솔에 출력
        // if (hasRequest) {
        //   console.log(`[API통신_데이터_요청]\n${JSON.stringify(logEntry.payload.request, null, tabSize)}`);
        // }

        // console.log(`[API통신_데이터_응답]\n${JSON.stringify(logEntry.payload.response, null, tabSize)}`);
        // console.log('-'.repeat(60));
      });

      next();
    });
  }

  const port = process.env.BACKEND_PORT || process.env.PORT || 4000;
  await app.listen(port);
  console.log(`🚀 애플리케이션 실행 중: http://localhost:${port} 🚀`);
}

bootstrap().catch((err) => {
  console.error('서버 부트스트랩 중 치명적 오류 발생:', err);
  process.exit(1);
});
