/**
 * API Logger Server Middleware
 * 모든 요청의 응답을 로깅합니다 (개발 모드)
 */
import { appendFileSync } from 'fs';
import { resolve } from 'path';
import { mkdirSync } from 'fs';

let initialized = false;

if (!initialized && process.dev) {
  const logsDir = resolve('logs');
  const logPath = resolve('logs/api-requests.log');
  
  try {
    mkdirSync(logsDir, { recursive: true });
    const initLog = {
      timestamp: new Date().toISOString(),
      type: 'LOGGER_INIT',
      message: 'API Logger middleware initialized'
    };
    appendFileSync(logPath, JSON.stringify(initLog) + '\n');
    console.log('✅ [API-Logger] Initialized');
  } catch (err) {
    console.error('[API-Logger] Error:', err);
  }
  
  initialized = true;
}

export default defineEventHandler(async (event) => {
  if (process.dev) {
    // /api/ 또는 /stats, /users, /questions, /exams, /groups, /study-logs, /dashboard 등의 백엔드 경로 로깅
    const path = event.node.req.url || '';
    const isApiPath = /^\/api\/|^\/stats|^\/users|^\/questions|^\/exams|^\/groups|^\/study-logs|^\/dashboard|^\/ombudsman/.test(path);
    
    if (isApiPath) {
      const logPath = resolve('logs/api-requests.log');
      const startTime = Date.now();
      let responseData: any = null;
      let isLogged = false;
      
      const originalSend = event.node.res.end;
      
      event.node.res.end = function (chunk?: any, ...args: any[]) {
        if (!isLogged) {
          isLogged = true;
          
          if (chunk) {
            try {
              const str = typeof chunk === 'string' ? chunk : chunk.toString();
              responseData = JSON.parse(str);
            } catch {
              responseData = chunk?.toString?.().substring(0, 200); // HTML 등은 처음 200자만
            }
          }
          
          const logEntry = {
            timestamp: new Date().toISOString(),
            method: event.node.req.method,
            url: event.node.req.url,
            statusCode: event.node.res.statusCode,
            duration: `${Date.now() - startTime}ms`,
            response: responseData
          };
          
          try {
            appendFileSync(logPath, JSON.stringify(logEntry) + '\n');
            // 콘솔에도 표시
            console.log(`[API] ${logEntry.method} ${logEntry.url} (${logEntry.statusCode}) ${logEntry.duration}`);
          } catch (err) {
            console.error('[API-Logger] Error:', err);
          }
        }
        
        return originalSend.call(this, chunk, ...args);
      };
    }
  }
});
