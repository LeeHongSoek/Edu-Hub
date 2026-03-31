<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import IconCalendar from '~/assets/icons/IconCalendar.svg?component';

const exams = ref<any[]>([]);
const loading = ref(true);
const pageSize = 5;
const currentPage = ref(1);
const sliderValue = ref(1);
const examSearchInput = ref('');
const examSearchQuery = ref('');

const filteredExams = computed(() => {
  const keyword = examSearchQuery.value.trim().toLowerCase();
  if (!keyword) return exams.value;
  return exams.value.filter((exam) => {
  const target = exam.exam_name;
    return target.toLowerCase().includes(keyword);
  });
});

const totalPages = computed(() => Math.max(1, Math.ceil(filteredExams.value.length / pageSize)));
const pagedExams = computed(() => {
  const start = (currentPage.value - 1) * pageSize;
  return filteredExams.value.slice(start, start + pageSize);
});
const pageStartItem = computed(() => {
  if (filteredExams.value.length === 0) return 0;
  return (currentPage.value - 1) * pageSize + 1;
});
const pageEndItem = computed(() => Math.min(currentPage.value * pageSize, filteredExams.value.length));
const sliderPercentage = computed(() => {
  if (totalPages.value <= 1) return 0;
  return ((sliderValue.value - 1) / (totalPages.value - 1)) * 100;
});

const isSliderDisabled = computed(() => totalPages.value <= 1);

watch(() => filteredExams.value.length, () => {
  currentPage.value = 1;
  sliderValue.value = 1;
});

watch(currentPage, (page) => {
  sliderValue.value = page;
});

const { apiBase, token, getAuthHeader } = useApi();
const router = useRouter();

const viewExamDetails = (examId: number | string | bigint) => {
  router.push({
    path: '/questions',
    query: { exam: String(examId) },
  });
};

const fetchExams = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/exams`, {
      headers: getAuthHeader()
    });
    exams.value = data as any[];
  } catch (err) {
    console.error('서버 통신 오류(fetch) exams:', err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchExams);

const handleSliderInput = (e: Event) => {
  sliderValue.value = Number((e.target as HTMLInputElement).value);
};

const goToPage = (page: number) => {
  const normalized = Math.min(Math.max(page, 1), totalPages.value);
  if (normalized !== currentPage.value) {
    currentPage.value = normalized;
  }
};

const commitSliderValue = () => {
  goToPage(sliderValue.value);
};

const applyExamSearch = () => {
  examSearchQuery.value = examSearchInput.value.trim();
  currentPage.value = 1;
};

const clearExamSearch = () => {
  examSearchInput.value = '';
  examSearchQuery.value = '';
  currentPage.value = 1;
};

</script>

<template>
  <div class="exam-manager">
    <h3><IconCalendar class="section-icon" /> 나의 고사집 목록</h3>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="filteredExams.length === 0" class="empty">검색 조건에 맞는 고사집이 없습니다.</div>
    <div v-else>
      <div class="pagination-panel-border">
        <div class="slider-panel">
          <div class="search-row">
          <input
            v-model="examSearchInput"
            type="text"
            class="search-input"
            placeholder="시험 제목을 입력하세요"
            @keyup.enter="applyExamSearch"
          />
            <button class="btn-search" @click="applyExamSearch">검색</button>
            <button v-if="examSearchQuery" class="btn-reset-search" @click="clearExamSearch">초기화</button>
          </div>
          <div class="slider-row">
            <span class="summary-text">총 {{ filteredExams.length }}개의 고사집</span>
            <div class="page-slider-section">
              <div class="slider-wrapper" :class="{ disabled: isSliderDisabled }">
                <span class="slider-limit">1</span>
                <div class="slider-track-container">
                  <input
                    type="range"
                    :min="1"
                    :max="totalPages"
                    :value="sliderValue"
                    class="page-slider"
                    @input="handleSliderInput"
                    @change="commitSliderValue"
                    :disabled="isSliderDisabled"
                  />
                  <div class="slider-fill" :style="{ width: sliderPercentage + '%' }"></div>
                  <div class="slider-tooltip" :style="{ left: sliderPercentage + '%' }">
                    {{ sliderValue }}
                  </div>
                </div>
                <span class="slider-limit">{{ totalPages }}</span>
              </div>
            </div>
            <span class="range-text">{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시 중</span>
          </div>
        </div>
      </div>
      <div class="exam-list">
        <div v-for="exam in pagedExams" :key="exam.exam_id" class="exam-card">
          <div class="exam-info">
            <div class="exam-headline">
              <div class="exam-badge">고사</div>
              <span class="exam-period-inline">{{ new Date(exam.start_time).toLocaleDateString('ko-KR') }} ~ {{ new Date(exam.end_time).toLocaleDateString('ko-KR') }}</span>
            </div>
            <h4><{{ exam.exam_id }}> {{ exam.exam_name }}</h4>
          </div>
          <div class="exam-meta">
            <span class="exam-meta-line">
              <span v-if="exam.creator?.username" class="exam-owner">{{ exam.creator.username }}</span>
              <span v-if="exam.creator?.username" class="exam-separator">·</span>
              <span class="exam-count">문제수 {{ exam._count?.questions ?? 0 }}문항</span>
            </span>
            <button class="btn-start" @click="viewExamDetails(exam.exam_id)">상세보기</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.exam-manager { display: flex; flex-direction: column; gap: 1.5rem; }
.exam-manager h3 {
  color: #f8fafc;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.section-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.exam-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
}

.exam-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1.25rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.exam-info { display: flex; flex-direction: column; gap: 0.35rem; }
.exam-headline {
  display: inline-flex;
  align-items: center;
  gap: 0.55rem;
  flex-wrap: wrap;
}
.exam-badge { 
  display: inline-block; 
  background: rgba(245, 158, 11, 0.1); 
  color: #fbbf24; 
  font-size: 0.7rem; 
  padding: 0.2rem 0.5rem; 
  border-radius: 4px; 
  width: fit-content;
  font-weight: 700;
}
.exam-info h4 { color: #f8fafc; margin: 0; font-size: 1.1rem; }

.exam-meta {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  color: #cbd5f5;
  gap: 0.3rem;
}

.exam-period-inline {
  font-size: 0.85rem;
  color: #94a3b8;
  white-space: nowrap;
}

.exam-meta-line {
  display: inline-flex;
  align-items: center;
  flex-wrap: wrap;
  justify-content: flex-end;
  gap: 0.35rem;
  font-size: 0.85rem;
  color: #94a3b8;
  text-align: right;
}

.exam-owner {
  color: #c7d2fe;
  font-weight: 700;
}

.exam-count {
  color: #c7d2fe;
  font-weight: 600;
}

.exam-separator {
  color: #64748b;
  font-weight: 700;
}

.btn-start {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #e2e8f0;
  padding: 0.55rem 1.3rem;
  border-radius: 10px;
  cursor: not-allowed;
  font-weight: 600;
}

.search-select,
.search-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 5px;
  color: #fff;
  padding: 0.45rem 0.7rem;
  font-size: 0.9rem;
}

.search-select {
  min-width: 130px;
  height: 38px;
}

.search-input {
  flex: 1;
  min-width: 220px;
  height: 38px;
}

.btn-search,
.btn-reset-search {
  border-radius: 10px;
  padding: 0.5rem 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  height: 38px;
}

.btn-search {
  border: none;
  background: #6366f1;
  color: white;
}

.btn-search:hover {
  background: #4f46e5;
  transform: translateY(-1px);
}

.btn-reset-search {
  background: rgba(255, 255, 255, 0.08);
  color: #e2e8f0;
  border: 1px solid rgba(255, 255, 255, 0.15);
}

.slider-panel {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.search-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.slider-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  justify-content: space-between;
  flex-wrap: nowrap;
}

.summary-text,
.range-text {
  font-size: 0.9rem;
  color: #cbd5f5;
  font-weight: 500;
  white-space: nowrap;
  flex-shrink: 0;
}

.page-slider-section {
  flex: 1;
  min-width: 0;
}

.slider-wrapper {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  width: 100%;
  max-width: none;
}

.slider-wrapper.disabled {
  pointer-events: none;
  opacity: 0.6;
}

.slider-wrapper.disabled .page-slider {
  cursor: not-allowed;
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

.loading, .empty {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}

@media (max-width: 1024px) {
  .exam-list {
    grid-template-columns: 1fr;
  }
}

.pagination-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 10px;
  padding: 1rem 1.25rem;
  background: rgba(15, 23, 42, 0.65);
  box-shadow: 0 20px 60px -22px rgba(15, 23, 42, 1);
  margin-bottom: 1.5rem;
}
</style>
