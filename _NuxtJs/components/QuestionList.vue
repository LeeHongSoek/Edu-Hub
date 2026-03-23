<script setup lang="ts">
import { ref, onMounted } from 'vue';
import type { Question, Group } from '~/types';

defineProps<{
  questions: Question[];
}>();

const groups = ref<Group[]>([]);

const formatGroupPath = (group: Group) => {
  const parts: string[] = [];
  let current: Group | undefined = group;
  while (current) {
    parts.unshift(current.name);
    current = current.parent_group;
  }
  return parts.join(' / ');
};

onMounted(async () => {
  try {
    const data = await $fetch<Group[]>('http://localhost:4000/groups');
    groups.value = data;
  } catch (error) {
    console.error('Failed to fetch groups:', error);
  }
});
</script>

<template>
  <div class="question-list-container">
    <!-- Hierarchical Group Display (Top Right) -->
    <div v-if="groups.length > 0" class="group-overlay">
      <div class="group-overlay-header">문제 그룹</div>
      <GroupHierarchy :groups="groups" />
    </div>

    <div class="question-list">
      <div v-for="q in questions" :key="q.question_id" class="question-item">
        <div class="question-header">
          <h3 class="question-title">{{ q.title }}</h3>
          <div v-if="q.group" class="question-group-path">
            {{ formatGroupPath(q.group) }}
          </div>
        </div>
        
        <div class="question-main">
          <div class="question-content">
            <LatexRenderer :text="q.question" class="question-preview" />
            <LatexRenderer v-if="q.content" :text="q.content" class="question-secondary" />
            <div class="question-footer">
              <span class="badge badge-type">{{ q.type.type_name }}</span>
              <span class="badge badge-level">Level: {{ q.difficulty || 1 }}</span>
              <span v-if="q.time_limit" class="badge badge-time">{{ q.time_limit }}s</span>
            </div>
          </div>
          <div class="question-actions">
            <button class="btn-solve">풀기</button>
          </div>
        </div>
    </div>
    </div>
  </div>
</template>

<style scoped>
.question-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-width: 900px;
  margin: 0 auto;
}

.question-item {
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.question-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.question-group-path {
  font-size: 0.65rem;
  color: #64748b;
  font-weight: 500;
  text-align: right;
  letter-spacing: 0.02em;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 0.5rem;
}

.question-item:hover {
  transform: translateX(5px);
  background: rgba(255, 255, 255, 0.08);
  border-color: var(--primary-color, #6366f1);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
}

.question-content {
  flex: 1;
}

.question-title {
  margin: 0 0 0.25rem 0;
  font-size: 0.85rem;
  font-weight: 500;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.question-preview {
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: #fff;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.question-secondary {
  margin: -0.5rem 0 1rem 0;
  font-size: 1rem;
  font-weight: 400;
  color: #94a3b8;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.question-footer {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.badge {
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 500;
}

.badge-type {
  background: rgba(99, 102, 241, 0.15);
  color: #818cf8;
  border: 1px solid rgba(99, 102, 241, 0.3);
}

.badge-level {
  background: rgba(245, 158, 11, 0.15);
  color: #fbbf24;
  border: 1px solid rgba(245, 158, 11, 0.3);
}

.badge-time {
  background: rgba(16, 185, 129, 0.15);
  color: #34d399;
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.btn-solve {
  padding: 0.6rem 1.2rem;
  background: #6366f1;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-solve:hover {
  background: #4f46e5;
}

@media (max-width: 640px) {
  .question-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  
  .question-actions {
    width: 100%;
  }
  
  .btn-solve {
    width: 100%;
  }
}


.question-list-container {
  position: relative;
  width: 100%;
}

.group-overlay {
  position: absolute;
  top: 0;
  right: -240px;
  width: 220px;
  background: rgba(15, 23, 42, 0.8);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  padding: 1rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  z-index: 100;
}

.group-overlay-header {
  font-size: 0.75rem;
  font-weight: 700;
  color: #94a3b8;
  text-transform: uppercase;
  margin-bottom: 0.75rem;
  letter-spacing: 0.05em;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 0.5rem;
}

@media (max-width: 1400px) {
  .group-overlay {
    position: static;
    width: 100%;
    margin-bottom: 1.5rem;
    right: auto;
  }
}
</style>
