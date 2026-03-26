import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { appendFileSync, mkdirSync } from 'fs';
import { resolve } from 'path';
import type { NextFunction, Request, Response } from 'express';
import * as express from 'express'; // 요청 바디 파싱을 위해 필요

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // [중요] 미들웨어보다 먼저 실행되어야 req.body를 읽을 수 있습니다.
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  app.enableCors();

  const loggerEnabled = process.env.API_REQUEST_LOGGER !== 'false';

  if (loggerEnabled) {
    const workspaceRoot = resolve(__dirname, '..', '..', '..');
    const logsDir = resolve(workspaceRoot, 'logs');
    const logPath = resolve(logsDir, 'api-requests.log');

    try { mkdirSync(logsDir, { recursive: true }); } catch (err) { }

    app.use((req: Request, res: Response, next: NextFunction) => {
      const startTime = Date.now();

      // 응답 바디를 캡처하기 위한 버퍼 배열
      const chunks: Buffer[] = [];

      // res.write와 res.end를 가로채서 응답 데이터를 수집합니다.
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

        // 수집된 응답 데이터를 JSON으로 변환 시도
        let responseBody: any = null;
        try {
          const resBodyStr = Buffer.concat(chunks).toString('utf8');
          responseBody = resBodyStr ? JSON.parse(resBodyStr) : null;
        } catch {
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
            request: req.body,    // 클라이언트가 보낸 데이터
            response: responseBody // 서버가 보낸 실제 데이터
          }
        };

        try {
          // 파일에는 한 줄로 저장 (용량 절약 및 분석용)
          appendFileSync(logPath, '[API통신] ' + logEntry.method + url + '(' + logEntry.statusCode + ') - ' + logEntry.duration + '\n');
          appendFileSync(logPath, '[API통신_데이터]\n' + JSON.stringify(logEntry.payload, null, 2) + '\n');

        } catch { }

        // 터미널 콘솔 출력 (가독성을 위해 2칸 들여쓰기)
        console.log(`\n[API통신] ${logEntry.method} ${url} (${logEntry.statusCode}) - ${logEntry.duration}`);
        console.log(`[API통신_데이터]\n${JSON.stringify(logEntry.payload, null, 2)}`);
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