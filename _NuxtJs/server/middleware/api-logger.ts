import { appendFileSync } from 'fs';
import { resolve } from 'path';
import { mkdirSync } from 'fs';

let initialized = false;

if (!initialized && process.dev) {
  const logsDir = resolve('logs');
  const logPath = resolve('logs/api-requests.log');
  
  try {
    mkdirSync(logsDir, { recursive: true });
  } catch (err) {
    console.error('[API-Logger] Failed to create logs directory:', err);
  }
  
  const initLog = {
    timestamp: new Date().toISOString(),
    type: 'MIDDLEWARE_INIT',
    message: 'API Logger middleware initialized'
  };
  
  try {
    appendFileSync(logPath, JSON.stringify(initLog) + '\n');
    console.log('✅ [API-Logger] Log file created at:', logPath);
  } catch (err) {
    console.error('[API-Logger] Failed to write init log:', err);
  }
  
  initialized = true;
}

export default defineEventHandler(async (event) => {
  if (process.dev && event.node.req.url?.startsWith('/api/')) {
    const logsDir = resolve('logs');
    const logPath = resolve('logs/api-requests.log');
    const startTime = Date.now();
    let responseData: any = null;
    
    // 응답이 완료될 때 호출되는 핸들러
    const originalEnd = event.node.res.end;
    let isResponseLogged = false;
    
    event.node.res.end = function (chunk?: any, ...args: any[]) {
      if (!isResponseLogged) {
        isResponseLogged = true;
        
        // chunk에서 응답 데이터 추출
        if (chunk) {
          try {
            const str = typeof chunk === 'string' ? chunk : chunk.toString();
            responseData = JSON.parse(str);
          } catch {
            responseData = chunk;
          }
        }
        
        const logEntry = {
          timestamp: new Date().toISOString(),
          type: 'API_REQUEST',
          method: event.node.req.method,
          url: event.node.req.url,
          statusCode: event.node.res.statusCode,
          duration: `${Date.now() - startTime}ms`,
          response: responseData
        };
        
        try {
          appendFileSync(logPath, JSON.stringify(logEntry) + '\n');
        } catch (err) {
          console.error('[API-Logger] Failed to write log:', err);
        }
      }
      
      return originalEnd.call(this, chunk, ...args);
    };
  }
});
