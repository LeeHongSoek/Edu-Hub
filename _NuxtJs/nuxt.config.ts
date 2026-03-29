import svgLoader from 'vite-svg-loader';

const frontendPort = Number(process.env.NUXT_PORT || 0);   // 실제론 0 이 되면 안된다. 300?번대 포트를 사용해야한다.
const backendOrigin = process.env.BACKEND_ORIGIN || 'http://127.0.0.1:0'; // 실제론 0 이 되면 안된다. 400?번대 포트를 사용해야한다.

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  vite: {
    // @ts-expect-error type mismatch between Nuxt's Vite and vite-svg-loader
    plugins: [svgLoader()],
    server: {
      allowedHosts: [
        '.trycloudflare.com' // 또는 모든 trycloudflare 서브도메인 허용
      ]
    }
  },
  devtools: {
    enabled: false,

    timeline: {
      enabled: false
    }
  },
  // If you are specifically trying to enable detailed debugging: 디버깅
  debug: false,
  devServer: {
    port: frontendPort
  },
  css: ['~/assets/css/index.css'],
  app: {
    head: {
      link: [
        {
          rel: 'stylesheet',
          href: 'https://cdn.jsdelivr.net/npm/katex@0.16.21/dist/katex.min.css'
        }
      ]
    }
  },
  runtimeConfig: {
    backendOrigin,
    public: {
      apiBase: process.env.API_BASE || '/api',
      backendOriginLabel: backendOrigin

    }
  },
  ssr: false,
  hooks: {

    'nitro:init': (nitro) => {
      // SSR이 false이므로 클라이언트 사이드에서만 실행됨
    }
  }
})
