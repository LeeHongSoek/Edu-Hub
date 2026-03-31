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
