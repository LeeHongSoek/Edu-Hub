export default defineNuxtPlugin((nuxtApp) => {
  if (process.dev) {
    const originalFetch = nuxtApp.$fetch;
    
    // $fetch 래퍼 - 모든 호출을 감지
    nuxtApp.$fetch = (async (request: any, init?: any) => {
      const url = typeof request === 'string' ? request : request?.url || '';
      const method = init?.method || 'GET';
      const startTime = Date.now();
      
      try {
        const response = await originalFetch(request, init);
        const duration = Date.now() - startTime;
        
        // 🔴 서버로 로그 전송
        const logData = {
          timestamp: new Date().toISOString(),
          method,
          url,
          statusCode: 200,
          duration: `${duration}ms`,
          response: response
        };
        
        // 서버 로깅 API에 POST
        try {
          await originalFetch('/api/logs', {
            method: 'POST',
            body: logData,
            headers: { 'Content-Type': 'application/json' }
          });
        } catch (logErr) {
          console.warn('[API-Logger] Failed to send log:', logErr);
        }
        
        console.log(`✅ ${method} ${url} (200) ${duration}ms`);
        return response;
      } catch (error: any) {
        const duration = Date.now() - startTime;
        
        // 에러도 로깅
        const logData = {
          timestamp: new Date().toISOString(),
          method,
          url,
          statusCode: error.response?.status || 0,
          duration: `${duration}ms`,
          error: error.message,
          errorData: error.data
        };
        
        try {
          await originalFetch('/api/logs', {
            method: 'POST',
            body: logData,
            headers: { 'Content-Type': 'application/json' }
          });
        } catch (logErr) {
          console.warn('[API-Logger] Failed to send error log:', logErr);
        }
        
        console.error(`❌ ${method} ${url} (${error.response?.status || 0}) ${duration}ms`, error);
        throw error;
      }
    }) as typeof originalFetch;
    
    // $fetch의 메서드들도 보존
    Object.assign(nuxtApp.$fetch, originalFetch);
    
    console.log('%c🎯 API Logger Initialized - All fetch() calls will be logged', 'color: #FF6B6B; font-weight: bold; font-size: 12px;');
  }
});
