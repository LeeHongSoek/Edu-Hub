<script setup lang="ts">
import { computed } from 'vue';
import katex from 'katex';

const props = defineProps<{
  text: string;
}>();

const renderedContent = computed(() => {
  if (!props.text) return '';
  
  let content = props.text;
  
  // Block math: $$ ... $$
  content = content.replace(/\$\$([\s\S]+?)\$\$/g, (match, p1) => {
    try {
      return katex.renderToString(p1, { displayMode: true, throwOnError: false });
    } catch (e) {
      console.error('Katex error:', e);
      return match;
    }
  });
  
  // Inline math: $ ... $
  content = content.replace(/\$([^\$]+)\$/g, (match, p1) => {
    try {
      return katex.renderToString(p1, { displayMode: false, throwOnError: false });
    } catch (e) {
      console.error('Katex error:', e);
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
