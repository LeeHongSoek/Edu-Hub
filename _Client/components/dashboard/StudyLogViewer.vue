<script setup lang="ts">
import { ref, onMounted } from "vue";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";

const logs = ref<any[]>([]);
const loading = ref(true);

const { apiBase, token, getAuthHeader } = useApi();

const fetchLogs = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/study-logs/my`, {
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

const formatAction = (memo: string) => {
  if (memo.startsWith("오답")) return { text: memo, class: "action-error" };
  if (memo === "정답") return { text: "정답", class: "action-success" };
  if (memo === "제한시간초과")
    return { text: "시간 초과", class: "action-warning" };
  return { text: memo, class: "action-info" };
};
</script>

<template>
  <div class="log-viewer">
    <div class="header-row">
      <h3><IconCalendar class="section-icon" /> 최근 학습 활동 내역</h3>
      <button class="btn-refresh" @click="fetchLogs">새로고침</button>
    </div>

    <div v-if="loading" class="loading">로그를 불러오는 중...</div>
    <div v-else-if="logs.length === 0" class="empty">
      기록된 학습 활동이 없습니다.
    </div>
    <div v-else class="log-list">
      <div v-for="log in logs" :key="log.log_id" class="log-item">
        <div class="log-time">
          {{
            new Date(log.last_played_at).toLocaleTimeString([], {
              hour: "2-digit",
              minute: "2-digit",
              second: "2-digit",
            })
          }}
        </div>
        <div class="log-question">
          <span class="q-title">{{
            log.question?.title || "알 수 없는 문제"
          }}</span>
          <span class="q-subject" v-if="log.question?.subject">{{
            log.question.subject
          }}</span>
        </div>
        <div class="log-action" :class="formatAction(log.user_memo).class">
          {{ formatAction(log.user_memo).text }}
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.log-viewer {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-row h3 {
  color: #f8fafc;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.section-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.btn-refresh {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #94a3b8;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.85rem;
}

.log-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.log-item {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1rem 1.5rem;
  display: grid;
  grid-template-columns: 100px 1fr 200px;
  align-items: center;
  gap: 1.5rem;
}

.log-time {
  color: #64748b;
  font-size: 0.85rem;
  font-family: monospace;
}

.log-question {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}

.q-title {
  color: #e2e8f0;
  font-weight: 600;
}
.q-subject {
  color: #64748b;
  font-size: 0.75rem;
}

.log-action {
  font-weight: 700;
  font-size: 0.9rem;
  text-align: right;
  padding: 0.3rem 0.8rem;
  border-radius: 6px;
}

.action-info {
  color: #38bdf8;
  background: rgba(56, 189, 248, 0.1);
}
.action-success {
  color: #4ade80;
  background: rgba(74, 222, 128, 0.1);
}
.action-error {
  color: #fb7185;
  background: rgba(251, 113, 133, 0.1);
}
.action-warning {
  color: #fbbf24;
  background: rgba(251, 191, 36, 0.1);
}

.loading,
.empty {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}
</style>
