/**
 * 클라이언트에서 보낸 API 호출 로그를 파일에 저장
 */
import { appendFileSync } from 'fs';
import { resolve } from 'path';
import { mkdirSync } from 'fs';

export default defineEventHandler(async (event) => {
  if (process.dev) {
    const logsDir = resolve('logs');
    const logPath = resolve('logs/api-requests.log');
    
    try {
      mkdirSync(logsDir, { recursive: true });
    } catch (err) {
      // 디렉토리 이미 존재
    }
    
    // 클라이언트에서 보낸 로그 데이터 가져오기
    const body = await readBody(event);
    
    if (body) {
      try {
        // JSON 데이터를 파일에 기록
        appendFileSync(logPath, JSON.stringify(body) + '\n');
        console.log(`📝 [API Log] ${body.method} ${body.url}`);
      } catch (err) {
        console.error('[API Logger] Write error:', err);
      }
    }
    
    return { success: true };
  }
});
