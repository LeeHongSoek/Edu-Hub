<!--
파일 개요:
- 역할: 마크다운 콘텐츠를 지정한 배경색과 스타일로 렌더링하는 뷰어입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { computed } from "vue";
import MarkdownIt from "markdown-it";

const props = withDefaults(
  defineProps<{
    content: string;
    background?: string;
  }>(),
  {
    background: "#1a232e",
  },
);

const md = new MarkdownIt({
  html: false,
  breaks: true,
  linkify: true,
  typographer: true,
});

const renderedContent = computed(() => md.render(props.content || ""));
</script>

<template>
  <div class="md-viewer">
    <div
      class="md-content"
      :style="{ background: background }"
      v-html="renderedContent"
    />
  </div>
</template>

<style scoped>
.md-viewer {
  border-radius: 0;
}

.md-content {
  border-radius: 0;
  padding: 0;
  border: none;
  color: #e2e8f0;
}

.md-content :deep(*) {
  color: inherit;
}

.md-content :deep(h1),
.md-content :deep(h2),
.md-content :deep(h3),
.md-content :deep(h4),
.md-content :deep(h5),
.md-content :deep(h6),
.md-content :deep(strong) {
  color: #f8fafc;
}

.md-content :deep(pre) {
  background: rgba(0, 0, 0, 0.32);
  border-radius: 8px;
  padding: 0.85rem;
  overflow-x: auto;
  border: 1px solid rgba(255, 255, 255, 0.15);
}

.md-content :deep(code) {
  color: #dbeafe;
}
</style>
