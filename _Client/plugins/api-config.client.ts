export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig(); // apiBase 설정값 가져오기 

  // 클라이언트 사이드에서만 실행
  if (process.client) {
    const hostname = window.location.hostname; // localhost 또는 127.0.0.1 또는 192.168.x.x 그외 cloudflare     

    console.log(''); console.log(''); console.log('');

    // 모든 환경에서 통합된 /api 경로를 사용합니다.
    config.public.apiBase = '/api';
    console.log(`[ API Unified ] API Base: ${config.public.apiBase}`);

    console.log(''); console.log(''); console.log(''); console.log('');
  }
});
