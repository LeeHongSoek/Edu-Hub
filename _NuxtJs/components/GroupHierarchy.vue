<script setup lang="ts">
import type { Group } from '~/types';
import { computed } from 'vue';

const props = defineProps<{
  groups: Group[];
}>();

// Transform recursive tree into flat list of full paths (up to 3 levels)
const flattenedPaths = computed(() => {
  const paths: string[] = [];
  
  const traverse = (groups: Group[], currentPath: string = '') => {
    for (const group of groups) {
      const newPath = currentPath ? `${currentPath} / ${group.name}` : group.name;
      
      // We only show the full path if it's a leaf node or if we want to show all possible paths.
      // Usually, showing all "paths" is clearer when the user wants "A / B / C".
      if (!group.child_groups || group.child_groups.length === 0) {
        paths.push(newPath);
      } else {
        // Option 1: Also show intermediate paths (uncomment if needed)
        // paths.push(newPath);
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
    <div v-for="(path, index) in flattenedPaths" :key="index" class="group-path">
      <span class="group-bullet">•</span>
      <span class="path-text">{{ path }}</span>
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
}

.group-path:hover {
  background: rgba(255, 255, 255, 0.08);
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
