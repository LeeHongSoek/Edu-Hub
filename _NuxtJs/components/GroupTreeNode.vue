<script setup lang="ts">
import type { Group } from '~/types';
import { ref } from 'vue';

const props = defineProps<{
  group: Group;
  selectedGroupId?: string | number | null;
  depth: number;
}>();

const emit = defineEmits<{
  (e: 'select-group', groupId: string | number | null): void;
}>();

const isExpanded = ref(false); // 기본적으로 접힌 상태

const toggleExpand = (event: Event) => {
  event.stopPropagation(); // 그룹 선택 이벤트와 분리
  isExpanded.value = !isExpanded.value;
};
</script>

<template>
  <div class="tree-node" :style="{ paddingLeft: `${depth * 0.5}rem` }">
    <div 
      class="node-content"
      :class="{ 'is-selected': group.group_id === selectedGroupId }"
      @click="emit('select-group', group.group_id)"
    >
      <span 
        v-if="group.child_groups && group.child_groups.length > 0" 
        class="toggle-icon" 
        :class="{ 'is-expanded': isExpanded }"
        @click="toggleExpand"
      >
        ▶
      </span>
      <span v-else class="bullet">•</span>
      <span class="name-text">{{ group.name }}</span>
    </div>

    <div v-if="isExpanded && group.child_groups && group.child_groups.length > 0" class="child-nodes">
      <GroupTreeNode 
        v-for="child in group.child_groups" 
        :key="child.group_id"
        :group="child"
        :selected-group-id="selectedGroupId"
        :depth="depth + 1"
        @select-group="emit('select-group', $event)"
      />
    </div>
  </div>
</template>

<style scoped>
.tree-node {
  display: flex;
  flex-direction: column;
}

.node-content {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.03);
  transition: all 0.2s;
  cursor: pointer;
  border: 1px solid transparent;
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

.toggle-icon {
  font-size: 0.75rem; /* 기본 0.6에서 20% 이상 확대 */
  color: #94a3b8; /* 기존보다 살짝 밝게 */
  transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275), color 0.2s;
  display: inline-block;
  width: 1.2rem;
  text-align: center;
}

.toggle-icon:hover {
  color: #ababc6; /* 마우스 오버 시 완전 밝게 */
  transform: scale(1.7); /* 살짝 더 커짐 */
}

.toggle-icon.is-expanded {
  transform: rotate(90deg);
}

.toggle-icon.is-expanded:hover {
  transform: rotate(90deg) scale(1.3);
}

.bullet {
  color: #6366f1;
  font-size: 0.85rem;
  display: inline-block;
  width: 1rem;
  text-align: center;
}

.name-text {
  font-size: 0.8rem;
  color: #cbd5e1;
  line-height: 1.25rem;
  word-break: break-all;
}

.child-nodes {
  display: flex;
  flex-direction: column;
}
</style>
