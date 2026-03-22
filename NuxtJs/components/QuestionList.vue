<script setup lang="ts">
interface Question {
  id: string;
  title: string;
  type: string;
  level: string;
}

defineProps<{
  questions: Question[];
}>();
</script>

<template>
  <div class="question-grid">
    <div v-for="q in questions" :key="q.id" class="question-card">
      <div class="question-title">{{ q.title }}</div>
      <div class="question-meta">
        <span class="badge badge-primary">{{ q.type }}</span>
        <span>Level: {{ q.level }}</span>
      </div>
    </div>
  </div>
</template>
