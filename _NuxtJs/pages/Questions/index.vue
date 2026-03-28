<script setup lang="ts">
import QuestionList from '~/components/dashboard/QuestionList.vue';
import type { QuestionListResponse } from '~/types';

const { apiBase } = useApi();

const route = useRoute();
const userCookie = useCookie('user_info');
const userInfo = computed(() => {
  if (!userCookie.value) return null;
  return typeof userCookie.value === 'string' ? JSON.parse(userCookie.value) : userCookie.value;
});

const selectedGroupId = ref<string | number | null>(null);
const appliedSearchField = ref<'title' | 'content'>('title');
const appliedSearchKeyword = ref('');
const currentPage = ref(1);
const pageSize = 10;
const hasResolvedOnce = ref(false);

const requestBody = computed(() => {
  const body: Record<string, string | number> = {};

  if (route.query.mine === 'true' && userInfo.value) {
    body.creator_no = userInfo.value.user_no;
  }

  if (selectedGroupId.value !== null) {
    body.group_id = selectedGroupId.value;
  }

  if (appliedSearchKeyword.value) {
    body.search_field = appliedSearchField.value;
    body.search_keyword = appliedSearchKeyword.value;
  }

  body.page = currentPage.value;
  body.limit = pageSize;

  return body;
});

const { data: questionResponse, pending, error, refresh } = await useFetch<QuestionListResponse>(() => `${apiBase.value}/questions`, {
  method: 'POST',
  body: requestBody,
});

watch(
  [questionResponse, error],
  ([data, fetchError]) => {
    if (data || fetchError) {
      hasResolvedOnce.value = true;
    }
  },
  { immediate: true },
);

watch(requestBody, () => {
  refresh();
}, { deep: true });

watch(() => route.query.mine, () => {
  currentPage.value = 1;
});

const handleGroupChange = (groupId: string | number | null) => {
  selectedGroupId.value = groupId;
  currentPage.value = 1;
};

const handleSearch = (payload: { field: 'title' | 'content'; keyword: string }) => {
  appliedSearchField.value = payload.field;
  appliedSearchKeyword.value = payload.keyword;
  currentPage.value = 1;
};

const handleResetSearch = () => {
  appliedSearchField.value = 'title';
  appliedSearchKeyword.value = '';
  currentPage.value = 1;
};

const handlePageChange = (page: number) => {
  currentPage.value = page;
};
</script>

<template>
  <div class="page-container">

    <div class="page-header">
      <h1 class="page-title">나의 문제목록</h1>
      <NuxtLink to="/dashboard" class="back-btn">← 대시보드</NuxtLink>
    </div>
    
    <div v-if="error && !questionResponse && !pending" class="error">
      문제를 불러오지 못했습니다. 백엔드 서버가 실행 중인지 확인해 주세요.
      <pre>{{ error }}</pre>
    </div>

    <div v-else>
      <div class="question-list-shell">
        <QuestionList
          :questions="questionResponse?.items || []"
          :selected-group-id="selectedGroupId"
          :applied-search-field="appliedSearchField"
          :applied-search-keyword="appliedSearchKeyword"
          :current-page="questionResponse?.page || 1"
          :total-pages="questionResponse?.totalPages || 1"
          :total-items="questionResponse?.total || 0"
          :page-size="questionResponse?.limit || pageSize"
          @refresh="refresh"
          @change-group="handleGroupChange"
          @search="handleSearch"
          @reset-search="handleResetSearch"
          @change-page="handlePageChange"
        />

        <!-- <div v-if="pending" class="loading-overlay">
          문제를 불러오는 중...
        </div> -->
      </div>

      <div v-if="error && questionResponse" class="inline-error">
        최신 문제 목록을 불러오지 못했습니다.
      </div>
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
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem 3rem;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 2rem;
  max-width: 900px;
  width: 100%;
  margin-left: auto;
  margin-right: auto;
}

.page-title {
  font-size: 2.25rem;
  font-weight: 700;
  color: #f8fafc;
  margin: 0;
}

.back-btn {
  color: #818cf8;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.95rem;
}

.loading, .error {
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

.question-list-shell {
  position: relative;
}

.loading-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding-top: 5rem;
  background: rgba(15, 23, 42, 0.18);
  backdrop-filter: blur(2px);
  border-radius: 16px;
  color: #cbd5e1;
  font-size: 0.95rem;
  font-weight: 600;
  pointer-events: none;
}

.inline-error {
  margin-top: 1rem;
  text-align: center;
  color: #fca5a5;
  font-size: 0.9rem;
}
</style>
