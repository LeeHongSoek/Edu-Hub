<script setup lang="ts">
import { ref, onMounted, computed, watch } from "vue";
import { useRoute } from "vue-router";
import ManagerNav from "~/components/dashboard/ManagerNav.vue";
import GroupHierarchy from "~/components/dashboard/GroupHierarchy.vue";
import GroupManager from "~/components/dashboard/GroupManager.vue";
import QuestionEditor from "~/components/dashboard/QuestionEditor.vue";
import QuestionSolver from "~/components/dashboard/QuestionSolver.vue";
import DailyQuestionsModal from "~/components/DailyQuestionsModal.vue";
import IconSettings from "~/assets/icons/IconSettings.svg?component";
import IconUsers from "~/assets/icons/IconUsers.svg?component";
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconCreateAction from "~/assets/icons/IconCreateAction.svg?component";
import IconDeleteAction from "~/assets/icons/IconDeleteAction.svg?component";
import { useApi } from "~/composables/useApi";
import type { Question, Group } from "~/types";

const route = useRoute();

const props = defineProps<{
  listTitle?: string;
  listSubtitle?: string | null;
  showScopeToggle?: boolean;
  scopeMode?: "mine" | "all";
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
  hideGroupOverlay?: boolean;
}>();

// API 설정 통합
const { apiBase } = useApi();

const groups = ref<Group[]>([]);
const selectedQuestionForSolve = ref<Question | null>(null);
const selectedQuestionForEdit = ref<Question | null>(null);
const showGroupManager = ref(false);
const unassignedCount = ref(0);

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
const selectedQuestionCount = computed(() => selectedQuestionIds.value.length);
const canDeleteQuestions = computed(() => selectedQuestionCount.value > 0);
const canBulkSolveQuestions = computed(() => selectedQuestionCount.value >= 5);

const isSliderDisabled = computed(() => props.totalPages <= 1);

const emit = defineEmits<{
  (e: "refresh"): void;
  (e: "change-scope", scope: "mine" | "all"): void;
  (e: "change-group", groupId: string | number | null): void;
  (e: "search", payload: { field: "title" | "content" | "id"; keyword: string }): void;
  (e: "reset-search"): void;
  (e: "change-page", page: number): void;
  (e: "copy-question", question: Question): void;
}>();

const handleSelectGroup = (groupId: string | number | null) => {
  emit("change-group", groupId);
};

const handleScopeChange = (scope: "mine" | "all") => {
  emit("change-scope", scope);
  // 스코프 변경 시 그룹 선택/검색 필터 초기화
  clearAllFilters();
};

const clearAllFilters = () => {
  searchField.value = "content";
  searchInput.value = "";
  groupSearchInput.value = "";
  emit("change-group", null);
  emit("reset-search");
};

const applySearch = () => {
  const keyword = searchInput.value.trim();

  if (!keyword) {
    clearAllFilters();
    return;
  }

  emit("search", {
    field: searchField.value,
    keyword,
  });
};

const resetSearch = () => {
  clearAllFilters();
};

const handleSolve = (question: Question) => {
  selectedQuestionForSolve.value = question;
};

const getQuestionIdKey = (questionId: string | number | bigint) =>
  String(questionId);

const isQuestionSelected = (questionId: string | number | bigint) =>
  selectedQuestionIds.value.includes(getQuestionIdKey(questionId));

const isAllVisibleSelected = computed(() => {
  if (props.questions.length === 0) return false;
  const selectableQuestions = props.questions.filter((q) => canEditQuestion(q) || props.viewMode === 'all');
  if (selectableQuestions.length === 0) return false;
  return selectableQuestions.every((q) => isQuestionSelected(q.question_id));
});

const isSomeVisibleSelected = computed(() => {
  const selectedCount = props.questions.filter((q) => isQuestionSelected(q.question_id)).length;
  return selectedCount > 0 && !isAllVisibleSelected.value;
});

const toggleSelectAllVisible = (checked: boolean) => {
  for (const q of props.questions) {
    if (!canEditQuestion(q) && props.viewMode !== 'all') continue;
    toggleQuestionSelected(q.question_id, checked);
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

const toggleQuestionSelected = (
  questionId: string | number | bigint,
  checked: boolean,
) => {
  const idKey = getQuestionIdKey(questionId);
  if (checked) {
    if (!selectedQuestionIds.value.includes(idKey)) {
      selectedQuestionIds.value = [...selectedQuestionIds.value, idKey];
    }
    rememberSelectedQuestion(questionId);
    return;
  }
  selectedQuestionIds.value = selectedQuestionIds.value.filter(
    (id) => id !== idKey,
  );
  const nextCache = { ...selectedQuestionCache.value };
  delete nextCache[idKey];
  selectedQuestionCache.value = nextCache;
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
      raw === true ||
      raw === 1 ||
      raw === "1" ||
      raw === "Y" ||
      raw === "y"
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
  if (prev) selectedQuestionForSolve.value = prev;
};

const handleNext = () => {
  const next = getNextQuestion();
  if (next) selectedQuestionForSolve.value = next;
};

const handleGoToQuestionIndex = (index: number) => {
  if (index < 0 || index >= props.questions.length) return;
  selectedQuestionForSolve.value = props.questions[index];
};

const openEditor = (q: Question | null) => {
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
    parts.unshift(current.name);
    current = current.parent_group;
  }
  while (parts.length < 3) {
    parts.push("");
  }
  return parts.join(" / ");
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
const bulkSolveQuestions = computed(() =>
  selectedQuestionIds.value
    .map((id) => selectedQuestionCache.value[id])
    .filter((question): question is Question => Boolean(question)),
);
const bulkSolveLogContent = computed(
  () => `임의로 ${bulkSolveQuestions.value.length}문항을 선택하여 임시문제집 풀이`,
);

const filterGroupsByOwner = (
  list: Group[],
  ownerNo: string | number,
): Group[] => {
  const matches = (group: Group) =>
    String(group.creator_no) === String(ownerNo);
  const result: Group[] = [];
  for (const group of list) {
    if (!matches(group)) continue;
    const childGroups = group.child_groups
      ? filterGroupsByOwner(group.child_groups, ownerNo)
      : [];
    result.push({ ...group, child_groups: childGroups });
  }
  return result;
};

const visibleGroups = computed(() => {
  const scope = props.scopeMode ?? "mine";
  if (scope !== "mine") return groups.value;
  if (props.currentUserNo === null || props.currentUserNo === undefined)
    return groups.value;
  return filterGroupsByOwner(groups.value, props.currentUserNo);
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

const searchedGroups = computed(() => {
  const query = groupSearchInput.value.trim().toLowerCase();
  if (!query) {
    return { groups: visibleGroups.value, expandedIds: new Set<string>() };
  }
  const { filtered, expandIds } = filterGroupsBySearch(visibleGroups.value, query);
  return { groups: filtered, expandedIds: expandIds };
});

const fetchGroups = async () => {
  try {
    const data = await $fetch<{ groups: Group[]; unassigned_count: number }>(`${apiBase.value}/groups`, {
      query: {
        scope: props.viewMode,
        userNo: props.currentUserNo ?? undefined,
        viewerNo: props.currentUserNo ?? undefined,
      },
    });
    groups.value = data.groups;
    unassignedCount.value = data.unassigned_count;
  } catch (error) {
    console.error("서버 통신 오류(fetch) groups:", error);
  }
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
    localStorage.removeItem(STORAGE_KEY_IDS);
    localStorage.removeItem(STORAGE_KEY_CACHE);
    emit("refresh");
  } catch (error) {
    console.error("문제 삭제 오류:", error);
    alert("문제 삭제 중 오류가 발생했습니다.");
  }
};

const openBulkSolveModal = () => {
  if (selectedQuestionCount.value < 5) {
    alert("모아 풀기는 문제를 5개 이상 선택해야 시작할 수 있습니다.");
    return;
  }

  if (bulkSolveQuestions.value.length < 5) {
    alert("선택한 문제 정보를 확인한 뒤 다시 시도해주세요.");
    return;
  }

  showBulkSolveModal.value = true;
};

// --- [문제 선택 데이터 관리 (영구 저장용 키)] ---
// 브라우저의 localStorage에 저장할 때 사용하는 고유 키 값들입니다.
const STORAGE_KEY_IDS = "edu_hub_selected_question_ids";
const STORAGE_KEY_CACHE = "edu_hub_selected_question_cache";
const STORAGE_KEY_USER = "edu_hub_selected_question_user";
// -----------------------------------------------

/**
 * 브라우저 저장소(localStorage)에서 이전에 선택했던 문제 정보를 불러옵니다.
 * 보안을 위해 현재 로그인한 사용자와 저장된 사용자 ID가 일치할 때만 복구합니다.
 */
const restoreSelectionFromStorage = () => {
  const savedUser = localStorage.getItem(STORAGE_KEY_USER);
  const currentUser = String(props.currentUserNo || "");
  
  // 만약 저장된 사용자 ID와 현재 사용자 ID가 다르면 복구하지 않음
  if (savedUser !== currentUser) {
    if (savedUser) clearSelection();
    return;
  }

  const savedIds = localStorage.getItem(STORAGE_KEY_IDS);
  const savedCache = localStorage.getItem(STORAGE_KEY_CACHE);

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

onMounted(async () => {
  restoreSelectionFromStorage();

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
  localStorage.removeItem(STORAGE_KEY_IDS);
  localStorage.removeItem(STORAGE_KEY_CACHE);
  localStorage.removeItem(STORAGE_KEY_USER);
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
watch(selectedQuestionIds, (newIds) => {
  localStorage.setItem(STORAGE_KEY_IDS, JSON.stringify(newIds));
  localStorage.setItem(STORAGE_KEY_USER, String(props.currentUserNo || ""));
}, { deep: true });

// 선택된 문제의 상세 정보(캐시)가 변경될 때마다 브라우저 저장소에 자동으로 백업합니다.
watch(selectedQuestionCache, (newCache) => {
  localStorage.setItem(STORAGE_KEY_CACHE, JSON.stringify(newCache));
  localStorage.setItem(STORAGE_KEY_USER, String(props.currentUserNo || ""));
}, { deep: true });
// ------------------------------


watch(
  () => props.viewMode,
  async () => {
    await fetchGroups();
  },
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
      <div v-if="!props.hideGroupOverlay" class="group-overlay">
        <div class="group-overlay-header">
          <span>문제 그룹</span>
          <div class="header-actions">
            <button
              class="btn-manage-groups"
              title="그룹 관리"
              @click="showGroupManager = true"
            >
              <IconSettings class="settings-icon" />
              <span class="btn-manage-label">그룹 관리</span>
            </button>
            <button class="btn-clear-filter" @click="clearAllFilters">
              <IconUsers class="filter-icon" />
              전체
            </button>
          </div>
          <div class="group-breadcrumb">{{ selectedGroupBreadcrumb }}</div>
          <div class="group-search">
            <input
              v-model="groupSearchInput"
              type="text"
              class="group-search-input"
              placeholder="그룹명 검색"
            />
            <button
              v-if="groupSearchInput"
              class="group-search-clear"
              @click="groupSearchInput = ''"
            >
              초기화
            </button>
          </div>
        </div>

        <GroupHierarchy
          :groups="searchedGroups.groups"
          :selected-group-id="props.selectedGroupId"
          :expanded-ids="searchedGroups.expandedIds"
          :current-user-no="props.currentUserNo"
          :unassigned-count="unassignedCount"
          @select-group="handleSelectGroup"
        />
        <div
          v-if="groupSearchInput && searchedGroups.groups.length === 0"
          class="group-search-empty"
        >
          검색 결과가 없습니다.
        </div>
      </div>

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
                    props.hideGroupOverlay && props.listSubtitle
                      ? props.listSubtitle
                      : (props.listTitle ?? "문제 목록")
                  }}
                </h3>

                <div class="action-button-group">
                  <button class="btn-create" @click="openEditor(null)">
                    <IconCreateAction class="btn-action-icon" />
                    새 문제
                  </button>
                  <button
                    class="btn-delete"
                    :disabled="!canDeleteQuestions"
                    @click="deleteSelectedQuestions"
                  >
                    <IconDeleteAction class="btn-action-icon" />
                    삭제
                  </button>
                  <button
                    class="btn-bulk-action"
                    :disabled="!canBulkSolveQuestions"
                    @click="openBulkSolveModal"
                  >
                    모아<br/>풀기
                  </button>
                  <button
                    class="btn-bulk-action"
                    :disabled="!canDeleteQuestions"
                  >
                    문제집<br/>만들기
                  </button>
                  <button
                    class="btn-bulk-action"
                    :disabled="!canDeleteQuestions"
                  >
                    고사집<br/>만들기
                  </button>
                </div>
              </div>
            </div>

            <ManagerNav 
              :active-page="hideGroupOverlay ? null : 'questions'" 
              :back-link="hideGroupOverlay ? { to: route.query.book ? '/question-books' : '/exams', label: '되돌아가기' } : null"
            />
          </div>

          <div class="pagination-panel-border">
            <div class="slider-panel">
              <div class="search-row">
                <div
                  v-if="props.showScopeToggle && !props.hideGroupOverlay"
                  class="scope-toggle"
                  role="tablist"
                  aria-label="문제 목록 범위 선택"
                >
                  <button
                    type="button"
                    class="scope-btn"
                    :class="{ active: (props.scopeMode ?? 'mine') === 'mine' }"
                    :aria-pressed="(props.scopeMode ?? 'mine') === 'mine'"
                    @click="handleScopeChange('mine')"
                  >
                    나의 문제
                  </button>
                  <button
                    type="button"
                    class="scope-btn"
                    :class="{ active: (props.scopeMode ?? 'mine') === 'all' }"
                    :aria-pressed="(props.scopeMode ?? 'mine') === 'all'"
                    @click="handleScopeChange('all')"
                  >
                    전체 문제
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
                  @click="resetSearch"
                >
                  초기화
                </button>
              </div>
              <div class="slider-row">
                 <input
                  type="checkbox"
                  class="copy-checkbox"
                  aria-label="전체 문제 선택"
                  :checked="isAllVisibleSelected"
                  :indeterminate="isSomeVisibleSelected"
                  @change="toggleSelectAllVisible(($event.target as HTMLInputElement).checked)"
                />
                <span class="summary-text"
                  >총 {{ props.totalItems }}문제
                  <span class="selected-count">
                    · {{ selectedQuestionCount }}개 선택됨
                  </span>
                </span
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
                        :max="props.totalPages"
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
                        v-if="!isSliderDisabled"
                        class="slider-tooltip"
                        :style="{ left: sliderPercentage + '%' }"
                      >
                        {{ sliderValue }}
                      </div>
                    </div>
                    <span class="slider-limit">{{ props.totalPages }}</span>
                  </div>
                </div>
                <span class="range-text"
                  >{{ pageStartItem }}-{{ pageEndItem }}번째 문제 표시
                  중</span
                >
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
              class="question-item"
            >
              <div class="question-header">
                <div class="question-title-row">
                  <h3 class="question-id">{{ q.question_id }}</h3>
                  <span class="badge badge-type question-type-badge">{{
                    getQuestionTypeBadgeLabel(q)
                  }}</span>
                  <h3 class="question-title">{{ q.title }}</h3>
                </div>
                <div class="question-group-path">
                  <span
                    v-if="q.creator?.username && shouldShowQuestionOwner(q)"
                    class="question-owner"
                    >{{ q.creator.username }}</span
                  >
                  <span
                    v-if="q.creator?.username && shouldShowQuestionOwner(q)"
                    class="question-separator"
                    >·</span
                  >
                  <span>{{
                    q.group ? formatGroupPath(q.group) : "문제 분류 없음"
                  }}</span>
                </div>
              </div>

              <div class="question-main">
                <input
                  type="checkbox"
                  class="copy-checkbox"
                  aria-label="문제 선택"
                  :checked="isQuestionSelected(q.question_id)"
                  :disabled="!canEditQuestion(q)"
                  @change="
                    toggleQuestionSelected(
                      q.question_id,
                      ($event.target as HTMLInputElement).checked,
                    )
                  "
                />
                <div class="question-content">
                  <LatexRenderer :text="q.question" class="question-preview" />
                </div>

                <div class="question-actions">
                  
                  <button
                    v-if="props.viewMode === 'all' && !props.hideGroupOverlay"
                    class="btn-copy"
                    @click="emit('copy-question', q)"
                  >복사 후 가져오기</button>
                  <button
                    v-else-if="canEditQuestion(q) && !props.hideGroupOverlay"
                    class="btn-modify"
                    @click="selectedQuestionForEdit = q"
                  >수정</button>
                  <button class="btn-solve" @click="handleSolve(q)">풀기</button>
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
      @close="showGroupManager = false"
      @updated="fetchGroups"
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
  width: 240px;
  flex: 0 0 240px;
  background: rgba(15, 23, 42, 0.8);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 1rem;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  z-index: 1;
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
  padding: 0.45rem 0.7rem;
  border: none;
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
  font-family: "Pretendard", "Segoe UI", Roboto, Helvetica, Arial, sans-serif !important;
  line-height: 1 !important;
  opacity: 1 !important;
}


.question-content {
  flex: 1;
  display: flex;
  align-items: center;
  min-width: 0;
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

.slider-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 10px;
  padding: 1rem 1.25rem;
  background: rgba(15, 23, 42, 0.65);
  box-shadow: 0 20px 60px -22px rgba(15, 23, 42, 1);
  margin-bottom: 0;
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
}

.btn-create {
  background: linear-gradient(135deg, #6366f1, #818cf8);
  color: white;
  border-radius: 8px;
}



.btn-delete {
  background: transparent;
  color: #94a3b8;
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
