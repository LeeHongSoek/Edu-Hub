<!--
파일 개요:
- 역할: 그룹 계층 트리의 단일 노드를 렌더링하는 컴포넌트입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { ref, watchEffect, computed } from "vue";
import type { Group } from "~/types";
import IconArrowRight from "~/assets/icons/IconArrowRight.svg?component";

defineOptions({
  name: "GroupTreeNode",
});

const props = withDefaults(
  defineProps<{
    group: Group;
    selectedGroupId?: string | number | null;
    depth: number;
    expandedIds?: Set<string | number> | null;
    currentUserNo?: string | number | null | (string | number | null)[];
    inheritedOwned?: boolean;
    selectionContext?: "A" | "B" | "C";
    showCount?: boolean;
  }>(),
  {
    showCount: true,
  },
);

const emit = defineEmits<{
  (e: "select-group", groupId: string | number | null): void;
}>();

const isExpanded = ref(false);
const isAllGroup = computed(() => props.group.name === "전체");
const displayedGroupName = computed(() => {
  if (!isAllGroup.value) return props.group.name;
  if (props.selectionContext === "B") return "전체_선택된문제집";
  if (props.selectionContext === "C") return "전체_선택된고사";
  return "전체_문제";
});
const isOwned = computed(() => {
  const creatorNo =
    (props.group as any).creator_no ?? (props.group as any).creator_id;
  const selfOwned = (() => {
    if (Array.isArray(props.currentUserNo)) {
      const valid = props.currentUserNo.filter(x => x !== null && x !== undefined).map(String);
      return valid.includes(String(creatorNo));
    } else {
      return props.currentUserNo !== null && props.currentUserNo !== undefined
        ? String(creatorNo) === String(props.currentUserNo)
        : false;
    }
  })();
  const isSystemOwned = String(creatorNo) === "0";
  return Boolean(props.inheritedOwned) || selfOwned || isSystemOwned;
});

const rawQuestionCount = (g: any) =>
  g?.question_count ??
  g?.questions_count ??
  g?.questionCount ??
  g?.questionsCount ??
  g?._count?.questions ??
  g?.question_total ??
  g?.questionTotal ??
  g?.total_question_count ??
  g?.question_count_all ??
  g?.questionCountWithChildren ??
  (Array.isArray(g?.questions) ? g.questions.length : 0) ??
  (Array.isArray(g?.questionList) ? g.questionList.length : 0) ??
  0;

const totalQuestionCount = (g: any): number => {
  if (!g) return 0;
  // 서버에서 이미 계산된 question_total이 있으면 우선 사용하고, 없으면 재귀 계산함
  if (g.question_total !== undefined && g.question_total !== null) {
    return Number(g.question_total);
  }
  const own = Number(rawQuestionCount(g)) || 0;
  const children = Array.isArray(g.child_groups)
    ? g.child_groups.reduce(
        (sum: number, child: any) => sum + totalQuestionCount(child),
        0,
      )
    : 0;
  return own + children;
};

watchEffect(() => {
  const groupKey = String(props.group.group_id);
  if (!props.expandedIds) return;
  isExpanded.value =
    props.expandedIds.has(groupKey) ||
    props.expandedIds.has(props.group.group_id);
});

const toggleExpand = (event: Event) => {
  event.stopPropagation();
  isExpanded.value = !isExpanded.value;
};
</script>

<template>
  <div class="tree-node" :style="{ paddingLeft: `${depth * 0.5}rem` }">
    <div
      class="node-content"
      :class="{
        'is-selected': group.group_id === selectedGroupId,
        'is-owned': isOwned,
        'is-all-group': isAllGroup,
      }"
      @click="emit('select-group', group.group_id)">
      <span
        v-if="group.child_groups && group.child_groups.length > 0"
        class="toggle-icon"
        :class="{ 'is-expanded': isExpanded }"
        @click="toggleExpand">
        <IconArrowRight class="toggle-icon-svg" />
      </span>
      <span v-else class="bullet">•</span>
      <span class="name-text">
        <span class="name-label">{{ displayedGroupName }}</span>
        <span v-if="showCount" class="count-pill"
          >({{ totalQuestionCount(group) }}개)</span
        >
      </span>
    </div>

    <div
      v-if="isExpanded && group.child_groups && group.child_groups.length > 0"
      class="child-nodes">
      <GroupTreeNode
        v-for="child in group.child_groups"
        :key="child.group_id"
        :group="child"
        :selected-group-id="selectedGroupId"
        :depth="depth + 1"
        :current-user-no="currentUserNo"
        :expanded-ids="expandedIds"
        :inherited-owned="isOwned"
        :selection-context="selectionContext"
        :show-count="showCount"
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
  border-width: 2px;
}

.node-content:hover .name-text {
  font-size: 0.88rem;
}

.node-content:hover .count-pill {
  font-size: 0.8rem;
}

.node-content.is-selected {
  background: rgba(99, 102, 241, 0.15);
  border-color: #6366f1;
}

.node-content.is-owned {
  background: rgba(99, 102, 241, 0.15);
  border-color: #6366f1;
}

.node-content.is-owned .name-text {
  color: #fff;
  font-weight: 600;
}

.node-content.is-selected .name-text {
  color: #fff;
  font-weight: 600;
}

.node-content.is-all-group .name-text {
  font-weight: 700;
}

.node-content.is-all-group {
  border-width: 2px;
  border-color: rgba(165, 180, 252, 0.7);
}

.node-content.is-selected .name-label {
  text-decoration: underline;
  text-underline-offset: 0.18rem;
}

.toggle-icon {
  font-size: 0.9rem;
  color: #94a3b8;
  transition:
    transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275),
    color 0.2s;
  display: inline-block;
  width: 1.45rem;
  text-align: center;
}

.toggle-icon-svg {
  width: 0.95rem;
  height: 0.95rem;
  transition: transform 0.2s ease;
}

.toggle-icon:hover {
  color: #ababc6;
  transform: scale(1.55);
}

.toggle-icon.is-expanded {
  transform: rotate(90deg);
}

.toggle-icon.is-expanded:hover {
  transform: rotate(90deg) scale(1.4);
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

.name-label {
  display: inline-block;
}

.count-pill {
  color: #a5b4fc;
  font-weight: 700;
  font-size: 0.75rem;
}

.child-nodes {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  margin-top: 0.25rem;
}
</style>
