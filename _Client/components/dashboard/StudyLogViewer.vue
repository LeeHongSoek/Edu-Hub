<script setup lang="ts">
import { ref, onMounted } from "vue";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconBook from "~/assets/icons/IconBook.svg?component";
import IconPencil from "~/assets/icons/IconPencil.svg?component";

const logs = ref<any[]>([]);
const loading = ref(true);

const { apiBase, token, getAuthHeader } = useApi();

const fetchLogs = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/user-logs/my`, {
      headers: getAuthHeader(),
    });
    logs.value = data as any[];
  } catch (err) {
    console.error("서버 통신 오류(fetch) logs:", err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchLogs);

const getLogTypeInfo = (type: string) => {
  switch (type) {
    case 'Q':
      return { icon: IconFileText, label: '문제', color: '#6366f1' };
    case 'B':
      return { icon: IconBook, label: '문제집', color: '#10b981' };
    case 'E':
      return { icon: IconPencil, label: '고사', color: '#f59e0b' };
    default:
      return { icon: IconFileText, label: '기타', color: '#94a3b8' };
  }
};

const formatResult = (log: any) => {
  if (log.logtype === 'Q') {
    if (log.user_content.includes('정답')) return { text: '정답', class: 'result-success' };
    if (log.user_content.includes('오답')) return { text: '오답', class: 'result-error' };
    return { text: log.user_content || '조회', class: 'result-info' };
  }
  
  // For Book/Exam, show score/total (score100)
  const scoreText = `${log.score}/${log.total_score}`;
  const percentText = log.score100 !== undefined ? `(${log.score100}점)` : '';
  return { 
    text: `${scoreText} ${percentText}`, 
    class: log.score100 >= 80 ? 'result-success' : log.score100 >= 60 ? 'result-warning' : 'result-error' 
  };
};

const formatTime = (dateStr: string) => {
  const date = new Date(dateStr);
  return date.toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit",
  });
};
</script>

<template>
  <div class="log-viewer">
    <div class="header-row">
      <h3><IconCalendar class="section-icon" /> 최근 학습 활동 내역</h3>
    </div>

    <div v-if="loading" class="loading-container">
      <div class="loader"></div>
      <span>로그를 불러오는 중...</span>
    </div>
    
    <div v-else-if="logs.length === 0" class="empty-state">
      <IconCalendar class="empty-icon" />
      <p>기록된 학습 활동이 없습니다.</p>
    </div>

    <div v-else class="log-list">
      <div v-for="log in logs" :key="log.log_id" class="log-card">
        <div class="log-type-indicator" :style="{ backgroundColor: getLogTypeInfo(log.logtype).color }">
          <component :is="getLogTypeInfo(log.logtype).icon" class="type-icon" />
        </div>
        
        <div class="log-main-info">
          <div class="log-top">
            <span class="log-type-label">{{ getLogTypeInfo(log.logtype).label }}</span>
            <span class="log-time">{{ formatTime(log.last_played_at) }}</span>
          </div>
          <div class="log-title">{{ log.title }}</div>
        </div>

        <div class="log-result" :class="formatResult(log).class">
          {{ formatResult(log).text }}
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.log-viewer {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.header-row h3 {
  color: #f8fafc;
  font-size: 1.1rem;
  font-weight: 700;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.section-icon {
  width: 1.1rem;
  height: 1.1rem;
  color: #818cf8;
}

.log-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.log-card {
  background: rgba(30, 41, 59, 0.4);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 0.85rem 1.25rem;
  display: flex;
  align-items: center;
  gap: 1.25rem;
  transition: all 0.2s ease;
}

.log-card:hover {
  background: rgba(30, 41, 59, 0.6);
  transform: translateX(4px);
  border-color: rgba(129, 140, 248, 0.2);
}

.log-type-indicator {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
}

.type-icon {
  width: 1.1rem;
  height: 1.1rem;
  color: white;
}

.log-main-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  min-width: 0;
}

.log-top {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.log-type-label {
  font-size: 0.7rem;
  font-weight: 700;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.log-time {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 500;
}

.log-title {
  font-size: 0.95rem;
  font-weight: 600;
  color: #e2e8f0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.log-result {
  font-size: 0.85rem;
  font-weight: 700;
  padding: 0.35rem 0.75rem;
  border-radius: 8px;
  min-width: 80px;
  text-align: center;
}

.result-info {
  background: rgba(56, 189, 248, 0.1);
  color: #38bdf8;
}

.result-success {
  background: rgba(16, 185, 129, 0.1);
  color: #10b981;
}

.result-error {
  background: rgba(244, 63, 94, 0.1);
  color: #f43f5e;
}

.result-warning {
  background: rgba(245, 158, 11, 0.1);
  color: #f59e0b;
}

/* Loading & Empty States */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
  gap: 1rem;
  color: #64748b;
}

.loader {
  width: 24px;
  height: 24px;
  border: 2px solid rgba(129, 140, 248, 0.2);
  border-top-color: #818cf8;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 5rem 2rem;
  color: #475569;
  gap: 0.75rem;
}

.empty-icon {
  width: 3rem;
  height: 3rem;
  opacity: 0.2;
}

.empty-state p {
  margin: 0;
  font-size: 1rem;
}
</style>
