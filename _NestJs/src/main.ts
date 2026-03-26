import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { appendFileSync, mkdirSync } from 'fs';
import { resolve } from 'path';
import type { NextFunction, Request, Response } from 'express';

// BigInt 타입을 JSON으로 직렬화할 때 문자열로 변환하는 설정
(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // CORS 활성화
  app.enableCors();

  // 디버깅용: 요청(HTTP incoming) 들어올 때마다 1줄 로그를 파일에 기록
  // - Nuxt가 아닌 Nest 백엔드로 들어오는 요청도 잡히도록 구성
  // - `tail -f logs/api-requests.log` 기준(프로젝트 루트)과 경로를 일치시킴
  const loggerEnabled = process.env.API_REQUEST_LOGGER !== 'false';
  if (loggerEnabled) {
    const workspaceRoot = resolve(__dirname, '..', '..', '..'); // _NestJs/src(or dist/src) -> workspace root
    const logsDir = resolve(workspaceRoot, 'logs');
    const logPath = resolve(logsDir, 'api-requests.log');

    try {
      mkdirSync(logsDir, { recursive: true });
    } catch (err) {
      console.error('[API-REQUEST-LOGGER] Failed to create logs dir:', err);
    }

    app.use((req: Request, res: Response, next: NextFunction) => {
      const startTime = Date.now();

      res.on('finish', () => {
        // 정적/소켓 등 불필요 로그 줄이기(원하면 범위 확대 가능)
        const url = req.originalUrl ?? req.url ?? '';
        if (url.includes('favicon.ico') || url.includes('sockjs-node')) return;

        const logEntry = {
          timestamp: new Date().toISOString(),
          type: 'API_REQUEST',
          method: req.method,
          url,
          statusCode: res.statusCode,
          duration: `${Date.now() - startTime}ms`,
        };

        try {
          appendFileSync(logPath, JSON.stringify(logEntry) + '\n');
        } catch (err) {
          // 파일 기록이 실패해도 요청 흐름은 유지
        }

        console.log(`[API] ${logEntry.method} ${logEntry.url} (${logEntry.statusCode}) ${logEntry.duration}`);
      });

      next();
    });
  }
  
  // 환경변수에서 포트를 가져오거나 기본값 4000 사용
  const port = process.env.PORT ?? 4000;
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
