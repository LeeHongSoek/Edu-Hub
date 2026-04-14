<!--
파일 개요:
- 역할: 문제 목록 화면의 상위 조립과 전환 흐름을 담당하는 래퍼입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import QuestionList from "~/components/dashboard/QuestionList.vue";
import type { Question } from "~/types";

const props = defineProps<{
  listTitle?: string;
  listSubtitle?: string | null;
  showScopeToggle?: boolean;
  scopeMode?: "mine" | "all";
  contextScopeMode?: "mine" | "all";
  showError?: boolean;
  errorMessage?: string | null;
  questions: Question[];
  currentUserNo?: string | number | null;
  selectedGroupId: string | number | null;
  appliedSearchField: "content" | "title" | "id";
  appliedSearchKeyword: string;
  currentPage: number;
  totalPages: number;
  totalItems: number;
  pageSize: number;
  viewMode: "mine" | "all";
  hideGroupOverlay?: boolean;
  selectionContext?: "A" | "B" | "C";
  contextId?: string | number | null;
}>();

const emit = defineEmits<{
  (e: "refresh"): void;
  (e: "change-scope", scope: "mine" | "all"): void;
  (e: "change-context-scope", scope: "mine" | "all"): void;
  (e: "change-group", groupId: string | number | null): void;
  (
    e: "search",
    payload: { field: "title" | "content" | "id"; keyword: string },
  ): void;
  (e: "reset-search"): void;
  (e: "change-page", page: number): void;
  (e: "copy-question", question: Question): void;
}>();
</script>

<template>
  <QuestionList
    :list-title="props.listTitle"
    :list-subtitle="props.listSubtitle"
    :show-scope-toggle="props.showScopeToggle"
    :scope-mode="props.scopeMode"
    :context-scope-mode="props.contextScopeMode"
    :show-error="props.showError"
    :error-message="props.errorMessage"
    :questions="props.questions"
    :current-user-no="props.currentUserNo"
    :selected-group-id="props.selectedGroupId"
    :applied-search-field="props.appliedSearchField"
    :applied-search-keyword="props.appliedSearchKeyword"
    :current-page="props.currentPage"
    :total-pages="props.totalPages"
    :total-items="props.totalItems"
    :page-size="props.pageSize"
    :view-mode="props.viewMode"
    :hide-group-overlay="props.hideGroupOverlay"
    :selection-context="props.selectionContext"
    :context-id="props.contextId"
    @refresh="emit('refresh')"
    @change-scope="emit('change-scope', $event)"
    @change-context-scope="emit('change-context-scope', $event)"
    @change-group="emit('change-group', $event)"
    @search="emit('search', $event)"
    @reset-search="emit('reset-search')"
    @change-page="emit('change-page', $event)"
    @copy-question="emit('copy-question', $event)"
  />
</template>
