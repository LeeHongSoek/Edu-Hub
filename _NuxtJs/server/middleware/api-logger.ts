import { appendFile, mkdir } from 'fs/promises';
import { resolve } from 'path';
import { existsSync } from 'fs';

// 로그 경로 설정
const logsDir = resolve('logs');
const logPath = resolve('logs/api-requests.log');

// 서버 시작 시 디렉토리 생성 (비동기 권장)
if (process.dev && !existsSync(logsDir)) {
  mkdir(logsDir, { recursive: true }).catch(console.error);
}

export default defineEventHandler(async (event) => {
  // API 요청이 아니면 무시
  if (!process.dev || !event.path.startsWith('/api/')) return;

  const startTime = Date.now();

  // Nitro의 'close' 훅을 사용하여 응답이 끝난 후 로그 기록
  event.node.res.on('finish', async () => {
    const duration = Date.now() - startTime;

    const logEntry = {
      timestamp: new Date().toISOString(),
      method: event.method,
      url: event.path,
      statusCode: event.node.res.statusCode,
      duration: `${duration}ms`,
    };

    try {
      // appendFile (비동기)를 사용하여 성능 저하 방지
      await appendFile(logPath, JSON.stringify(logEntry) + '\n');
    } catch (err) {
      console.error('[API-Logger] Write Error:', err);
    }
  });
});