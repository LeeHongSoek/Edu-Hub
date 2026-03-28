import svgLoader from 'vite-svg-loader';

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
    enabled: true,

    timeline: {
      enabled: true
    }
  },
  // If you are specifically trying to enable detailed debugging: 디버깅
  debug: true,
  devServer: {
    port: 3000
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
    public: {
      apiBase: process.env.API_BASE || '/api'

    }
  },
  ssr: false,
  hooks: {

    'nitro:init': (nitro) => {
      // SSR이 false이므로 클라이언트 사이드에서만 실행됨
    }
  }
})
