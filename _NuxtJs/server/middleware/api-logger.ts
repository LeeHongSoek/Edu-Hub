import { appendFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import { readBody } from 'h3';
import { getApiRequestLogPath } from '~/server/utils/log-path';

// 로그 경로 설정
const { logDir: logsDir, logPath } = getApiRequestLogPath();

// 서버 시작 시 디렉토리 생성 (비동기 권장)
if (process.dev && !existsSync(logsDir)) {
  mkdir(logsDir, { recursive: true }).catch(console.error);
}

export default defineEventHandler(async (event) => {
  // API 요청이 아니면 무시
  if (!process.dev || !event.path.startsWith('/api/')) return;

  const startTime = Date.now();
  const hasRequestBody = ['POST', 'PUT', 'PATCH', 'DELETE'].includes(event.method || '');
  const responseChunks: Buffer[] = [];
  const res = event.node.res as any;
  const originalWrite = res.write.bind(res);
  const originalEnd = res.end.bind(res);

  const toBuffer = (chunk: unknown, encoding?: any) => {
    if (Buffer.isBuffer(chunk)) return chunk;
    if (typeof chunk === 'string') return Buffer.from(chunk, encoding);
    if (chunk instanceof Uint8Array) return Buffer.from(chunk);
    return Buffer.from(String(chunk ?? ''));
  };

  res.write = (chunk: unknown, encoding?: any, callback?: any) => {
    if (chunk !== undefined && chunk !== null) {
      responseChunks.push(toBuffer(chunk, encoding));
    }

    return originalWrite(chunk, encoding, callback);
  };

  res.end = (chunk: unknown, encoding?: any, callback?: any) => {
    if (chunk !== undefined && chunk !== null) {
      responseChunks.push(toBuffer(chunk, encoding));
    }

    return originalEnd(chunk, encoding, callback);
  };

  let requestBodyPretty = '(empty)';
  if (hasRequestBody) {
    try {
      const requestBody = await readBody(event);
      requestBodyPretty = requestBody === null
        ? '(empty)'
        : typeof requestBody === 'string'
          ? requestBody
          : JSON.stringify(requestBody, null, 2);
    } catch {
      requestBodyPretty = '(unavailable)';
    }
  }

  // Nitro의 'close' 훅을 사용하여 응답이 끝난 후 로그 기록
  event.node.res.on('finish', async () => {
    const duration = Date.now() - startTime;
    const responseText = responseChunks.length > 0
      ? Buffer.concat(responseChunks).toString('utf8')
      : '';

    const responseBody = responseText
      ? (() => {
          try {
            return JSON.parse(responseText);
          } catch {
            return responseText;
          }
        })()
      : null;

    const reqEntry = {
      timestamp: new Date().toISOString(),
      method: event.method,
      url: event.path,
      body: requestBodyPretty,
    };

    const resEntry = {
      statusCode: event.node.res.statusCode,
      duration: `${duration}ms`,
      body: responseBody,
    };

    try {
      // appendFile (비동기)를 사용하여 성능 저하 방지
      const prettyLog = [
        'REQ',
        JSON.stringify(reqEntry, null, 2),
        'RES',
        JSON.stringify(resEntry, null, 2),
        ''
      ].join('\n');

      await appendFile(logPath, prettyLog + '\n');
    } catch (err) {
      console.error('[API-Logger] Write Error:', err);
    }
  });
});
