<script setup lang="ts">
import { computed, ref } from "vue";
import GroupSelectorPanel from "~/components/dashboard/GroupSelectorPanel.vue";
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
    showCount?: boolean;
    initialDepth?: number;
    hideTopLevel?: boolean;
  }>(),
  {
    modelValue: null,
    title: "문제분류 그룹",
    placeholder: "그룹 선택",
    disabled: false,
    currentUserNo: null,
    selectionContext: "A",
    showManageButton: false,
    showCount: true,
    initialDepth: 0,
    hideTopLevel: false,
  },
);

const emit = defineEmits<{
  (e: "update:modelValue", value: string | number | null): void;
  (e: "open-manage"): void;
}>();

const detailsRef = ref<HTMLDetailsElement | null>(null);
const groupSearchInput = ref("");
const userCookie = useCookie("user_info");

const cookieUserNo = computed(() => {
  if (!userCookie.value) return null;
  try {
    const rawValue =
      typeof userCookie.value === "string"
        ? decodeURIComponent(userCookie.value)
        : userCookie.value;
    const parsed =
      typeof rawValue === "string" ? JSON.parse(rawValue) : rawValue;
    return parsed?.user_no ?? parsed?.userNo ?? null;
  } catch {
    return null;
  }
});

const effectiveUserNo = computed(
  () => props.currentUserNo ?? cookieUserNo.value ?? null,
);

const filterGroupsByOwner = (
  list: Group[],
  ownerNo: string | number | null,
): Group[] => {
  if (ownerNo === null || ownerNo === undefined) return list;

  const matchesOwner = (group: Group) => {
    const creatorNo = (group as any).creator_no ?? (group as any).creator_id;
    return String(creatorNo) === String(ownerNo) || String(creatorNo) === "0";
  };

  const owned: Group[] = [];

  for (const group of list) {
    const childGroups = filterGroupsByOwner(group.child_groups ?? [], ownerNo);
    if (matchesOwner(group)) {
      owned.push({
        ...group,
        child_groups: childGroups,
      });
      continue;
    }

    // 비소유 부모는 보여주지 않고, 소유 자식만 상위로 승격
    if (childGroups.length > 0) {
      owned.push(...childGroups);
    }
  }

  return owned;
};

const filteredGroups = computed(() =>
  filterGroupsByOwner(props.groups, effectiveUserNo.value),
);

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
  const path = findGroupPath(filteredGroups.value, props.modelValue);
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
      groups: filteredGroups.value,
      expandedIds: collectDefaultExpandedIds(filteredGroups.value),
    };
  }
  const { filtered, expandIds } = filterGroupsBySearch(
    filteredGroups.value,
    query,
  );
  return { groups: filtered, expandedIds: expandIds };
});

const closeSelector = () => {
  if (detailsRef.value) {
    detailsRef.value.open = false;
  }
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
  <details ref="detailsRef" class="group-select-dropdown">
    <summary
      class="group-select-trigger"
      :aria-disabled="disabled ? 'true' : 'false'">
      <span class="group-select-value">
        {{ selectedGroupBreadcrumb || placeholder }}
      </span>
      <span class="group-select-chevron">▾</span>
    </summary>

    <div class="group-panel-anchor">
      <GroupSelectorPanel
        :title="title"
        :show-manage-button="showManageButton"
        :selected-group-breadcrumb="selectedGroupBreadcrumb"
        :group-search-input="groupSearchInput"
        :searched-groups="searchedGroups"
        :model-value="modelValue"
        :current-user-no="currentUserNo"
        :selection-context="selectionContext"
        :show-actions="true"
        :show-count="showCount"
        :initial-depth="initialDepth"
        :hide-top-level="hideTopLevel"
        @update:group-search-input="groupSearchInput = $event"
        @select-group="selectGroup"
        @open-manage="emit('open-manage')"
        @clear-selection="clearGroup"
        @close="closeSelector"
      />
    </div>
  </details>
</template>

<style scoped>
.group-select-dropdown {
  position: relative;
  z-index: 1;
  pointer-events: auto;
  min-width: 0;
}

.group-select-dropdown[open] {
  z-index: 40;
}

.group-select-trigger {
  list-style: none;
  -webkit-user-select: none;
  user-select: none;
  position: relative;
  z-index: 2;
  pointer-events: auto;
  width: 100%;
  height: 42px;
  box-sizing: border-box;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  padding: 0 1rem;
  cursor: pointer;
}

.group-select-trigger::-webkit-details-marker {
  display: none;
}

.group-select-dropdown[open] .group-select-chevron {
  transform: rotate(180deg);
}

.group-select-trigger[aria-disabled="true"] {
  opacity: 0.6;
  cursor: not-allowed;
  pointer-events: none;
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

.group-panel-anchor {
  display: none;
  position: absolute;
  top: calc(100% + 0.5rem);
  left: 0;
  right: 0;
  z-index: 100;
  max-height: min(68vh, 560px);
}

.group-select-dropdown[open] .group-panel-anchor {
  display: block;
}
</style>
