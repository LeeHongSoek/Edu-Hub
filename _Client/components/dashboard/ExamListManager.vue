<script setup lang="ts">
import { ref, computed, watch, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";
import ManagerNav from "~/components/dashboard/ManagerNav.vue";
import IconCreateAction from "~/assets/icons/IconCreateAction.svg?component";
import IconDeleteAction from "~/assets/icons/IconDeleteAction.svg?component";
import PageSlider from "~/components/PageSlider.vue";
import DailyQuestionsModal from "~/components/DailyQuestionsModal.vue";
import type { Question } from "~/types";
import { useUserLog } from "~/composables/useUserLog";

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
const pageSize = 10;
const currentPage = ref(1);
const sliderValue = ref(1);
const route = useRoute();
const listScope = ref<"mine" | "all">(
  route.query.scope === "all" ? "all" : "mine",
);
const selectedExamIds = ref<string[]>([]);
const examSearchInput = ref("");
const examSearchQuery = ref("");
const assignableClasses = ref<Array<{ classId: string; className: string }>>(
  [],
);
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
const { writeUserLog, writeUserLogOncePerSession } = useUserLog();
const router = useRouter();

const logExamAction = async (
  examId: number | string | bigint,
  userContent: string,
  score = 0,
  totalScore = 0,
  score100 = 0,
) => {
  await writeUserLog("E", examId, {
    user_content: userContent,
    score,
    total_score: totalScore,
    score100,
  });
};

const showDailyQuizModal = ref(false);
const dailyQuizQuestions = ref<Question[]>([]);
const dailyQuizTitle = ref("");
const dailyQuizLogContent = ref("");
const dailyQuizLogExamId = ref<number | string | bigint | null>(null);

const getExamLogLabel = (exam: any) =>
  `고사 #${String(exam.exam_id)} [${exam.exam_name || "제목 없음"}]`;

const closeDailyQuizModal = () => {
  showDailyQuizModal.value = false;
  dailyQuizQuestions.value = [];
  dailyQuizLogExamId.value = null;
};

const startQuiz = async (examId: number | string | bigint) => {
  const exam = exams.value.find((item) => String(item.exam_id) === String(examId));
  void logExamAction(
    examId,
    exam
      ? `${getExamLogLabel(exam)} 문제풀이 시작`
      : `고사 #${String(examId)} 문제풀이 시작`,
  );

  try {
    const payload = await $fetch<any>(`${apiBase.value}/exams/${examId}`, {
      headers: getAuthHeader(),
    });
    const fetchedQuestions = Array.isArray(payload?.questions)
      ? payload.questions
          .map((item: any) => item?.question)
          .filter((question: Question | undefined): question is Question =>
            Boolean(question),
          )
      : [];

    if (fetchedQuestions.length === 0) {
      alert("고사에 담긴 문제가 없습니다.");
      return;
    }

    dailyQuizQuestions.value = fetchedQuestions;
    dailyQuizTitle.value = exam
      ? `${exam.exam_name || "고사"} 일괄 풀기`
      : "고사 일괄 풀기";
    dailyQuizLogContent.value = exam
      ? `${getExamLogLabel(exam)} 일괄 풀이`
      : `고사 #${String(examId)} 일괄 풀이`;
    dailyQuizLogExamId.value = examId;
    showDailyQuizModal.value = true;
  } catch (error) {
    console.error("고사 문제 조회 실패:", error);
    alert("고사 문제를 불러오는 중 오류가 발생했습니다.");
  }
};

const viewExamDetails = async (examId: number | string | bigint) => {
  const exam = exams.value.find((item) => String(item.exam_id) === String(examId));
  await logExamAction(
    examId,
    exam ? `${getExamLogLabel(exam)} 문제등록 화면 이동` : `고사 #${String(examId)} 문제등록 화면 이동`,
  );
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
  void logExamAction(
    0,
    `고사집 목록 범위 전환: ${scope === "all" ? "전체 고사집" : "나의 고사집"}`,
  );
  router.replace({
    query: {
      ...route.query,
      scope,
    },
  });
};

const goToPage = (page: number) => {
  const normalized = Math.min(Math.max(page, 1), totalPages.value);
  if (normalized !== currentPage.value) {
    currentPage.value = normalized;
  }
};

const commitSliderValue = (page?: number) => {
  goToPage(page ?? sliderValue.value);
};

const applyExamSearch = () => {
  examSearchQuery.value = examSearchInput.value.trim();
  currentPage.value = 1;
  if (examSearchQuery.value) {
    void logExamAction(0, `고사집 검색 실행: "${examSearchQuery.value}"`);
  }
};

const clearExamSearch = () => {
  examSearchInput.value = "";
  examSearchQuery.value = "";
  currentPage.value = 1;
  void logExamAction(0, "고사집 검색어 초기화");
};

const clearClassFilter = () => {
  void logExamAction(
    selectedClassId.value || 0,
    `클래스 필터 해제: ${selectedClassName.value || "선택된 클래스 없음"}`,
  );
  const nextQuery = { ...route.query };
  delete nextQuery.classId;
  delete nextQuery.className;
  router.replace({ query: nextQuery });
};
const showCreateModal = ref(false);
const createLoading = ref(false);
const createError = ref("");
const editingExamId = ref<string>("");
const createForm = ref({
  classId: "",
  exam_name: "",
  description: "",
  start_time: "",
  end_time: "",
  location: "",
  is_auto_score: true,
});

const isEditingExam = computed(() => editingExamId.value !== "");
const modalTitle = computed(() =>
  isEditingExam.value ? "고사집 수정" : "새 고사집 만들기",
);
const submitButtonLabel = computed(() => {
  if (createLoading.value) {
    return isEditingExam.value ? "수정 중..." : "생성 중...";
  }
  return isEditingExam.value ? "고사 수정" : "고사 생성";
});

const pad2 = (value: number) => String(value).padStart(2, "0");

const toLocalDateTimeInputValue = (value?: string | Date | null) => {
  if (!value) return "";
  const date = new Date(value);
  return `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}T${pad2(date.getHours())}:${pad2(date.getMinutes())}`;
};

const openCreateModal = async () => {
  await fetchAssignableClasses();
  editingExamId.value = "";
  createForm.value = {
    classId: "",
    exam_name: "",
    description: "",
    start_time: "",
    end_time: "",
    location: "",
    is_auto_score: true,
  };
  createError.value = "";
  showCreateModal.value = true;
  await logExamAction(0, "고사 생성 모달 열기");
};

const openEditModal = async (exam: any) => {
  await fetchAssignableClasses();
  const linkedClassId =
    Array.isArray(exam?.class_exam_links) && exam.class_exam_links.length > 0
      ? String(exam.class_exam_links[0]?.class_id ?? "")
      : "";
  editingExamId.value = String(exam.exam_id);
  createForm.value = {
    classId: linkedClassId,
    exam_name: exam.exam_name || "",
    description: exam.description || "",
    start_time: toLocalDateTimeInputValue(exam.start_time),
    end_time: toLocalDateTimeInputValue(exam.end_time),
    location: exam.location || "",
    is_auto_score: exam.is_auto_score ?? true,
  };
  createError.value = "";
  showCreateModal.value = true;
  await logExamAction(exam.exam_id, `${getExamLogLabel(exam)} 수정 모달 열기`);
};

const closeCreateModal = () => {
  editingExamId.value = "";
  showCreateModal.value = false;
};

const fetchAssignableClasses = async () => {
  if (
    String(
      userInfo.value?.role_id || userInfo.value?.role || "",
    ).toUpperCase() !== "T"
  ) {
    assignableClasses.value = [];
    return;
  }

  try {
    const data = await $fetch<Array<{ classId: string; className: string }>>(
      `${apiBase.value}/dashboard/classes`,
      {
        headers: getAuthHeader(),
      },
    );
    assignableClasses.value = Array.isArray(data)
      ? data.map((item) => ({
          classId: String(item.classId),
          className: item.className,
        }))
      : [];
  } catch (error) {
    console.error("지정 가능 클래스 조회 실패:", error);
    assignableClasses.value = [];
  }
};

const submitExamForm = async () => {
  if (!createForm.value.exam_name.trim()) {
    createError.value = "고사 이름을 입력해주세요.";
    return;
  }
  if (!createForm.value.start_time || !createForm.value.end_time) {
    createError.value = "시작일시와 종료일시를 모두 입력해주세요.";
    return;
  }
  if (
    new Date(createForm.value.start_time) >= new Date(createForm.value.end_time)
  ) {
    createError.value = "종료일시는 시작일시보다 이후여야 합니다.";
    return;
  }
  createLoading.value = true;
  createError.value = "";
  try {
    const payload = {
      classId: createForm.value.classId || undefined,
      exam_name: createForm.value.exam_name.trim(),
      description: createForm.value.description.trim() || undefined,
      start_time: createForm.value.start_time,
      end_time: createForm.value.end_time,
      location: createForm.value.location.trim() || undefined,
      is_auto_score: createForm.value.is_auto_score,
    };

    if (isEditingExam.value) {
      await $fetch(`${apiBase.value}/exams/${editingExamId.value}`, {
        method: "PATCH",
        headers: getAuthHeader(),
        body: payload,
      });
      await logExamAction(
        editingExamId.value,
        `고사 #${String(editingExamId.value)} [${payload.exam_name}] 수정 저장 완료`,
      );
    } else {
      const createdExam = (await $fetch(`${apiBase.value}/exams`, {
        method: "POST",
        headers: getAuthHeader(),
        body: payload,
      })) as { exam_id?: string | number };
      await logExamAction(
        createdExam?.exam_id ?? 0,
        `고사 #${String(createdExam?.exam_id ?? 0)} [${payload.exam_name}] 생성 저장 완료`,
      );
    }
    closeCreateModal();
    await fetchExams();
  } catch (err: any) {
    createError.value =
      err?.data?.message ||
      (isEditingExam.value
        ? "고사 수정 중 오류가 발생했습니다."
        : "고사 생성 중 오류가 발생했습니다.");
  } finally {
    createLoading.value = false;
  }
};

const getExamIdKey = (examId: number | string | bigint) => String(examId);

const getExamClassNames = (exam: any) => {
  const links = Array.isArray(exam?.class_exam_links)
    ? exam.class_exam_links
    : [];
  const names = links
    .map((link: any) => link?.class?.class_name)
    .filter((name: string | undefined | null): name is string => Boolean(name));
  return names;
};

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

const toggleExamSelectedByName = (exam: any) => {
  if (!isCurrentUserOwner(exam.creator?.user_no)) return;
  const nextChecked = !isExamSelected(exam.exam_id);
  toggleExamSelected(exam.exam_id, nextChecked);
  void logExamAction(
    exam.exam_id,
    `${getExamLogLabel(exam)} 선택 ${nextChecked ? "추가" : "해제"}`,
  );
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
    await logExamAction(
      0,
      `고사집 일괄 삭제 요청 완료: ${selectedExamCount.value}개 선택`,
      deletedCount,
      selectedExamCount.value,
      selectedExamCount.value > 0
        ? Math.round((deletedCount / selectedExamCount.value) * 100)
        : 0,
    );
    selectedExamIds.value = [];
    await fetchExams();
  } catch (err) {
    console.error("고사집 삭제 오류:", err);
    alert("고사집 삭제 중 오류가 발생했습니다.");
  }
};

onMounted(() => {
  void writeUserLogOncePerSession("dashboard-exams-visit", "E", 0, {
    user_content: "고사집 관리 화면 진입",
    score: 1,
    total_score: 1,
    score100: 100,
  });
});
</script>

<template>
  <div class="exam-manager">
    <div class="manager-header">
      <div class="header-copy">
        <div class="title-row">
          <h3><IconCalendar class="section-icon" /> {{ listTitle }}</h3>

          <div class="action-button-group">
            <button
              class="btn-create"
              @click="openCreateModal"
              id="btn-open-create-exam">
              <IconCreateAction class="btn-action-icon" />
              새 고사집
            </button>
            <button
              class="btn-delete"
              :disabled="!canDeleteExams"
              @click="deleteSelectedExams">
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
              aria-label="고사집 범위 선택">
              <button
                type="button"
                class="scope-btn"
                :class="{ active: listScope === 'mine' }"
                :aria-pressed="listScope === 'mine'"
                @click="setScope('mine')">
                나의 고사집
              </button>
              <button
                type="button"
                class="scope-btn"
                :class="{ active: listScope === 'all' }"
                :aria-pressed="listScope === 'all'"
                @click="setScope('all')">
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
              @click="clearExamSearch">
              초기화
            </button>
          </div>
          <div class="slider-row">
            <span class="summary-text"
              >총 {{ filteredExams.length }}개의 고사집</span>
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
              >{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시 중</span>
          </div>
        </div>
      </div>
      <div class="exam-list">
        <div v-for="exam in pagedExams" :key="exam.exam_id" class="exam-card">
          <div class="exam-info">
            <div class="exam-headline">
              <div class="headline-left">
                <span class="exam-id">{{ exam.exam_id }}</span>

                <span class="exam-class-badge"
                  >지정 클래스 {{ getExamClassNames(exam).length ?? 0 }}개</span>
              </div>
              <div class="headline-right">
                <span class="exam-period-inline"
                  >{{
                    new Date(exam.start_time).toLocaleDateString("ko-KR", {
                      year: "2-digit",
                      month: "numeric",
                      day: "numeric",
                    })
                  }} ~
                  {{
                    new Date(exam.end_time).toLocaleDateString("ko-KR", {
                      year: "2-digit",
                      month: "numeric",
                      day: "numeric",
                    })
                  }}</span>
                <span class="exam-count"
                  >{{ exam._count?.questions ?? 0 }} 문제</span>
              </div>
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
              <span class="exam-name-wrap">
                <span
                  class="exam-name-link"
                  :class="{
                    selectable: isCurrentUserOwner(exam.creator?.user_no),
                  }"
                  @click="toggleExamSelectedByName(exam)"
                  >{{ exam.exam_name }}</span>
                <span class="exam-hover-card">
                  <strong>위치</strong>
                  <span>{{ exam.location || "장소 미지정" }}</span>
                  <strong>설명</strong>
                  <span>{{ exam.description || "설명 없음" }}</span>
                </span>
              </span>
              <div
                v-if="isCurrentUserOwner(exam.creator?.user_no)"
                class="exam-card-actions">
                <button
                  class="btn-start btn-card-action"
                  @click="openEditModal(exam)">
                  수정
                </button>
                <button
                  class="btn-start btn-card-action"
                  @click="viewExamDetails(exam.exam_id)">
                  문제등록
                </button>
                <button
                  class="btn-start btn-card-action"
                  @click="startQuiz(exam.exam_id)">
                  문제풀기
                </button>
              </div>
            </h4>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- 새 고사 생성 모달 -->
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="showCreateModal"
        class="modal-backdrop"
        @click.self="closeCreateModal">
        <div
          class="modal-box"
          role="dialog"
          aria-modal="true"
          aria-labelledby="modal-title">
          <div class="modal-header">
            <h2 id="modal-title" class="modal-title">{{ modalTitle }}</h2>
            <button
              class="modal-close-btn"
              @click="closeCreateModal"
              aria-label="닫기">
              ✕
            </button>
          </div>

          <form class="modal-form" @submit.prevent="submitExamForm">
            <div class="form-group">
              <select
                id="exam-class"
                v-model="createForm.classId"
                class="form-input">
                <option value="">지정클래스 없음</option>
                <option
                  v-for="classItem in assignableClasses"
                  :key="classItem.classId"
                  :value="classItem.classId">
                  {{ classItem.className }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label for="exam-name" class="form-label"
                >고사 이름 <span class="required">*</span></label>
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

            <div class="form-row form-row-datetime">
              <div class="form-group">
                <label for="exam-start" class="form-label"
                  >시작 일시 <span class="required">*</span></label>
                <DateTimePicker
                  id="exam-start"
                  v-model="createForm.start_time"
                  :size="1"
                />
              </div>
              <div class="form-group">
                <label for="exam-end" class="form-label"
                  >종료 일시 <span class="required">*</span></label>
                <DateTimePicker
                  id="exam-end"
                  v-model="createForm.end_time"
                  align="right"
                  :size="1"
                />
              </div>
            </div>
            <p class="form-help">
              날짜를 더블클릭하면 바로 확정되고, 하단 완료 버튼으로도 저장할 수
              있습니다.
            </p>

            <div class="form-group">
              <label for="exam-location" class="form-label"
                >장소 <span class="optional">(선택)</span></label>
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
              <button
                type="button"
                class="btn-cancel"
                @click="closeCreateModal"
                :disabled="createLoading">
                취소
              </button>
              <button
                type="submit"
                class="btn-submit"
                :disabled="createLoading"
                id="btn-submit-create-exam">
                <span v-if="createLoading" class="loading-spinner"></span>
                {{ submitButtonLabel }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Transition>
  </Teleport>

  <DailyQuestionsModal
    v-if="showDailyQuizModal"
    :questions="dailyQuizQuestions"
    :title="dailyQuizTitle"
    log-type="E"
    :log-object-id="dailyQuizLogExamId"
    :log-content="dailyQuizLogContent"
    @close="closeDailyQuizModal"
  />
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
  background: rgba(30, 41, 59, 0.4);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 16px;
  padding: 1.25rem 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  position: relative;
  overflow: visible;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.exam-card:hover {
  background: rgba(30, 41, 59, 0.4);
  transform: none;
  border-color: rgba(255, 255, 255, 0.05);
  box-shadow: none;
  z-index: 10;
}

.exam-info {
  display: flex;
  flex-direction: column;
  gap: 0.175rem;
  width: 100%;
}
.exam-headline {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  width: 100%;
}

.headline-left {
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.headline-right {
  display: inline-flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.3rem;
  margin-left: auto;
  flex-shrink: 0;
}

.exam-period-inline,
.exam-count,
.exam-class-name,
.exam-id {
  display: inline-flex;
  align-items: center;
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
}

.exam-info h4 {
  display: flex;
  align-items: center;
  gap: 0.15rem;
  color: #f8fafc;
  margin: 0;
  font-size: 1.15rem;
  font-weight: 700;
  width: 100%;
}

.exam-name-link {
  min-width: 0;
  flex: 1;
}

.exam-name-wrap {
  position: relative;
  flex: 1;
  min-width: 0;
  display: inline-flex;
  align-items: center;
}

.exam-name-link.selectable {
  cursor: pointer;
}

.exam-name-wrap:hover .exam-hover-card {
  opacity: 1;
  transform: translateY(0);
  pointer-events: auto;
}

.exam-hover-card {
  position: absolute;
  left: 0;
  top: calc(100% + 0.65rem);
  z-index: 20;
  min-width: 280px;
  max-width: 420px;
  padding: 0.9rem 1rem;
  border-radius: 14px;
  border: 1px solid rgba(129, 140, 248, 0.28);
  background: rgba(15, 23, 42, 0.96);
  box-shadow: 0 18px 40px -18px rgba(0, 0, 0, 0.75);
  backdrop-filter: blur(12px);
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 0.45rem 0.75rem;
  opacity: 0;
  transform: translateY(6px);
  pointer-events: none;
  transition:
    opacity 0.18s ease,
    transform 0.18s ease;
}

.exam-hover-card strong {
  color: #c7d2fe;
  font-size: 0.78rem;
  font-weight: 800;
  white-space: nowrap;
}

.exam-hover-card span {
  color: #e2e8f0;
  font-size: 0.92rem;
  line-height: 1.45;
  white-space: normal;
  word-break: break-word;
}

.exam-card-actions {
  margin-left: auto;
  display: inline-flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0;
  flex-shrink: 0;
  border-radius: 9px;
  overflow: hidden;
  border: 1px solid rgba(129, 140, 248, 0.24);
  background: rgba(15, 23, 42, 0.55);
}

.exam-card-actions .btn-card-action + .btn-card-action {
  margin-left: -1px;
}

.exam-card-actions .btn-card-action:first-child {
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}

.exam-card-actions .btn-card-action:not(:first-child):not(:last-child) {
  border-radius: 0;
}

.exam-card-actions .btn-card-action:last-child {
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
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
  margin-right: 0.22rem;
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
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding-top: 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
  color: #cbd5f5;
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
  font-size: 0.72rem;
  color: #818cf8;
  background: rgba(129, 140, 248, 0.1);
  width: 70px;
  min-width: 70px;
  max-width: 70px;
  flex: 0 0 70px;
  box-sizing: border-box;
  justify-content: center;
  padding: 0.08rem 0.03rem;
  border-radius: 6px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  letter-spacing: -0.01em;
  cursor: pointer;
  transition: all 0.2s ease;
}

.exam-count:hover {
  background: rgba(129, 140, 248, 0.22);
  color: #ffffff;
}

.exam-class-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.12rem 0.55rem;
  border-radius: 999px;
  background: rgba(56, 189, 248, 0.12);
  border: 1px solid rgba(56, 189, 248, 0.2);
  color: #7dd3fc;
  font-size: 0.72rem;
  font-weight: 700;
  line-height: 1;
  white-space: nowrap;
}

.exam-separator {
  color: #64748b;
  font-weight: 700;
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
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.625rem;
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

.btn-card-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 72px;
  height: 34px;
  padding: 0 0.95rem;
  border-radius: 0;
  border: 1px solid rgba(129, 140, 248, 0.24);
  background: rgba(99, 102, 241, 0.1);
  color: #c7d2fe;
  font-size: 0.84rem;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
  transition:
    background 0.2s ease,
    border-color 0.2s ease,
    color 0.2s ease,
    transform 0.2s ease;
}

.btn-card-action:hover {
  background: rgba(99, 102, 241, 0.18);
  border-color: rgba(129, 140, 248, 0.42);
  color: #ffffff;
  transform: translateY(-1px);
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
  background: linear-gradient(
    145deg,
    rgba(15, 23, 42, 0.98),
    rgba(30, 41, 59, 0.98)
  );
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
  transition:
    border-color 0.2s,
    box-shadow 0.2s;
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
  to {
    transform: rotate(360deg);
  }
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
