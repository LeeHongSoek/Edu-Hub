<script setup lang="ts">
import { ref, onMounted } from 'vue';

const relations = ref<any[]>([]);
const loading = ref(true);

const { apiBase, token, getAuthHeader } = useApi();

const fetchRelations = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/dashboard/relations`, {
      headers: getAuthHeader()
    });
    relations.value = data as any[];
  } catch (err) {
    console.error('서버 통신 오류(fetch) relations:', err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchRelations);
</script>

<template>
  <div class="relation-manager">
    <div class="header">
      <h2>👥 나의 인맥 관리</h2>
      <button class="btn-add">+ 친구/연결 추가</button>
    </div>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="relations.length === 0" class="empty">
      연결된 사용자가 없습니다. 친구들이나 선생님을 추가해 보세요!
    </div>
    <div v-else class="relation-list">
      <div v-for="rel in relations" :key="rel.relation_id" class="relation-item">
        <div class="user-avatar">👤</div>
        <div class="user-info">
          <span class="user-name">{{ rel.user2.username }}</span>
          <span class="user-role">{{ rel.user2.role_id === 'T' ? '선생님' : rel.user2.role_id === 'P' ? '학부모' : '학생' }}</span>
        </div>
        <div class="relation-badge">{{ rel.relation_type.description }}</div>
        <button class="btn-msg">메시지</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.relation-manager {
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

.btn-add {
  background: #818cf8;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
}

.relation-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1rem;
}

.relation-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.user-avatar {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.05);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 1.2rem;
}

.user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.user-name {
  font-weight: 700;
  color: #f8fafc;
}

.user-role {
  font-size: 0.8rem;
  color: #94a3b8;
}

.relation-badge {
  font-size: 0.75rem;
  padding: 0.2rem 0.5rem;
  background: rgba(129, 140, 248, 0.1);
  color: #818cf8;
  border-radius: 4px;
}

.btn-msg {
  background: none;
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #94a3b8;
  padding: 0.3rem 0.6rem;
  font-size: 0.8rem;
  border-radius: 4px;
  cursor: pointer;
}

.loading, .empty {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}
</style>
