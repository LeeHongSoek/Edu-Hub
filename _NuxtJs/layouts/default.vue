<script setup lang="ts">
import { ref, computed } from 'vue';
import UserProfileModal from '~/components/UserProfileModal.vue';
import IconHome from '~/assets/icons/IconHome.svg?component';
import IconUser from '~/assets/icons/IconUser.svg?component';
import IconLogout from '~/assets/icons/IconLogout.svg?component';

const showUserModal = ref(false);
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
          <div class="nav-path-box">
            <NuxtLink to="/Dashboard" class="path-home">
              <IconHome class="icon-home" />
              홈(대시보드)
            </NuxtLink>
            <span class="path-sep">&gt;</span>
            <NuxtLink to="/Questions" class="path-current">문제 목록</NuxtLink>
          </div>
          <a href="#" class="user-greeting" @click.prevent="showUserModal = true">
            <IconUser class="icon-user" />
            {{ userInfo.username }}님
          </a>
          <a href="#" class="logout-link" @click.prevent="handleLogout">
            <IconLogout class="icon-logout" />
            로그아웃
          </a>
        </template>
      </nav>
    </header>
    <main>
      <slot />
    </main>
    <UserProfileModal 
      v-if="showUserModal && userInfo" 
      :user="userInfo" 
      @close="showUserModal = false" 
    />
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
.nav-path-box {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.4rem 0.8rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  backdrop-filter: blur(4px);
  font-size: 0.9rem;
  color: #94a3b8;
}
.nav-path-box .path-home {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  color: #94a3b8;
}
.icon-home {
  width: 1rem;
  height: 1rem;
}
.nav-path-box .path-sep {
  color: #475569;
  font-size: 0.8rem;
}
.nav-path-box .path-current {
  color: #e2e8f0;
  font-weight: 600;
}
.user-greeting {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  color: #a5b4fc !important;
  font-size: 0.95rem !important;
  font-weight: 600 !important;
  margin-left: 0.5rem;
  text-decoration: none;
  padding: 0.4rem 0.8rem;
  border-radius: 8px;
  transition: all 0.2s;
}
.user-greeting:hover {
  background: rgba(99, 102, 241, 0.1);
  color: #c7d2fe !important;
}
.logout-link {
  display: flex;
  align-items: center;
  gap: 0.3rem;
  color: rgba(240,244,255,0.5) !important;
  font-size: 0.85rem !important;
  font-weight: 400 !important;
  text-decoration: none;
  transition: color 0.2s;
}
.logout-link:hover {
  color: #f87171 !important;
}
.icon-user, .icon-logout {
  width: 1.1rem;
  height: 1.1rem;
}
</style>
