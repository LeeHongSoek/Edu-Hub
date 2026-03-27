import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { appendFileSync, mkdirSync } from 'fs';
import { resolve } from 'path';
import type { NextFunction, Request, Response } from 'express';

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

async function bootstrap() {

  const app = await NestFactory.create(AppModule, {
    bodyParser: true,
  });

  app.enableCors();
  app.setGlobalPrefix('api');


  const loggerEnabled = process.env.API_REQUEST_LOGGER !== 'false';

  if (loggerEnabled) {
    const workspaceRoot = resolve(__dirname, '..', '..', '..');
    const logsDir = resolve(workspaceRoot, 'logs');
    const logPath = resolve(logsDir, 'api-requests.log');

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
         *           ✨🌟✨  긴급 해결 마법 ✨🌟✨
         * 
         *           데이터가 제대로 안 찍히는 그 순간...
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
          const logHeader = `[API통신_헤더] ${logEntry.method} ${url} (${logEntry.statusCode}) - ${logEntry.duration}\n`;

          // 요청 데이터가 있을 때만 요청 로그 생성, 없으면 빈 문자열
          const logReqData = hasRequest ? `[API통신_데이터_요청]\n${JSON.stringify(logEntry.payload.request, null, tabSize)}\n` : '';

          const logResData = `[API통신_데이터_응답]\n${JSON.stringify(logEntry.payload.response, null, tabSize)}\n`;

          appendFileSync(logPath, logHeader + logReqData + logResData);
        } catch { }

        // 콘솔 출력
        console.log(`\n[API통신_헤더] ${logEntry.method} ${url} (${logEntry.statusCode}) - ${logEntry.duration}`);

        // 요청 데이터가 있을 때만 콘솔에 출력
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