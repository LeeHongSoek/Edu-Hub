<script setup lang="ts">
import { ref, onMounted, computed, watch } from "vue";
import { useRoute } from "vue-router";
import ManagerNav from "~/components/dashboard/ManagerNav.vue";
import GroupSelectorPanel from "~/components/dashboard/GroupSelectorPanel.vue";
import GroupManager from "~/components/dashboard/GroupManager.vue";
import QuestionEditor from "~/components/dashboard/QuestionEditor.vue";
import QuestionSolver from "~/components/dashboard/QuestionSolver.vue";
import DailyQuestionsModal from "~/components/DailyQuestionsModal.vue";
import QuestionBookUpsertModal from "~/components/dashboard/QuestionBookUpsertModal.vue";
import QuestionExamCreateModal from "~/components/dashboard/QuestionExamCreateModal.vue";
import PageSlider from "~/components/PageSlider.vue";
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconCreateAction from "~/assets/icons/IconCreateAction.svg?component";
import IconDeleteAction from "~/assets/icons/IconDeleteAction.svg?component";
import { useApi } from "~/composables/useApi";
import { useUserLog } from "~/composables/useUserLog";
import type { Question, Group } from "~/types";

const route = useRoute();
const { writeUserLog, writeUserLogOncePerSession } = useUserLog();

const props = defineProps<{
  listTitle?: string;
  listSubtitle?: string | null;
  showScopeToggle?: boolean;
  scopeMode?: "mine" | "all";
  contextScopeMode?: "mine" | "all";
  showError?: boolean;
  errorMessage?: string | null;
  questions: Question[];
  currentUserNo?: string | number | null;
  selectedGroupId: string | number | null;
  appliedSearchField: "content" | "title" | "id";
  appliedSearchKeyword: string;
  currentPage: number;
  totalPages: number;
  totalItems: number;
  pageSize: number;
  viewMode: "mine" | "all";
  selectionContext?: "A" | "B" | "C";
  contextId?: string | number | null;
}>();

// API 설정 통합
const { apiBase, getAuthHeader } = useApi();
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

const groups = ref<Group[]>([]);
const selectedQuestionForSolve = ref<Question | null>(null);
const selectedQuestionForEdit = ref<Question | null>(null);
const showGroupManager = ref(false);
const assignableClasses = ref<Array<{ classId: string; className: string }>>([]);

// --- [토스트 메시지 관리] ---
const showToast = ref(false);
const toastMessage = ref("");
let toastTimer: any = null;

const triggerToast = (msg: string) => {
  if (toastTimer) clearTimeout(toastTimer);
  toastMessage.value = msg;
  showToast.value = true;
  toastTimer = setTimeout(() => {
    showToast.value = false;
  }, 1800); // 부드러운 노출 시간 유지
};
// --------------------------

// --- [문제 선택 데이터 관리 (메모리)] ---
// selectedQuestionIds: 선택한 문제들의 ID를 담는 배열 (실시간 화면 연동용)
const selectedQuestionIds = ref<string[]>([]);
// selectedQuestionCache: 선택한 문제의 상세 객체 정보를 저장하는 맵 (페이지 이동 시에도 정보 유지용)
const selectedQuestionCache = ref<Record<string, Question>>({});
// ------------------------------------------
const searchField = ref<"content" | "title" | "id">(props.appliedSearchField);
const searchInput = ref("");

// 문제번호인 경우 숫자만 입력받도록 강제하는 watch
watch(searchInput, (newVal) => {
  if (searchField.value === "id") {
    const cleaned = newVal.replace(/[^0-9]/g, "");
    if (newVal !== cleaned) {
      searchInput.value = cleaned;
    }
  }
});

// 검색 필드 변경 시 입력값 초기화 (옵션)
watch(searchField, () => {
  searchInput.value = "";
});
const sliderValue = ref(props.currentPage);

watch(
  () => props.currentPage,
  (val) => {
    sliderValue.value = val;
  },
);

let debounceTimer: any = null;
const commitSliderValue = (page?: number) => {
  if (debounceTimer) {
    clearTimeout(debounceTimer);
    debounceTimer = null;
  }

  goToPage(page ?? sliderValue.value);
};

const selectedQuestionCount = computed(() => selectedQuestionIds.value.length);
const canDeleteQuestions = computed(() => selectedQuestionCount.value > 0);
const canBulkSolveQuestions = computed(() => selectedQuestionCount.value >= 5);

const isSliderDisabled = computed(() => props.totalPages <= 1);

const emit = defineEmits<{
  (e: "refresh"): void;
  (e: "change-scope", scope: "mine" | "all"): void;
  (e: "change-context-scope", scope: "mine" | "all"): void;
  (e: "change-group", groupId: string | number | null): void;
  (
    e: "search",
    payload: { field: "title" | "content" | "id"; keyword: string },
  ): void;
  (e: "reset-search"): void;
  (e: "change-page", page: number): void;
  (e: "copy-question", question: Question): void;
}>();

const getQuestionListContextLabel = () => {
  if (props.selectionContext === "B") {
    return props.listSubtitle || props.listTitle || "문제집 문제 목록";
  }
  if (props.selectionContext === "C") {
    return props.listSubtitle || props.listTitle || "고사 문제 목록";
  }
  return props.listTitle || "문제 목록";
};

const logViewAction = async (message: string, objId: string | number | bigint = 0) => {
  await writeUserLog("V", objId, {
    user_content: message,
  });
};

// --- [로컬 스토리지 키 관리] ---
const currentKeys = computed(() => {
  const userNo = props.currentUserNo || "guest";
  const context = props.selectionContext || "A";
  const id = props.contextId || "default";
  const prefix = `edu_hub_sel_${userNo}_${context}_${id}`;
  return {
    ids: `${prefix}_ids`,
    cache: `${prefix}_cache`,
    user: `${prefix}_user`,
  };
});
// ----------------------------

const handleSelectGroup = (groupId: string | number | null) => {
  void logViewAction(
    groupId == null
      ? `문제 그룹 선택 해제: ${getQuestionListContextLabel()}`
      : `문제 그룹 선택: #${String(groupId)} / ${getQuestionListContextLabel()}`,
  );
  emit("change-group", groupId);
};

const resetFilterInputs = (options?: { keepGroupSelection?: boolean }) => {
  searchField.value = "content";
  searchInput.value = "";
  groupSearchInput.value = "";
  if (!options?.keepGroupSelection) {
    emit("change-group", null);
  }
  emit("reset-search");
};

const handleScopeChange = (scope: "mine" | "all") => {
  void logViewAction(
    `문제 범위 전환: ${scope === "mine" ? "나의 문제" : "그외 문제"}`,
  );
  emit("change-scope", scope);
  resetFilterInputs({ keepGroupSelection: true });
};

const handleContextScopeChange = (scope: "mine" | "all") => {
  void logViewAction(
    `컨텍스트 범위 전환: ${scope === "mine" ? "소속 문제" : "그외 문제"}`,
  );
  emit("change-context-scope", scope);
  resetFilterInputs({ keepGroupSelection: true });
};

const clearAllFilters = () => {
  resetFilterInputs();

  if (props.selectionContext === "A") {
    // A 환경일 경우 '전체' <-> '나의그룹' 토글
    const nextScope = props.scopeMode === "all" ? "mine" : "all";
    emit("change-scope", nextScope);
  } else {
    emit("change-context-scope", "all");
  }
};

const applySearch = () => {
  const keyword = searchInput.value.trim();

  if (!keyword) {
    void logViewAction(`문제 검색어 비움으로 전체 초기화: ${getQuestionListContextLabel()}`);
    clearAllFilters();
    return;
  }

  void logViewAction(
    `문제 검색 실행: ${searchField.value} / "${keyword}" / ${getQuestionListContextLabel()}`,
  );

  emit("search", {
    field: searchField.value,
    keyword,
  });
};

const resetSearch = () => {
  void logViewAction(`문제 검색 및 필터 초기화: ${getQuestionListContextLabel()}`);
  clearAllFilters();
};

const handleSolve = (question: Question) => {
  void logViewAction(
    `문제 풀기 열기: 문제 #${String(question.question_id)} [${question.title || "제목 없음"}]`,
    question.question_id,
  );
  selectedQuestionForSolve.value = question;
};

const getQuestionIdKey = (questionId: string | number | bigint) =>
  String(questionId);

const isQuestionSelected = (questionId: string | number | bigint) =>
  selectedQuestionIds.value.includes(getQuestionIdKey(questionId));

const isAllVisibleSelected = computed(() => {
  if (props.questions.length === 0) return false;
  // B, C 환경에서는 모든 문제가 선택 가능하므로 canEditQuestion 체크를 건너뜁니다.
  const isContextA = (props.selectionContext || "A") === "A";
  const selectableQuestions = props.questions.filter(
    (q) => !isContextA || canEditQuestion(q) || props.viewMode === "all",
  );
  if (selectableQuestions.length === 0) return false;
  return selectableQuestions.every((q) => isQuestionSelected(q.question_id));
});

const isSomeVisibleSelected = computed(() => {
  const selectedCount = props.questions.filter((q) =>
    isQuestionSelected(q.question_id),
  ).length;
  return selectedCount > 0 && !isAllVisibleSelected.value;
});

/**
 * 환경 B(문제집) 또는 C(고사)일 때, 선택 변경 사항을 백엔드에 즉시 반영합니다.
 */
const syncContextSelection = async (
  questionId: string | number | bigint,
  isAdded: boolean,
) => {
  if (props.selectionContext === "A" || !props.contextId) return;

  try {
    const endpoint =
      props.selectionContext === "B" ? "question-books" : "exams";
    if (isAdded) {
      await $fetch(`${apiBase.value}/${endpoint}/${props.contextId}/items`, {
        method: "POST",
        headers: getAuthHeader(),
        body: { question_id: String(questionId) },
      });
    } else {
      await $fetch(
        `${apiBase.value}/${endpoint}/${props.contextId}/items/${questionId}`,
        {
          method: "DELETE",
          headers: getAuthHeader(),
        },
      );
    }
  } catch (err) {
    console.error(
      `Failed to sync selection for context ${props.selectionContext}:`,
      err,
    );
  }
};

const toggleSelectAllVisible = async (checked: boolean) => {
  void logViewAction(
    `현재 화면 전체 선택 ${checked ? "적용" : "해제"}: ${props.questions.length}개 항목 / ${getQuestionListContextLabel()}`,
  );
  const isContextA = (props.selectionContext || "A") === "A";
  const syncPromises: Promise<any>[] = [];

  for (const q of props.questions) {
    if (isContextA && !canEditQuestion(q) && props.viewMode !== "all") continue;

    // 로컬 상태 즉시 변경
    const idKey = getQuestionIdKey(q.question_id);
    const currentlySelected = isQuestionSelected(q.question_id);
    if (currentlySelected !== checked) {
      if (checked) {
        selectedQuestionIds.value.push(idKey);
        selectedQuestionCache.value[idKey] = q;
      } else {
        selectedQuestionIds.value = selectedQuestionIds.value.filter(
          (id) => id !== idKey,
        );
        delete selectedQuestionCache.value[idKey];
      }
      // 컨텍스트 환경일 경우 백엔드 동기화 대기열 추가
      if (!isContextA) {
        syncPromises.push(syncContextSelection(q.question_id, checked));
      }
    }
  }

  if (syncPromises.length > 0) {
    try {
      if (!isContextA) {
        const msg = checked
          ? "선택한 문항을 모두 '해당 문제'로 이전합니다"
          : "선택한 문항을 모두 '그외 문제'로 이전합니다";
        triggerToast(msg);
      }
      await Promise.all(syncPromises);
      await fetchGroups();
      emit("refresh");
    } catch (err) {
      console.error("Bulk sync failed:", err);
    }
  }
};

const rememberSelectedQuestion = (questionId: string | number | bigint) => {
  const idKey = getQuestionIdKey(questionId);
  const question = props.questions.find(
    (item) => getQuestionIdKey(item.question_id) === idKey,
  );
  if (!question) return;
  selectedQuestionCache.value = {
    ...selectedQuestionCache.value,
    [idKey]: question,
  };
};

const toggleQuestionSelected = async (
  questionId: string | number | bigint,
  checked: boolean,
) => {
  const idKey = getQuestionIdKey(questionId);
  const question = props.questions.find((q) => q.question_id === questionId);

  if (question) {
    void logViewAction(
      `문제 선택 ${checked ? "추가" : "해제"}: 문제 #${String(question.question_id)} [${question.title || "제목 없음"}]`,
      question.question_id,
    );
  }

  if (checked) {
    if (!selectedQuestionIds.value.includes(idKey)) {
      selectedQuestionIds.value.push(idKey);
    }
    if (question) {
      selectedQuestionCache.value[idKey] = question;
    }
  } else {
    selectedQuestionIds.value = selectedQuestionIds.value.filter(
      (id) => id !== idKey,
    );
    const nextCache = { ...selectedQuestionCache.value };
    delete nextCache[idKey];
    selectedQuestionCache.value = nextCache;
  }

  // 컨텍스트 환경일 경우 백엔드 동기화 및 리프레시
  if (props.selectionContext !== "A") {
    const msg = checked
      ? "'해당 문제'로 이전합니다"
      : "'그외 문제'로 이전합니다";
    triggerToast(msg);
    await syncContextSelection(questionId, checked);
    await fetchGroups();
    emit("refresh");
  }
};

const canEditQuestion = (question: Question) => {
  if (props.currentUserNo === undefined || props.currentUserNo === null)
    return false;
  return String(question.creator_no) === String(props.currentUserNo);
};

const shouldShowQuestionOwner = (question: Question) => {
  if (props.currentUserNo === undefined || props.currentUserNo === null)
    return true;
  return String(question.creator_no) !== String(props.currentUserNo);
};

const getQuestionTypeBadgeLabel = (question: Question) => {
  const typeId = String(question.question_type_id || "").toUpperCase();
  const typeName = question.type?.type_name || "";
  const isMultipleChoice = typeId === "M" || typeName.includes("객관식");

  if (!isMultipleChoice) {
    return typeName || "객관식";
  }

  const answerCount = (question.options || []).filter((opt: any) => {
    const raw = opt?.is_answer;
    return (
      raw === true || raw === 1 || raw === "1" || raw === "Y" || raw === "y"
    );
  }).length;

  if (answerCount >= 2) return "객관식_선다";
  if (answerCount === 1) return "객관식_선단";
  return "객관식";
};

const pageStartItem = computed(() => {
  if (props.totalItems === 0) return 0;
  return (props.currentPage - 1) * props.pageSize + 1;
});

const pageEndItem = computed(() => {
  return Math.min(props.currentPage * props.pageSize, props.totalItems);
});

const goToPage = (page: number) => {
  void logViewAction(
    `문제 목록 페이지 이동: ${Math.min(Math.max(page, 1), props.totalPages)}페이지 / ${getQuestionListContextLabel()}`,
  );
  emit("change-page", Math.min(Math.max(page, 1), props.totalPages));
};

// 이전/다음 문제 탐색용 로직
const currentQuestionIndex = computed(() => {
  if (!selectedQuestionForSolve.value) return -1;
  return props.questions.findIndex(
    (q) => q.question_id === selectedQuestionForSolve.value?.question_id,
  );
});

const getPrevQuestion = () => {
  const idx = currentQuestionIndex.value;
  if (idx > 0) return props.questions[idx - 1];
  return null;
};

const getNextQuestion = () => {
  const idx = currentQuestionIndex.value;
  if (idx !== -1 && idx < props.questions.length - 1)
    return props.questions[idx + 1];
  return null;
};

const handlePrev = () => {
  const prev = getPrevQuestion();
  if (prev) {
    void logViewAction(
      `문제 풀이 이전 이동: 문제 #${String(prev.question_id)} [${prev.title || "제목 없음"}]`,
      prev.question_id,
    );
    selectedQuestionForSolve.value = prev;
  }
};

const handleNext = () => {
  const next = getNextQuestion();
  if (next) {
    void logViewAction(
      `문제 풀이 다음 이동: 문제 #${String(next.question_id)} [${next.title || "제목 없음"}]`,
      next.question_id,
    );
    selectedQuestionForSolve.value = next;
  }
};

const handleGoToQuestionIndex = (index: number) => {
  if (index < 0 || index >= props.questions.length) return;
  void logViewAction(
    `문제 풀이 인덱스 이동: ${index + 1}번째 / 문제 #${String(props.questions[index].question_id)} [${props.questions[index].title || "제목 없음"}]`,
    props.questions[index].question_id,
  );
  selectedQuestionForSolve.value = props.questions[index];
};

const openEditor = (q: Question | null) => {
  void logViewAction(
    q
      ? `문제 수정 열기: 문제 #${String(q.question_id)} [${q.title || "제목 없음"}]`
      : `새 문제 작성 열기: ${getQuestionListContextLabel()}`,
    q?.question_id ?? 0,
  );
  if (q) {
    selectedQuestionForEdit.value = q;
  } else {
    // 새 문제 생성 시 초기값
    selectedQuestionForEdit.value = {
      title: "",
      question: "",
      content: "",
      question_type_id: "M",
      difficulty: 3,
      rating: 3,
      options: [
        { option_number: 1, content: "", is_answer: true },
        { option_number: 2, content: "", is_answer: false },
        { option_number: 3, content: "", is_answer: false },
        { option_number: 4, content: "", is_answer: false },
      ],
      group_id: props.selectedGroupId || undefined,
    } as Question;
  }
};

const formatGroupPath = (group: Group) => {
  const parts: string[] = [];
  let current: Group | undefined = group;
  while (current) {
    if (current.name !== "전체") {
      parts.unshift(current.name);
    }
    current = current.parent_group;
  }
  return parts.length > 0 ? parts.join(" / ") : "미분류";
};

const findGroupPath = (
  list: Group[],
  targetId: string | number,
  trail: string[] = [],
): string[] | null => {
  for (const group of list) {
    const nextTrail = [...trail, group.name];
    if (String(group.group_id) === String(targetId)) {
      return nextTrail;
    }
    if (group.child_groups && group.child_groups.length > 0) {
      const found = findGroupPath(group.child_groups, targetId, nextTrail);
      if (found) return found;
    }
  }
  return null;
};

const selectedGroupBreadcrumb = computed(() => {
  if (props.selectedGroupId === null || props.selectedGroupId === undefined) {
    return "";
  }
  const path = findGroupPath(groups.value, props.selectedGroupId);
  if (!path || path.length === 0) return "";
  return path.join(" / ");
});

const groupSearchInput = ref("");
const showBulkSolveModal = ref(false);
const showCreateBookModal = ref(false);
const showCreateExamModal = ref(false);
const bulkSolveQuestions = computed(() =>
  selectedQuestionIds.value
    .map((id) => selectedQuestionCache.value[id])
    .filter((question): question is Question => Boolean(question)),
);
const bulkSolveLogContent = computed(
  () =>
    `임의로 ${bulkSolveQuestions.value.length}문항을 선택하여 임시문제집 풀이`,
);

const filterGroupsByOwner = (
  list: Group[],
  ownerNo: string | number | null | (string | number | null)[],
): Group[] => {
  const owners = Array.isArray(ownerNo) ? ownerNo : [ownerNo];
  const validOwners = owners.filter(o => o !== null && o !== undefined).map(String);

  const matches = (group: Group) =>
    validOwners.includes(String(group.creator_no));
  const result: Group[] = [];
  for (const group of list) {
    if (!matches(group)) continue;
    const childGroups = group.child_groups
      ? filterGroupsByOwner(group.child_groups, validOwners)
      : [];
    result.push({ ...group, child_groups: childGroups });
  }
  return result;
};

const totalGroupQuestionCount = (group: Group): number => {
  if (group.question_total !== undefined && group.question_total !== null) {
    return Number(group.question_total) || 0;
  }
  const own = Number(group.question_count ?? group._count?.questions ?? 0) || 0;
  const children = (group.child_groups ?? []).reduce(
    (sum, child) => sum + totalGroupQuestionCount(child),
    0,
  );
  return own + children;
};

const filterZeroCountGroups = (list: Group[]): Group[] =>
  list
    .map((group) => ({
      ...group,
      child_groups: filterZeroCountGroups(group.child_groups ?? []),
    }))
    .filter((group) => totalGroupQuestionCount(group) > 0);

const visibleGroups = computed(() => {
  const shouldKeepZeroCountGroups =
    (props.selectionContext || "A") === "A" &&
    (props.scopeMode ?? "mine") === "mine";

  let baseGroups: Group[];

  if ((props.selectionContext || "A") !== "A") {
    baseGroups = groups.value;
  } else {
    const scope = props.scopeMode ?? "mine";
    if (
      scope !== "mine" ||
      props.currentUserNo === null ||
      props.currentUserNo === undefined
    ) {
      baseGroups = groups.value;
    } else {
      baseGroups = filterGroupsByOwner(groups.value, [props.currentUserNo, 0]);
    }
  }

  return shouldKeepZeroCountGroups
    ? baseGroups
    : filterZeroCountGroups(baseGroups);
});

const filterGroupsBySearch = (list: Group[], query: string) => {
  const expandIds = new Set<string>();

  const visit = (group: Group, ancestors: Group[]): Group | null => {
    const nameMatch = group.name.toLowerCase().includes(query);
    const children = group.child_groups
      ? group.child_groups
          .map((child) => visit(child, [...ancestors, group]))
          .filter((child): child is Group => Boolean(child))
      : [];

    if (!nameMatch && children.length === 0) return null;

    if (nameMatch) {
      for (const ancestor of ancestors) {
        expandIds.add(String(ancestor.group_id));
      }
      expandIds.add(String(group.group_id));
    }

    if (children.length > 0) {
      expandIds.add(String(group.group_id));
    }

    return { ...group, child_groups: children };
  };

  const filtered = list
    .map((group) => visit(group, []))
    .filter((group): group is Group => Boolean(group));

  return { filtered, expandIds };
};

const collectDefaultExpandedIds = (list: Group[]) => {
  const expandIds = new Set<string>();

  for (const group of list) {
    expandIds.add(String(group.group_id));
  }

  return expandIds;
};

const searchedGroups = computed(() => {
  const query = groupSearchInput.value.trim().toLowerCase();
  if (!query) {
    return {
      groups: visibleGroups.value,
      expandedIds: collectDefaultExpandedIds(visibleGroups.value),
    };
  }
  const { filtered, expandIds } = filterGroupsBySearch(
    visibleGroups.value,
    query,
  );
  return { groups: filtered, expandedIds: expandIds };
});

const fetchGroups = async () => {
  try {
    const isContextA = (props.selectionContext || "A") === "A";
    const data = await $fetch<{ groups: Group[]; unassigned_count: number }>(
      `${apiBase.value}/groups`,
      {
        query: {
          scope: isContextA
            ? props.viewMode
            : (props.contextScopeMode ?? "mine"),
          userNo: isContextA ? (props.currentUserNo ?? undefined) : undefined,
          viewerNo: props.currentUserNo ?? undefined,
          bookId:
            props.selectionContext === "B"
              ? (props.contextId ?? undefined)
              : undefined,
          examId:
            props.selectionContext === "C"
              ? (props.contextId ?? undefined)
              : undefined,
        },
      },
    );
    groups.value = data.groups;
  } catch (error) {
    console.error("서버 통신 오류(fetch) groups:", error);
  }
};

const openGroupManager = () => {
  void logViewAction(`문제 그룹 관리 열기: ${getQuestionListContextLabel()}`);
  showGroupManager.value = true;
};

const clearGroupSearch = () => {
  void logViewAction(`문제 그룹 검색 초기화: ${getQuestionListContextLabel()}`);
  groupSearchInput.value = "";
};

const deleteSelectedQuestions = async () => {
  if (!canDeleteQuestions.value) return;
  if (props.currentUserNo === null || props.currentUserNo === undefined) {
    alert("사용자 정보가 없어 삭제할 수 없습니다.");
    return;
  }

  const ok = window.confirm(
    `선택한 문제 ${selectedQuestionCount.value}개를 삭제하시겠습니까?`,
  );
  if (!ok) return;

  void logViewAction(
    `선택 문제 삭제 실행: ${selectedQuestionCount.value}개 / ${getQuestionListContextLabel()}`,
  );

  try {
    const result = (await $fetch(`${apiBase.value}/questions/soft-delete`, {
      method: "PATCH",
      body: {
        questionIds: selectedQuestionIds.value,
        user_no: String(props.currentUserNo),
      },
    })) as { updatedCount?: number };

    const deletedCount = Number(result?.updatedCount ?? 0);
    if (deletedCount === 0) {
      alert("삭제 가능한 문제가 없습니다.");
    }
    selectedQuestionIds.value = [];
    selectedQuestionCache.value = {};
    const keys = currentKeys.value;
    localStorage.removeItem(keys.ids);
    localStorage.removeItem(keys.cache);
    localStorage.removeItem(keys.user);
    emit("refresh");
  } catch (error) {
    console.error("문제 삭제 오류:", error);
    alert("문제 삭제 중 오류가 발생했습니다.");
  }
};

const handleGroupsUpdated = () => {
  fetchGroups();
};

const openBulkSolveModal = () => {
  if (selectedQuestionCount.value < 5) {
    alert("모아 풀기는 문제를 5개 이상 선택해야 시작할 수 있습니다.");
    return;
  }

  void logViewAction(
    `모아 풀기 열기: ${selectedQuestionCount.value}개 선택 / ${getQuestionListContextLabel()}`,
  );
  showBulkSolveModal.value = true;
};

const handleCreateQuestionBook = () => {
  void logViewAction(
    `선택 문제로 문제집 만들기 클릭: ${selectedQuestionCount.value}개 선택 / ${getQuestionListContextLabel()}`,
  );
  showCreateBookModal.value = true;
};

const fetchAssignableClasses = async () => {
  if (String(userInfo.value?.role_id || userInfo.value?.role || "").toUpperCase() !== "T") {
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

const handleCreateExamBook = async () => {
  void logViewAction(
    `선택 문제로 고사집 만들기 클릭: ${selectedQuestionCount.value}개 선택 / ${getQuestionListContextLabel()}`,
  );
  await fetchAssignableClasses();
  showCreateExamModal.value = true;
};

const closeCreateBookModal = () => {
  showCreateBookModal.value = false;
};

const closeCreateExamModal = () => {
  showCreateExamModal.value = false;
};

const getSelectedQuestions = () =>
  selectedQuestionIds.value
    .map((id) => selectedQuestionCache.value[id])
    .filter((question): question is Question => Boolean(question));

type QuestionBookCreateForm = {
  name: string;
  description: string;
};

type QuestionExamCreateForm = {
  classId: string;
  classIds: string[];
  name: string;
  description: string;
  start_time: string;
  end_time: string;
  location: string;
  is_auto_score: boolean;
};

const submitCreateBookForm = async (bundleForm: QuestionBookCreateForm) => {
  const selectedQuestions = getSelectedQuestions();
  if (selectedQuestions.length === 0) {
    triggerToast("선택된 문제가 없습니다.");
    return;
  }

  if (!bundleForm.name.trim()) {
    triggerToast("문제집 이름을 입력해 주세요.");
    return;
  }

  try {
    const createdBook = (await $fetch<{ book_id?: string | number }>(
      `${apiBase.value}/question-books`,
      {
        method: "POST",
        headers: getAuthHeader(),
        body: {
          book_name: bundleForm.name.trim(),
          description: bundleForm.description.trim(),
        },
      },
    )) as { book_id?: string | number };

    const bookId = createdBook?.book_id;
    if (!bookId) {
      throw new Error("문제집 생성 응답에 book_id가 없습니다.");
    }

    for (const question of selectedQuestions) {
      await $fetch(`${apiBase.value}/question-books/${bookId}/items`, {
        method: "POST",
        headers: getAuthHeader(),
        body: { question_id: String(question.question_id) },
      });
    }

    void logViewAction(
      `문제집 생성 완료: ${bundleForm.name.trim()} / ${selectedQuestions.length}문항`,
    );
    triggerToast("선택한 문제로 문제집을 만들었습니다.");

    closeCreateBookModal();
    clearSelection();
    emit("refresh");
  } catch (error) {
    console.error("문제 묶음 생성 오류:", error);
    triggerToast("문제집 생성에 실패했습니다.");
  }
};

const submitCreateBookFromUpsert = (payload: {
  form: { book_name: string; description: string };
}) => {
  void submitCreateBookForm({
    name: payload.form.book_name,
    description: payload.form.description,
  });
};

const submitCreateExamForm = async (bundleForm: QuestionExamCreateForm) => {
  const selectedQuestions = getSelectedQuestions();
  if (selectedQuestions.length === 0) {
    triggerToast("선택된 문제가 없습니다.");
    return;
  }

  if (!bundleForm.name.trim()) {
    triggerToast("고사집 이름을 입력해 주세요.");
    return;
  }

  if (!bundleForm.start_time || !bundleForm.end_time) {
    triggerToast("시작 일시와 종료 일시를 모두 입력해 주세요.");
    return;
  }

  const startTime = bundleForm.start_time;
  const endTime = bundleForm.end_time;
  if (new Date(startTime) >= new Date(endTime)) {
    triggerToast("종료일시는 시작일시보다 이후여야 합니다.");
    return;
  }

  try {
    const createdExam = (await $fetch<{ exam_id?: string | number }>(
      `${apiBase.value}/exams`,
      {
        method: "POST",
        headers: getAuthHeader(),
        body: {
          classIds:
            Array.isArray(bundleForm.classIds) && bundleForm.classIds.length > 0
              ? bundleForm.classIds
              : bundleForm.classId
                ? [bundleForm.classId]
                : undefined,
          exam_name: bundleForm.name.trim(),
          description: bundleForm.description.trim(),
          start_time: startTime,
          end_time: endTime,
          location: bundleForm.location.trim() || undefined,
          is_auto_score: bundleForm.is_auto_score,
        },
      },
    )) as { exam_id?: string | number };

    const examId = createdExam?.exam_id;
    if (!examId) {
      throw new Error("고사 생성 응답에 exam_id가 없습니다.");
    }

    for (const question of selectedQuestions) {
      await $fetch(`${apiBase.value}/exams/${examId}/items`, {
        method: "POST",
        headers: getAuthHeader(),
        body: { question_id: String(question.question_id) },
      });
    }

    void logViewAction(
      `고사집 생성 완료: ${bundleForm.name.trim()} / ${selectedQuestions.length}문항`,
    );
    triggerToast("선택한 문제로 고사집을 만들었습니다.");

    closeCreateExamModal();
    clearSelection();
    emit("refresh");
  } catch (error) {
    console.error("문제 묶음 생성 오류:", error);
    triggerToast("고사집 생성에 실패했습니다.");
  }
};

const handleCopyQuestion = (question: Question) => {
  void logViewAction(
    `문제 복사 후 가져오기 클릭: 문제 #${String(question.question_id)} [${question.title || "제목 없음"}]`,
    question.question_id,
  );
  emit("copy-question", question);
};

// --- [문제 선택 데이터 관리 (영구 저장용 키)] ---
// 진입 환경(Context)별로 저장 키를 분리하여 독립적인 선택 상태를 유지합니다.
const STORAGE_KEYS = {
  A: { ids: "edu_hub_ids_A", cache: "edu_hub_cache_A", user: "edu_hub_user_A" },
  B: { ids: "edu_hub_ids_B", cache: "edu_hub_cache_B", user: "edu_hub_user_B" },
  C: { ids: "edu_hub_ids_C", cache: "edu_hub_cache_C", user: "edu_hub_user_C" },
};

// 현재 환경에 맞는 키를 가져오는 computed
// Outdated currentKeys declaration removed

/**
 * 브라우저 저장소(localStorage)에서 이전에 선택했던 문제 정보를 불러옵니다.
 * 보안을 위해 현재 로그인한 사용자와 저장된 사용자 ID가 일치할 때만 복구합니다.
 */
const restoreSelectionFromStorage = () => {
  const keys = currentKeys.value;
  const savedUser = localStorage.getItem(keys.user);
  const currentUser = String(props.currentUserNo || "");

  // 만약 저장된 사용자 ID와 현재 사용자 ID가 다르면 복구하지 않음
  if (savedUser !== currentUser) {
    if (savedUser) clearSelection();
    return;
  }

  const savedIds = localStorage.getItem(keys.ids);
  const savedCache = localStorage.getItem(keys.cache);

  if (savedIds) {
    try {
      selectedQuestionIds.value = JSON.parse(savedIds);
    } catch (e) {
      console.error("Failed to parse saved IDs", e);
    }
  }

  if (savedCache) {
    try {
      selectedQuestionCache.value = JSON.parse(savedCache);
    } catch (e) {
      console.error("Failed to parse saved cache", e);
    }
  }
};

const extractContextQuestions = (data: any): Question[] => {
  const collection =
    props.selectionContext === "B" ? data?.items : data?.questions;
  if (!Array.isArray(collection)) return [];

  return collection
    .map((item: any) => item?.question ?? null)
    .filter((question: Question | null): question is Question =>
      Boolean(question),
    );
};

const syncSelectionFromContext = async (options?: { force?: boolean }) => {
  if (props.selectionContext === "A" || !props.contextId) return;

  const initKey = `edu_hub_init_${props.selectionContext}_${props.contextId}`;
  const isInitialized = localStorage.getItem(initKey);
  if (!options?.force && isInitialized) return;

  try {
    const endpoint =
      props.selectionContext === "B" ? "question-books" : "exams";
    const data = await $fetch<any>(
      `${apiBase.value}/${endpoint}/${props.contextId}`,
      {
        headers: getAuthHeader(),
      },
    );

    const questions = extractContextQuestions(data);
    const nextIds = questions.map((q) => getQuestionIdKey(q.question_id));
    const nextCache = questions.reduce<Record<string, Question>>(
      (acc, question) => {
        acc[getQuestionIdKey(question.question_id)] = question;
        return acc;
      },
      {},
    );

    selectedQuestionIds.value = nextIds;
    selectedQuestionCache.value = nextCache;
    localStorage.setItem(initKey, "true");
  } catch (err) {
    console.error("Context selection synchronization failed:", err);
  }
};

/**
 * 특정 문제집(B) 또는 고사(C) 진입 시, 해당 항목에 이미 포함된 문제들을
 * 기본값으로 자동 선택해주는 초기화 프로세스입니다.
 */
const initContextSelection = async () => {
  await syncSelectionFromContext();
};

onMounted(async () => {
  await writeUserLogOncePerSession(
    `view_enter_${props.selectionContext || "A"}_${props.contextId || "default"}_${getQuestionListContextLabel()}`,
    "V",
    0,
    {
      user_content: `화면 진입: ${getQuestionListContextLabel()}`,
    },
  );
  restoreSelectionFromStorage();
  await initContextSelection(); // 컨텍스트별 자동 선택 실행

  await fetchGroups();
  searchInput.value = props.appliedSearchKeyword;
  searchField.value = props.appliedSearchField;
});

/**
 * 선택된 모든 문제 데이터와 저장소의 기록을 삭제하여 초기화합니다.
 */
const clearSelection = () => {
  selectedQuestionIds.value = [];
  selectedQuestionCache.value = {};
  const keys = currentKeys.value;
  localStorage.removeItem(keys.ids);
  localStorage.removeItem(keys.cache);
  localStorage.removeItem(keys.user);
};

// 로그아웃하거나 사용자가 바뀌면 선택 상태 및 필터 초기화
watch(
  () => props.currentUserNo,
  (newVal, oldVal) => {
    // 이미 로그인된 상태에서 값이 바뀌거나 null이 되면 로그아웃/교체로 간주하고 초기화
    if (newVal !== oldVal) {
      clearSelection();
      clearAllFilters();
    }
  },
);

// --- [자동 저장 로직 (Watch)] ---
// 선택된 문제 ID 목록이 변경될 때마다 브라우저 저장소에 자동으로 백업합니다.
watch(
  selectedQuestionIds,
  (newIds) => {
    const keys = currentKeys.value;
    localStorage.setItem(keys.ids, JSON.stringify(newIds));
    localStorage.setItem(keys.user, String(props.currentUserNo || ""));
  },
  { deep: true },
);

// 선택된 문제의 상세 정보(캐시)가 변경될 때마다 브라우저 저장소에 자동으로 백업합니다.
watch(
  selectedQuestionCache,
  (newCache) => {
    const keys = currentKeys.value;
    localStorage.setItem(keys.cache, JSON.stringify(newCache));
    localStorage.setItem(keys.user, String(props.currentUserNo || ""));
  },
  { deep: true },
);
// ------------------------------

watch(
  () => props.viewMode,
  async () => {
    if ((props.selectionContext || "A") !== "A") return;
    await fetchGroups();
  },
);

watch(
  () => props.contextScopeMode,
  async () => {
    if ((props.selectionContext || "A") === "A") return;
    await fetchGroups();
  },
);

watch(
  () => props.selectionContext,
  (newContext) => {
    if (newContext === "B" || newContext === "C") {
      emit("change-context-scope", "mine");
    }
  },
  { immediate: true },
);

watch(
  [
    () => props.selectionContext,
    () => props.contextId,
    () => props.contextScopeMode,
  ],
  async ([context, contextId, contextScope]) => {
    if (
      (context === "B" || context === "C") &&
      contextId &&
      (contextScope ?? "mine") === "mine"
    ) {
      await syncSelectionFromContext({ force: true });
    }
  },
  { immediate: false },
);

watch(
  () => props.appliedSearchField,
  (value) => {
    searchField.value = value;
  },
);

watch(
  () => props.appliedSearchKeyword,
  (value) => {
    searchInput.value = value;
  },
);

watch(
  [() => props.questions, () => selectedQuestionIds.value],
  ([newQuestions, newIds]) => {
    const nextCache = { ...selectedQuestionCache.value };
    for (const question of newQuestions) {
      const idKey = getQuestionIdKey(question.question_id);
      if (newIds.includes(idKey)) {
        nextCache[idKey] = question;
      }
    }
    selectedQuestionCache.value = nextCache;
  },
  { immediate: true, deep: true },
);
</script>

<template>
  <div class="question-list-container">
    <div class="question-list-row">
      <GroupSelectorPanel
          class="group-overlay group-overlay--wide"
          title="문제분류 그룹"
          :show-manage-button="(props.selectionContext || 'A') === 'A'"
          :selected-group-breadcrumb="selectedGroupBreadcrumb"
          :group-search-input="groupSearchInput"
          :searched-groups="searchedGroups"
          :model-value="props.selectedGroupId"
          :current-user-no="[props.currentUserNo ?? null, 0]"
          :selection-context="props.selectionContext"
          :show-actions="false"
          :show-count="true"
          :initial-depth="0"
          :hide-top-level="false"
          @update:group-search-input="groupSearchInput = $event"
          @select-group="handleSelectGroup"
          @open-manage="openGroupManager"
        />

      <div class="question-list-main">
        <div v-if="props.showError" class="error-panel">
          <div class="error">
            {{
              props.errorMessage ??
              "문제를 불러오지 못했습니다. 백엔드 서버가 실행 중인지 확인해 주세요."
            }}
          </div>
        </div>

        <div v-else class="question-list-body">
          <div class="manager-header">
            <div class="header-copy">
              <div class="title-row">
                <h3 class="question-list-title">
                  <IconFileText class="section-icon" />
                  {{
                    props.selectionContext !== "A" && props.listSubtitle
                      ? props.listSubtitle
                      : (props.listTitle ?? "문제 목록")
                  }}
                </h3>

                <div
                  v-if="(props.selectionContext || 'A') === 'A'"
                  class="action-button-group">
                  <button class="btn-create" @click="openEditor(null)">
                    <IconCreateAction class="btn-action-icon" />
                    새 문제
                  </button>
                  <button
                    class="btn-delete"
                    :disabled="!canDeleteQuestions"
                    @click="deleteSelectedQuestions">
                    <IconDeleteAction class="btn-action-icon" />
                    삭제
                  </button>
                  <button
                    class="btn-bulk-action"
                    :disabled="!canBulkSolveQuestions"
                    @click="openBulkSolveModal">
                    모아<br />풀기
                  </button>
                  <button
                    class="btn-bulk-action"
                    :disabled="!canDeleteQuestions"
                    @click="handleCreateQuestionBook">
                    문제집<br />만들기
                  </button>
                  <button
                    v-if="(props.selectionContext || 'A') === 'A'"
                    class="btn-bulk-action"
                    :disabled="!canDeleteQuestions"
                    @click="handleCreateExamBook">
                    고사집<br />만들기
                  </button>
                </div>
              </div>
            </div>

            <ManagerNav
              :active-page="selectionContext === 'A' ? 'questions' : null"
              :back-link="
                selectionContext !== 'A'
                  ? {
                      to: route.query.book ? '/question-books' : '/exams',
                      label: '되돌아가기',
                    }
                  : null
              "
            />
          </div>

          <div class="pagination-panel-border">
            <div class="slider-panel">
              <div class="search-row">
                <div
                  v-if="(props.selectionContext || 'A') === 'A'"
                  class="scope-toggle"
                  role="tablist"
                  aria-label="범주 선택">
                  <button
                    type="button"
                    class="scope-btn"
                    :class="{ active: (props.scopeMode ?? 'mine') === 'mine' }"
                    :aria-pressed="(props.scopeMode ?? 'mine') === 'mine'"
                    @click="handleScopeChange('mine')">
                    나의 문제
                  </button>
                  <button
                    type="button"
                    class="scope-btn"
                    :class="{ active: (props.scopeMode ?? 'mine') === 'all' }"
                    :aria-pressed="(props.scopeMode ?? 'mine') === 'all'"
                    @click="handleScopeChange('all')">
                    그외 문제
                  </button>
                </div>
                <div
                  v-if="props.selectionContext === 'B'"
                  class="scope-toggle"
                  role="tablist"
                  aria-label="범주 선택">
                  <button
                    type="button"
                    class="scope-btn"
                    :class="{
                      active: (props.contextScopeMode ?? 'mine') === 'mine',
                    }"
                    :aria-pressed="
                      (props.contextScopeMode ?? 'mine') === 'mine'
                    "
                    @click="handleContextScopeChange('mine')">
                    소속 문제
                  </button>
                  <button
                    type="button"
                    class="scope-btn"
                    :class="{
                      active: (props.contextScopeMode ?? 'mine') === 'all',
                    }"
                    :aria-pressed="(props.contextScopeMode ?? 'mine') === 'all'"
                    @click="handleContextScopeChange('all')">
                    그외 문제
                  </button>
                </div>
                <div
                  v-if="props.selectionContext === 'C'"
                  class="scope-toggle"
                  role="tablist"
                  aria-label="범주 선택">
                  <button
                    type="button"
                    class="scope-btn"
                    :class="{
                      active: (props.contextScopeMode ?? 'mine') === 'mine',
                    }"
                    :aria-pressed="
                      (props.contextScopeMode ?? 'mine') === 'mine'
                    "
                    @click="handleContextScopeChange('mine')">
                    소속 문제
                  </button>
                  <button
                    type="button"
                    class="scope-btn"
                    :class="{
                      active: (props.contextScopeMode ?? 'mine') === 'all',
                    }"
                    :aria-pressed="(props.contextScopeMode ?? 'mine') === 'all'"
                    @click="handleContextScopeChange('all')">
                    그외 문제
                  </button>
                </div>
                <select v-model="searchField" class="search-select">
                  <option value="id">문제번호</option>
                  <option value="content">문제 내용</option>
                  <option value="title">제목</option>
                </select>
                <input
                  v-model="searchInput"
                  type="text"
                  class="search-input"
                  :placeholder="
                    searchField === 'id'
                      ? '문제번호(ID)를 입력하세요'
                      : searchField === 'title'
                        ? '문제 제목을 입력하세요'
                        : '문제 내용을 입력하세요'
                  "
                  @keyup.enter="applySearch"
                />
                <button class="btn-search" @click="applySearch">검색</button>
                <button
                  v-if="props.appliedSearchKeyword || searchInput"
                  class="btn-reset-search"
                  @click="resetSearch">
                  초기화
                </button>
              </div>
              <div class="slider-row">
                <input
                  v-if="(props.selectionContext || 'A') === 'A'"
                  type="checkbox"
                  class="copy-checkbox"
                  aria-label="전체 문제 선택"
                  :checked="isAllVisibleSelected"
                  :indeterminate="isSomeVisibleSelected"
                  @change="
                    toggleSelectAllVisible(
                      ($event.target as HTMLInputElement).checked,
                    )
                  "
                />
                <span class="summary-text"
                  >총 {{ props.totalItems }}문제
                  <span class="selected-count">
                    · {{ selectedQuestionCount }}개 선택됨
                  </span>
                </span>
                <div class="page-slider-section">
                  <PageSlider
                    v-model="sliderValue"
                    :max="props.totalPages"
                    :disabled="isSliderDisabled"
                    postfix="페이지"
                    @commit="commitSliderValue"
                  />
                </div>
                <span class="range-text"
                  >{{ pageStartItem }}-{{ pageEndItem }}번째 문제 표시 중</span>
              </div>
            </div>
          </div>

          <div v-if="props.questions.length === 0" class="no-results">
            {{
              props.appliedSearchKeyword
                ? "검색 조건에 맞는 문제가 없습니다."
                : "해당 조건에 등록된 문제가 없습니다."
            }}
          </div>
          <div v-else class="question-list">
            <div
              v-for="q in props.questions"
              :key="q.question_id"
              class="question-item">
              <div class="question-header">
                <div class="question-title-row">
                  <h3 class="question-id">{{ q.question_id }}</h3>
                  <span class="badge badge-type question-type-badge">{{
                    getQuestionTypeBadgeLabel(q)
                  }}</span>
                  <h3 class="question-title">{{ q.title }}</h3>
                </div>
                <div class="question-group-path">
                  <span>{{
                    q.group ? formatGroupPath(q.group) : "미분류"
                  }}</span>
                  <span
                    v-if="q.creator?.username && shouldShowQuestionOwner(q)"
                    class="question-separator"
                    >·</span>
                  <span
                    v-if="q.creator?.username && shouldShowQuestionOwner(q)"
                    class="question-owner"
                    >{{ q.creator?.username }}</span>
                </div>
              </div>

              <div class="question-main">
                <input
                  type="checkbox"
                  class="copy-checkbox"
                  aria-label="문제 선택"
                  :checked="isQuestionSelected(q.question_id)"
                  :disabled="
                    (props.selectionContext || 'A') === 'A' &&
                    !canEditQuestion(q)
                  "
                  @change="
                    toggleQuestionSelected(
                      q.question_id,
                      ($event.target as HTMLInputElement).checked,
                    )
                  "
                />
                <div
                  class="question-content"
                  :class="{
                    'is-interactive': !(
                      (props.selectionContext || 'A') === 'A' &&
                      !canEditQuestion(q)
                    ),
                  }"
                  @click="
                    !(
                      (props.selectionContext || 'A') === 'A' &&
                      !canEditQuestion(q)
                    ) &&
                    toggleQuestionSelected(
                      q.question_id,
                      !isQuestionSelected(q.question_id),
                    )
                  "
                  :style="{
                    cursor:
                      (props.selectionContext || 'A') === 'A' &&
                      !canEditQuestion(q)
                        ? 'default'
                        : 'pointer',
                  }">
                  <LatexRenderer :text="q.question" class="question-preview" />
                </div>

                <div class="question-actions">
                  <button
                    v-if="props.viewMode === 'all'"
                    class="btn-copy"
                    @click="handleCopyQuestion(q)">
                    복사 후 가져오기
                  </button>
                  <button v-else-if="canEditQuestion(q)" class="btn-modify" @click="openEditor(q)">
                    수정
                  </button>
                  <button class="btn-solve" @click="handleSolve(q)">
                    풀기
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- 그룹 관리 오버레이 -->
    <GroupManager
      v-if="showGroupManager"
      :current-user-no="props.currentUserNo"
      @close="showGroupManager = false"
      @updated="handleGroupsUpdated"
    />

    <!-- 문제 수정 오버레이 -->
    <QuestionEditor
      v-if="selectedQuestionForEdit"
      :question="selectedQuestionForEdit"
      @close="selectedQuestionForEdit = null"
      @updated="emit('refresh')"
    />

    <!-- 문제 풀기 오버레이 -->
    <QuestionSolver
      v-if="selectedQuestionForSolve && selectedQuestionForSolve.question_id"
      :key="selectedQuestionForSolve.question_id"
      :question="selectedQuestionForSolve"
      :has-prev="getPrevQuestion() !== null"
      :has-next="getNextQuestion() !== null"
      :current-index="currentQuestionIndex"
      :total-questions="props.questions.length"
      @close="selectedQuestionForSolve = null"
      @prev="handlePrev"
      @next="handleNext"
      @go-to-index="handleGoToQuestionIndex"
    />

    <DailyQuestionsModal
      v-if="showBulkSolveModal"
      :questions="bulkSolveQuestions"
      title="선택 문제 모아 풀기"
      log-type="B"
      :log-object-id="0"
      :log-content="bulkSolveLogContent"
      @close="showBulkSolveModal = false"
    />

    <QuestionBookUpsertModal
      v-if="showCreateBookModal"
      :show="showCreateBookModal"
      title="문제집 만들기"
      submit-label="문제집 생성"
      :initial-form="{ book_name: '', description: '' }"
      :selected-count="selectedQuestionCount"
      @close="closeCreateBookModal"
      @submit="submitCreateBookFromUpsert"
    />

    <QuestionExamCreateModal
      v-if="showCreateExamModal"
      :show="showCreateExamModal"
      :assignable-classes="assignableClasses"
      :selected-count="selectedQuestionCount"
      @close="closeCreateExamModal"
      @submit="submitCreateExamForm"
    />

    <!-- 토스트 알림 오버레이 (원복) -->
    <Transition name="toast-fade">
      <div v-if="showToast" class="toast-overlay">
        {{ toastMessage }}
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.question-list-container {
  display: flex;
  flex-direction: column;
  gap: 0.85rem;
  width: 100%;
  margin: 0 auto;
}

.question-list-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 0.85rem;
  width: 100%;
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
  gap: 0.125rem;
  padding: 0;
  width: 100%;
  min-width: 0;
  max-width: 100%;
  box-sizing: border-box;
}

.question-list .header-copy {
  width: 100%;
  padding: 0;
  margin-bottom: 0;
  border: none;
  background: transparent;
  box-shadow: none;
  border-radius: 0;
}

.header-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  min-width: 0;
}

.title-row {
  display: flex;
  align-items: center;
  gap: 0.65rem;
  min-width: 0;
  flex-wrap: nowrap;
}

.question-list-title {
  font-size: 1.35rem;
  line-height: 1.2;
  font-weight: 800;
  color: #f8fafc;
  margin: 0;
  letter-spacing: -0.03em;
  white-space: nowrap;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
}

.question-list-title .section-icon {
  width: 1.4rem;
  height: 1.4rem;
  flex-shrink: 0;
}

.question-list-subtitle {
  font-size: 0.8rem;
  color: #94a3b8;
  margin: 0;
}

.scope-toggle {
  display: inline-flex;
  gap: 2px;
  padding: 2px;
  border-radius: 6px;
  background: rgba(15, 23, 42, 0.55);
  border: 1px solid rgba(148, 163, 184, 0.14);
  flex-shrink: 0;
}

.scope-btn {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 0.75rem;
  font-weight: 700;
  border-radius: 4px;
  padding: 0.47rem 1rem;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  white-space: nowrap;
  cursor: pointer;
}

.scope-btn.active {
  background: linear-gradient(135deg, #6366f1, #818cf8);
  color: #ffffff;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.35);
}

.question-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  width: 100%;
  margin: 0;
}

.question-list-row {
  display: flex;
  align-items: flex-start;
  width: 100%;
  gap: 1.25rem;
  padding: 0;
}

.question-list-main {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  flex: 1;
  min-width: 0;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 1rem;
  background: rgba(30, 41, 59, 0.5); /* content-box와 동일 */
  overflow: hidden;
}

.group-overlay {
  position: relative;
  max-width:230px;
  width: 230px;
  flex: 0 0 230px;
  background: rgba(15, 23, 42, 0.8);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 1rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  z-index: 1;
}

.group-overlay--wide {
  width: 288px;
  flex-basis: 288px;
}

.error-panel {
  width: 100%;
  padding: 0;
}

.question-list-body {
  width: 100%;
  padding: 0;
  min-width: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.question-list {
  min-width: 0;
  width: 100%;
}

.question-list .slider-panel-border,
.question-list .question-item,
.question-list .no-results {
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

.pagination-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 10px;
  padding: 1rem 1.25rem;
  background: rgba(15, 23, 42, 0.65);
  box-shadow: 0 20px 60px -22px rgba(15, 23, 42, 1);
}

.search-bar {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  margin-bottom: 0.5rem;
}

.search-select,
.search-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 5px;
  color: #fff;
  padding: 0 1rem;
  font-size: 0.7rem;
  height: 2.75rem;
  line-height: 2.75rem;
  display: flex;
  align-items: center;
  box-sizing: border-box;
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
}

.btn-search {
  border: none;
  background: #6366f1;
  color: #fff;
}

.btn-create {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  border: none;
  background: #6366f1;
  color: #fff;
  height: 32px;
  padding: 0 0.95rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 700;
  line-height: 1;
  white-space: nowrap;
  cursor: pointer;
}

.btn-delete {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  border: 1px solid rgba(248, 113, 113, 0.45);
  background: rgba(239, 68, 68, 0.14);
  color: #fecaca;
  height: 32px;
  padding: 0 0.95rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 700;
  line-height: 1;
  white-space: nowrap;
  cursor: pointer;
}

.btn-delete:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.btn-action-icon {
  width: 0.92rem;
  height: 0.92rem;
  flex-shrink: 0;
}

.btn-bulk-action {
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.18rem;
  min-width: 72px;
  height: 48px;
  padding: 0.45rem 0.35rem;
  border: 1px solid rgba(148, 163, 184, 0.3);
  border-radius: 8px;
  background: transparent;
  color: #94a3b8;
  font-size: 0.84rem;
  font-weight: 800;
  line-height: 1.02;
  text-align: center;
  cursor: pointer;
  cursor: pointer;
}

.btn-bulk-action:disabled {
  opacity: 0.38;
  cursor: not-allowed;
}

.btn-reset-search {
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.05);
  color: #cbd5e1;
  cursor: pointer;
}

.pagination-summary {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding: 0.9rem 1rem;
  border-radius: 10px;
  background: rgba(15, 23, 42, 0.6);
  border: 1px solid rgba(148, 163, 184, 0.14);
  color: #94a3b8;
  font-size: 0.9rem;
}

.question-item {
  display: flex;
  flex-direction: column;
  padding: 0.75rem 1.25rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  backdrop-filter: blur(10px);
}

.question-main {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.5rem;
}

.question-group-path {
  font-size: 0.65rem;
  color: #64748b;
  font-weight: 500;
  text-align: right;
  letter-spacing: 0.02em;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  flex-wrap: wrap;
}

.question-owner {
  color: #c7d2fe;
  font-weight: 700;
}

.question-separator {
  color: #475569;
  font-weight: 700;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.25rem;
  gap: 1rem;
}

.question-title-row {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  min-width: 0;
}

.question-id {
  margin: 0 !important;
  font-size: 1.5rem !important;
  font-weight: 900 !important;
  color: #0055ff !important;
  font-family:
    "Pretendard", "Segoe UI", Roboto, Helvetica, Arial, sans-serif !important;
  line-height: 1 !important;
  opacity: 1 !important;
}

.question-content {
  flex: 1;
  display: flex;
  align-items: center;
  min-width: 0;
  transition: background-color 0.2s ease;
  border-radius: 6px;
  padding: 4px;
}

.question-content.is-interactive:hover {
  background-color: rgba(255, 255, 255, 0.06);
}

.question-title {
  margin: 0;
  font-size: 0.75rem;
  font-weight: 500;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  min-width: 0;
}

.question-type-badge {
  flex-shrink: 0;
  padding: 0.1rem 0.4rem;
  font-size: 0.65rem;
}

.question-preview {
  margin: 0;
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
  margin-right: 0.05rem;
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

.btn-solve {
  padding: 0.6rem 1.2rem;
  background: #6366f1;
  color: white;
  border: none;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
}

.btn-modify {
  padding: 0.6rem 1.2rem;
  background: rgba(255, 255, 255, 0.05);
  color: #94a3b8;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
}

.btn-copy {
  padding: 0.6rem 1.1rem;
  background: rgba(99, 102, 241, 0.12);
  color: #c7d2fe;
  border: 1px solid rgba(99, 102, 241, 0.28);
  border-radius: 10px;
  white-space: nowrap;
  cursor: pointer;
}

.slider-wrapper {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  width: 100%;
  max-width: none;
}

.slider-wrapper.disabled {
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

.pagination-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 10px;
  padding: 1rem 1.25rem;
  background: rgba(15, 23, 42, 0.65);
  box-shadow: 0 20px 60px -22px rgba(15, 23, 42, 1);
  margin-bottom: 1.5rem;
}

/* 토스트 알림 스타일 (대형) */
.toast-overlay {
  position: fixed;
  bottom: 6rem; /* 위치 약간 상향 */
  left: 50%;
  transform: translateX(-50%);
  background: rgba(30, 41, 59, 0.98);
  backdrop-filter: blur(16px);
  color: #818cf8; /* 강조 색상 적용 */
  padding: 1.5rem 3rem; /* 크기 2배 확대 */
  border-radius: 10px; /* 둥근 사각형 느낌으로 변경 */
  font-weight: 800;
  font-size: 1.8rem; /* 폰트 2배 확대 */
  box-shadow:
    0 20px 25px -5px rgba(0, 0, 0, 0.4),
    0 0 0 2px rgba(129, 140, 248, 0.4);
  z-index: 10000;
  white-space: nowrap;
  pointer-events: none;
}

.toast-fade-enter-active {
  transition: all 0.3s ease-out;
}

.toast-fade-leave-active {
  transition: all 1.2s cubic-bezier(0.4, 0, 0.2, 1); /* 스르르 효과 유지 */
}

.toast-fade-enter-from {
  opacity: 0;
  transform: translate(-50%, 1rem);
}

.toast-fade-leave-to {
  opacity: 0;
  transform: translate(-50%, 1.5rem);
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
  min-width: 200px;
  height: 38px;
}

.btn-search,
.btn-reset-search {
  border-radius: 10px;
  padding: 0.5rem 1rem;
  font-weight: 600;
  cursor: pointer;
  height: 38px;
}

.btn-search {
  background: #6366f1;
  color: white;
}

.btn-reset-search {
  background: rgba(255, 255, 255, 0.08);
  color: #e2e8f0;
  border: 1px solid rgba(255, 255, 255, 0.15);
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

.selected-count {
  color: #a5b4fc;
  font-weight: 700;
}

.page-slider-section {
  flex: 1;
  min-width: 0;
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

@media (max-width: 640px) {
  .search-row {
    flex-direction: column;
    align-items: stretch;
  }

  .search-select,
  .search-input,
  .btn-search,
  .btn-reset-search {
    width: 100%;
  }

  .slider-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.75rem;
  }

  .slider-row .summary-text,
  .slider-row .range-text {
    width: 100%;
  }

  .question-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }
  .question-actions {
    width: 100%;
  }
}

.group-overlay-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  flex-wrap: wrap;
  font-size: 0.75rem;
  font-weight: 700;
  color: #94a3b8;
  text-transform: uppercase;
  margin-bottom: 0.75rem;
  letter-spacing: 0.05em;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 0.5rem;
}

.action-button-group {
  display: flex !important;
  align-items: center !important;
  gap: 0.35rem;
  background: rgba(15, 23, 42, 0.4);
  padding: 4px;
  border-radius: 10px;
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
  padding: 0 0.475rem;
  border: none;
  font-size: 0.9rem;
  font-weight: 700;
  line-height: 1;
  cursor: pointer;
  white-space: nowrap;
}

.btn-create {
  background: linear-gradient(135deg, #6366f1, #818cf8);
  color: white;
  border-radius: 8px;
}

.btn-delete {
  background: transparent;
  color: #94a3b8;
  border: 1px solid rgba(148, 163, 184, 0.3);
  border-radius: 8px;
  margin-left: 2px;
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

.header-actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.group-breadcrumb {
  width: 100%;
  margin-top: 0.35rem;
  font-size: 0.7rem;
  font-weight: 600;
  color: #94a3b8;
  text-decoration: underline;
  text-underline-offset: 0.16em;
  text-transform: none;
  letter-spacing: 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.group-search {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 0.35rem;
  margin-top: 0.45rem;
}

.group-search-input {
  flex: 1;
  min-width: 0;
  height: 28px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(15, 23, 42, 0.45);
  color: #e2e8f0;
  padding: 0 0.5rem;
  font-size: 0.72rem;
}

.group-search-input:focus {
  outline: none;
  border-color: rgba(99, 102, 241, 0.45);
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.15);
}

.group-search-clear {
  height: 28px;
  padding: 0 0.5rem;
  border-radius: 8px;
  border: 1px solid rgba(99, 102, 241, 0.3);
  background: rgba(99, 102, 241, 0.15);
  color: #c7d2fe;
  font-size: 0.7rem;
  cursor: pointer;
}

.group-search-empty {
  margin-top: 0.5rem;
  font-size: 0.7rem;
  color: #64748b;
}

.btn-manage-groups {
  background: rgba(99, 102, 241, 0.2);
  border: 1px solid rgba(99, 102, 241, 0.4);
  cursor: pointer;
  opacity: 0.6;
  padding: 0.2rem 0.5rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  border-radius: 4px;
  cursor: pointer;
}

.settings-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
  color: #a5b4fc;
}

.btn-manage-label {
  font-size: 0.7rem;
  font-weight: 600;
  color: #a5b4fc;
  letter-spacing: 0.02em;
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

.btn-clear-filter {
  background: rgba(14, 165, 233, 0.15);
  border: 1px solid rgba(14, 165, 233, 0.35);
  color: #7dd3fc;
  cursor: pointer;
  padding: 0.25rem 0.6rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  border-radius: 6px;
  font-size: 0.72rem;
  font-weight: 700;
  transition: all 0.22s cubic-bezier(0.4, 0, 0.2, 1);
  white-space: nowrap;
}

.btn-clear-filter:hover {
  background: rgba(14, 165, 233, 0.25);
  border-color: rgba(14, 165, 233, 0.55);
  color: #e0f2fe;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(14, 165, 233, 0.2);
}

.btn-clear-filter:active {
  transform: translateY(0);
}

.filter-icon {
  width: 0.95rem;
  height: 0.95rem;
  flex-shrink: 0;
  color: inherit;
}

@media (max-width: 1400px) {
  .group-overlay {
    width: 100%;
    margin-bottom: 1rem;
  }

  .question-list-row {
    flex-direction: column;
  }
}
</style>
