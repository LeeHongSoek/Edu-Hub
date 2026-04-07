<template>
  <div v-if="!hasChecked" class="app-shell" aria-hidden="true"></div>
  <div
    v-else-if="isMobileBlocked"
    class="mobile-blocker"
    role="dialog"
    aria-modal="true"
    aria-labelledby="mobile-blocker-title">
    <div class="mobile-blocker-card">
      <div class="mobile-blocker-badge">PC 전용</div>
      <h1 id="mobile-blocker-title">이 서비스는 PC에서만 이용할 수 있습니다</h1>
      <p>
        현재 화면은 모바일 또는 작은 화면으로 감지되었습니다. 브라우저 창을
        넓히거나 PC에서 다시 접속해주세요.
      </p>
      <div class="mobile-blocker-note">권장 화면 너비: 1024px 이상</div>
    </div>
  </div>
  <div v-else class="app-wrapper">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from "vue";

const hasChecked = ref(false);
const isMobileBlocked = ref(false);

const updateDeviceMode = () => {
  if (typeof window === "undefined") return;
  isMobileBlocked.value = window.innerWidth < 1024;
  document.body.style.overflow = isMobileBlocked.value ? "hidden" : "";
  hasChecked.value = true;
};

onMounted(() => {
  updateDeviceMode();
  window.addEventListener("resize", updateDeviceMode);
});

onBeforeUnmount(() => {
  if (typeof window === "undefined") return;
  window.removeEventListener("resize", updateDeviceMode);
  document.body.style.overflow = "";
});
</script>

<style>
.mobile-blocker {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: grid;
  place-items: center;
  padding: 24px;
  background:
    radial-gradient(circle at top, rgba(99, 102, 241, 0.28), transparent 45%),
    linear-gradient(180deg, #020617 0%, #0f172a 100%);
  color: #f8fafc;
}

.mobile-blocker-card {
  width: min(100%, 560px);
  padding: 32px 28px;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(15, 23, 42, 0.82);
  backdrop-filter: blur(18px);
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.45);
  text-align: center;
}

.mobile-blocker-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 18px;
  padding: 0.35rem 0.8rem;
  border-radius: 10px;
  background: rgba(99, 102, 241, 0.18);
  border: 1px solid rgba(129, 140, 248, 0.35);
  color: #c7d2fe;
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 0.08em;
}

.mobile-blocker-card h1 {
  margin: 0 0 14px;
  font-size: 1.5rem;
  line-height: 1.35;
  font-weight: 800;
  letter-spacing: -0.03em;
}

.mobile-blocker-card p {
  margin: 0;
  color: rgba(226, 232, 240, 0.8);
  font-size: 1rem;
  line-height: 1.7;
}

.mobile-blocker-note {
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
  color: #94a3b8;
  font-size: 0.95rem;
}

/*
body {
  user-select: none;
  -webkit-user-select: none;
}
input, textarea {
  user-select: text;
  -webkit-user-select: text;
}
*/
</style>
