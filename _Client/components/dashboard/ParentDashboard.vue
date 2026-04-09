<!--
파일 개요:
- 역할: 학부모 역할에 맞는 대시보드 화면을 구성하는 컴포넌트입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { ref, onMounted } from "vue";
import IconUsers from "~/assets/icons/IconUsers.svg?component";

const childrenStats = ref<any[]>([]);
const loading = ref(true);

const { apiBase, token, getAuthHeader } = useApi();

const fetchStats = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/dashboard/stats`, {
      headers: getAuthHeader(),
    });
    childrenStats.value = data as any[];
  } catch (err) {
    console.error("서버 통신 오류(fetch) parent stats:", err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchStats);
</script>

<template>
  <div v-if="loading" class="loading">자녀 학습 정보를 불러오는 중...</div>
  <div v-else-if="childrenStats.length === 0" class="empty">
    연결된 자녀가 없습니다. 학생 계정을 자녀로 등록해 주세요.
  </div>
  <div v-else class="parent-stats">
    <h3><IconUsers class="section-icon" /> 자녀 학습 요약</h3>
    <div class="children-grid">
      <div
        v-for="child in childrenStats"
        :key="child.studentNo"
        class="child-card">
        <div class="child-header">
          <span class="child-name">{{ child.studentName }}</span>
          <span class="child-status">활동 중</span>
        </div>
        <div class="child-body">
          <div class="metric">
            <span class="label">최근 풀이 문제</span>
            <span class="value">{{ child.recentSolveCount }}개</span>
          </div>
        </div>
        <button class="btn-detail">상세 리포트 보기</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.parent-stats h3 {
  margin-bottom: 1.5rem;
  color: #f8fafc;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.section-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.children-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.child-card {
  background: rgba(245, 158, 11, 0.05);
  border: 1px solid rgba(245, 158, 11, 0.1);
  border-radius: 10px;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}

.child-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.child-name {
  font-size: 1.3rem;
  font-weight: 800;
  color: #fbbf24;
}

.child-status {
  font-size: 0.8rem;
  color: #fbbf24;
  background: rgba(251, 191, 36, 0.1);
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
}

.metric {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.metric .label {
  color: #94a3b8;
}

.metric .value {
  font-size: 1.5rem;
  font-weight: 700;
  color: #f8fafc;
}

.btn-detail {
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.2);
  color: #fbbf24;
  padding: 0.75rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-detail:hover {
  background: #fbbf24;
  color: #000;
}

.loading,
.empty {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}
</style>
