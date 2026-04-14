<!--
파일 개요:
- 역할: 수식과 마크다운 내 LaTeX 표현을 렌더링하는 공통 컴포넌트입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { computed } from "vue";
import katex from "katex";

const props = defineProps<{
  text: string;
  stripNewlines?: boolean;
}>();

const renderedContent = computed(() => {
  if (!props.text) return "";

  let content = props.text;
  if (props.stripNewlines) {
    content = content.replace(/\n/g, " ");
  }

  // 블록 수식: $$ ... $$
  content = content.replace(/\$\$([\s\S]+?)\$\$/g, (match, p1) => {
    try {
      return katex.renderToString(p1, {
        displayMode: true,
        throwOnError: false,
      });
    } catch (e) {
      console.error("Katex error:", e);
      return match;
    }
  });

  // 인라인 수식: $ ... $
  content = content.replace(/\$([^\$]+)\$/g, (match, p1) => {
    try {
      return katex.renderToString(p1, {
        displayMode: false,
        throwOnError: false,
      });
    } catch (e) {
      console.error("Katex error:", e);
      return match;
    }
  });

  return content;
});
</script>

<template>
  <div v-html="renderedContent" class="latex-renderer"></div>
</template>

<style>
.latex-renderer {
  display: inline-block;
}
.latex-renderer .katex-display {
  margin: 1em 0;
}
</style>
