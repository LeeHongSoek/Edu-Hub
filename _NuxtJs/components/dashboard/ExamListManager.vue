<script setup lang="ts">
import { ref, onMounted } from 'vue';

const exams = ref<any[]>([]);
const loading = ref(true);

const { apiBase, token, getAuthHeader } = useApi();

const fetchExams = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/exams`, {
      headers: getAuthHeader()
    });
    exams.value = data as any[];
  } catch (err) {
    console.error('서버 통신 오류(fetch) exams:', err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchExams);
</script>

<template>
  <div class="exam-manager">
    <h3>📝 나의 고사집 목록</h3>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="exams.length === 0" class="empty">참여 중인 고사가 없습니다.</div>
    <div v-else class="exam-list">
      <div v-for="exam in exams" :key="exam.exam_id" class="exam-card">
        <div class="exam-info">
          <div class="exam-badge">고사</div>
          <h4>{{ exam.exam_name }}</h4>
          <div class="exam-period">
            {{ new Date(exam.start_time).toLocaleDateString() }} ~ {{ new Date(exam.end_time).toLocaleDateString() }}
          </div>
        </div>
        <button class="btn-start" disabled>자세히 보기 (준비중)</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.exam-manager { display: flex; flex-direction: column; gap: 1.5rem; }
.exam-manager h3 { color: #f8fafc; margin: 0; }

.exam-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.exam-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1.25rem 1.5rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.exam-info { display: flex; flex-direction: column; gap: 0.4rem; }
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
.exam-info h4 { color: #f8fafc; margin: 0; font-size: 1.1rem; }
.exam-period { color: #64748b; font-size: 0.85rem; }

.btn-start {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #94a3b8;
  padding: 0.6rem 1.2rem;
  border-radius: 10px;
  cursor: pointer;
}

.loading, .empty { text-align: center; padding: 3rem; color: #64748b; }
</style>
