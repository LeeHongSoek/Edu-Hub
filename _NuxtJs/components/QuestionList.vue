<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';
import type { Question, Group } from '~/types';

const props = defineProps<{
  questions: Question[];
  selectedGroupId: string | number | null;
  appliedSearchField: 'title' | 'content';
  appliedSearchKeyword: string;
  currentPage: number;
  totalPages: number;
  totalItems: number;
  pageSize: number;
}>();

// API 설정 통합
const { apiBase } = useApi();

const groups = ref<Group[]>([]);
const selectedQuestionForSolve = ref<Question | null>(null);
const selectedQuestionForEdit = ref<Question | null>(null);
const showGroupManager = ref(false);
const searchField = ref<'title' | 'content'>(props.appliedSearchField);
const searchInput = ref('');
const sliderValue = ref(props.currentPage);

watch(() => props.currentPage, (val) => {
  sliderValue.value = val;
});

let debounceTimer: any = null;
const handleSliderInput = (e: Event) => {
  const value = parseInt((e.target as HTMLInputElement).value);
  sliderValue.value = value;
};

const commitSliderValue = () => {
  if (debounceTimer) {
    clearTimeout(debounceTimer);
    debounceTimer = null;
  }

  goToPage(sliderValue.value);
};

const sliderPercentage = computed(() => {
  if (props.totalPages <= 1) return 0;
  return ((sliderValue.value - 1) / (props.totalPages - 1)) * 100;
});

const emit = defineEmits<{
  (e: 'refresh'): void;
  (e: 'change-group', groupId: string | number | null): void;
  (e: 'search', payload: { field: 'title' | 'content'; keyword: string }): void;
  (e: 'reset-search'): void;
  (e: 'change-page', page: number): void;
}>();

const handleSelectGroup = (groupId: string | number | null) => {
  emit('change-group', groupId);
};

const applySearch = () => {
  emit('search', {
    field: searchField.value,
    keyword: searchInput.value.trim(),
  });
};

const resetSearch = () => {
  searchField.value = 'title';
  searchInput.value = '';
  emit('reset-search');
};

const handleSolve = (question: Question) => {
  selectedQuestionForSolve.value = question;
};


const pageStartItem = computed(() => {
  if (props.totalItems === 0) return 0;
  return (props.currentPage - 1) * props.pageSize + 1;
});

const pageEndItem = computed(() => {
  return Math.min(props.currentPage * props.pageSize, props.totalItems);
});

const goToPage = (page: number) => {
  emit('change-page', Math.min(Math.max(page, 1), props.totalPages));
};


// 이전/다음 문제 탐색용 로직
const currentQuestionIndex = computed(() => {
  if (!selectedQuestionForSolve.value) return -1;
  return props.questions.findIndex(q => q.question_id === selectedQuestionForSolve.value?.question_id);
});

const getPrevQuestion = () => {
  const idx = currentQuestionIndex.value;
  if (idx > 0) return props.questions[idx - 1];
  return null;
};

const getNextQuestion = () => {
  const idx = currentQuestionIndex.value;
  if (idx !== -1 && idx < props.questions.length - 1) return props.questions[idx + 1];
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
    const data = await $fetch<Group[]>(`${apiBase.value}/groups`);
    groups.value = data;
  } catch (error) {
    console.error('서버 통신 오류(fetch) groups:', error);
  }
};

onMounted(async () => {
  await fetchGroups();
  searchInput.value = props.appliedSearchKeyword;
});

watch(() => props.appliedSearchField, (value) => {
  searchField.value = value;
});

watch(() => props.appliedSearchKeyword, (value) => {
  searchInput.value = value;
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
          <button v-if="props.selectedGroupId" class="btn-clear-filter" @click="handleSelectGroup(null)">
            전체
          </button>
        </div>
      </div>
      <GroupHierarchy 
        :groups="groups" 
        :selected-group-id="props.selectedGroupId"
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
      <div class="search-bar">
        <select v-model="searchField" class="search-select">
          <option value="title">문제제목</option>
          <option value="content">문제내용</option>
        </select>
        <input
          v-model="searchInput"
          type="text"
          class="search-input"
          :placeholder="searchField === 'title' ? '문제 제목을 입력하세요' : '문제 내용을 입력하세요'"
          @keyup.enter="applySearch"
        />
        <button class="btn-search" @click="applySearch">검색</button>
        <button
          v-if="props.appliedSearchKeyword || searchInput"
          class="btn-reset-search"
          @click="resetSearch"
        >
          초기화
        </button>
      </div>

      <div v-if="props.questions.length === 0" class="no-results">
        {{ props.appliedSearchKeyword ? '검색 조건에 맞는 문제가 없습니다.' : '해당 조건에 등록된 문제가 없습니다.' }}
      </div>
      <div v-else class="pagination-summary">
        <span>총 {{ props.totalItems }}문제</span>
         <div v-if="props.totalPages > 1" class="page-slider-container">
           <div class="slider-wrapper">
             <span class="slider-limit">1</span>
             <div class="slider-track-container">
               <input
                 type="range"
                 :min="1"
                 :max="props.totalPages"
                 :value="sliderValue"
                 class="page-slider"
                 @input="handleSliderInput"
                 @change="commitSliderValue"
               />
               <div class="slider-fill" :style="{ width: sliderPercentage + '%' }"></div>
               <div class="slider-tooltip" :style="{ left: sliderPercentage + '%' }">
                 {{ sliderValue }}
               </div>
             </div>
             <span class="slider-limit">{{ props.totalPages }}</span>
           </div>
         </div>
        <span>{{ pageStartItem }}-{{ pageEndItem }}번째 문제 표시 중</span>
      </div>
     

      <div v-for="q in props.questions" :key="q.question_id" class="question-item">
        <div class="question-header">
          <div class="question-title-row">
            <span class="badge badge-type question-type-badge">{{ q.type.type_name }}</span>
            <h3 class="question-title">{{ q.title }} <{{ q.question_id }}></h3>
          </div>
          <!-- 문제의 그룹 경로를 표시 -->
          <div v-if="q.group" class="question-group-path">
            {{ formatGroupPath(q.group) }}
          </div>
        </div>
        
        <div class="question-main">
          <div class="question-content">
            <!--  문제 내용, 추가 내용을 표시 -->
            <LatexRenderer :text="q.question" class="question-preview" />
            <LatexRenderer v-if="q.content" :text="q.content" class="question-secondary" />

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
      :current-index="currentQuestionIndex"
      :total-questions="props.questions.length"
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

.search-bar {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  margin-bottom: 0.5rem;
}

.search-select,
.search-input {
  height: 2.75rem;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(15, 23, 42, 0.72);
  color: #e2e8f0;
  padding: 0 0.9rem;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.search-select {
  min-width: 8.5rem;
  cursor: pointer;
}

.search-input {
  flex: 1;
}

.search-select:focus,
.search-input:focus {
  border-color: rgba(99, 102, 241, 0.65);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.btn-search,
.btn-reset-search {
  height: 2.75rem;
  padding: 0 1rem;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-search {
  border: none;
  background: #6366f1;
  color: #fff;
}

.btn-search:hover {
  background: #4f46e5;
}

.btn-reset-search {
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.05);
  color: #cbd5e1;
}

.btn-reset-search:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.pagination-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding: 0.9rem 1rem;
  border-radius: 12px;
  background: rgba(15, 23, 42, 0.6);
  border: 1px solid rgba(148, 163, 184, 0.14);
  color: #94a3b8;
  font-size: 0.9rem;
}

.question-item {
  display: flex;
  flex-direction: column;
  padding: 1.25rem 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
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
  align-items: flex-start;
  margin-bottom: 0.35rem;
  gap: 1rem;
}

.question-title-row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 0;
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
  min-width: 0;
}

.question-type-badge {
  flex-shrink: 0;
  padding: 0.2rem 0.6rem;
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
  margin: -0.35rem 0 0 0;
  font-size: 1rem;
  font-weight: 400;
  color: #94a3b8;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.badge {
  padding: 0.25rem 0.75rem;
  border-radius: 10px;
  font-size: 0.75rem;
  font-weight: 500;
}

.badge-type {
  background: rgba(99, 102, 241, 0.15);
  color: #818cf8;
  border: 1px solid rgba(99, 102, 241, 0.3);
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
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-modify {
  padding: 0.6rem 1.2rem;
  background: rgba(255, 255, 255, 0.05);
  color: #94a3b8;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
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

.page-slider-container {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0 1rem;
}

.slider-wrapper {
  display: flex;
  align-items: center;
  gap: 1rem;
  width: 100%;
  max-width: 400px;
}

.slider-limit {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 600;
  min-width: 20px;
  text-align: center;
}

.slider-track-container {
  position: relative;
  flex: 1;
  height: 32px;
  display: flex;
  align-items: center;
}

.page-slider {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
  outline: none;
  cursor: pointer;
  z-index: 2;
  position: relative;
  touch-action: none;
}

.page-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  background: #6366f1;
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 0 15px rgba(99, 102, 241, 0.4);
  border: 2px solid #fff;
  transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.page-slider:hover::-webkit-slider-thumb {
  transform: scale(1.15);
  box-shadow: 0 0 20px rgba(99, 102, 241, 0.6);
}

.slider-fill {
  position: absolute;
  height: 6px;
  background: linear-gradient(90deg, #6366f1, #a855f7);
  border-radius: 3px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  z-index: 1;
}

.slider-tooltip {
  position: absolute;
  top: -24px;
  transform: translateX(-50%);
  background: #6366f1;
  color: white;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 800;
  pointer-events: none;
  white-space: nowrap;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.slider-tooltip::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-top: 4px solid #6366f1;
}


@media (max-width: 640px) {
  .search-bar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-select,
  .search-input,
  .btn-search,
  .btn-reset-search {
    width: 100%;
  }

  .pagination-summary {
    flex-direction: column;
    align-items: flex-start;
  }

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
  border-radius: 10px;
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
  border-radius: 10px;
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
