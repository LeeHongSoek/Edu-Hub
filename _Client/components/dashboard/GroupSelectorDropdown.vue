<script setup lang="ts">
import { computed, ref } from "vue";
import GroupHierarchy from "~/components/dashboard/GroupHierarchy.vue";
import IconSettings from "~/assets/icons/IconSettings.svg?component";
import type { Group } from "~/types";

const props = withDefaults(
  defineProps<{
    modelValue?: string | number | null;
    groups: Group[];
    title?: string;
    placeholder?: string;
    disabled?: boolean;
    currentUserNo?: string | number | null;
    selectionContext?: "A" | "B" | "C";
    showManageButton?: boolean;
  }>(),
  {
    modelValue: null,
    title: "문제분류 그룹",
    placeholder: "그룹 선택",
    disabled: false,
    currentUserNo: null,
    selectionContext: "A",
    showManageButton: false,
  },
);

const emit = defineEmits<{
  (e: "update:modelValue", value: string | number | null): void;
  (e: "open-manage"): void;
}>();

const isOpen = ref(false);
const groupSearchInput = ref("");

const findGroupPath = (
  list: Group[],
  targetId: string | number,
  trail: string[] = [],
): string[] | null => {
  for (const group of list) {
    const nextTrail = [...trail, group.name];
    if (String(group.group_id) === String(targetId)) {
      return nextTrail;
    }
    if (group.child_groups && group.child_groups.length > 0) {
      const found = findGroupPath(group.child_groups, targetId, nextTrail);
      if (found) return found;
    }
  }
  return null;
};

const selectedGroupBreadcrumb = computed(() => {
  if (props.modelValue === null || props.modelValue === undefined) {
    return "";
  }
  const path = findGroupPath(props.groups, props.modelValue);
  if (!path || path.length === 0) return "";
  return path.join(" / ");
});

const filterGroupsBySearch = (list: Group[], query: string) => {
  const expandIds = new Set<string>();

  const visit = (group: Group, ancestors: Group[]): Group | null => {
    const nameMatch = group.name.toLowerCase().includes(query);
    const children = group.child_groups
      ? group.child_groups
          .map((child) => visit(child, [...ancestors, group]))
          .filter((child): child is Group => Boolean(child))
      : [];

    if (!nameMatch && children.length === 0) return null;

    if (nameMatch) {
      for (const ancestor of ancestors) {
        expandIds.add(String(ancestor.group_id));
      }
      expandIds.add(String(group.group_id));
    }

    if (children.length > 0) {
      expandIds.add(String(group.group_id));
    }

    return { ...group, child_groups: children };
  };

  const filtered = list
    .map((group) => visit(group, []))
    .filter((group): group is Group => Boolean(group));

  return { filtered, expandIds };
};

const collectDefaultExpandedIds = (list: Group[]) => {
  const expandIds = new Set<string>();
  for (const group of list) {
    expandIds.add(String(group.group_id));
  }
  return expandIds;
};

const searchedGroups = computed(() => {
  const query = groupSearchInput.value.trim().toLowerCase();
  if (!query) {
    return {
      groups: props.groups,
      expandedIds: collectDefaultExpandedIds(props.groups),
    };
  }
  const { filtered, expandIds } = filterGroupsBySearch(props.groups, query);
  return { groups: filtered, expandedIds: expandIds };
});

const openSelector = () => {
  if (props.disabled) return;
  isOpen.value = true;
};

const closeSelector = () => {
  isOpen.value = false;
  groupSearchInput.value = "";
};

const selectGroup = (groupId: string | number | null) => {
  emit("update:modelValue", groupId);
  closeSelector();
};

const clearGroup = () => {
  emit("update:modelValue", null);
  closeSelector();
};
</script>

<template>
  <div class="group-select-dropdown">
    <button
      type="button"
      class="group-select-trigger"
      :disabled="disabled"
      @click.stop.prevent="openSelector">
      <span class="group-select-value">
        {{ selectedGroupBreadcrumb || placeholder }}
      </span>
      <span class="group-select-chevron">▾</span>
    </button>

    <Teleport to="body">
      <Transition name="group-fade">
        <div v-if="isOpen" class="group-modal-overlay" @click.self="closeSelector">
          <div class="group-modal-card" role="dialog" aria-modal="true">
            <div class="group-overlay-header">
              <span>{{ title }}</span>
              <div v-if="showManageButton" class="header-actions">
                <button
                  class="btn-manage-groups"
                  title="그룹 관리"
                  @click="emit('open-manage')">
                  <IconSettings class="settings-icon" />
                  <span class="btn-manage-label">그룹 관리</span>
                </button>
              </div>
              <div
                class="group-breadcrumb"
                v-html="selectedGroupBreadcrumb || '&nbsp;'"
              ></div>
              <div class="group-search">
                <input
                  v-model="groupSearchInput"
                  type="text"
                  class="group-search-input"
                  placeholder="그룹명 검색"
                />
                <button
                  v-if="groupSearchInput"
                  class="group-search-clear"
                  @click="groupSearchInput = ''">
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
              @select-group="selectGroup"
            />
            <div
              v-if="groupSearchInput && searchedGroups.groups.length === 0"
              class="group-search-empty">
              검색 결과가 없습니다.
            </div>

            <div class="group-modal-actions">
              <button type="button" class="btn-secondary" @click="clearGroup">
                선택 해제
              </button>
              <button type="button" class="btn-primary" @click="closeSelector">
                닫기
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<style scoped>
.group-select-trigger {
  width: 100%;
  min-height: 44px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  padding: 0.75rem 1rem;
  cursor: pointer;
}

.group-select-trigger:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.group-select-value {
  text-align: left;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.group-select-chevron {
  color: #a5b4fc;
  font-size: 0.9rem;
}

.group-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 23, 0.68);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  z-index: 3000;
}

.group-modal-card {
  width: min(680px, 100%);
  max-height: min(78vh, 720px);
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
  overflow: auto;
  background: linear-gradient(180deg, #0f1b37 0%, #0a1530 100%);
  border: 1px solid rgba(79, 70, 229, 0.35);
  border-radius: 10px;
  padding: 1rem;
}

.group-overlay-header {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
  font-size: 0.95rem;
  color: #f8fafc;
  font-weight: 700;
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
  min-height: 34px;
  border-radius: 10px;
  border: 1px solid rgba(148, 163, 184, 0.25);
  background: rgba(15, 23, 42, 0.72);
  color: #f8fafc;
  padding: 0.5rem 0.7rem;
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

.group-fade-enter-active,
.group-fade-leave-active {
  transition: opacity 0.2s ease;
}

.group-fade-enter-from,
.group-fade-leave-to {
  opacity: 0;
}
</style>
