<script setup lang="ts">
import { ref, onMounted, computed, watch } from "vue";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";
import IconAll from "~/assets/icons/IconAll.svg?component";
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconBook from "~/assets/icons/IconBook.svg?component";
import IconPencil from "~/assets/icons/IconPencil.svg?component";
import IconUsers from "~/assets/icons/IconUsers.svg?component";
import IconClassRoom from "~/assets/icons/IconClassRoom.svg?component";
import IconHome from "~/assets/icons/IconHome.svg?component";
import IconCursor from "~/assets/icons/IconCreateAction.svg?component";
import PageSlider from "~/components/PageSlider.vue";

const logs = ref<any[]>([]);
const totalLogs = ref(0);
const loading = ref(true);

const filterTypes = [
  { id: "all", label: "전체", icon: IconAll, color: "#636663" },
  { id: "L", label: "로그인", icon: IconHome, color: "#64748b" },
  { id: "Q", label: "문제", icon: IconFileText, color: "#6366f1" },
  { id: "B", label: "문제집", icon: IconBook, color: "#10b981" },
  { id: "E", label: "고사", icon: IconPencil, color: "#f59e0b" },
  { id: "C", label: "클래스", icon: IconClassRoom, color: "#06b6d4" },
  { id: "R", label: "관계", icon: IconUsers, color: "#a855f7" },
  { id: "V", label: "활동", icon: IconCursor, color: "#38bdf8" },
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

const totalPages = computed(() =>
  Math.max(1, Math.ceil(totalLogs.value / pageSize.value)),
);
const isSliderDisabled = computed(() => totalPages.value <= 1);
const commitSliderValue = (page?: number) => {
  currentPage.value = page ?? sliderValue.value;
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
    case "Q":
      return { icon: IconFileText, label: "문제", color: "#6366f1" };
    case "B":
      return { icon: IconBook, label: "문제집", color: "#10b981" };
    case "E":
      return { icon: IconPencil, label: "고사", color: "#f59e0b" };
    case "C":
      return { icon: IconClassRoom, label: "클래스", color: "#06b6d4" };
    case "R":
      return { icon: IconUsers, label: "관계", color: "#a855f7" };
    case "L":
      return { icon: IconHome, label: "로그인", color: "#64748b" };
    case "V":
      return { icon: IconCursor, label: "활동", color: "#38bdf8" };
    default:
      return { icon: IconFileText, label: "기타", color: "#94a3b8" };
  }
};

const formatResult = (log: any) => {
  const parts: string[] = [];

  if (
    log.score != null &&
    log.total_score != null &&
    Number(log.total_score) > 0
  ) {
    const scoreText = `${log.score}/${log.total_score}`;
    const percentText =
      log.score100 !== undefined ? `(${log.score100}점)` : "";
    parts.push(`${scoreText} ${percentText}`.trim());
  }

  if (log.time_taken != null && Number(log.time_taken) > 0) {
    parts.push(`${log.time_taken}초`);
  }

  if (parts.length === 0 && log.user_content) {
    parts.push("학습 완료");
  }

  return parts.length ? parts.join(" · ") : null;
};

const parseToLocalDate = (value?: string | null) => {
  if (!value) {
    return new Date(NaN);
  }
  const normalized = value.includes("T") ? value : value.replace(" ", "T");
  return new Date(normalized);
};

const formatTime = (dateStr: string) => {
  const date = parseToLocalDate(dateStr);
  return date.toLocaleString("ko-KR", {
    timeZone: "Asia/Seoul",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
};

const formatExactTime = (dateStr: string) => {
  const date = parseToLocalDate(dateStr);
  if (Number.isNaN(date.getTime())) return "--";
  const pad = (value: number) => String(value).padStart(2, "0");
  return `${pad(date.getDate())}.${pad(date.getMonth() + 1)} ${pad(
    date.getHours(),
  )}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
};

const formatRecentTime = (dateStr: string) => {
  const date = parseToLocalDate(dateStr);
  const diffMs = Date.now() - date.getTime();
  const diffMinutes = Math.floor(diffMs / 60000);

  if (diffMinutes >= 0 && diffMinutes < 60) {
    return `${Math.max(1, diffMinutes)}분 전`;
  }

  return formatTime(dateStr);
};

const isRecentTime = (dateStr: string) => {
  const date = parseToLocalDate(dateStr);
  const diffMs = Date.now() - date.getTime();
  const diffMinutes = Math.floor(diffMs / 60000);
  return diffMinutes >= 0 && diffMinutes < 60;
};
</script>

<template>
  <div class="log-viewer">
    <div class="header-row">
      <div class="title-group">
        <h3><IconCalendar class="section-icon" />나의 활동 로그</h3>
      </div>

      <div class="header-controls">
        <div class="filter-group" role="tablist">
          <button
            v-for="type in filterTypes"
            :key="type.id"
            :class="{ active: selectedType === type.id }"
            :style="{ '--active-color': type.color }"
            @click="selectedType = type.id">
            <component
              :is="type.icon"
              v-if="type.icon"
              class="filter-btn-icon"
            />
            {{ type.label }}
          </button>
        </div>
        <div class="search-bar">
          <input
            v-model="searchInput"
            type="text"
            placeholder="기록 검색..."
            @keyup.enter="handleSearch"
          />
          <button v-if="searchInput" class="clear-btn" @click="clearSearch">
            ✕
          </button>
          <button class="search-btn" @click="handleSearch">검색</button>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-container">
      <div class="loader"></div>
      <span>로그를 불러오는 중...</span>
    </div>

    <div v-else-if="logs.length === 0" class="empty-state">
      <IconCalendar class="empty-icon" />
      <p>기록된 활동 로그가 없습니다.</p>
    </div>

    <div v-else class="log-content-area">
      <!-- Pagination Slider -->
      <div class="pagination-area">
        <PageSlider
          v-model="sliderValue"
          :max="totalPages"
          :disabled="isSliderDisabled"
          postfix="페이지"
          @commit="commitSliderValue"
        />
        <div class="page-info">{{ currentPage }} / {{ totalPages }}</div>
      </div>
      <div class="log-list">
        <div v-for="log in logs" :key="log.log_id" class="log-card">
          <div
            class="log-type-indicator"
            :style="{ backgroundColor: getLogTypeInfo(log.logtype).color }">
            <component
              :is="getLogTypeInfo(log.logtype).icon"
              class="type-icon"
            />
          </div>

          <div class="log-main-info">
            <div class="log-top">
              <span class="log-type-label">{{
                getLogTypeInfo(log.logtype).label
              }}</span>
              <span
                v-if="log.user_content"
                class="log-action-memo"
                :title="log.title"
                >{{ log.title }}</span>
              <span
                class="log-time"
                :class="{ 'log-time-recent': isRecentTime(log.created_at) }"
                >{{
                  formatRecentTime(log.created_at)
                }}</span>
            </div>
            <div class="log-title-row">
              <div class="log-title" :title="log.user_content">
                {{ log.user_content }}
              </div>
              <div v-if="formatResult(log)" class="log-result">
                {{ formatResult(log) }}
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

.header-controls {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  flex: 1;
  justify-content: flex-end;
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
  display: inline-flex;
  align-items: center;
  gap: 0;
  padding: 0;
  background: rgba(15, 23, 42, 0.6);
  border: 1px solid rgba(148, 163, 184, 0.18);
  border-radius: 10px;
  overflow: hidden;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.04);
}

.filter-group button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  min-height: 38px;
  border: 1px solid rgba(148, 163, 184, 0.12);
  border-radius: 0;
  background: rgba(15, 23, 42, 0.4);
  color: #94a3b8;
  padding: 0.45rem 0.95rem;
  font-size: 0.84rem;
  font-weight: 800;
  cursor: pointer;
  transition:
    background 0.2s ease,
    color 0.2s ease,
    border-color 0.2s ease,
    transform 0.2s ease,
    box-shadow 0.2s ease;
}

.filter-group button:hover {
  color: #e2e8f0;
  border-color: rgba(165, 180, 252, 0.28);
  transform: translateY(-1px);
  background: rgba(30, 41, 59, 0.55);
}

.filter-group button.active {
  background: var(--active-color);
  color: white;
  border-color: rgba(191, 219, 254, 0.28);
  box-shadow: 0 8px 18px rgba(0, 0, 0, 0.2);
}

.filter-group button + button {
  margin-left: -1px;
}

.filter-group button:first-child {
  border-top-left-radius: 11px;
  border-bottom-left-radius: 11px;
  font-weight: 900;
  font-size: 0.9rem;
}

.filter-group button:last-child {
  border-top-right-radius: 11px;
  border-bottom-right-radius: 11px;
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
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
}

@media (max-width: 1200px) {
  .log-list {
    grid-template-columns: 1fr;
  }
}

.log-card {
  background: rgba(30, 41, 59, 0.4);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 0.75rem 1.25rem;
  display: flex;
  align-items: center;
  gap: 1.25rem;
  min-width: 0;
  overflow: hidden;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.log-card:hover {
  background: rgba(30, 41, 59, 0.6);
  transform: translateY(-2px) scale(1.01);
  border-color: rgba(129, 140, 248, 0.25);
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
}

.log-type-indicator {
  width: 42px;
  height: 42px;
  border-radius: 10px;
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
  display: grid;
  grid-template-columns: auto minmax(0, 1fr) auto;
  align-items: center;
  gap: 0.85rem;
  min-width: 0;
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
  display: inline-block;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  min-width: 0;
  width: fit-content;
  max-width: 100%;
  justify-self: start;
}

.log-time {
  margin-left: auto;
  font-size: 0.78rem;
  color: #64748b;
  font-weight: 500;
  flex-shrink: 0;
}

.log-time-detail {
  font-size: 0.65rem;
  color: #94a3b8;
  letter-spacing: 0.02em;
  margin-left: 0.35rem;
  white-space: nowrap;
}

.log-time-recent {
  color: #f8fafc;
  font-weight: 800;
}

.log-title-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: center;
  gap: 1rem;
  min-width: 0;
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
  padding: 0.25rem 0.75rem; /* 상하좌우 여백을 조금 더 확보 */
  border-radius: 6px;
  text-align: center;
  letter-spacing: -0.01em;
  white-space: nowrap; /* 내용이 길어도 아래로 떨어지지 않게 함 */
  flex-shrink: 0; /* 부모 요소가 좁아져도 크기가 줄어들지 않음 */

  /* --- 수정 및 추가된 부분 --- */
  min-width: 100px; /* 최소 폭 고정 (내용이 짧아도 이 크기 유지) */
  width: fit-content; /* 내용에 맞춰 폭이 늘어남 */
  display: inline-flex; /* 중앙 정렬을 위해 플렉스 적용 */
  align-items: center;
  justify-content: center;

  /* 색깔 제거 및 중립 스타일 적용 */
  background: rgba(148, 163, 184, 0.1);
  color: #94a3b8;
  border: 1px solid rgba(148, 163, 184, 0.1);
}

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

.slider-container.disabled {
  opacity: 0.4;
}

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
  border-radius: 10px;
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
  border-radius: 10px;
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

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

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
