<!--
파일 개요:
- 역할: 그룹 선택 드롭다운과 선택 패널을 연결하는 래퍼 컴포넌트입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { computed, ref } from "vue";
import CmmGroupSelector from "~/components/CmmGroupSelector.vue";
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
    renderFromDepth?: number;
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
    renderFromDepth: 2,
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
  ownerNo: string | number | null | (string | number | null)[],
): Group[] => {
  const owners = Array.isArray(ownerNo) ? ownerNo : [ownerNo];
  const validOwners = owners.filter(o => o !== null && o !== undefined).map(String);
  if (validOwners.length === 0) return list;

  const matchesOwner = (group: Group) => {
    const creatorNo = (group as any).creator_no ?? (group as any).creator_id;
    return validOwners.includes(String(creatorNo));
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
  filterGroupsByOwner(props.groups, [effectiveUserNo.value, 0]),
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
      :title="selectedGroupBreadcrumb || placeholder"
      :aria-label="title"
      :aria-disabled="disabled ? 'true' : 'false'">
      <span
        class="group-select-value"
        :class="{ 'is-placeholder': !selectedGroupBreadcrumb }">
        {{ selectedGroupBreadcrumb || placeholder }}
      </span>
      <span class="group-select-right">
        <span v-if="!selectedGroupBreadcrumb" class="group-select-hint">
          클릭하여 선택
        </span>
        <span class="group-select-chevron" aria-hidden="true">▾</span>
      </span>
    </summary>

    <div class="group-panel-anchor">
      <CmmGroupSelector
        :title="title"
        :show-manage-button="showManageButton"
        :selected-group-breadcrumb="selectedGroupBreadcrumb"
        :group-search-input="groupSearchInput"
        :searched-groups="searchedGroups"
        :model-value="modelValue"
        :current-user-no="[currentUserNo ?? null, 0]"
        :selection-context="selectionContext"
        :show-actions="true"
        :show-count="showCount"
        :initial-depth="initialDepth"
        :hide-top-level="hideTopLevel"
        :render-from-depth="renderFromDepth"
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
  max-width: 400px;
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
  transition:
    border-color 0.2s ease,
    background-color 0.2s ease,
    box-shadow 0.2s ease;
}

.group-select-trigger:hover {
  border-color: rgba(129, 140, 248, 0.6);
  background: rgba(129, 140, 248, 0.08);
}

.group-select-trigger:focus-visible {
  outline: none;
  border-color: rgba(99, 102, 241, 0.9);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.22);
}

.group-select-dropdown[open] .group-select-trigger {
  border-color: rgba(99, 102, 241, 0.9);
  background: rgba(99, 102, 241, 0.1);
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
  flex: 1;
  text-align: left;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.group-select-value.is-placeholder {
  color: #94a3b8;
}

.group-select-right {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.group-select-hint {
  font-size: 0.72rem;
  color: #94a3b8;
  font-weight: 600;
  white-space: nowrap;
}

.group-select-chevron {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.3rem;
  height: 1.3rem;
  color: #c7d2fe;
  font-size: 0.9rem;
  line-height: 1;
  border-radius: 999px;
  background: rgba(99, 102, 241, 0.25);
  transition: transform 0.2s ease;
}

.group-panel-anchor {
  display: none;
  position: absolute;
  top: calc(100% + 0.5rem);
  left: 0;
  right: 0;
  z-index: 100;
  max-height: min(68vh, 560px);
  max-width: 400px;
  background: #1e293b;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
}

.group-select-dropdown[open] .group-panel-anchor {
  display: block;
}
</style>
