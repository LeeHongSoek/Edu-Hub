import { appendFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import { readBody } from 'h3';
import { getApiRequestLogPath } from '~/server/utils/log-path';

// 로그 경로 설정
const { logDir: logsDir, logPath } = getApiRequestLogPath('api-front.log');

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

  let requestBody: unknown = null;
  if (hasRequestBody) {
    try {
      requestBody = await readBody(event);
    } catch {
      requestBody = '(unavailable)';
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

    try {
      // appendFile (비동기)를 사용하여 성능 저하 방지
      const tabSize = 8;
      const requestBodyPretty = requestBody === null
        ? '(empty)'
        : requestBody === '(unavailable)'
          ? '(unavailable)'
          : typeof requestBody === 'string'
            ? JSON.stringify(requestBody, null, tabSize)
            : JSON.stringify(requestBody, null, tabSize);
      const responseBodyPretty = responseBody === null
        ? 'null'
        : typeof responseBody === 'string'
          ? JSON.stringify(responseBody, null, tabSize)
          : JSON.stringify(responseBody, null, tabSize);
      const hasRequestBody = requestBodyPretty !== '(empty)' && requestBodyPretty !== '(unavailable)';
      const logHeader = `[API통신_헤더 front ] <${event.method}> ${event.path} (${event.node.res.statusCode}) - ${duration} [${new Date().toLocaleString()}]\n`;
      const logReqData = hasRequestBody
        ? `[API통신_데이터_요청]\n${requestBodyPretty}\n`
        : '';
      const logResData = `[API통신_데이터_응답]\n${responseBodyPretty}\n`;

      await appendFile(logPath, logHeader + logReqData + logResData);
    } catch (err) {
      console.error('[API-Logger] Write Error:', err);
    }
  });
});
