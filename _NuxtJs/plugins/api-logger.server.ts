import { appendFileSync } from 'fs';
import { resolve } from 'path';
import { mkdirSync } from 'fs';

console.log('[API-Logger] Plugin file loaded');

export default defineNuxtPlugin(async (nuxtApp) => {
  console.log('[API-Logger] Plugin executing...');
  
  if (process.server && process.dev) {
    console.log('[API-Logger] Running on server in dev mode');
    
    const logsDir = resolve('logs');
    const logPath = resolve('logs/api-requests.log');
    
    // logs 폴더 생성
    try {
      mkdirSync(logsDir, { recursive: true });
      console.log('[API-Logger] Logs directory created:', logsDir);
    } catch (err) {
      console.error('[API-Logger] Failed to create logs directory:', err);
    }
    
    // 플러그인 초기화 로그 작성
    const initLog = {
      timestamp: new Date().toISOString(),
      type: 'PLUGIN_INIT',
      message: 'API Logger plugin initialized',
      environment: 'development'
    };
    
    try {
      appendFileSync(logPath, JSON.stringify(initLog) + '\n');
      console.log('✅ [API-Logger] Log file created:', logPath);
    } catch (err) {
      console.error('[API-Logger] Failed to write init log:', err);
    }
  } else {
    console.log('[API-Logger] Not running on server or not in dev mode. process.server=', process.server, 'process.dev=', process.dev);
  }
});
