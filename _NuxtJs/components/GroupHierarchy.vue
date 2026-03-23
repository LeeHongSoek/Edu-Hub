<script setup lang="ts">
import type { Group } from '~/types';
import { computed } from 'vue';

const props = defineProps<{
  groups: Group[];
  selectedGroupId?: string | number | null;
}>();

const emit = defineEmits<{
  (e: 'select-group', groupId: string | number | null): void;
}>();

// 계층형 그룹 트리를 플랫한 리스트 맵으로 변환 (최대 3단계)
const flattenedPaths = computed(() => {
  const paths: { path: string; groupId: string | number }[] = [];
  
  const traverse = (groups: Group[], currentPath: string = '') => {
    for (const group of groups) {
      const newPath = currentPath ? `${currentPath} / ${group.name}` : group.name;
      
      if (!group.child_groups || group.child_groups.length === 0) {
        paths.push({ path: newPath, groupId: group.group_id });
      } else {
        // 중간 계층 그룹도 선택 가능하도록 추가
        paths.push({ path: newPath, groupId: group.group_id });
        traverse(group.child_groups, newPath);
      }
    }
  };
  
  traverse(props.groups);
  return paths;
});
</script>

<template>
  <div class="group-hierarchy">
    <div 
      v-for="(item, index) in flattenedPaths" 
      :key="item.groupId" 
      class="group-path"
      :class="{ 'is-selected': item.groupId === selectedGroupId }"
      @click="emit('select-group', item.groupId)"
    >
      <span class="group-bullet">•</span>
      <span class="path-text">{{ item.path }}</span>
    </div>
    <div v-if="flattenedPaths.length === 0" class="no-groups">
      그룹 정보 없음
    </div>
  </div>
</template>

<style scoped>
.group-hierarchy {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.group-path {
  display: flex;
  align-items: flex-start;
  gap: 0.5rem;
  padding: 0.25rem 0.5rem;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.03);
  transition: all 0.2s;
  cursor: pointer;
  border: 1px solid transparent;
}

.group-path:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(99, 102, 241, 0.3);
}

.group-path.is-selected {
  background: rgba(99, 102, 241, 0.15);
  border-color: #6366f1;
}

.group-path.is-selected .path-text {
  color: #fff;
  font-weight: 600;
}

.group-bullet {
  color: #6366f1;
  font-size: 0.85rem;
  line-height: 1.25rem;
}

.path-text {
  font-size: 0.8rem;
  color: #cbd5e1;
  line-height: 1.25rem;
  word-break: break-all;
}

.no-groups {
  font-size: 0.75rem;
  color: #64748b;
  font-style: italic;
  padding: 0.5rem;
}
</style>
