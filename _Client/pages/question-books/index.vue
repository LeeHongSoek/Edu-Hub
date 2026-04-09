<!--
파일 개요:
- 역할: 문제집 관리 기능의 페이지 진입점입니다. 문제집 생성과 관리 흐름을 제공합니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import QuestionBookManager from "~/components/dashboard/QuestionBookManager.vue";
</script>

<template>
  <div class="page-container">
    <div class="content-box">
      <QuestionBookManager :show-scope-toggle="true" />
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
