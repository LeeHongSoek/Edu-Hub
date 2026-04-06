<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import IconFeedback from "~/assets/icons/IconFeedback.svg?component";
import IconClose from "~/assets/icons/IconClose.svg?component";
import IconSearch from "~/assets/icons/IconSearch.svg?component";
import IconPencil from "~/assets/icons/IconPencil.svg?component";
import IconTrash from "~/assets/icons/IconTrash.svg?component";
import PageSlider from "~/components/PageSlider.vue";

const emit = defineEmits(["close"]);

const reports = ref<any[]>([]);
const loading = ref(true);
const showForm = ref(false);
const editingReport = ref<any>(null);
const searchInput = ref("");
const searchQuery = ref("");
const currentPage = ref(1);
const pageSize = 5;
const sliderValue = ref(1);

const { apiBase, getAuthHeader } = useApi();

const form = ref({
  category: "OPINION",
  title: "",
  content: "",
});

const categories = [
  { value: "OPINION", label: "단순 의견" },
  { value: "IMPROVEMENT", label: "개선 제안" },
  { value: "COMPLAINT", label: "불만/오류 제보" },
];

const normalizedSearch = computed(() => searchQuery.value.trim().toLowerCase());

const filteredReports = computed(() => {
  if (!normalizedSearch.value) return reports.value;

  return reports.value.filter((report) => {
    const categoryLabel =
      categories.find((item) => item.value === report.category)?.label ?? "";

    return [report.title, report.content, categoryLabel]
      .filter(Boolean)
      .some((value) =>
        String(value).toLowerCase().includes(normalizedSearch.value),
      );
  });
});

const totalPages = computed(() =>
  Math.max(1, Math.ceil(filteredReports.value.length / pageSize)),
);
const isSliderDisabled = computed(() => totalPages.value <= 1);

const paginatedReports = computed(() => {
  const start = (currentPage.value - 1) * pageSize;
  return filteredReports.value.slice(start, start + pageSize);
});

const pageStartItem = computed(() => {
  if (filteredReports.value.length === 0) return 0;
  return (currentPage.value - 1) * pageSize + 1;
});

const pageEndItem = computed(() =>
  Math.min(currentPage.value * pageSize, filteredReports.value.length),
);

watch(searchQuery, () => {
  currentPage.value = 1;
  sliderValue.value = 1;
});

watch(filteredReports, () => {
  if (currentPage.value > totalPages.value) {
    currentPage.value = totalPages.value;
  }
  sliderValue.value = currentPage.value;
});

const goToPage = (page: number) => {
  currentPage.value = Math.min(Math.max(page, 1), totalPages.value);
  sliderValue.value = currentPage.value;
};

const applySearch = () => {
  searchQuery.value = searchInput.value.trim();
};

const clearSearch = () => {
  searchInput.value = "";
  searchQuery.value = "";
};

const commitSliderValue = (page?: number) => {
  goToPage(page ?? sliderValue.value);
};

const fetchMyReports = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/ombudsman/my`, {
      headers: getAuthHeader(),
    });
    reports.value = data as any[];
    currentPage.value = 1;
    sliderValue.value = 1;
  } catch (err) {
    console.error("서버 통신 오류(fetch) reports:", err);
  } finally {
    loading.value = false;
  }
};

const submitReport = async () => {
  try {
    if (editingReport.value) {
      await $fetch(
        `${apiBase.value}/ombudsman/${editingReport.value.report_id}`,
        {
          method: "PATCH",
          headers: getAuthHeader(),
          body: form.value,
        },
      );
    } else {
      await $fetch(`${apiBase.value}/ombudsman`, {
        method: "POST",
        headers: getAuthHeader(),
        body: form.value,
      });
    }
    resetForm();
    await fetchMyReports();
  } catch (err) {
    alert("제출에 실패했습니다.");
  }
};

const editReport = (report: any) => {
  editingReport.value = report;
  form.value = {
    category: report.category,
    title: report.title,
    content: report.content,
  };
  showForm.value = true;
};

const deleteReport = async (id: string) => {
  if (!confirm("정말 삭제하시겠습니까?")) return;
  try {
    await $fetch(`${apiBase.value}/ombudsman/${id}`, {
      method: "DELETE",
      headers: getAuthHeader(),
    });
    await fetchMyReports();
  } catch (err) {
    alert("삭제에 실패했습니다.");
  }
};

const resetForm = () => {
  showForm.value = false;
  editingReport.value = null;
  form.value = { category: "OPINION", title: "", content: "" };
};

onMounted(fetchMyReports);
</script>

<template>
  <div class="modal-overlay" @click.self="emit('close')">
    <div class="modal-card">
      <div class="modal-header">
        <h2><IconFeedback class="header-icon" /> 옴브즈먼 (사이트 피드백)</h2>
        <button class="btn-close" @click="emit('close')">
          <IconClose class="close-icon" />
        </button>
      </div>

      <div class="modal-body">
        <Transition name="section-slide" mode="out-in">
          <div v-if="!showForm" key="report-list" class="list-section">
            <div class="list-header">
              <h3>나의 제보 내역</h3>
              <button class="btn-primary" @click="showForm = true">
                새 제보하기
              </button>
            </div>

            <div v-if="reports.length > 0" class="pagination-panel-border">
              <div class="slider-panel">
                <div class="search-row">
                  <label class="search-box">
                    <IconSearch class="search-icon-svg" />
                    <input
                      v-model="searchInput"
                      type="search"
                      placeholder="제목, 내용, 분류를 입력하세요"
                      @keyup.enter="applySearch"
                    />
                  </label>
                  <button class="btn-search" @click="applySearch">검색</button>
                  <button
                    v-if="searchQuery"
                    class="btn-reset-search"
                    @click="clearSearch"
                  >
                    초기화
                  </button>
                </div>
                <div v-if="filteredReports.length > 0" class="slider-row">
                  <span class="summary-text"
                    >총 {{ filteredReports.length }}건의 제보</span
                  >
                  <div class="page-slider-section">
                    <PageSlider
                      v-model="sliderValue"
                      :max="totalPages"
                      :disabled="isSliderDisabled"
                      postfix="페이지"
                      @commit="commitSliderValue"
                    />
                  </div>
                  <span class="range-text"
                    >{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시
                    중</span
                  >
                </div>
              </div>
            </div>

            <div v-if="loading" class="loading">불러오는 중...</div>
            <div v-else-if="reports.length === 0" class="empty">
              아직 등록된 제보가 없습니다.
            </div>
            <div v-else-if="filteredReports.length === 0" class="empty">
              검색 결과가 없습니다.
            </div>
            <div v-else class="report-list-shell">
              <TransitionGroup
                name="report-slide"
                tag="div"
                class="report-list"
              >
                <div
                  v-for="report in paginatedReports"
                  :key="report.report_id"
                  class="report-item"
                >
                  <div class="report-main">
                    <div class="report-meta">
                      <span
                        class="category-badge"
                        :class="report.category.toLowerCase()"
                      >
                        {{
                          categories.find((c) => c.value === report.category)
                            ?.label
                        }}
                      </span>
                      <p class="report-date">
                        {{ new Date(report.created_at).toLocaleDateString() }}
                      </p>
                    </div>
                    <div class="report-content-row">
                      <h4 class="report-title">{{ report.title }}</h4>
                      <div class="report-actions">
                        <button class="btn-icon" @click="editReport(report)">
                          <IconPencil class="action-icon" />
                        </button>
                        <button
                          class="btn-icon"
                          @click="deleteReport(report.report_id)"
                        >
                          <IconTrash class="action-icon" />
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </TransitionGroup>
            </div>
          </div>

          <div v-else key="report-form" class="form-section">
            <h3>{{ editingReport ? "제보 수정" : "새 제보 등록" }}</h3>
            <div class="form-group">
              <label>분류</label>
              <select v-model="form.category">
                <option
                  v-for="cat in categories"
                  :key="cat.value"
                  :value="cat.value"
                >
                  {{ cat.label }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>제목</label>
              <input
                v-model="form.title"
                type="text"
                placeholder="제목을 입력하세요"
              />
            </div>
            <div class="form-group">
              <label>내용</label>
              <textarea
                v-model="form.content"
                rows="6"
                placeholder="상세 내용을 입력하세요"
              ></textarea>
            </div>
            <div class="form-actions">
              <button class="btn-secondary" @click="resetForm">취소</button>
              <button class="btn-primary" @click="submitReport">
                {{ editingReport ? "수정 완료" : "제출하기" }}
              </button>
            </div>
          </div>
        </Transition>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-card {
  background: #1e293b;
  width: 90%;
  max-width: 600px;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  max-height: 85vh;
}

.modal-header {
  padding: 0.5rem 1.4rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h2 {
  font-size: 1.25rem;
  color: #f8fafc;
  font-weight: 800;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  cursor: pointer;
}

.header-icon,
.close-icon,
.search-icon-svg,
.action-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.modal-body {
  padding: 1.2rem 1.4rem 1.4rem;
  overflow-y: auto;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.9rem;
}

.list-header h3 {
  color: #94a3b8;
  font-size: 1rem;
}
.pagination-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  padding: 0.95rem 1rem;
  background: rgba(15, 23, 42, 0.58);
  box-shadow: 0 20px 60px -22px rgba(15, 23, 42, 1);
  margin-bottom: 0.95rem;
}
.slider-panel {
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
}
.search-row {
  display: flex;
  align-items: center;
  gap: 0.7rem;
  flex-wrap: wrap;
}
.search-box {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 0.55rem;
  background: rgba(15, 23, 42, 0.55);
  border: 1px solid rgba(148, 163, 184, 0.18);
  border-radius: 10px;
  padding: 0.6rem 0.9rem;
}
.search-box input {
  width: 100%;
  background: transparent;
  border: none;
  color: #e2e8f0;
  outline: none;
}
.search-box input::placeholder {
  color: #64748b;
}
.search-icon-svg {
  color: #94a3b8;
}
.result-count {
  color: #94a3b8;
  font-size: 0.82rem;
  white-space: nowrap;
}
.btn-search,
.btn-reset-search {
  border: none;
  border-radius: 10px;
  padding: 0.62rem 1rem;
  font-weight: 700;
  cursor: pointer;
}
.btn-search {
  background: #6366f1;
  color: #fff;
}
.btn-reset-search {
  background: rgba(255, 255, 255, 0.08);
  color: #cbd5e1;
}
.slider-row {
  display: flex;
  align-items: center;
  gap: 0.9rem;
  justify-content: space-between;
}
.summary-text,
.range-text {
  font-size: 0.85rem;
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
}
.slider-wrapper.disabled {
  pointer-events: none;
  opacity: 0.6;
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
  box-shadow:
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
}
.slider-tooltip::after {
  content: "";
  position: absolute;
  bottom: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-top: 4px solid #6366f1;
}

.report-list {
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
}
.report-list-shell {
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
}

.report-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 0.68rem 0.9rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.report-main {
  width: 100%;
}
.report-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.4rem;
  margin-bottom: 0.05rem;
}
.report-content-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.category-badge {
  font-size: 0.7rem;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-weight: 700;
  display: inline-block;
}

.category-badge.opinion {
  background: rgba(56, 189, 248, 0.1);
  color: #38bdf8;
}
.category-badge.improvement {
  background: rgba(34, 197, 94, 0.1);
  color: #4ade80;
}
.category-badge.complaint {
  background: rgba(244, 63, 94, 0.1);
  color: #fb7185;
}

.report-title {
  color: #f8fafc;
  font-weight: 600;
  margin: 0;
  line-height: 1.2;
}
.report-date {
  color: #64748b;
  font-size: 0.8rem;
}

.report-actions {
  display: flex;
  gap: 0.5rem;
}
.btn-icon {
  background: none;
  border: none;
  font-size: 0.82rem;
  cursor: pointer;
  opacity: 0.6;
  transition: opacity 0.2s;
}
.btn-icon:hover {
  opacity: 1;
}

.section-slide-enter-active,
.section-slide-leave-active {
  transition:
    opacity 0.22s ease,
    transform 0.22s ease;
}
.section-slide-enter-from,
.section-slide-leave-to {
  opacity: 0;
  transform: translateX(18px);
}

.report-slide-enter-active,
.report-slide-leave-active,
.report-slide-move {
  transition:
    opacity 0.22s ease,
    transform 0.22s ease;
}
.report-slide-enter-from,
.report-slide-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

.form-section h3 {
  color: #f8fafc;
  margin-bottom: 1.5rem;
}

.form-group {
  margin-bottom: 1.2rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.form-group label {
  color: #94a3b8;
  font-size: 0.9rem;
  font-weight: 600;
}

.form-group input,
.form-group textarea,
.form-group select {
  background: rgba(15, 23, 42, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 0.8rem;
  color: #f8fafc;
  outline: none;
}

.form-group input:focus,
.form-group textarea:focus {
  border-color: #818cf8;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 2rem;
}

.btn-primary {
  background: #818cf8;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 10px;
  font-weight: 700;
  cursor: pointer;
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.05);
  color: #94a3b8;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 10px;
  font-weight: 700;
  cursor: pointer;
}

.loading,
.empty {
  text-align: center;
  padding: 2rem;
  color: #64748b;
}

@media (max-width: 640px) {
  .modal-card {
    width: calc(100% - 1.2rem);
  }

  .list-header,
  .search-row,
  .slider-row,
  .report-meta,
  .report-content-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .search-box,
  .page-slider-section {
    width: 100%;
  }

  .report-actions,
  .btn-reset-search,
  .btn-search,
  .range-text {
    align-self: flex-end;
  }
}
</style>
