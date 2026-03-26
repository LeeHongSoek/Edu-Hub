<script setup lang="ts">
import { ref, onMounted } from 'vue';

const messages = ref<any[]>([]);
const loading = ref(true);

const { apiBase, token, getAuthHeader } = useApi();

const fetchMessages = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/dashboard/messages`, {
      headers: getAuthHeader()
    });
    messages.value = data as any[];
  } catch (err) {
    console.error('서버 통신 오류(fetch) messages:', err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchMessages);
</script>

<template>
  <div class="message-manager">
    <div class="header">
      <h2>💬 메시지 함</h2>
      <button class="btn-new">새 메시지 작성</button>
    </div>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="messages.length === 0" class="empty">
      메시지 내역이 없습니다.
    </div>
    <div v-else class="message-list">
      <div v-for="msg in messages" :key="msg.message_id" class="message-item">
        <div class="msg-header">
          <span class="msg-author">{{ msg.sender.username }}</span>
          <span class="msg-date">{{ new Date(msg.created_at).toLocaleString() }}</span>
        </div>
        <p class="msg-content">{{ msg.content }}</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.message-manager {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header h2 {
  font-size: 1.25rem;
  color: #f8fafc;
}

.btn-new {
  background: #c084fc;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
}

.message-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.message-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1.2rem;
}

.msg-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.7rem;
}

.msg-author {
  font-weight: 700;
  color: #e2e8f0;
}

.msg-date {
  font-size: 0.8rem;
  color: #64748b;
}

.msg-content {
  color: #cbd5e1;
  line-height: 1.5;
  word-break: break-all;
}

.loading, .empty {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}
</style>
