<script setup lang="ts">
import { computed, ref, watch } from "vue";
import QuestionListManager from "~/components/dashboard/QuestionListManager.vue";
import type { Question, QuestionListResponse } from "~/types";

const { apiBase, token, getAuthHeader } = useApi();

const route = useRoute();
const router = useRouter();
const userCookie = useCookie("user_info");
const userInfo = computed(() => {
  if (!userCookie.value) return null;
  return typeof userCookie.value === "string"
    ? JSON.parse(userCookie.value)
    : userCookie.value;
});

const selectedGroupId = ref<string | number | null>(null);
const appliedSearchField = ref<"content" | "title">("content");
const appliedSearchKeyword = ref("");
const currentPage = ref(1);
const pageSize = 10;

const activeBookId = computed<number | undefined>(() => {
  const raw = route.query.book;
  if (!raw) return undefined;
  const numeric = Number(raw);
  return Number.isNaN(numeric) ? undefined : numeric;
});

const activeBookDetail = ref<any | null>(null);
const activeExamId = computed<number | undefined>(() => {
  const raw = route.query.exam;
  if (!raw) return undefined;
  const numeric = Number(raw);
  return Number.isNaN(numeric) ? undefined : numeric;
});
const activeExamDetail = ref<any | null>(null);
const isSourceDetail = computed(
  () => activeBookId.value !== undefined || activeExamId.value !== undefined,
);
const questionScope = computed<"mine" | "all">(() => {
  if (isSourceDetail.value) {
    if (route.query.scope === "mine" || route.query.mine === "true")
      return "mine";
    return "all";
  }
  if (route.query.scope === "all" || route.query.mine === "false") return "all";
  return "mine";
});

const requestBody = computed(() => {
  const body: Record<string, string | number | boolean> = {};

  if (!isSourceDetail.value) {
    if (questionScope.value === "mine" && userInfo.value) {
      body.creator_no = userInfo.value.user_no;
    }

    if (questionScope.value === "all") {
      body.public_only = true;
      if (userInfo.value) {
        body.viewer_no = userInfo.value.user_no;
      }
    }
  }

  if (selectedGroupId.value !== null) {
    body.group_id = selectedGroupId.value;
  }

  if (appliedSearchKeyword.value) {
    body.search_field = appliedSearchField.value;
    body.search_keyword = appliedSearchKeyword.value;
  }

  if (activeExamId.value !== undefined) {
    body.exam_id = activeExamId.value;
  }

  if (activeBookId.value !== undefined) {
    body.book_id = activeBookId.value;
  }

  body.page = currentPage.value;
  body.limit = pageSize;

  return body;
});

const activeSourceLabel = computed(() => {
  if (activeExamDetail.value?.exam_name)
    return `고사집: ${activeExamDetail.value.exam_name}`;
  if (activeBookDetail.value?.book_name)
    return `문제집: ${activeBookDetail.value.book_name}`;
  return "";
});

const loadActiveBookDetail = async (bookId?: number) => {
  if (!bookId) {
    activeBookDetail.value = null;
    return;
  }

  if (!token.value) {
    activeBookDetail.value = null;
    return;
  }

  try {
    activeBookDetail.value = await $fetch(
      `${apiBase.value}/question-books/${bookId}`,
      {
        headers: getAuthHeader(),
      },
    );
  } catch (err) {
    console.error("문제집 상세 조회 실패:", err);
    activeBookDetail.value = null;
  }
};

const loadActiveExamDetail = async (examId?: number) => {
  if (!examId) {
    activeExamDetail.value = null;
    return;
  }

  if (!token.value) {
    activeExamDetail.value = null;
    return;
  }

  try {
    activeExamDetail.value = await $fetch(`${apiBase.value}/exams/${examId}`, {
      headers: getAuthHeader(),
    });
  } catch (err) {
    console.error("고사집 상세 조회 실패:", err);
    activeExamDetail.value = null;
  }
};

const {
  data: questionResponse,
  pending,
  error,
  refresh,
} = await useFetch<QuestionListResponse>(() => `${apiBase.value}/questions`, {
  method: "POST",
  body: requestBody,
});

watch(
  requestBody,
  () => {
    refresh();
  },
  { deep: true },
);

watch(
  () => [route.query.scope, route.query.mine],
  () => {
    currentPage.value = 1;
  },
);

watch(
  () => route.query.book,
  () => {
    currentPage.value = 1;
    if (activeExamId.value === undefined) {
      loadActiveBookDetail(activeBookId.value);
    } else {
      activeBookDetail.value = null;
    }
  },
  { immediate: true },
);

watch(
  () => route.query.exam,
  () => {
    currentPage.value = 1;
    activeBookDetail.value = null;
    loadActiveExamDetail(activeExamId.value);
  },
  { immediate: true },
);

const handleGroupChange = (groupId: string | number | null) => {
  selectedGroupId.value = groupId;
  currentPage.value = 1;
};

const handleSearch = (payload: {
  field: "title" | "content";
  keyword: string;
}) => {
  appliedSearchField.value = payload.field;
  appliedSearchKeyword.value = payload.keyword;
  currentPage.value = 1;
};

const handleResetSearch = () => {
  appliedSearchField.value = "title";
  appliedSearchKeyword.value = "";
  currentPage.value = 1;
};

const handlePageChange = (page: number) => {
  currentPage.value = page;
};

const setQuestionScope = async (scope: "mine" | "all") => {
  const nextQuery: Record<string, string> = {};

  for (const [key, value] of Object.entries(route.query)) {
    if (typeof value === "string") {
      nextQuery[key] = value;
    }
  }

  nextQuery.scope = scope;
  delete nextQuery.mine;
  currentPage.value = 1;
  await router.replace({ query: nextQuery });
};

const handleCopyQuestion = async (question: Question) => {
  if (!userInfo.value) {
    alert("문제를 내 계정으로 가져오려면 로그인이 필요합니다.");
    return;
  }

  try {
    await $fetch(`${apiBase.value}/questions/${question.question_id}/copy`, {
      method: "POST",
      headers: getAuthHeader(),
      body: {
        user_no: userInfo.value.user_no,
      },
    });
    alert("문제를 내 문제로 가져왔습니다.");
    await setQuestionScope("mine");
  } catch (err) {
    console.error("문제 복사 실패:", err);
    alert("문제를 복사하는 중 오류가 발생했습니다.");
  }
};
</script>

<template>
  <div class="page-container">
    <div class="content-box">
      <QuestionListManager
        :list-title="'문제 목록'"
        :list-subtitle="activeSourceLabel"
        :show-scope-toggle="true"
        :scope-mode="questionScope"
        :show-error="!!(error && !questionResponse && !pending)"
        :error-message="'문제를 불러오지 못했습니다. 백엔드 서버가 실행 중인지 확인해 주세요.'"
        :questions="questionResponse?.items || []"
        :current-user-no="userInfo?.user_no ?? null"
        :selected-group-id="selectedGroupId"
        :applied-search-field="appliedSearchField"
        :applied-search-keyword="appliedSearchKeyword"
        :current-page="questionResponse?.page || 1"
        :total-pages="questionResponse?.totalPages || 1"
        :total-items="questionResponse?.total || 0"
        :page-size="questionResponse?.limit || pageSize"
        :view-mode="questionScope"
        @refresh="refresh"
        @change-scope="setQuestionScope"
        @change-group="handleGroupChange"
        @search="handleSearch"
        @reset-search="handleResetSearch"
        @change-page="handlePageChange"
        @copy-question="handleCopyQuestion"
      />
    </div>
  </div>
</template>

<style scoped>
.nav-header {
  margin-bottom: 1rem;
  display: flex;
  justify-content: flex-start;
}

.back-button {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1.2rem;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.05);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #e2e8f0;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.back-button:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.2);
  transform: translateX(-4px);
  box-shadow: 0 10px 20px -10px rgba(0, 0, 0, 0.5);
}

.icon {
  width: 1.25rem;
  height: 1.25rem;
}

.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem 1rem 3rem;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1rem;
  max-width: 1200px;
  width: 100%;
  margin-left: auto;
  margin-right: auto;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  color: #94a3b8;
  text-decoration: none;
  font-weight: 500;
  font-size: 0.9rem;
  padding: 0.35rem 0.55rem;
  border-radius: 8px;
  background: transparent;
  border: none;
  transition: all 0.2s;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.04);
  color: #eef2ff;
  transform: translateY(-1px);
}

.back-icon,
.quick-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.page-nav {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: nowrap;
  width: 100%;
  justify-content: space-between;
}

.page-links {
  display: flex;
  gap: 0.75rem;
  flex-wrap: nowrap;
  justify-content: flex-end;
  margin-left: auto;
}

.quick-link {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  padding: 0.35rem 0.55rem;
  border-radius: 8px;
  background: transparent;
  border: none;
  color: #94a3b8;
  text-decoration: none;
  font-weight: 500;
  font-size: 0.9rem;
  transition: all 0.2s;
}

.quick-link:hover {
  background: rgba(255, 255, 255, 0.04);
  color: #eef2ff;
  transform: translateY(-1px);
}

.loading,
.error {
  text-align: center;
  padding: 4rem;
  font-size: 1.2rem;
  color: #94a3b8;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  border: 1px dashed rgba(255, 255, 255, 0.1);
}

.error {
  color: #f87171;
  border-color: rgba(248, 113, 113, 0.2);
}

.inline-error {
  margin-top: 1rem;
  text-align: center;
  color: #fca5a5;
  font-size: 0.9rem;
}

@media (max-width: 900px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .page-nav {
    align-items: flex-start;
    width: 100%;
  }

  .page-links {
    justify-content: flex-start;
    flex-wrap: wrap;
  }

}
</style>
