<script setup lang="ts">
import type { Question } from '~/types';

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

  return body;
});

const { data: questions, pending, error, refresh } = await useFetch<Question[]>(() => `${apiBase.value}/questions`, {
  method: 'POST',
  body: requestBody,
});

watch(() => route.query.mine, () => refresh());

const handleGroupChange = (groupId: string | number | null) => {
  selectedGroupId.value = groupId;
};

const handleSearch = (payload: { field: 'title' | 'content'; keyword: string }) => {
  appliedSearchField.value = payload.field;
  appliedSearchKeyword.value = payload.keyword;
};

const handleResetSearch = () => {
  appliedSearchField.value = 'title';
  appliedSearchKeyword.value = '';
};
</script>

<template>
  <div class="container">

    <h1 class="title">나의 문제목록</h1>
    
    <div v-if="pending" class="loading">
      문제를 불러오는 중...
    </div>
    
    <div v-else-if="error" class="error">
      문제를 불러오지 못했습니다. 백엔드 서버가 실행 중인지 확인해 주세요.
      <pre>{{ error }}</pre>
    </div>
    
    <div v-else>
      <QuestionList
        :questions="questions || []"
        :selected-group-id="selectedGroupId"
        :applied-search-field="appliedSearchField"
        :applied-search-keyword="appliedSearchKeyword"
        @refresh="refresh"
        @change-group="handleGroupChange"
        @search="handleSearch"
        @reset-search="handleResetSearch"
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

.container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.title {
  font-size: 2.5rem;
  font-weight: 800;
  text-align: center;
  margin-bottom: 3rem;
  background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
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
</style>
