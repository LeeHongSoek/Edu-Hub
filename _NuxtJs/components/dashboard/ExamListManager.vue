<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';

const exams = ref<any[]>([]);
const loading = ref(true);
const pageSize = 5;
const currentPage = ref(1);
const sliderValue = ref(1);
const totalPages = computed(() => Math.max(1, Math.ceil(exams.value.length / pageSize)));
const pagedExams = computed(() => {
  const start = (currentPage.value - 1) * pageSize;
  return exams.value.slice(start, start + pageSize);
});
const pageStartItem = computed(() => {
  if (exams.value.length === 0) return 0;
  return (currentPage.value - 1) * pageSize + 1;
});
const pageEndItem = computed(() => Math.min(currentPage.value * pageSize, exams.value.length));
const sliderPercentage = computed(() => {
  if (totalPages.value <= 1) return 0;
  return ((sliderValue.value - 1) / (totalPages.value - 1)) * 100;
});

watch(() => exams.value.length, () => {
  currentPage.value = 1;
  sliderValue.value = 1;
});

watch(currentPage, (page) => {
  sliderValue.value = page;
});

const { apiBase, token, getAuthHeader } = useApi();

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

const prevPage = () => goToPage(currentPage.value - 1);
const nextPage = () => goToPage(currentPage.value + 1);
</script>

<template>
  <div class="exam-manager">
    <h3>📝 나의 고사집 목록</h3>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="exams.length === 0" class="empty">참여 중인 고사가 없습니다.</div>
    <div v-else>
      <div class="pagination-panel">
        <div class="pagination-summary">
          <span>총 {{ exams.length }}개의 고사집</span>
          <span>{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시 중</span>
        </div>
        <div class="pagination-actions">
          <button class="btn-nav" :disabled="currentPage <= 1" @click="prevPage">이전 페이지</button>
          <span>페이지 {{ currentPage }} / {{ totalPages }}</span>
          <button class="btn-nav" :disabled="currentPage >= totalPages" @click="nextPage">다음 페이지</button>
        </div>
        <div v-if="totalPages > 1" class="page-slider-container">
          <div class="slider-wrapper">
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
              />
              <div class="slider-fill" :style="{ width: sliderPercentage + '%' }"></div>
              <div class="slider-tooltip" :style="{ left: sliderPercentage + '%' }">
                {{ sliderValue }}
              </div>
            </div>
            <span class="slider-limit">{{ totalPages }}</span>
          </div>
        </div>
      </div>
      <div class="exam-list">
        <div v-for="exam in pagedExams" :key="exam.exam_id" class="exam-card">
          <div class="exam-info">
            <div class="exam-badge">고사</div>
            <h4>{{ exam.exam_name }}</h4>
            <div class="exam-period">
              {{ new Date(exam.start_time).toLocaleDateString() }} ~ {{ new Date(exam.end_time).toLocaleDateString() }}
            </div>
          </div>
          <button class="btn-start" disabled>자세히 보기 (준비중)</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.exam-manager { display: flex; flex-direction: column; gap: 1.5rem; }
.exam-manager h3 { color: #f8fafc; margin: 0; }

.exam-list {
  display: flex;
  flex-direction: column;
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

.exam-info { display: flex; flex-direction: column; gap: 0.4rem; }
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
.exam-period { color: #64748b; font-size: 0.85rem; }

.btn-start {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #94a3b8;
  padding: 0.6rem 1.2rem;
  border-radius: 10px;
  cursor: pointer;
}

.pagination-panel {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding-bottom: 0.5rem;
}

.pagination-summary {
  display: flex;
  justify-content: space-between;
  color: #cbd5f5;
  font-size: 0.9rem;
}

.pagination-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.5rem;
  color: #e2e8f0;
  font-size: 0.85rem;
}

.btn-nav {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #e2e8f0;
  padding: 0.4rem 0.9rem;
  border-radius: 999px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s;
}

.btn-nav:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.btn-nav:not(:disabled):hover {
  transform: translateY(-1px);
}

.page-slider-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 0 0.75rem;
}

.slider-wrapper {
  display: flex;
  align-items: center;
  gap: 1rem;
  width: 100%;
  max-width: 420px;
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

.loading, .empty { text-align: center; padding: 3rem; color: #64748b; }
</style>
