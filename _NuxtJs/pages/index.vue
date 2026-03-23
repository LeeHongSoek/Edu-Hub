<script setup lang="ts">
// Landing Page
</script>

<template>
  <div class="landing-page">
    <div class="hero">
      <div class="glass-card">
        <h1 class="hero-title"><span class="gradient-text">Edu-Hub</span>에 오신것을 환영합니다!</h1>
        <p class="hero-subtitle">
          최첨단 AI 기반 학습 플랫폼으로 여러분의 잠재력을 마음껏 발휘해 보세요. 
          학습 내용을 분석하고, 실전 연습을 통해 학업 성취도를 높여보세요.
        </p>
        <NuxtLink to="/Questions" class="cta-button">
          Explore Questions
          <svg viewBox="0 0 24 24" width="20" height="20" class="arrow-icon">
            <path d="M13.172 12l-4.95-4.95 1.414-1.414L16 12l-6.364 6.364-1.414-1.414z" fill="currentColor"/>
          </svg>
        </NuxtLink>
      </div>
    </div>
    
    <div class="background-blobs">
      <div class="blob blob-1"></div>
      <div class="blob blob-2"></div>
      <div class="blob blob-3"></div>
    </div>
  </div>
</template>

<style scoped>
.landing-page {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  background: #0f172a;
  color: #f8fafc;
}

.hero {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 800px;
  padding: 2rem;
  text-align: center;
}

.glass-card {
  background: rgba(255, 255, 255, 0.03);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 32px;
  padding: 4rem 3rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  animation: fadeInDown 1s ease-out;
}

.hero-title {
  font-size: 4rem;
  font-weight: 800;
  line-height: 1.1;
  margin-bottom: 1.5rem;
}

.gradient-text {
  background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero-subtitle {
  font-size: 1.25rem;
  color: #94a3b8;
  max-width: 600px;
  margin: 0 auto 3rem;
  line-height: 1.6;
}

.cta-button {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
  color: white;
  padding: 1.25rem 2.5rem;
  border-radius: 9999px;
  font-size: 1.1rem;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 10px 20px -5px rgba(99, 102, 241, 0.4);
}

.cta-button:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 20px 25px -5px rgba(99, 102, 241, 0.5);
  background: linear-gradient(135deg, #4f46e5 0%, #4338ca 100%);
}

.arrow-icon {
  transition: transform 0.3s ease;
}

.cta-button:hover .arrow-icon {
  transform: translateX(5px);
}

/* Background Blobs */
.background-blobs {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1;
}

.blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.4;
  animation: blobFloat 20s infinite alternate;
}

.blob-1 {
  width: 400px;
  height: 400px;
  background: #4f46e5;
  top: -100px;
  right: -50px;
}

.blob-2 {
  width: 500px;
  height: 500px;
  background: #9333ea;
  bottom: -150px;
  left: -100px;
  animation-delay: -5s;
}

.blob-3 {
  width: 300px;
  height: 300px;
  background: #0ea5e9;
  top: 20%;
  left: 10%;
  animation-delay: -10s;
}

@keyframes fadeInDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes blobFloat {
  0% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(30px, -50px) scale(1.1); }
  66% { transform: translate(-20px, 20px) scale(0.9); }
  100% { transform: translate(0, 0) scale(1); }
}

@media (max-width: 640px) {
  .hero-title { font-size: 2.75rem; }
  .hero-subtitle { font-size: 1.1rem; }
  .glass-card { padding: 3rem 1.5rem; }
}
</style>
