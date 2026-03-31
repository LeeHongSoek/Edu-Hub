<script setup lang="ts">
import ExamListManager from "~/components/dashboard/ExamListManager.vue";
import IconArrowUp from "~/assets/icons/IconArrowUp.svg?component";
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconBook from "~/assets/icons/IconBook.svg?component";
</script>

<template>
  <div class="page-container">
    <div class="page-header">
      <div class="page-nav"></div>
    </div>

    <div class="content-box">
      <ExamListManager :show-scope-toggle="true" />
    </div>
  </div>
</template>

<style scoped>
.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem 1rem;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 0.5rem;
  width: 100%;
}

.page-title {
  font-size: 2.2rem;
  font-weight: 800;
  color: #f8fafc;
}

.page-nav {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: nowrap;
  width: 100%;
  justify-content: space-between;
}

.page-links {
  display: flex;
  gap: 0.75rem;
  flex-wrap: nowrap;
  justify-content: flex-end;
  margin-left: auto;
}

.back-btn,
.quick-link {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  padding: 0.35rem 0.55rem;
  border-radius: 8px;
  text-decoration: none;
  transition: all 0.2s;
}

.back-btn {
  color: #94a3b8;
  font-weight: 500;
  font-size: 0.9rem;
  background: transparent;
  border: none;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.04);
  color: #eef2ff;
  transform: translateY(-1px);
}

.quick-link {
  background: transparent;
  border: none;
  color: #94a3b8;
  font-weight: 500;
  font-size: 0.9rem;
}

.quick-link:hover {
  background: rgba(255, 255, 255, 0.04);
  color: #eef2ff;
  transform: translateY(-1px);
}

.back-icon,
.quick-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.content-box {
  background: rgba(30, 41, 59, 0.5);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.05);
  padding: 1rem 1rem;
  min-height: 430px;
}

@media (max-width: 900px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .page-nav {
    align-items: flex-start;
    width: 100%;
  }

  .page-links {
    justify-content: flex-start;
    flex-wrap: wrap;
  }
}
</style>
