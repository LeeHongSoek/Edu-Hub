<script setup lang="ts">
import { ref, onMounted, computed, watch } from "vue";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconBook from "~/assets/icons/IconBook.svg?component";
import IconPencil from "~/assets/icons/IconPencil.svg?component";

const logs = ref<any[]>([]);
const totalLogs = ref(0);
const loading = ref(true);

const filterTypes = [
  { id: "all", label: "전체", color: "#6366f1" },
  { id: "Q", label: "문제", icon: IconFileText, color: "#6366f1" },
  { id: "B", label: "문제집", icon: IconBook, color: "#10b981" },
  { id: "E", label: "고사", icon: IconPencil, color: "#f59e0b" },
];

const selectedType = ref("all");
const searchQuery = ref("");
const searchInput = ref("");
const currentPage = ref(1);
const pageSize = ref(10);
const sliderValue = ref(1);

const { apiBase, getAuthHeader } = useApi();

const fetchLogs = async () => {
  loading.value = true;
  try {
    const data = await $fetch<any>(`${apiBase.value}/user-logs/my`, {
      headers: getAuthHeader(),
      query: {
        logtype: selectedType.value,
        search: searchQuery.value,
        page: currentPage.value,
        limit: pageSize.value,
      },
    });
    logs.value = data.items || [];
    totalLogs.value = data.total || 0;
  } catch (err) {
    console.error("서버 통신 오류(fetch) logs:", err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchLogs);

// 필터/검색 변경 시 1페이지로 리셋 후 재조회
watch([selectedType, searchQuery], () => {
  currentPage.value = 1;
  sliderValue.value = 1;
  fetchLogs();
});

// 페이지 변경 시 재조회
watch(currentPage, fetchLogs);

const totalPages = computed(() => Math.max(1, Math.ceil(totalLogs.value / pageSize.value)));
const isSliderDisabled = computed(() => totalPages.value <= 1);
const sliderPercentage = computed(() => {
  if (totalPages.value <= 1) return 0;
  return ((sliderValue.value - 1) / (totalPages.value - 1)) * 100;
});

const handleSliderInput = (e: Event) => {
  sliderValue.value = Number((e.target as HTMLInputElement).value);
};

const commitSliderValue = () => {
  currentPage.value = sliderValue.value;
};

const handleSearch = () => {
  searchQuery.value = searchInput.value.trim();
};

const clearSearch = () => {
  searchInput.value = "";
  searchQuery.value = "";
};

const getLogTypeInfo = (type: string) => {
  switch (type) {
    case "Q": return { icon: IconFileText, label: "문제", color: "#6366f1" };
    case "B": return { icon: IconBook, label: "문제집", color: "#10b981" };
    case "E": return { icon: IconPencil, label: "고사", color: "#f59e0b" };
    default: return { icon: IconFileText, label: "기타", color: "#94a3b8" };
  }
};

const formatResult = (log: any) => {
  if (log.logtype === "Q") {
    if (log.user_content.includes("정답")) return { text: "정답", class: "result-success" };
    if (log.user_content.includes("오답")) return { text: "오답", class: "result-error" };
    return { text: log.user_content || "조회", class: "result-info" };
  }
  const scoreText = `${log.score}/${log.total_score}`;
  const percentText = log.score100 !== undefined ? `(${log.score100}점)` : "";
  return { 
    text: `${scoreText} ${percentText}`, 
    class: log.score100 >= 80 ? "result-success" : log.score100 >= 60 ? "result-warning" : "result-error" 
  };
};

const formatTime = (dateStr: string) => {
  const date = new Date(dateStr);
  return date.toLocaleString("ko-KR", {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
};
</script>

<template>
  <div class="log-viewer">
    <div class="header-row">
      <div class="title-group">
        <h3><IconCalendar class="section-icon" /> 최근 학습 활동 내역</h3>
        
        <div class="filter-group" role="tablist">
          <button
            v-for="type in filterTypes"
            :key="type.id"
            :class="{ active: selectedType === type.id }"
            :style="{ '--active-color': type.color }"
            @click="selectedType = type.id"
          >
            <component :is="type.icon" v-if="type.icon" class="filter-btn-icon" />
            {{ type.label }}
          </button>
        </div>
      </div>

      <div class="search-bar">
        <input 
          v-model="searchInput" 
          type="text" 
          placeholder="기록 검색..." 
          @keyup.enter="handleSearch"
        />
        <button v-if="searchInput" class="clear-btn" @click="clearSearch">✕</button>
        <button class="search-btn" @click="handleSearch">검색</button>
      </div>
    </div>

    <div v-if="loading" class="loading-container">
      <div class="loader"></div>
      <span>로그를 불러오는 중...</span>
    </div>
    
    <div v-else-if="logs.length === 0" class="empty-state">
      <IconCalendar class="empty-icon" />
      <p>기록된 학습 활동이 없습니다.</p>
    </div>

    <div v-else class="log-content-area">
       <!-- Pagination Slider -->
      <div class="pagination-area">
        <div class="slider-container" :class="{ disabled: isSliderDisabled }">
          <span class="slider-label">1</span>
          <div class="slider-track-wrap">
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
            <div v-if="!isSliderDisabled" class="slider-tooltip" :style="{ left: sliderPercentage + '%' }">
              {{ sliderValue }}
            </div>
          </div>
          <span class="slider-label">{{ totalPages }}</span>
        </div>
        <div class="page-info">
          {{ currentPage }} / {{ totalPages }}
        </div>
      </div>
      <div class="log-list">
        <div v-for="log in logs" :key="log.log_id" class="log-card">
          <div class="log-type-indicator" :style="{ backgroundColor: getLogTypeInfo(log.logtype).color }">
            <component :is="getLogTypeInfo(log.logtype).icon" class="type-icon" />
          </div>
          
          <div class="log-main-info">
            <div class="log-top">
              <span class="log-type-label">{{ getLogTypeInfo(log.logtype).label }}</span>
              <span v-if="log.user_content" class="log-action-memo">{{ log.title }}</span>
              <span class="log-time">{{ formatTime(log.last_played_at) }}</span>
            </div>
            <div class="log-title-row">
              <div class="log-title" :title="log.title">{{ log.user_content }}</div>
              <div class="log-result" :class="formatResult(log).class">
                {{ formatResult(log).text }}
              </div>
            </div>
          </div>

          
        </div>
      </div>

     
    </div>
  </div>
</template>

<style scoped>
.log-viewer {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.title-group {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  flex-wrap: wrap;
}

.header-row h3 {
  color: #f8fafc;
  font-size: 1.15rem;
  font-weight: 800;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.6rem;
  white-space: nowrap;
}

.section-icon {
  width: 1.25rem;
  height: 1.25rem;
  color: #818cf8;
}

/* 필터 버튼 그룹 */
.filter-group {
  display: flex;
  background: rgba(15, 23, 42, 0.4);
  padding: 0.25rem;
  border-radius: 999px;
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.filter-group button {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  border: none;
  background: transparent;
  color: #94a3b8;
  padding: 0.4rem 0.9rem;
  font-size: 0.82rem;
  font-weight: 700;
  border-radius: 999px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.filter-group button:hover {
  color: #e2e8f0;
}

.filter-group button.active {
  background: var(--active-color);
  color: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.filter-btn-icon {
  width: 0.9rem;
  height: 0.9rem;
}

/* 검색바 */
.search-bar {
  display: flex;
  align-items: center;
  background: rgba(15, 23, 42, 0.4);
  border: 1px solid rgba(148, 163, 184, 0.15);
  border-radius: 10px;
  padding: 0.25rem 0.5rem;
  flex: 1;
  max-width: 320px;
  min-width: 200px;
}

.search-bar input {
  flex: 1;
  background: transparent;
  border: none;
  color: white;
  padding: 0.4rem 0.6rem;
  font-size: 0.9rem;
  outline: none;
}

.search-bar input::placeholder {
  color: #475569;
}

.clear-btn {
  background: transparent;
  border: none;
  color: #64748b;
  cursor: pointer;
  padding: 0.25rem;
  font-size: 0.8rem;
}

.search-btn {
  background: rgba(129, 140, 248, 0.1);
  border: 1px solid rgba(129, 140, 248, 0.2);
  color: #a5b4fc;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
  margin-left: 0.5rem;
}

.search-btn:hover {
  background: rgba(129, 140, 248, 0.2);
  color: white;
}

.log-content-area {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.log-list {
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
}

.log-card {
  background: rgba(30, 41, 59, 0.4);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 16px;
  padding: 0.75rem 1.25rem;
  display: flex;
  align-items: center;
  gap: 1.25rem;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.log-card:hover {
  background: rgba(30, 41, 59, 0.6);
  transform: translateX(6px) scale(1.01);
  border-color: rgba(129, 140, 248, 0.25);
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
}

.log-type-indicator {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
}

.type-icon {
  width: 1.25rem;
  height: 1.25rem;
  color: white;
}

.log-main-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  min-width: 0;
}

.log-top {
  display: flex;
  align-items: center;
  gap: 0.85rem;
}

.log-type-label {
  font-size: 0.72rem;
  font-weight: 800;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.log-action-memo {
  font-size: 0.75rem;
  color: #a5b4fc;
  background: rgba(129, 140, 248, 0.1);
  padding: 0.1rem 0.5rem;
  border-radius: 6px;
  font-weight: 600;
  white-space: nowrap;
}

.log-time {
  margin-left: auto;
  font-size: 0.78rem;
  color: #64748b;
  font-weight: 500;
}

.log-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.log-title {
  font-size: 1.05rem;
  font-weight: 600;
  color: #f1f5f9;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  flex: 1;
  min-width: 0;
}

.log-result {
  font-size: 0.72rem;
  font-weight: 800;
  padding: 0.2rem 0.6rem;
  border-radius: 6px;
  text-align: center;
  letter-spacing: -0.01em;
  white-space: nowrap;
  flex-shrink: 0;
}

.result-info { background: rgba(56, 189, 248, 0.1); color: #38bdf8; border: 1px solid rgba(56, 189, 248, 0.2); }
.result-success { background: rgba(16, 185, 129, 0.1); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.2); }
.result-error { background: rgba(244, 63, 94, 0.1); color: #f43f5e; border: 1px solid rgba(244, 63, 94, 0.2); }
.result-warning { background: rgba(245, 158, 11, 0.1); color: #f59e0b; border: 1px solid rgba(245, 158, 11, 0.2); }

/* Pagination Styles */
.pagination-area {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
  padding: 0.5rem 0.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05); /* 상단에서 하단으로 변경 (리스트 위에 있으므로) */
}

.slider-container {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex: 1; /* 가용 공간 차지 */
}

.slider-container.disabled { opacity: 0.4; }

.slider-label {
  font-size: 0.8rem;
  color: #64748b;
  font-weight: 700;
  min-width: 24px;
}

.slider-track-wrap {
  position: relative;
  flex: 1;
  height: 24px;
  display: flex;
  align-items: center;
}

.page-slider {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 999px;
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
  background: #818cf8;
  border-radius: 50%;
  border: 3px solid #1e293b;
  cursor: grab;
  box-shadow: 0 0 10px rgba(99, 102, 241, 0.4);
}

.slider-fill {
  position: absolute;
  left: 0;
  height: 6px;
  background: #6366f1;
  border-radius: 999px;
  z-index: 1;
}

.slider-tooltip {
  position: absolute;
  top: 28px;
  transform: translateX(-50%);
  background: #818cf8;
  color: white;
  padding: 0.2rem 0.6rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 800;
  pointer-events: none;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
  z-index: 10;
}

.page-info {
  white-space: nowrap;
  font-size: 0.85rem;
  color: #818cf8;
  font-weight: 700;
  background: rgba(129, 140, 248, 0.1);
  padding: 0.25rem 0.75rem;
  border-radius: 8px;
}

/* Loading & Empty States */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 6rem 2rem;
  gap: 1.25rem;
  color: #64748b;
}

.loader {
  width: 32px;
  height: 32px;
  border: 3px solid rgba(129, 140, 248, 0.1);
  border-top-color: #818cf8;
  border-radius: 50%;
  animation: spin 1s cubic-bezier(0.4, 0, 0.2, 1) infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 8rem 2rem;
  color: #334155;
  gap: 1rem;
}

.empty-icon {
  width: 4rem;
  height: 4rem;
  opacity: 0.1;
}

.empty-state p {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 500;
}

@media (max-width: 768px) {
  .header-row {
    flex-direction: column;
    align-items: stretch;
  }
  .search-bar {
    max-width: none;
  }
}
</style>
