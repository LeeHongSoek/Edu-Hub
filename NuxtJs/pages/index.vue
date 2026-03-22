<script setup lang="ts">
import type { Question } from '~/types';

const config = useRuntimeConfig();
const { data: questions, pending, error } = await useFetch<Question[]>(`${config.public.apiBase}/questions`);
</script>

<template>
  <div class="container">
    <h1 class="title">Question Hub</h1>
    
    <div v-if="pending" class="loading">
      Loading questions...
    </div>
    
    <div v-else-if="error" class="error">
      Failed to load questions. Please check if the backend is running.
      <pre>{{ error }}</pre>
    </div>
    
    <div v-else>
      <QuestionList :questions="questions || []" />
    </div>
  </div>
</template>

<style scoped>
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
