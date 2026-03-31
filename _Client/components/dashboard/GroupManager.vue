<script setup lang="ts">
import { ref, onMounted } from 'vue';
import type { Group } from '~/types';
import IconClose from '~/assets/icons/IconClose.svg?component';
import IconPencil from '~/assets/icons/IconPencil.svg?component';
import IconTrash from '~/assets/icons/IconTrash.svg?component';

const { apiBase, token, getAuthHeader } = useApi();

const emit = defineEmits<{
  (e: 'close'): void;
  (e: 'updated'): void;
}>();

const groups = ref<Group[]>([]);
const isSaving = ref(false);
const newGroupName = ref('');
const selectedParentId = ref<string | number | null>(null);

const fetchGroups = async () => {
  try {
    groups.value = await $fetch<Group[]>(`${apiBase.value}/groups`);
  } catch (error) {
    console.error('서버 통신 오류(fetch) groups:', error);
  }
};

onMounted(fetchGroups);

const handleAddGroup = async () => {
  if (!newGroupName.value.trim()) return;
  
  isSaving.value = true;
  try {
    let depth = 1;
    if (selectedParentId.value) {
      // Find parent depth
      const findDepth = (gs: Group[], id: string | number, currentDepth: number): number | null => {
        for (const g of gs) {
          if (String(g.group_id) === String(id)) return currentDepth;
          if (g.child_groups) {
            const d = findDepth(g.child_groups, id, currentDepth + 1);
            if (d) return d;
          }
        }
        return null;
      };
      const parentDepth = findDepth(groups.value, selectedParentId.value, 1);
      depth = (parentDepth || 1) + 1;
    }

    if (depth > 3) {
      alert('최대 3단계까지만 생성 가능합니다.');
      return;
    }

    await $fetch(`${apiBase.value}/groups`, {
      method: 'POST',
      body: {
        name: newGroupName.value,
        parent_group_id: selectedParentId.value,
        depth,
        creator_no: 1 // TODO: dynamic user ID
      }
    });
    newGroupName.value = '';
    await fetchGroups();
    emit('updated');
  } catch (error) {
    console.error('서버 통신 오류(add) group:', error);
  } finally {
    isSaving.value = false;
  }
};

const handleRename = async (group: Group) => {
  const newName = prompt('새 그룹 이름을 입력하세요:', group.name);
  if (!newName || newName === group.name) return;

  try {
    await $fetch(`${apiBase.value}/groups/${group.group_id}`, {
      method: 'PATCH',
      body: { name: newName }
    });
    await fetchGroups();
    emit('updated');
  } catch (error) {
    console.error('서버 통신 오류(rename) group:', error);
  }
};

const handleDelete = async (group: Group) => {
  if (!confirm(`'${group.name}' 그룹을 삭제하시겠습니까? 하위 그룹과 소속 문제들도 모두 삭제될 수 있습니다.`)) return;

  try {
    await $fetch(`${apiBase.value}/groups/${group.group_id}`, {
      method: 'DELETE'
    });
    await fetchGroups();
    emit('updated');
  } catch (error) {
    console.error('서버 통신 오류(delete) group:', error);
  }
};
</script>

<template>
  <div class="manager-overlay">
    <div class="manager-card">
      <div class="manager-header">
        <h3>전체 그룹 관리</h3>
        <button class="btn-close" @click="emit('close')">
          <IconClose class="close-icon" />
        </button>
      </div>

      <div class="manager-body">
        <div class="add-group-form">
          <select v-model="selectedParentId" class="parent-select">
            <option :value="null">최상위 그룹으로 추가</option>
            <optgroup v-for="g1 in groups" :key="g1.group_id" :label="g1.name">
              <option :value="g1.group_id">{{ g1.name }} (L1)</option>
              <template v-for="g2 in g1.child_groups" :key="g2.group_id">
                <option :value="g2.group_id">&nbsp;&nbsp;↳ {{ g2.name }} (L2)</option>
              </template>
            </optgroup>
          </select>
          <input v-model="newGroupName" type="text" placeholder="새 그룹 이름" @keyup.enter="handleAddGroup" />
          <button class="btn-add" :disabled="!newGroupName || isSaving" @click="handleAddGroup">추가</button>
        </div>

        <div class="group-tree-admin">
          <div v-for="g1 in groups" :key="g1.group_id" class="admin-item-l1">
            <div class="item-row">
              <span class="depth-badge l1">L1</span>
              <span class="item-name">{{ g1.name }}</span>
              <div class="item-actions">
                <button @click="handleRename(g1)"><IconPencil class="action-icon" /></button>
                <button @click="handleDelete(g1)"><IconTrash class="action-icon" /></button>
              </div>
            </div>
            
            <div v-for="g2 in g1.child_groups" :key="g2.group_id" class="admin-item-l2">
              <div class="item-row">
                <span class="depth-badge l2">L2</span>
                <span class="item-name">{{ g2.name }}</span>
                <div class="item-actions">
                  <button @click="handleRename(g2)"><IconPencil class="action-icon" /></button>
                  <button @click="handleDelete(g2)"><IconTrash class="action-icon" /></button>
                </div>
              </div>

              <div v-for="g3 in g2.child_groups" :key="g3.group_id" class="admin-item-l3">
                <div class="item-row">
                  <span class="depth-badge l3">L3</span>
                  <span class="item-name">{{ g3.name }}</span>
                  <div class="item-actions">
                    <button @click="handleRename(g3)"><IconPencil class="action-icon" /></button>
                    <button @click="handleDelete(g3)"><IconTrash class="action-icon" /></button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.manager-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.8);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2500;
  padding: 2rem;
}

.manager-card {
  background: #1e293b;
  width: 100%;
  max-width: 600px;
  max-height: 80vh;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
}

.manager-header {
  padding: 1.25rem 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.manager-header h3 {
  margin: 0;
  font-size: 1.1rem;
  color: #fff;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  cursor: pointer;
}

.close-icon,
.action-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.manager-body {
  padding: 1.5rem;
  overflow-y: auto;
}

.add-group-form {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 2rem;
  background: rgba(255, 255, 255, 0.03);
  padding: 1rem;
  border-radius: 10px;
}

.add-group-form input, .add-group-form select {
  background: rgba(15, 23, 42, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #fff;
  padding: 0.5rem;
  border-radius: 10px;
  font-size: 0.9rem;
}

.add-group-form input { flex: 1; }
.add-group-form select { flex: 1; max-width: 150px; }

.btn-add {
  padding: 0.5rem 1rem;
  background: #6366f1;
  color: #fff;
  border: none;
  border-radius: 10px;
  cursor: pointer;
}

.group-tree-admin {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.item-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.6rem 1rem;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  margin-bottom: 0.25rem;
}

.item-name {
  flex: 1;
  color: #cbd5e1;
  font-size: 0.95rem;
}

.item-actions {
  display: flex;
  gap: 0.5rem;
}

.item-actions button {
  background: none;
  border: none;
  cursor: pointer;
  filter: grayscale(1);
  transition: filter 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.item-actions button:hover {
  filter: grayscale(0);
}

.depth-badge {
  font-size: 0.65rem;
  padding: 0.1rem 0.4rem;
  border-radius: 4px;
  font-weight: 700;
}

.l1 { background: rgba(99, 102, 241, 0.2); color: #818cf8; }
.l2 { background: rgba(16, 185, 129, 0.2); color: #34d399; }
.l3 { background: rgba(245, 158, 11, 0.2); color: #fbbf24; }

.admin-item-l2 { margin-left: 1.5rem; border-left: 1px dashed rgba(255, 255, 255, 0.1); }
.admin-item-l3 { margin-left: 1.5rem; }
</style>
