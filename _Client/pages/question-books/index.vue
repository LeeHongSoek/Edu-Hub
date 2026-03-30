<script setup lang="ts">
import QuestionBookManager from '~/components/dashboard/QuestionBookManager.vue';

const route = useRoute();
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <h1 class="page-title">나의 문제집 관리</h1>
      <NuxtLink to="/dashboard" class="back-btn">← 대시보드</NuxtLink>
    </div>
    
    <div class="content-box">
      <QuestionBookManager />
    </div>
  </div>
</template>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem 1rem;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.back-btn {
  color: #818cf8;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.95rem;
}

.page-title {
  font-size: 2.2rem;
  font-weight: 800;
  color: #f8fafc;
}

.content-box {
  background: rgba(30, 41, 59, 0.5);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.05);
  padding: 1rem 1rem;
  min-height: 430px;
}
</style>
