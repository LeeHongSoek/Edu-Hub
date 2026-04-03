<script setup lang="ts">
import { ref, computed, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";
import ManagerNav from "~/components/dashboard/ManagerNav.vue";
import IconCreateAction from "~/assets/icons/IconCreateAction.svg?component";
import IconDeleteAction from "~/assets/icons/IconDeleteAction.svg?component";

const props = withDefaults(
  defineProps<{
    showScopeToggle?: boolean;
  }>(),
  {
    showScopeToggle: false,
  },
);

const exams = ref<any[]>([]);
const loading = ref(true);
const pageSize = 5;
const currentPage = ref(1);
const sliderValue = ref(1);
const route = useRoute();
const listScope = ref<"mine" | "all">(
  route.query.scope === "all" ? "all" : "mine",
);
const selectedExamIds = ref<string[]>([]);
const examSearchInput = ref("");
const examSearchQuery = ref("");
const userCookie = useCookie("user_info");
const userInfo = computed(() => {
  if (!userCookie.value) return null;
  try {
    return typeof userCookie.value === "string"
      ? JSON.parse(userCookie.value)
      : userCookie.value;
  } catch {
    return null;
  }
});

const listTitle = computed(() =>
  listScope.value === "all" ? "전체 고사집 목록" : "나의 고사집 목록",
);
const selectedClassId = computed(() => {
  const raw = route.query.classId;
  return typeof raw === "string" && raw.trim() ? raw : "";
});
const selectedClassName = computed(() => {
  const raw = route.query.className;
  return typeof raw === "string" && raw.trim() ? raw : "";
});
const emptyText = computed(() => {
  if (examSearchQuery.value) return "검색 조건에 맞는 고사집이 없습니다.";
  if (selectedClassName.value) {
    return `${selectedClassName.value}에 연결된 고사집이 없습니다.`;
  }
  return listScope.value === "all"
    ? "등록된 고사집이 없습니다."
    : "생성된 고사집이 없습니다.";
});

const isCurrentUserOwner = (
  ownerUserNo: string | number | bigint | null | undefined,
) => {
  if (!userInfo.value || ownerUserNo === null || ownerUserNo === undefined)
    return false;
  return String(userInfo.value.user_no) === String(ownerUserNo);
};

const filteredExams = computed(() => {
  const keyword = examSearchQuery.value.trim().toLowerCase();
  if (!keyword) return exams.value;
  return exams.value.filter((exam) => {
    const target = exam.exam_name;
    return target.toLowerCase().includes(keyword);
  });
});

const totalPages = computed(() =>
  Math.max(1, Math.ceil(filteredExams.value.length / pageSize)),
);
const pagedExams = computed(() => {
  // 프론트 단순 페이지네이션 (서버 페이징 없음)
  const start = (currentPage.value - 1) * pageSize;
  return filteredExams.value.slice(start, start + pageSize);
});
const pageStartItem = computed(() => {
  if (filteredExams.value.length === 0) return 0;
  return (currentPage.value - 1) * pageSize + 1;
});
const pageEndItem = computed(() =>
  Math.min(currentPage.value * pageSize, filteredExams.value.length),
);
const sliderPercentage = computed(() => {
  if (totalPages.value <= 1) return 0;
  return ((sliderValue.value - 1) / (totalPages.value - 1)) * 100;
});
const selectedExamCount = computed(() => selectedExamIds.value.length);
const canDeleteExams = computed(() => selectedExamCount.value > 0);

const isSliderDisabled = computed(() => totalPages.value <= 1);

watch(
  () => filteredExams.value.length,
  () => {
    currentPage.value = 1;
    sliderValue.value = 1;
  },
);

watch(currentPage, (page) => {
  sliderValue.value = page;
});

const { apiBase, getAuthHeader } = useApi();
const router = useRouter();

const viewExamDetails = (examId: number | string | bigint) => {
  router.push({
    path: "/questions",
    query: { exam: String(examId) },
  });
};

const fetchExams = async () => {
  loading.value = true;
  try {
    // scope와 classId를 함께 보내서 서버에서 즉시 필터된 목록을 가져옵니다.
    const data = await $fetch(`${apiBase.value}/exams`, {
      headers: getAuthHeader(),
      query: {
        scope: listScope.value,
        classId: selectedClassId.value || undefined,
      },
    });
    exams.value = data as any[];
    selectedExamIds.value = [];
  } catch (err) {
    console.error("서버 통신 오류(fetch) exams:", err);
  } finally {
    loading.value = false;
  }
};

watch(
  () => route.query.scope,
  (scope) => {
    listScope.value = scope === "all" ? "all" : "mine";
  },
);

watch(
  [listScope, selectedClassId],
  async () => {
    currentPage.value = 1;
    sliderValue.value = 1;
    await fetchExams();
  },
  { immediate: true },
);

const setScope = (scope: "mine" | "all") => {
  if (listScope.value === scope) return;
  router.replace({
    query: {
      ...route.query,
      scope,
    },
  });
};

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
  examSearchInput.value = "";
  examSearchQuery.value = "";
  currentPage.value = 1;
};

const clearClassFilter = () => {
  const nextQuery = { ...route.query };
  delete nextQuery.classId;
  delete nextQuery.className;
  router.replace({ query: nextQuery });
};
const showCreateModal = ref(false);
const createLoading = ref(false);
const createError = ref("");
const createForm = ref({
  exam_name: "",
  description: "",
  start_time: "",
  end_time: "",
  location: "",
  is_auto_score: true,
  class_id: "", // 추가
});

const taughtClasses = ref<any[]>([]); // 추가

const openCreateModal = async () => {
  createForm.value = {
    exam_name: "",
    description: "",
    start_time: "",
    end_time: "",
    location: "",
    is_auto_score: true,
    class_id: "",
  };
  createError.value = "";
  showCreateModal.value = true;
  await fetchTaughtClasses(); // 모달 열 때 클래스 목록 로드
};

const fetchTaughtClasses = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/dashboard/classes`, {
      headers: getAuthHeader(),
    });
    taughtClasses.value = (data as any).classes || [];
  } catch (err) {
    console.error("클래스 목록 로드 실패:", err);
  }
};

const closeCreateModal = () => {
  showCreateModal.value = false;
};

const submitCreateExam = async () => {
  if (!createForm.value.exam_name.trim()) {
    createError.value = "고사 이름을 입력해주세요.";
    return;
  }
  if (!createForm.value.start_time || !createForm.value.end_time) {
    createError.value = "시작일시와 종료일시를 모두 입력해주세요.";
    return;
  }
  if (new Date(createForm.value.start_time) >= new Date(createForm.value.end_time)) {
    createError.value = "종료일시는 시작일시보다 이후여야 합니다.";
    return;
  }
  createLoading.value = true;
  createError.value = "";
  try {
    await $fetch(`${apiBase.value}/exams`, {
      method: "POST",
      headers: getAuthHeader(),
      body: {
        exam_name: createForm.value.exam_name.trim(),
        description: createForm.value.description.trim() || undefined,
        start_time: createForm.value.start_time,
        end_time: createForm.value.end_time,
        location: createForm.value.location.trim() || undefined,
        is_auto_score: createForm.value.is_auto_score,
        class_id: createForm.value.class_id ? Number(createForm.value.class_id) : null,
      },
    });
    closeCreateModal();
    await fetchExams();
  } catch (err: any) {
    createError.value = err?.data?.message || "고사 생성 중 오류가 발생했습니다.";
  } finally {
    createLoading.value = false;
  }
};

const getExamIdKey = (examId: number | string | bigint) => String(examId);

const isExamSelected = (examId: number | string | bigint) =>
  selectedExamIds.value.includes(getExamIdKey(examId));

const toggleExamSelected = (
  examId: number | string | bigint,
  checked: boolean,
) => {
  const idKey = getExamIdKey(examId);
  if (checked) {
    if (!selectedExamIds.value.includes(idKey)) {
      selectedExamIds.value = [...selectedExamIds.value, idKey];
    }
    return;
  }
  selectedExamIds.value = selectedExamIds.value.filter((id) => id !== idKey);
};

const deleteSelectedExams = async () => {
  if (!canDeleteExams.value) return;
  const ok = window.confirm(
    `선택한 고사집 ${selectedExamCount.value}개를 삭제하시겠습니까?`,
  );
  if (!ok) return;

  try {
    const result = (await $fetch(`${apiBase.value}/exams/soft-delete`, {
      method: "PATCH",
      headers: getAuthHeader(),
      body: {
        examIds: selectedExamIds.value,
      },
    })) as { updatedCount?: number };

    const deletedCount = Number(result?.updatedCount ?? 0);
    if (deletedCount === 0) {
      alert("삭제할 수 있는 고사집이 없습니다.");
    }
    selectedExamIds.value = [];
    await fetchExams();
  } catch (err) {
    console.error("고사집 삭제 오류:", err);
    alert("고사집 삭제 중 오류가 발생했습니다.");
  }
};

</script>

<template>
  <div class="exam-manager">
    <div class="manager-header">
      <div class="header-copy">
        <div class="title-row">
          <h3><IconCalendar class="section-icon" /> {{ listTitle }}</h3>

          <div class="action-button-group">
            <button class="btn-create" @click="openCreateModal" id="btn-open-create-exam">
              <IconCreateAction class="btn-action-icon" />
              새 고사집
            </button>
            <button class="btn-delete" :disabled="!canDeleteExams" @click="deleteSelectedExams">
              <IconDeleteAction class="btn-action-icon" />
              삭제
            </button>
          </div>
        </div>
      </div>

      <ManagerNav active-page="exams" />
    </div>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="filteredExams.length === 0" class="empty">
      {{ emptyText }}
    </div>
    <div v-else>
      <div class="pagination-panel-border">
        <div class="slider-panel">
          <div v-if="selectedClassName" class="class-filter-banner">
            <span class="class-filter-label">클래스 필터</span>
            <strong>{{ selectedClassName }}</strong>
            <button class="class-filter-clear" @click="clearClassFilter">
              전체 보기
            </button>
          </div>
          <div class="search-row">
            <div
              v-if="showScopeToggle"
              class="scope-toggle"
              role="tablist"
              aria-label="고사집 범위 선택"
            >
              <button
                type="button"
                class="scope-btn"
                :class="{ active: listScope === 'mine' }"
                :aria-pressed="listScope === 'mine'"
                @click="setScope('mine')"
              >
                나의 고사집
              </button>
              <button
                type="button"
                class="scope-btn"
                :class="{ active: listScope === 'all' }"
                :aria-pressed="listScope === 'all'"
                @click="setScope('all')"
              >
                전체 고사집
              </button>
            </div>
            <input
              v-model="examSearchInput"
              type="text"
              class="search-input"
              placeholder="시험 제목을 입력하세요"
              @keyup.enter="applyExamSearch"
            />
            <button class="btn-search" @click="applyExamSearch">검색</button>
            <button
              v-if="examSearchQuery"
              class="btn-reset-search"
              @click="clearExamSearch"
            >
              초기화
            </button>
          </div>
          <div class="slider-row">
            <span class="summary-text"
              >총 {{ filteredExams.length }}개의 고사집</span
            >
            <div class="page-slider-section">
              <div
                class="slider-wrapper"
                :class="{ disabled: isSliderDisabled }"
              >
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
                  <div
                    class="slider-fill"
                    :style="{ width: sliderPercentage + '%' }"
                  ></div>
                  <div
                    class="slider-tooltip"
                    :style="{ left: sliderPercentage + '%' }"
                  >
                    {{ sliderValue }}
                  </div>
                </div>
                <span class="slider-limit">{{ totalPages }}</span>
              </div>
            </div>
            <span class="range-text"
              >{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시 중</span
            >
          </div>
        </div>
      </div>
      <div class="exam-list">
        <div v-for="exam in pagedExams" :key="exam.exam_id" class="exam-card">
          <div class="exam-info">
            <div class="exam-headline">
              <span class="exam-id">{{ exam.exam_id }}</span> 
              <div class="exam-badge">고사</div>
              <span class="exam-period-inline"
                >{{ new Date(exam.start_time).toLocaleDateString("ko-KR") }} ~
                {{ new Date(exam.end_time).toLocaleDateString("ko-KR") }}</span
              >
            </div>
            <h4>
              <input
                type="checkbox"
                class="copy-checkbox"
                aria-label="고사 선택"
                :checked="isExamSelected(exam.exam_id)"
                :disabled="!isCurrentUserOwner(exam.creator?.user_no)"
                @change="
                  toggleExamSelected(
                    exam.exam_id,
                    ($event.target as HTMLInputElement).checked,
                  )
                "
              />
              <span>{{ exam.exam_name }}</span>
            </h4>
          </div>
          <div class="exam-meta">
            <span class="exam-meta-line">
              <span
                v-if="
                  exam.creator?.username &&
                  !isCurrentUserOwner(exam.creator.user_no)
                "
                class="exam-owner"
                >{{ exam.creator.username }}</span
              >
              <span
                v-if="
                  exam.creator?.username &&
                  !isCurrentUserOwner(exam.creator.user_no)
                "
                class="exam-separator"
                >·</span
              >
              <span class="exam-count"
                >문제수 {{ exam._count?.questions ?? 0 }}문항</span
              >
              <span v-if="exam.class?.class_name" class="exam-separator">·</span>
              <span v-if="exam.class?.class_name" class="exam-class-name">
                {{ exam.class.class_name }}
              </span>
            </span>
            <button class="btn-start" @click="viewExamDetails(exam.exam_id)">
              상세보기
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- 새 고사 생성 모달 -->
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="showCreateModal" class="modal-backdrop" @click.self="closeCreateModal">
        <div class="modal-box" role="dialog" aria-modal="true" aria-labelledby="modal-title">
          <div class="modal-header">
            <h2 id="modal-title" class="modal-title">새 고사집 만들기</h2>
            <button class="modal-close-btn" @click="closeCreateModal" aria-label="닫기">✕</button>
          </div>

          <form class="modal-form" @submit.prevent="submitCreateExam">
            <div class="form-group">
              <label for="exam-name" class="form-label">고사 이름 <span class="required">*</span></label>
              <input
                id="exam-name"
                v-model="createForm.exam_name"
                type="text"
                class="form-input"
                placeholder="예) 2024년 1학기 중간고사"
                maxlength="255"
                autocomplete="off"
              />
            </div>

            <div class="form-group">
              <label for="exam-class" class="form-label"
                >대상 클래스 <span class="optional">(선택)</span></label
              >
              <select
                id="exam-class"
                v-model="createForm.class_id"
                class="form-input"
              >
                <option value="">선택하지 않음</option>
                <option
                  v-for="cls in taughtClasses"
                  :key="cls.classId"
                  :value="cls.classId"
                >
                  {{ cls.className }}
                </option>
              </select>
            </div>


            <div class="form-row form-row-datetime">
              <div class="form-group">
                <label for="exam-start" class="form-label">시작 일시 <span class="required">*</span></label>
                <DateTimePicker
                  id="exam-start"
                  v-model="createForm.start_time"
                  :size="1"
                />
              </div>
              <div class="form-group">
                <label for="exam-end" class="form-label">종료 일시 <span class="required">*</span></label>
                <DateTimePicker
                  id="exam-end"
                  v-model="createForm.end_time"
                  align="right"
                  :size="1"
                />
              </div>
            </div>
            <p class="form-help">
              날짜를 더블클릭하면 바로 확정되고, 하단 완료 버튼으로도 저장할 수 있습니다.
            </p>

            <div class="form-group">
              <label for="exam-location" class="form-label">장소 <span class="optional">(선택)</span></label>
              <input
                id="exam-location"
                v-model="createForm.location"
                type="text"
                class="form-input"
                placeholder="예) 1학년 1반 교실"
                maxlength="100"
                autocomplete="off"
              />
            </div>

            <div class="form-group form-group-check">
              <label class="form-check-label" for="exam-auto-score">
                <input
                  id="exam-auto-score"
                  v-model="createForm.is_auto_score"
                  type="checkbox"
                  class="form-checkbox"
                />
                <span class="check-text">자동 채점 활성화</span>
              </label>
            </div>


            <div class="form-group">
              <label for="exam-description" class="form-label">
                설명 <span class="optional">(선택)</span>
              </label>
              <textarea
                id="exam-description"
                v-model="createForm.description"
                class="form-input form-textarea"
                placeholder="고사집에 대한 설명을 적어주세요."
                maxlength="1000"
              ></textarea>
            </div>

            <div v-if="createError" class="form-error">{{ createError }}</div>

            <div class="modal-actions">
              <button type="button" class="btn-cancel" @click="closeCreateModal" :disabled="createLoading">
                취소
              </button>
              <button type="submit" class="btn-submit" :disabled="createLoading" id="btn-submit-create-exam">
                <span v-if="createLoading" class="loading-spinner"></span>
                {{ createLoading ? '생성 중...' : '고사 생성' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.exam-manager {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.class-filter-banner {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  flex-wrap: wrap;
  margin-bottom: 0.9rem;
}

.class-filter-label {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.2rem 0.5rem;
  border-radius: 999px;
  background: rgba(129, 140, 248, 0.14);
  color: #c7d2fe;
  font-size: 0.74rem;
  font-weight: 700;
}

.class-filter-banner strong {
  color: #f8fafc;
  font-size: 0.95rem;
}

.class-filter-clear {
  appearance: none;
  border: 1px solid rgba(129, 140, 248, 0.22);
  background: rgba(30, 41, 59, 0.72);
  color: #cbd5e1;
  padding: 0.32rem 0.65rem;
  border-radius: 8px;
  cursor: pointer;
}

.exam-class-name {
  color: #c7d2fe;
  font-size: 0.86rem;
}
.manager-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  width: 100%;
}
.header-copy {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  flex: 1;
}
.title-row {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  flex-wrap: wrap;
}
.exam-manager h3 {
  color: #f8fafc;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.35rem;
  font-size: 1.35rem;
  line-height: 1.2;
  font-weight: 800;
}

.section-icon {
  width: 1.4rem;
  height: 1.4rem;
  flex-shrink: 0;
}

.scope-toggle {
  display: inline-flex;
  gap: 2px;
  padding: 2px;
  border-radius: 6px;
  background: rgba(15, 23, 42, 0.55);
  border: 1px solid rgba(148, 163, 184, 0.14);
}

.scope-btn {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 0.9rem;
  font-weight: 700;
  border-radius: 999px;
  padding: 0 0.85rem;
  height: 32px;
  line-height: 32px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  transition: all 0.2s ease;
}

.scope-btn {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 0.75rem;
  font-weight: 700;
  border-radius: 4px;
  padding: 0.45rem 0.9rem;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.scope-btn.active {
  background: linear-gradient(135deg, #6366f1, #818cf8);
  color: #ffffff;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.35);
}


.exam-card {
  display: inline-flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1.25rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.exam-info {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}
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
.exam-id {
  font-size: 1.5rem !important;
  font-weight: 900 !important;
  color: #0055ff !important;
  margin-right: 0.5rem;
}

.exam-info h4 {
  display: flex;
  align-items: center;
  color: #f8fafc;
  margin: 0;
  font-size: 1.15rem;
  font-weight: 700;
}

.copy-checkbox {
  width: 1.4rem;
  height: 1.4rem;
  -webkit-appearance: none;
  appearance: none;
  border: 1.9px solid rgba(148, 163, 184, 0.7);
  border-radius: 0.19rem;
  background: rgba(15, 23, 42, 0.55);
  box-shadow: inset 0 0 0 1px rgba(15, 23, 42, 0.35);
  cursor: pointer;
  position: relative;
  display: inline-flex;
  flex-shrink: 0;
  align-self: center;
  margin-right: 0.6rem;
}

.copy-checkbox:checked {
  border-color: #818cf8;
  background: rgba(99, 102, 241, 0.28);
}

.copy-checkbox:checked::after {
  content: "";
  position: absolute;
  left: 35%;
  top: 18%;
  width: 20%;
  height: 42%;
  border: solid #dbeafe;
  border-width: 0 0.18rem 0.18rem 0;
  transform: rotate(45deg);
}

.copy-checkbox:disabled {
  opacity: 0.42;
  cursor: not-allowed;
}

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

.search-input {
  flex: 1;
  min-width: 220px;
  height: 30px;
  padding-top: 0.1rem;
  padding-bottom: 0.1rem;
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
  top: 32px;
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
  z-index: 10;
}

.slider-tooltip::after {
  content: "";
  position: absolute;
  top: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-bottom: 4px solid #6366f1;
}

.loading,
.empty {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}

.exam-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
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

/* 새 고사 버튼 */
.action-button-group {
  display: flex !important;
  align-items: center !important;
  background: rgba(15, 23, 42, 0.4);
  padding: 4px;
  border-radius: 12px;
  border: 1px solid rgba(129, 140, 248, 0.2);
  backdrop-filter: blur(8px);
}

.btn-create,
.btn-delete {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  height: 32px;
  padding: 0 0.95rem;
  border: none;
  font-size: 0.9rem;
  font-weight: 700;
  line-height: 1;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.btn-create {
  background: linear-gradient(135deg, #6366f1, #818cf8);
  color: white;
  border-radius: 8px;
}

.btn-create:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4);
}

.btn-delete {
  background: transparent;
  color: #94a3b8;
  border-radius: 8px;
  margin-left: 2px;
}

.btn-delete:hover:not(:disabled) {
  background: rgba(239, 68, 68, 0.15);
  color: #f87171;
}

.btn-delete:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.btn-action-icon {
  width: 0.92rem;
  height: 0.92rem;
  flex-shrink: 0;
}

.btn-delete-exam:hover:not(:disabled) {
  background: rgba(239, 68, 68, 0.22);
  border-color: rgba(248, 113, 113, 0.7);
}

.btn-delete-exam:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.btn-action-icon {
  width: 0.92rem;
  height: 0.92rem;
  flex-shrink: 0;
}

.btn-new-icon {
  font-size: 1rem;
  line-height: 1;
}

/* 모달 스타일 */
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 23, 0.75);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 1rem;
}

.modal-box {
  background: linear-gradient(145deg, rgba(15, 23, 42, 0.98), rgba(30, 41, 59, 0.98));
  border: 1px solid rgba(99, 102, 241, 0.3);
  border-radius: 18px;
  padding: 2rem;
  width: 100%;
  max-width: 520px;
  box-shadow:
    0 25px 60px rgba(0, 0, 0, 0.6),
    0 0 0 1px rgba(255, 255, 255, 0.04) inset;
  animation: modal-slide-in 0.25s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes modal-slide-in {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.97);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.75rem;
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 800;
  color: #f1f5f9;
  margin: 0;
}

.modal-close-btn {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #94a3b8;
  width: 34px;
  height: 34px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 1rem;
  transition: all 0.2s;
}

.modal-close-btn:hover {
  background: rgba(255, 255, 255, 0.12);
  color: #f1f5f9;
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.form-row-datetime {
  gap: 0.75rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.45rem;
  min-width: 0;
}

.form-group-check {
  flex-direction: row;
  align-items: center;
}

.form-label {
  font-size: 0.88rem;
  font-weight: 600;
  color: #94a3b8;
}

.required {
  color: #f87171;
}

.optional {
  color: #64748b;
  font-weight: 400;
  font-size: 0.82rem;
}

.form-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  color: #f1f5f9;
  padding: 0.6rem 0.85rem;
  font-size: 0.92rem;
  transition: border-color 0.2s, box-shadow 0.2s;
  outline: none;
  width: 100%;
  box-sizing: border-box;
}

.form-input:focus {
  border-color: rgba(99, 102, 241, 0.6);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.12);
}

.form-input::placeholder {
  color: #475569;
}

.form-textarea {
  min-height: 96px;
  resize: vertical;
}

.form-input-datetime {
  min-width: 0;
  font-size: 0.88rem;
  letter-spacing: -0.01em;
}

.form-help {
  margin: -0.35rem 0 0.1rem;
  font-size: 0.76rem;
  color: #94a3b8;
  line-height: 1.45;
}

.form-check-label {
  display: inline-flex;
  align-items: center;
  gap: 0.6rem;
  cursor: pointer;
}

.form-checkbox {
  width: 1rem;
  height: 1rem;
  accent-color: #6366f1;
  cursor: pointer;
}

.check-text {
  font-size: 0.9rem;
  color: #94a3b8;
  font-weight: 500;
}

.form-error {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: 8px;
  padding: 0.6rem 0.9rem;
  font-size: 0.88rem;
  color: #fca5a5;
  font-weight: 500;
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
  margin-top: 0.5rem;
}

.btn-cancel {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #94a3b8;
  padding: 0.6rem 1.4rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-cancel:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.1);
  color: #e2e8f0;
}

.btn-cancel:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-submit {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border: none;
  color: #fff;
  padding: 0.6rem 1.6rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 700;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.2s;
  box-shadow: 0 4px 14px rgba(99, 102, 241, 0.35);
}

.btn-submit:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.5);
}

.btn-submit:disabled {
  opacity: 0.65;
  cursor: not-allowed;
  transform: none;
}

.loading-spinner {
  width: 14px;
  height: 14px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* 모달 트랜지션 */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.2s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

@media (max-width: 600px) {
  .form-row {
    grid-template-columns: 1fr;
  }

  .form-row-datetime {
    gap: 1rem;
  }

  .modal-box {
    padding: 1.5rem 1.25rem;
  }

}
</style>
