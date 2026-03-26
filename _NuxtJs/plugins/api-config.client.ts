export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig(); // apiBase 설정값 가져오기 

  // 클라이언트 사이드에서만 실행
  if (process.client) {
    const hostname = window.location.hostname; // localhost 또는 127.0.0.1 또는 192.168.x.x 그외 cloudflare     

    console.log(''); console.log(''); console.log('');

    // localhost 또는 127.0.0.1인 경우
    if (hostname === 'localhost' || hostname === '127.0.0.1' || hostname.startsWith('192.168')) {
      config.public.apiBase = 'http://localhost:4000';
      console.log(`[ API 로컬서버 ] Hostname: ${hostname}, API Base: ${config.public.apiBase}`);
    } else {
      // 원격 환경
      config.public.apiBase = 'https://transcripts-moment-youth-education.trycloudflare.com';
      console.log(`[ API 클라우드페어서버 ] Hostname: ${hostname}, API Base: ${config.public.apiBase}`);
    }

    console.log(''); console.log(''); console.log(''); console.log('');
  }
});
