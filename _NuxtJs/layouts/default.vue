<script setup lang="ts">
const userCookie = useCookie('user_info');

const userInfo = computed(() => {
  if (!userCookie.value) return null;
  try {
    return typeof userCookie.value === 'string'
      ? JSON.parse(userCookie.value)
      : userCookie.value;
  } catch { return null; }
});

function handleLogout() {
  const token = useCookie('auth_token');
  token.value = null;
  userCookie.value = null;
  navigateTo('/');
}
</script>

<template>
  <div>
    <header class="top-bar">
      <NuxtLink to="/" class="logo">
        <span class="logo-icon">📘</span>
        <span class="logo-text">Edu<em>Hub</em></span>
      </NuxtLink>
      <nav class="nav-links">
        <template v-if="userInfo">
          홈 > <NuxtLink to="/Questions">문제 목록</NuxtLink>
          <span class="user-greeting">{{ userInfo.username }}님</span>
          <a href="#" class="logout-link" @click.prevent="handleLogout">로그아웃</a>
        </template>
      </nav>
    </header>
    <main>
      <slot />
    </main>
  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&display=swap');

.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.2rem 5rem;
  position: relative;
  z-index: 100;
  font-family: 'Noto Sans KR', 'Apple SD Gothic Neo', sans-serif;
}
.logo {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.5rem;
  font-weight: 900;
  letter-spacing: -0.03em;
  text-decoration: none;
  color: #f0f4ff;
}
.logo-icon { font-size: 1.6rem; }
.logo-text em {
  font-style: normal;
  background: linear-gradient(135deg, #818cf8, #c084fc);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}
.nav-links {
  display: flex;
  align-items: center;
  gap: 1.2rem;
}
.nav-links a {
  color: rgba(240,244,255,0.65);
  text-decoration: none;
  font-size: 0.95rem;
  font-weight: 500;
  letter-spacing: 0.03em;
  transition: color 0.25s;
}
.nav-links a:hover,
.nav-links a.router-link-active {
  color: #f0f4ff;
}
.user-greeting {
  color: #a5b4fc;
  font-size: 0.9rem;
  font-weight: 600;
  margin-left: 0.5rem;
}
.logout-link {
  color: rgba(240,244,255,0.5) !important;
  font-size: 0.85rem !important;
  font-weight: 400 !important;
}
.logout-link:hover {
  color: #f87171 !important;
}
</style>
