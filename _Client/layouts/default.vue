<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import UserProfileModal from "~/components/UserProfileModal.vue";
import IconHome from "~/assets/icons/IconHome.svg?component";
import IconUser from "~/assets/icons/IconUser.svg?component";
import IconMessage from "~/assets/icons/IconMessage.svg?component";
import IconLogout from "~/assets/icons/IconLogout.svg?component";
import IconFeedback from "~/assets/icons/IconFeedback.svg?component";
import OmbudsmanModal from "~/components/OmbudsmanModal.vue";
import { useApi } from "~/composables/useApi";

const showOmbudsmanModal = ref(false);
const showUserModal = ref(false);
const showMessagePopover = ref(false);
const messageList = ref<any[]>([]);
const messageLoading = ref(false);
const messageError = ref("");
let messageHideTimer: ReturnType<typeof setTimeout> | null = null;
const messageSeenCookie = useCookie<string | null>("message_seen_user");
const userCookie = useCookie("user_info");
const { apiBase, getAuthHeader } = useApi();

const userInfo = computed(() => {
  if (!userCookie.value) return null;
  try {
    return typeof userCookie.value === "string"
      ? JSON.parse(userCookie.value)
      : userCookie.value;
  } catch {
    return null;
  }
});

function handleLogout() {
  const token = useCookie("auth_token");
  token.value = null;
  userCookie.value = null;
  messageSeenCookie.value = null;
  navigateTo("/");
}

const loadRecentMessages = async () => {
  if (!userInfo.value) return;
  messageLoading.value = true;
  messageError.value = "";
  try {
    const data = await $fetch(`${apiBase.value}/dashboard/messages`, {
      headers: getAuthHeader(),
      query: { view: "received", page: 1, limit: 5 },
    });
    const response = data as { items: any[] };
    messageList.value = response.items ?? [];
  } catch (err: any) {
    messageError.value = err?.data?.message || err?.message || "메시지를 불러올 수 없습니다.";
    messageList.value = [];
  } finally {
    messageLoading.value = false;
  }
};

const openMessagePopover = async (autoClose = false) => {
  if (userInfo.value && userInfo.value.msgAlert && userInfo.value.msgAlert !== "none") {
    return;
  }
  setMsgAlertConfirm(); // 한번이라도 실행되면 Confirm

  showMessagePopover.value = true;
  if (messageHideTimer) {
    clearTimeout(messageHideTimer);
    messageHideTimer = null;
  }
  await loadRecentMessages();
  if (autoClose) {
    messageHideTimer = setTimeout(() => {
      markMessagesSeen();
      showMessagePopover.value = false;
      messageHideTimer = null;
    }, 10000);
  }
};

const markMessagesSeen = () => {
  if (userInfo.value) {
    messageSeenCookie.value = String(userInfo.value.user_no ?? "");
  }
};

const setMsgAlertConfirm = () => {
  if (!userCookie.value) return;
  const next =
    typeof userCookie.value === "string"
      ? { ...(JSON.parse(userCookie.value) as any) }
      : { ...userCookie.value };
  next.msgAlert = "confirm";
  userCookie.value = next as any;
};

const handleMessageBadgeClick = async () => {
  setMsgAlertConfirm();
  await openMessagePopover();
};

const closeMessagePopover = () => {
  showMessagePopover.value = false;
  if (messageHideTimer) {
    clearTimeout(messageHideTimer);
    messageHideTimer = null;
  }
  // 팝오버를 한 번이라도 닫으면 다시 자동으로 뜨지 않도록 쿠키에 기록
  markMessagesSeen();
};

onMounted(() => {
  if (!userInfo.value) {
    // 로그인 전 초기 상태: 자동 팝업 관련 쿠키를 비워 새 세션에서 다시 판단
    messageSeenCookie.value = null;
    return;
  }
  // 페이지 최초 진입 시 받은 메시지 팝오버 표시
  void openMessagePopover(true);
});
</script>

<template>
  <div>
    <header class="top-bar">
      <div class="header-left">
        <NuxtLink to="/" class="logo">
          <span class="logo-icon">📘</span>
          <span class="logo-text">Edu<em>Hub</em></span>
        </NuxtLink>
        <a
          v-if="userInfo"
          href="#"
          class="ombudsman-link"
          @click.prevent="showOmbudsmanModal = true"
        >
          <IconFeedback class="icon-feedback" />
          옴브즈먼
        </a>
      </div>
      <nav class="nav-links">
        <template v-if="userInfo">
          <div class="nav-path-box">
            <NuxtLink to="/dashboard" class="path-home">
              <IconHome class="icon-home" />
              홈(대시보드)
            </NuxtLink>
          </div>
          <a
            href="#"
            class="user-greeting"
            @click.prevent="showUserModal = true"
          >
            <IconUser class="icon-user" />
            {{ userInfo.username }} <{{ userInfo.user_no }}>님
          </a>
          <NuxtLink
            to="/dashboard?tab=messages&view=received"
            class="message-badge"
            title="받은 메시지 확인"
            @click.prevent="handleMessageBadgeClick"
          >
            <IconMessage class="icon-message" aria-hidden="true" />
            <!-- [{{ userInfo.msgAlert }}] -->
          </NuxtLink>
          <NuxtLink
            v-if="userInfo.role_id === 'S' || userInfo.role_id === 'T'"
            to="/questions"
            class="my-questions-link"
          >
            나의 문제목록
          </NuxtLink>
          <a href="#" class="logout-link" @click.prevent="handleLogout">
            <IconLogout class="icon-logout" />
            로그아웃
          </a>
        </template>
      </nav>
    </header>
    <Transition name="fade">
      <div v-if="showMessagePopover" class="message-popover">
        <div class="popover-header">
          <div class="popover-title">
            <IconMessage class="icon-message" />
            받은 메시지
          </div>
          <button class="popover-close" @click="closeMessagePopover">✕</button>
        </div>
        <div v-if="messageLoading" class="popover-body">불러오는 중...</div>
        <div v-else-if="messageError" class="popover-body error">
          {{ messageError }}
        </div>
        <div v-else-if="messageList.length === 0" class="popover-body empty">
          받은 메시지가 없습니다.
        </div>
        <ul v-else class="popover-list">
          <li v-for="msg in messageList" :key="msg.message_id" class="popover-item">
            <div class="popover-item-top">
              <span class="from">{{ msg.sender?.username || "발신자 없음" }}</span>
              <span class="time">
                {{ new Date(msg.created_at).toLocaleString("ko-KR", { month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit" }) }}
              </span>
            </div>
            <div class="popover-content">{{ msg.content }}</div>
          </li>
        </ul>
      </div>
    </Transition>
    <main>
      <slot />
    </main>
    <UserProfileModal
      v-if="showUserModal && userInfo"
      :user="userInfo"
      @close="showUserModal = false"
    />
    <OmbudsmanModal
      v-if="showOmbudsmanModal && userInfo"
      @close="showOmbudsmanModal = false"
    />
  </div>
</template>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&display=swap");

.top-bar {
  display: flex !important;
  justify-content: space-between !important;
  align-items: center !important;
  padding: 1rem 2.5rem;
  background: rgba(15, 23, 42, 0.85);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.header-left {
  display: flex !important;
  flex-direction: row !important;
  align-items: center !important;
  gap: 1.5rem !important;
}

.logo {
  display: flex !important;
  align-items: center !important;
  gap: 0.5rem;
  font-size: 1.5rem;
  font-weight: 900;
  letter-spacing: -0.03em;
  text-decoration: none;
  color: #f0f4ff;
  white-space: nowrap;
}
.logo-icon {
  width: 1.6rem;
  height: 1.6rem;
  color: #fbbf24;
}
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
  color: rgba(240, 244, 255, 0.65);
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

.message-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.35rem 0.75rem;
  border-radius: 999px;
  background: rgba(99, 102, 241, 0.18);
  border: 1px solid rgba(129, 140, 248, 0.32);
  color: #e0e7ff !important;
  font-size: 0.88rem;
  font-weight: 700;
  text-decoration: none;
  transition: all 0.18s ease;
}

.message-badge:hover {
  background: rgba(99, 102, 241, 0.32);
  border-color: rgba(129, 140, 248, 0.6);
  color: #ffffff !important;
  transform: translateY(-1px);
  box-shadow: 0 8px 18px rgba(109, 110, 255, 0.25);
}

.icon-message {
  width: 1rem;
  height: 1rem;
}

.message-popover {
  position: fixed;
  top: 76px;
  right: 32px;
  width: 320px;
  max-height: 60vh;
  background: rgba(15, 23, 42, 0.96);
  border: 1px solid rgba(129, 140, 248, 0.35);
  border-radius: 12px;
  box-shadow: 0 24px 60px rgba(0, 0, 0, 0.35);
  backdrop-filter: blur(8px);
  z-index: 1300;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.popover-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.65rem 0.8rem;
  background: rgba(99, 102, 241, 0.08);
  border-bottom: 1px solid rgba(129, 140, 248, 0.2);
}

.popover-title {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  color: #e0e7ff;
  font-weight: 800;
}

.popover-close {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 1rem;
  cursor: pointer;
}

.popover-close:hover {
  color: #fff;
}

.popover-body {
  padding: 0.8rem;
  color: #cbd5e1;
  font-size: 0.9rem;
}

.popover-body.error {
  color: #fca5a5;
}

.popover-body.empty {
  color: #94a3b8;
}

.popover-list {
  list-style: none;
  margin: 0;
  padding: 0.6rem 0.8rem 0.8rem;
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
  overflow-y: auto;
}

.popover-item {
  padding: 0.55rem 0.65rem;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
}

.popover-item-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.2rem;
}

.popover-item .from {
  color: #e2e8f0;
  font-weight: 700;
  font-size: 0.9rem;
}

.popover-item .time {
  color: #94a3b8;
  font-size: 0.78rem;
}

.popover-content {
  color: #cbd5e1;
  font-size: 0.88rem;
  line-height: 1.4;
  word-break: break-word;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.18s ease, transform 0.18s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(-4px);
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
  color: rgba(240, 244, 255, 0.5) !important;
  font-size: 0.85rem !important;
  font-weight: 400 !important;
  text-decoration: none;
  transition: color 0.2s;
}
.logout-link:hover {
  color: #f87171 !important;
}
.icon-user,
.icon-logout,
.icon-feedback {
  width: 1.1rem;
  height: 1.1rem;
}

.ombudsman-link {
  margin-left: 0.8rem;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  color: rgba(240, 244, 255, 0.5) !important;
  font-size: 0.85rem !important;
  font-weight: 500 !important;
  text-decoration: none;
  transition: color 0.2s;
}

.ombudsman-link:hover {
  color: #818cf8 !important;
}

.my-questions-link {
  color: #e2e8f0 !important;
  font-weight: 600 !important;
  font-size: 0.95rem !important;
  margin-left: 0.5rem;
  padding: 0.4rem 0.8rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  transition: all 0.2s;
}

.my-questions-link:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.2);
}
</style>
