<script setup lang="ts">
import GroupTreeNode from "~/components/dashboard/GroupTreeNode.vue";
import type { Group } from "~/types";

const props = defineProps<{
  groups: Group[];
  selectedGroupId?: string | number | null;
  expandedIds?: Set<string | number> | null;
  currentUserNo?: string | number | null;
}>();

const emit = defineEmits<{
  (e: "select-group", groupId: string | number | null): void;
}>();
</script>

<template>
  <div class="group-hierarchy">
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
    <div v-if="groups.length === 0" class="no-groups">그룹 정보 없음</div>
  </div>
</template>

<style scoped>
.group-hierarchy {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.no-groups {
  font-size: 0.75rem;
  color: #64748b;
  font-style: italic;
  padding: 0.5rem;
}
</style>
