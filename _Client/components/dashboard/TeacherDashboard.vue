<script setup lang="ts">
import { ref, onMounted } from "vue";
import IconRocket from "~/assets/icons/IconRocket.svg?component";

const stats = ref<any>(null);
const loading = ref(true);

const { apiBase, token, getAuthHeader } = useApi();

const fetchStats = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/dashboard/stats`, {
      headers: getAuthHeader(),
    });
    stats.value = data;
  } catch (err) {
    console.error("서버 통신 오류(fetch) stats:", err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchStats);
</script>

<template>
  <div v-if="loading" class="loading">통계를 불러오는 중...</div>
  <div v-else-if="stats" class="teacher-stats">
    <div class="stats-overview">
      <div class="stat-card">
        <span class="label">운영 중인 학급</span>
        <span class="value">{{ stats.classCount }}개</span>
      </div>
      <div class="stat-card">
        <span class="label">관리 학생 수</span>
        <span class="value">{{ stats.studentCount }}명</span>
      </div>
      <div class="stat-card">
        <span class="label">직접 만든 문제</span>
        <span class="value">{{ stats.myQuestions }}개</span>
      </div>
    </div>

    <div class="quick-actions">
      <h3><IconRocket class="section-icon" /> 빠른 실행</h3>
      <div class="action-buttons">
        <button @click="navigateTo('/questions')">새 문제 만들기</button>
        <button @click="navigateTo('/questions')">과제 출제하기</button>
        <button @click="navigateTo('/dashboard')">학생 전체 리포트</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.teacher-stats {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.stats-overview {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.stat-card {
  background: rgba(99, 102, 241, 0.05);
  border: 1px solid rgba(129, 140, 248, 0.2);
  border-radius: 10px;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.stat-card .label {
  color: #94a3b8;
  font-size: 1rem;
}

.stat-card .value {
  font-size: 2.5rem;
  font-weight: 800;
  color: #818cf8;
}

.quick-actions h3 {
  margin-bottom: 1rem;
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

.action-buttons {
  display: flex;
  gap: 1rem;
}

.action-buttons button {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #f8fafc;
  padding: 1rem 1.5rem;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  flex: 1;
}

.action-buttons button:hover {
  background: rgba(129, 140, 248, 0.1);
  border-color: #818cf8;
  transform: translateY(-2px);
}

.loading {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}
</style>
