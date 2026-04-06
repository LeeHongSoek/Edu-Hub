<script setup lang="ts">
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconBook from "~/assets/icons/IconBook.svg?component";
import IconPencil from "~/assets/icons/IconPencil.svg?component";
import IconArrowUp from "~/assets/icons/IconArrowUp.svg?component";

defineProps<{
  activePage?: "questions" | "books" | "exams" | null;
  backLink?: {
    to: string;
    label: string;
  } | null;
  isDashboard?: boolean;
}>();
</script>

<template>
  <div class="nav-button-group">
    <template v-if="!backLink">
      <NuxtLink
        :to="isDashboard ? '/questions?mine=true' : '/questions'"
        class="nav-btn"
        :class="{ active: activePage === 'questions' }">
        <IconFileText class="nav-icon" />
        문제 목록
      </NuxtLink>
      <NuxtLink
        to="/question-books"
        class="nav-btn"
        :class="{ active: activePage === 'books' }">
        <IconBook class="nav-icon" />
        문제집 목록
      </NuxtLink>
      <NuxtLink
        to="/exams"
        class="nav-btn"
        :class="{ active: activePage === 'exams' }">
        <IconPencil class="nav-icon" />
        고사집 목록
      </NuxtLink>
    </template>

    <template v-else>
      <NuxtLink :to="backLink.to" class="nav-btn">
        {{ backLink.label }}
        <IconArrowUp
          class="nav-icon"
          style="transform: rotate(-270deg)"
        />
      </NuxtLink>
    </template>
  </div>
</template>

<style scoped>
.nav-button-group {
  display: flex !important;
  align-items: center !important;
  background: rgba(15, 23, 42, 0.4);
  padding: 4px;
  border-radius: 12px;
  border: 1px solid rgba(129, 140, 248, 0.2);
  backdrop-filter: blur(8px);
}

.nav-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  color: #e2e8f0;
  text-decoration: none;
  font-size: 0.85rem;
  font-weight: 600;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  white-space: nowrap;
  flex-shrink: 0;
}

.nav-btn:hover:not(.active) {
  background: rgba(255, 255, 255, 0.05);
  color: #ffffff;
}

.nav-btn.active {
  color: #475569;
  pointer-events: none;
  cursor: default;
}

.nav-icon {
  width: 1rem;
  height: 1rem;
}
</style>
