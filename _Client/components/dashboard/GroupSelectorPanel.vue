<script setup lang="ts">
import GroupHierarchy from "~/components/dashboard/GroupHierarchy.vue";
import IconSettings from "~/assets/icons/IconSettings.svg?component";
import type { Group } from "~/types";

const props = withDefaults(
  defineProps<{
    title: string;
    showManageButton?: boolean;
    selectedGroupBreadcrumb?: string;
    groupSearchInput?: string;
    searchedGroups: { groups: Group[]; expandedIds: Set<string> };
    modelValue?: string | number | null;
    currentUserNo?: string | number | null | (string | number | null)[];
    selectionContext?: "A" | "B" | "C";
    showActions?: boolean;
    showCount?: boolean;
    initialDepth?: number;
    hideTopLevel?: boolean;
    renderFromDepth?: number;
  }>(),
  {
    showManageButton: false,
    selectedGroupBreadcrumb: "",
    groupSearchInput: "",
    modelValue: null,
    currentUserNo: null,
    selectionContext: "A",
    showActions: true,
    showCount: true,
    initialDepth: 0,
    hideTopLevel: false,
    renderFromDepth: 1,
  },
);

const emit = defineEmits<{
  (e: "update:groupSearchInput", value: string): void;
  (e: "select-group", groupId: string | number | null): void;
  (e: "open-manage"): void;
  (e: "clear-selection"): void;
  (e: "close"): void;
}>();
</script>

<template>
  <div class="group-panel" role="dialog" aria-modal="false">
    <div class="group-overlay-header">
      <div class="group-title-row">
        <span v-if="groupSearchInput" class="group-title">{{ title }}</span>
        <div v-if="showManageButton" class="header-actions">
          <button
            class="btn-manage-groups"
            title="그룹 관리"
            @click="emit('open-manage')">
            <IconSettings class="settings-icon" />
            <span class="btn-manage-label">그룹 관리</span>
          </button>
        </div>
      </div>
      <div v-if="groupSearchInput" 
        class="group-breadcrumb"
        v-html="selectedGroupBreadcrumb || '&nbsp;'"
      ></div>
      <div class="group-search">
        <input
          :value="groupSearchInput"
          type="text"
          class="group-search-input"
          placeholder="그룹명 검색"
          @input="
            emit(
              'update:groupSearchInput',
              ($event.target as HTMLInputElement).value,
            )
          "
        />
        <button
          v-if="groupSearchInput"
          class="group-search-clear"
          @click="emit('update:groupSearchInput', '')">
          초기화
        </button>
      </div>
    </div>

    <GroupHierarchy
      :groups="searchedGroups.groups"
      :selected-group-id="modelValue"
      :expanded-ids="searchedGroups.expandedIds"
      :current-user-no="currentUserNo"
      :selection-context="selectionContext"
      :show-count="showCount"
      :initial-depth="initialDepth"
      :hide-top-level="hideTopLevel"
      :render-from-depth="renderFromDepth"
      @select-group="emit('select-group', $event)"
    />
    <div
      v-if="groupSearchInput && searchedGroups.groups.length === 0"
      class="group-search-empty">
      검색 결과가 없습니다.
    </div>

    <div v-if="showActions && groupSearchInput" class="group-modal-actions">
      <button type="button" class="btn-secondary" @click="emit('clear-selection')">
        선택 해제
      </button>
      <button type="button" class="btn-primary" @click="emit('close')">
        닫기
      </button>
    </div>
  </div>
</template>

<style scoped>
.group-panel {
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
  overflow: auto;
  border-radius: 10px;
  padding: 1rem;
  background: rgba(15, 23, 42, 0.01);
}

.group-overlay-header {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
  font-size: 0.95rem;
  color: #f8fafc;
  font-weight: 700;
}

.group-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
}

.group-title {
  display: inline-flex;
  align-items: center;
}

.header-actions {
  display: flex;
  justify-content: flex-end;
}

.btn-manage-groups {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  border: 1px solid rgba(99, 102, 241, 0.45);
  border-radius: 10px;
  background: rgba(99, 102, 241, 0.12);
  color: #c7d2fe;
  font-size: 0.78rem;
  font-weight: 700;
  padding: 0.32rem 0.58rem;
  cursor: pointer;
}

.settings-icon {
  width: 0.78rem;
  height: 0.78rem;
}

.group-breadcrumb {
  min-height: 1.25rem;
  font-size: 0.82rem;
  color: #a5b4fc;
  font-weight: 600;
  overflow-wrap: anywhere;
}

.group-search {
  display: flex;
  align-items: center;
  gap: 0.45rem;
}

.group-search-input {
  flex: 1;
  min-height: 17px;
  border-radius: 10px;
  border: 1px solid rgba(148, 163, 184, 0.25);
  background: rgba(15, 23, 42, 0.72);
  color: #f8fafc;
  padding: 0.25rem 0.7rem;
  font-size: 0.86rem;
  outline: none;
}

.group-search-clear {
  border: 1px solid rgba(99, 102, 241, 0.45);
  border-radius: 10px;
  background: rgba(99, 102, 241, 0.14);
  color: #c7d2fe;
  font-size: 0.75rem;
  font-weight: 700;
  padding: 0.38rem 0.62rem;
  cursor: pointer;
  white-space: nowrap;
}

.group-search-empty {
  color: #94a3b8;
  text-align: center;
  font-size: 0.85rem;
  padding: 0.4rem 0;
}

.group-modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 0.35rem;
}

.btn-secondary,
.btn-primary {
  border: none;
  border-radius: 10px;
  height: 38px;
  padding: 0 0.95rem;
  font-weight: 700;
  cursor: pointer;
}

.btn-secondary {
  background: rgba(148, 163, 184, 0.14);
  color: #cbd5e1;
}

.btn-primary {
  background: rgba(99, 102, 241, 0.92);
  color: #fff;
}
</style>
