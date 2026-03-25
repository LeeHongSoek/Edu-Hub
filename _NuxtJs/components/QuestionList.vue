<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import type { Question, Group } from '~/types';

const props = defineProps<{
  questions: Question[];
}>();

const groups = ref<Group[]>([]);
const selectedGroupId = ref<string | number | null>(null);
const selectedQuestionForSolve = ref<Question | null>(null);
const selectedQuestionForEdit = ref<Question | null>(null);
const showGroupManager = ref(false);

const emit = defineEmits<{
  (e: 'refresh'): void;
}>();

// 선택된 그룹과 그 하위 그룹들의 모든 ID를 가져오는 함수
const getDescendantIds = (groupId: string | number, allGroups: Group[]): (string | number)[] => {
  const ids: (string | number)[] = [];
  const targetIdStr = String(groupId);
  
  const traverse = (groups: Group[], targetFound = false) => {
    for (const g of groups) {
      const isTarget = String(g.group_id) === targetIdStr || targetFound;
      if (isTarget) {
        ids.push(g.group_id);
      }
      if (g.child_groups && g.child_groups.length > 0) {
        traverse(g.child_groups, isTarget);
      }
    }
  };

  traverse(allGroups);
  return ids;
};

// 필터링된 문제 목록 (계층 구조 반영)
const filteredQuestions = computed(() => {
  if (!selectedGroupId.value) return props.questions;
  
  // 모든 비교를 문자열로 수행하여 BigInt/String/Number 타입 불일치 방지
  const targetIds = getDescendantIds(selectedGroupId.value, groups.value).map(String);
  return props.questions.filter(q => {
    if (!q.group_id) return false;
    return targetIds.includes(String(q.group_id));
  });
});

const handleSelectGroup = (groupId: string | number | null) => {
  selectedGroupId.value = groupId;
};

const handleSolve = (question: Question) => {
  selectedQuestionForSolve.value = question;
};

// 이전/다음 문제 탐색용 로직
const currentQuestionIndex = computed(() => {
  if (!selectedQuestionForSolve.value) return -1;
  return filteredQuestions.value.findIndex(q => q.question_id === selectedQuestionForSolve.value?.question_id);
});

const getPrevQuestion = () => {
  const idx = currentQuestionIndex.value;
  if (idx > 0) return filteredQuestions.value[idx - 1];
  return null;
};

const getNextQuestion = () => {
  const idx = currentQuestionIndex.value;
  if (idx !== -1 && idx < filteredQuestions.value.length - 1) return filteredQuestions.value[idx + 1];
  return null;
};

const handlePrev = () => {
  const prev = getPrevQuestion();
  if (prev) selectedQuestionForSolve.value = prev;
};

const handleNext = () => {
  const next = getNextQuestion();
  if (next) selectedQuestionForSolve.value = next;
};

const formatGroupPath = (group: Group) => {
  const parts: string[] = [];
  let current: Group | undefined = group;
  while (current) {
    parts.unshift(current.name);
    current = current.parent_group;
  }
  return parts.join(' / ');
};

const fetchGroups = async () => {
  try {
    const data = await $fetch<Group[]>('http://localhost:4000/groups');
    groups.value = data;
  } catch (error) {
    console.error('Failed to fetch groups:', error);
  }
};

onMounted(async () => {
  await fetchGroups();
});
</script>

<template>
  <div class="question-list-container">
    <!-- 계층형 그룹 표시 (우측 상단 오버레이) -->
    <div v-if="groups.length > 0" class="group-overlay">
      <div class="group-overlay-header">
        <span>문제 그룹</span>
        <div class="header-actions">
          <button class="btn-manage-groups" title="그룹 관리" @click="showGroupManager = true">⚙️</button>
          <button v-if="selectedGroupId" class="btn-clear-filter" @click="handleSelectGroup(null)">
            전체
          </button>
        </div>
      </div>
      <GroupHierarchy 
        :groups="groups" 
        :selected-group-id="selectedGroupId"
        @select-group="handleSelectGroup" 
      />
    </div>

    <!-- 그룹 관리 오버레이 -->
    <GroupManager
      v-if="showGroupManager"
      @close="showGroupManager = false"
      @updated="fetchGroups"
    />

    <div class="question-list">
      <div v-if="filteredQuestions.length === 0" class="no-results">
        해당 그룹에 등록된 문제가 없습니다.
      </div>
      <div v-for="q in filteredQuestions" :key="q.question_id" class="question-item">
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
            <button class="btn-modify" @click="selectedQuestionForEdit = q">수정</button>
            <button class="btn-solve" @click="handleSolve(q)">풀기</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 문제 수정 오버레이 -->
    <QuestionEditor
      v-if="selectedQuestionForEdit"
      :question="selectedQuestionForEdit"
      @close="selectedQuestionForEdit = null"
      @updated="emit('refresh')"
    />

    <!-- 문제 풀기 오버레이 -->
    <QuestionSolver 
      v-if="selectedQuestionForSolve" 
      :key="selectedQuestionForSolve.question_id"
      :question="selectedQuestionForSolve"
      :has-prev="getPrevQuestion() !== null"
      :has-next="getNextQuestion() !== null"
      @close="selectedQuestionForSolve = null"
      @prev="handlePrev"
      @next="handleNext"
    />
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

.question-actions {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.btn-solve {
  padding: 0.6rem 1.2rem;
  background: #6366f1;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-modify {
  padding: 0.6rem 1.2rem;
  background: rgba(255, 255, 255, 0.05);
  color: #94a3b8;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-solve:hover {
  background: #4f46e5;
  transform: translateY(-2px);
}

.btn-modify:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  border-color: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
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
  left: -240px;
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
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.75rem;
  font-weight: 700;
  color: #94a3b8;
  text-transform: uppercase;
  margin-bottom: 0.75rem;
  letter-spacing: 0.05em;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 0.5rem;
}

.btn-clear-filter {
  background: rgba(99, 102, 241, 0.2);
  border: 1px solid rgba(99, 102, 241, 0.4);
  color: #a5b4fc;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-size: 0.65rem;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-clear-filter:hover {
  background: rgba(99, 102, 241, 0.3);
  color: #fff;
}

.header-actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.btn-manage-groups {
  background: none;
  border: none;
  font-size: 0.9rem;
  cursor: pointer;
  opacity: 0.6;
  transition: opacity 0.2s;
  padding: 2px;
}

.btn-manage-groups:hover {
  opacity: 1;
}

.no-results {
  text-align: center;
  padding: 3rem;
  background: rgba(255, 255, 255, 0.02);
  border: 1px dashed rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  color: #64748b;
  font-size: 1rem;
}

@media (max-width: 1400px) {
  .group-overlay {
    position: static;
    width: 100%;
    margin-bottom: 1.5rem;
    left: auto;
  }
}
</style>
