<script setup lang="ts">
import type { Question } from '~/types';

const config = useRuntimeConfig();
const { data: questions, pending, error, refresh } = await useFetch<Question[]>(`${config.public.apiBase}/questions`);
</script>

<template>
  <div class="container">
    <div class="nav-header">
      <NuxtLink to="/" class="back-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
        <span>초기 화면으로..</span>
      </NuxtLink>
    </div>

    <h1 class="title">문제 목록</h1>
    
    <div v-if="pending" class="loading">
      문제를 불러오는 중...
    </div>
    
    <div v-else-if="error" class="error">
      문제를 불러오지 못했습니다. 백엔드 서버가 실행 중인지 확인해 주세요.
      <pre>{{ error }}</pre>
    </div>
    
    <div v-else>
      <QuestionList :questions="questions || []" @refresh="refresh" />
    </div>
  </div>
</template>

<style scoped>
.nav-header {
  margin-bottom: 1rem;
  display: flex;
  justify-content: flex-start;
}

.back-button {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1.2rem;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #e2e8f0;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.back-button:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.2);
  transform: translateX(-4px);
  box-shadow: 0 10px 20px -10px rgba(0, 0, 0, 0.5);
}

.icon {
  width: 1.25rem;
  height: 1.25rem;
}

.container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.title {
  font-size: 2.5rem;
  font-weight: 800;
  text-align: center;
  margin-bottom: 3rem;
  background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.loading, .error {
  text-align: center;
  padding: 4rem;
  font-size: 1.2rem;
  color: #94a3b8;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 16px;
  border: 1px dashed rgba(255, 255, 255, 0.1);
}

.error {
  color: #f87171;
  border-color: rgba(248, 113, 113, 0.2);
}
</style>
