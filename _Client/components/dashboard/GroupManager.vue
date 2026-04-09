<script setup lang="ts">
import { ref, onMounted, watch } from "vue";
import type { Group } from "~/types";
import IconClose from "~/assets/icons/IconClose.svg?component";
import IconPencil from "~/assets/icons/IconPencil.svg?component";
import IconTrash from "~/assets/icons/IconTrash.svg?component";

const { apiBase, token, getAuthHeader } = useApi();

const props = defineProps<{
  currentUserNo?: string | number | bigint | null;
}>();

const emit = defineEmits<{
  (e: "close"): void;
  (e: "updated"): void;
}>();

const ROOT_GROUP_ID = "-1";
const fallbackSystemGroups: Group[] = [
  {
    group_id: "-1",
    creator_no: "0",
    name: "전체",
    description: null,
    parent_group_id: null,
    depth: 1,
    question_count: 0,
    question_total: 0,
    child_groups: [
      {
        group_id: "0",
        creator_no: "0",
        name: "문제분류 없음",
        description: null,
        parent_group_id: "-1",
        depth: 1,
        question_count: 0,
        question_total: 0,
        child_groups: [],
      },
    ],
  },
];
const groups = ref<Group[]>([]);
const isSaving = ref(false);
const newGroupName = ref("");
const selectedParentId = ref<string | number | null>(ROOT_GROUP_ID);

const fetchGroups = async () => {
  if (!token.value) {
    groups.value = fallbackSystemGroups;
    return;
  }

  try {
    const params: any = {
      scope: "mine",
      userNo: props.currentUserNo,
    };
    const queryStr = new URLSearchParams(params).toString();
    const data = await $fetch<any>(`/api/groups?${queryStr}`, {
      headers: getAuthHeader(),
    });
    groups.value = data?.groups || [];
  } catch (error) {
    console.error("서버 통신 오류(fetch) groups:", error);
  }
};

onMounted(fetchGroups);

watch(
  () => token.value,
  (nextToken, prevToken) => {
    if (nextToken === prevToken) return;
    void fetchGroups();
  },
);

const findGroup = (list: Group[], id: string | number): Group | null => {
  for (const group of list) {
    if (String(group.group_id) === String(id)) return group;
    const child = findGroup(group.child_groups ?? [], id);
    if (child) return child;
  }
  return null;
};

const isProtectedSystemGroup = (group: Group) => {
  const groupId = String(group.group_id);
  return groupId === "-1" || groupId === "0";
};

const handleAddGroup = async () => {
  if (!newGroupName.value.trim()) return;

  isSaving.value = true;
  try {
    let depth = 1;
    if (selectedParentId.value) {
      if (String(selectedParentId.value) === ROOT_GROUP_ID) {
        depth = 1;
      } else {
        const parentGroup = findGroup(groups.value, selectedParentId.value);
        depth = Number(parentGroup?.depth || 1) + 1;
      }
    }

    if (depth > 4) {
      alert("최대 4단계까지만 생성 가능합니다.");
      return;
    }

    await $fetch(`${apiBase.value}/groups`, {
      method: "POST",
      headers: getAuthHeader(),
      body: {
        name: newGroupName.value,
        parent_group_id: selectedParentId.value ?? ROOT_GROUP_ID,
        depth,
        creator_no: props.currentUserNo,
      },
    });
    newGroupName.value = "";
    selectedParentId.value = ROOT_GROUP_ID;
    await fetchGroups();
    emit("updated");
  } catch (error) {
    console.error("서버 통신 오류(add) group:", error);
  } finally {
    isSaving.value = false;
  }
};

const handleRename = async (group: Group) => {
  const newName = prompt("새 그룹 이름을 입력하세요:", group.name);
  if (!newName || newName === group.name) return;

  try {
    await $fetch(`${apiBase.value}/groups/${group.group_id}`, {
      method: "PATCH",
      headers: getAuthHeader(),
      body: { name: newName },
    });
    await fetchGroups();
    emit("updated");
  } catch (error) {
    console.error("서버 통신 오류(rename) group:", error);
  }
};

const handleDelete = async (group: Group) => {
  if (
    !confirm(
      `'${group.name}' 그룹을 삭제하시겠습니까? 하위 그룹과 소속 문제들도 모두 삭제될 수 있습니다.`,
    )
  )
    return;

  try {
    await $fetch(`${apiBase.value}/groups/${group.group_id}`, {
      method: "DELETE",
      headers: getAuthHeader(),
    });
    await fetchGroups();
    emit("updated");
  } catch (error) {
    console.error("서버 통신 오류(delete) group:", error);
  }
};
</script>

<template>
  <div class="manager-overlay">
    <div class="manager-card">
      <div class="manager-header">
        <h3>문제분류 그룹관리</h3>
        <button class="btn-close" @click="emit('close')">
          <IconClose class="close-icon" />
        </button>
      </div>

      <div class="manager-body">
        <div class="add-group-form">
          <select v-model="selectedParentId" class="parent-select">
            <optgroup v-for="g1 in groups" :key="g1.group_id" :label="g1.name">
              <option :value="g1.group_id">
                {{
                  String(g1.group_id) === ROOT_GROUP_ID
                    ? `${g1.name} 하위 (ROOT)`
                    : `${g1.name} (L1)`
                }}
              </option>
              <template v-for="g2 in g1.child_groups" :key="g2.group_id">
                <option :value="g2.group_id">
                  &nbsp;&nbsp;↳ {{ g2.name }} (L1)
                </option>
                <template v-for="g3 in g2.child_groups" :key="g3.group_id">
                  <option :value="g3.group_id">
                    &nbsp;&nbsp;&nbsp;&nbsp;↳ {{ g3.name }} (L2)
                  </option>
                  <template v-for="g4 in g3.child_groups" :key="g4.group_id">
                    <option :value="g4.group_id">
                      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;↳ {{ g4.name }} (L3)
                    </option>
                  </template>
                </template>
              </template>
            </optgroup>
          </select>
          <input
            v-model="newGroupName"
            type="text"
            placeholder="새 그룹 이름"
            @keyup.enter="handleAddGroup"
          />
          <button
            class="btn-add"
            :disabled="!newGroupName || isSaving"
            @click="handleAddGroup">
            추가
          </button>
        </div>

        <div class="group-tree-admin">
          <div v-for="g1 in groups" :key="g1.group_id" class="admin-item-l1">
            <div class="item-row">
              <span class="depth-badge root">ROOT</span>
              <span class="item-name">{{ g1.name }}</span>
              <div v-if="!isProtectedSystemGroup(g1)" class="item-actions">
                <button @click="handleRename(g1)">
                  <IconPencil class="action-icon" />
                </button>
                <button @click="handleDelete(g1)">
                  <IconTrash class="action-icon" />
                </button>
              </div>
            </div>

            <div
              v-for="g2 in g1.child_groups"
              :key="g2.group_id"
              class="admin-item-l2">
              <div class="item-row">
                <span class="depth-badge l1">L1</span>
                <span class="item-name">{{ g2.name }}</span>
                <div v-if="!isProtectedSystemGroup(g2)" class="item-actions">
                  <button @click="handleRename(g2)">
                    <IconPencil class="action-icon" />
                  </button>
                  <button @click="handleDelete(g2)">
                    <IconTrash class="action-icon" />
                  </button>
                </div>
              </div>

              <div
                v-for="g3 in g2.child_groups"
                :key="g3.group_id"
                class="admin-item-l3">
                <div class="item-row">
                  <span class="depth-badge l2">L2</span>
                  <span class="item-name">{{ g3.name }}</span>
                  <div v-if="!isProtectedSystemGroup(g3)" class="item-actions">
                    <button @click="handleRename(g3)">
                      <IconPencil class="action-icon" />
                    </button>
                    <button @click="handleDelete(g3)">
                      <IconTrash class="action-icon" />
                    </button>
                  </div>
                </div>

                <div
                  v-for="g4 in g3.child_groups"
                  :key="g4.group_id"
                  class="admin-item-l4">
                  <div class="item-row">
                    <span class="depth-badge l3">L3</span>
                    <span class="item-name">{{ g4.name }}</span>
                    <div
                      v-if="!isProtectedSystemGroup(g4)"
                      class="item-actions">
                      <button @click="handleRename(g4)">
                        <IconPencil class="action-icon" />
                      </button>
                      <button @click="handleDelete(g4)">
                        <IconTrash class="action-icon" />
                      </button>
                    </div>
                  </div>

                  <div
                    v-for="g5 in g4.child_groups"
                    :key="g5.group_id"
                    class="admin-item-l5">
                    <div class="item-row">
                      <span class="depth-badge l4">L4</span>
                      <span class="item-name">{{ g5.name }}</span>
                      <div
                        v-if="!isProtectedSystemGroup(g5)"
                        class="item-actions">
                        <button @click="handleRename(g5)">
                          <IconPencil class="action-icon" />
                        </button>
                        <button @click="handleDelete(g5)">
                          <IconTrash class="action-icon" />
                        </button>
                      </div>
                    </div>
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

.add-group-form input,
.add-group-form select {
  background: rgba(15, 23, 42, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #fff;
  padding: 0.5rem;
  border-radius: 10px;
  font-size: 0.9rem;
}

.add-group-form input {
  flex: 1;
}
.add-group-form select {
  flex: 1;
  max-width: 150px;
}

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
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 10px;
  width: 2rem;
  height: 2rem;
  cursor: pointer;
  color: #e2e8f0;
  transition:
    background 0.2s,
    border-color 0.2s,
    color 0.2s,
    transform 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.item-actions button:hover {
  background: rgba(99, 102, 241, 0.12);
  border-color: rgba(129, 140, 248, 0.45);
  color: #ffffff;
  transform: translateY(-1px);
}

.depth-badge {
  font-size: 0.65rem;
  padding: 0.1rem 0.4rem;
  border-radius: 4px;
  font-weight: 700;
}

.root {
  background: rgba(99, 102, 241, 0.2);
  color: #c4b5fd;
}
.l1 {
  background: rgba(16, 185, 129, 0.2);
  color: #34d399;
}
.l2 {
  background: rgba(245, 158, 11, 0.2);
  color: #fbbf24;
}
.l3 {
  background: rgba(34, 197, 94, 0.2);
  color: #86efac;
}
.l4 {
  background: rgba(236, 72, 153, 0.2);
  color: #f9a8d4;
}

.admin-item-l2 {
  margin-left: 1.5rem;
  border-left: 1px dashed rgba(255, 255, 255, 0.1);
}
.admin-item-l3 {
  margin-left: 1.5rem;
}
.admin-item-l4 {
  margin-left: 1.5rem;
}
.admin-item-l5 {
  margin-left: 1.5rem;
}
</style>
