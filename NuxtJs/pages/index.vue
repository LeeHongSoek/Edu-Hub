<script setup lang="ts">
const config = useRuntimeConfig();
const { data: questions, pending, error } = await useFetch(`${config.public.apiBase}/questions`);
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
      <QuestionList :questions="questions" />
    </div>
  </div>
</template>

<style scoped>
.loading, .error {
  text-align: center;
  padding: 3rem;
  font-size: 1.25rem;
  color: var(--text-secondary);
}

.error {
  color: #ef4444;
}
</style>
