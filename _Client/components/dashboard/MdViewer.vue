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
