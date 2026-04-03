<script setup lang="ts">
import GroupTreeNode from "~/components/dashboard/GroupTreeNode.vue";
import type { Group } from "~/types";

const props = defineProps<{
  groups: Group[];
  selectedGroupId?: string | number | null;
  expandedIds?: Set<string | number> | null;
  currentUserNo?: string | number | null;
  unassignedCount?: number;
}>();

const emit = defineEmits<{
  (e: "select-group", groupId: string | number | null): void;
}>();
</script>

<template>
  <div class="group-hierarchy">
    <!-- 미분류 문제 노드 (디자인 일관성을 위해 내부에 배치) -->
    <div
      v-if="typeof unassignedCount === 'number'"
      class="node-content special-node"
      :class="{ 'is-selected': selectedGroupId === -1 }"
      @click="emit('select-group', -1)"
    >
      <span class="bullet">•</span>
      <span class="name-text">
        문제 분류 없음
        <span class="count-pill">({{ unassignedCount }}개)</span>
      </span>
    </div>

    <GroupTreeNode
      v-for="group in groups"
      :key="group.group_id"
      :group="group"
      :selected-group-id="selectedGroupId"
      :expanded-ids="expandedIds"
      :current-user-no="currentUserNo"
      :depth="0"
      @select-group="emit('select-group', $event)"
    />
    <div v-if="groups.length === 0 && (typeof unassignedCount !== 'number' || unassignedCount === 0)" class="no-groups">
      그룹 정보 없음
    </div>
  </div>
</template>

<style scoped>
.group-hierarchy {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

/* GroupTreeNode와 동일한 디자인 코드를 공유 */
.node-content {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.25rem 0.5rem;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.03);
  transition: all 0.2s;
  cursor: pointer;
  border: 1px solid rgba(255, 255, 255, 0.08);
  margin-bottom: 0.25rem;
}

.node-content:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(99, 102, 241, 0.3);
}

.node-content.is-selected {
  background: rgba(99, 102, 241, 0.15);
  border-color: #6366f1;
}

.node-content.is-selected .name-text {
  color: #fff;
  font-weight: 600;
}

.bullet {
  color: #6366f1;
  font-size: 0.85rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.2rem;
  height: 1.2rem;
  text-align: center;
}

.name-text {
  font-size: 0.8rem;
  color: #cbd5e1;
  line-height: 1.25rem;
  word-break: break-all;
  display: inline-flex;
  align-items: baseline;
  gap: 0.28rem;
}

.count-pill {
  color: #a5b4fc;
  font-weight: 700;
  font-size: 0.75rem;
}

.special-node {
  background: rgba(99, 102, 241, 0.06);
  border-color: rgba(99, 102, 241, 0.15);
}

.no-groups {
  font-size: 0.75rem;
  color: #64748b;
  font-style: italic;
  padding: 0.5rem;
}
</style>
