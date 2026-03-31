<script setup lang="ts">
import { computed, onMounted, ref, watch } from "vue";
import IconMessage from "~/assets/icons/IconMessage.svg?component";
import IconSearch from "~/assets/icons/IconSearch.svg?component";
import IconClose from "~/assets/icons/IconClose.svg?component";

type MessageRoleId = "S" | "T" | "P";

const messagePageSize = 8;
const recipientPageSize = 6;

const messages = ref<any[]>([]);
const messageLoading = ref(true);
const messageSearchInput = ref("");
const messageSearchQuery = ref("");
const messageCurrentPage = ref(1);
const messageSliderValue = ref(1);
const messageTotal = ref(0);
const messageTotalPages = ref(1);
const messageView = ref<"received" | "sent">("received");

const showComposeModal = ref(false);
const recipientItems = ref<any[]>([]);
const recipientLoading = ref(false);
const recipientSearchInput = ref("");
const recipientSearchQuery = ref("");
const recipientCurrentPage = ref(1);
const recipientSliderValue = ref(1);
const recipientTotal = ref(0);
const recipientTotalPages = ref(1);
const selectedRecipient = ref<any | null>(null);
const composeContent = ref("");
const sendingMessage = ref(false);
const noticeMessage = ref("");
const composeRecipientPreset = ref(false);
const activeThreadTarget = ref<any | null>(null);

const props = defineProps<{
  composeTarget?: any | null;
  threadTarget?: any | null;
}>();

const emit = defineEmits<{
  (event: "compose-consumed"): void;
  (event: "compose-dismissed"): void;
  (event: "thread-consumed"): void;
}>();

const { apiBase, getAuthHeader } = useApi();
const userCookie = useCookie("user_info");

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

const userRoleId = computed<MessageRoleId | "">(() => {
  const role = userInfo.value?.role_id ?? userInfo.value?.role ?? "";
  return ["S", "T", "P"].includes(role) ? role : "";
});

const messageSummary = computed(() => {
  if (userRoleId.value === "S")
    return "학생은 연결된 사람에게 메시지를 보내고 받은 내역을 확인할 수 있습니다.";
  if (userRoleId.value === "P")
    return "학부모는 연결된 자녀와 선생님에게 메시지를 보낼 수 있습니다.";
  if (userRoleId.value === "T")
    return "선생님은 연결된 학생과 학부모에게 메시지를 보낼 수 있습니다.";
  return "메시지 기능을 사용할 수 없습니다.";
});

const messageIsSliderDisabled = computed(() => messageTotalPages.value <= 1);
const messageSliderPercentage = computed(() => {
  if (messageTotalPages.value <= 1) return 0;
  return ((messageSliderValue.value - 1) / (messageTotalPages.value - 1)) * 100;
});
const messagePageStartItem = computed(() => {
  if (messageTotal.value === 0) return 0;
  return (messageCurrentPage.value - 1) * messagePageSize + 1;
});
const messagePageEndItem = computed(() =>
  Math.min(messageCurrentPage.value * messagePageSize, messageTotal.value),
);

const recipientIsSliderDisabled = computed(
  () => recipientTotalPages.value <= 1,
);
const recipientSliderPercentage = computed(() => {
  if (recipientTotalPages.value <= 1) return 0;
  return (
    ((recipientSliderValue.value - 1) / (recipientTotalPages.value - 1)) * 100
  );
});
const recipientPageStartItem = computed(() => {
  if (recipientTotal.value === 0) return 0;
  return (recipientCurrentPage.value - 1) * recipientPageSize + 1;
});
const recipientPageEndItem = computed(() =>
  Math.min(
    recipientCurrentPage.value * recipientPageSize,
    recipientTotal.value,
  ),
);

const roleLabel = (roleId?: string) => {
  if (roleId === "T") return "선생님";
  if (roleId === "P") return "학부모";
  if (roleId === "S") return "학생";
  return "미확인";
};

const formatDateTime = (value: string | Date | null | undefined) => {
  if (!value) return "-";
  return new Intl.DateTimeFormat("ko-KR", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  }).format(new Date(value));
};

const messageDirectionLabel = (message: any) =>
  message?.direction === "sent" ? "보낸 메시지" : "받은 메시지";

const messageThreadTitle = computed(() => {
  if (!activeThreadTarget.value) return "";
  return `${activeThreadTarget.value.username || "상대방"} 님에게서 받은 메시지`;
});

const loadMessages = async () => {
  try {
    messageLoading.value = true;
    const peerUserNo =
      messageView.value === "received" && activeThreadTarget.value
        ? activeThreadTarget.value.user_no
        : null;
    const data = await $fetch(`${apiBase.value}/dashboard/messages`, {
      headers: getAuthHeader(),
      query: {
        view: messageView.value,
        q: messageSearchQuery.value,
        page: messageCurrentPage.value,
        limit: messagePageSize,
        ...(peerUserNo ? { peerUserNo: String(peerUserNo) } : {}),
      },
    });

    const response = data as {
      items: any[];
      total: number;
      page: number;
      totalPages: number;
      limit: number;
    };

    messages.value = response.items ?? [];
    messageTotal.value = Number(response.total ?? 0);
    messageCurrentPage.value =
      Number(response.page ?? messageCurrentPage.value) || 1;
    messageTotalPages.value = Number(response.totalPages ?? 1) || 1;
    messageSliderValue.value = messageCurrentPage.value;
  } catch (err) {
    console.error("서버 통신 오류(fetch) messages:", err);
    messages.value = [];
    messageTotal.value = 0;
    messageTotalPages.value = 1;
  } finally {
    messageLoading.value = false;
  }
};

const applyMessageSearch = async () => {
  messageSearchQuery.value = messageSearchInput.value.trim();
  messageCurrentPage.value = 1;
  messageSliderValue.value = 1;
  await loadMessages();
};

const clearMessageSearch = async () => {
  messageSearchInput.value = "";
  messageSearchQuery.value = "";
  messageCurrentPage.value = 1;
  messageSliderValue.value = 1;
  await loadMessages();
};

const handleMessageSliderInput = (event: Event) => {
  messageSliderValue.value = Number((event.target as HTMLInputElement).value);
};

const commitMessageSliderValue = async () => {
  messageCurrentPage.value = Math.min(
    Math.max(messageSliderValue.value, 1),
    messageTotalPages.value,
  );
  await loadMessages();
};

const switchMessageView = async (view: "received" | "sent") => {
  if (messageView.value === view) return;
  messageView.value = view;
  messageCurrentPage.value = 1;
  messageSliderValue.value = 1;
  if (view !== "received") {
    activeThreadTarget.value = null;
    emit("thread-consumed");
  }
  await loadMessages();
};

const loadRecipients = async () => {
  try {
    recipientLoading.value = true;
    const data = await $fetch(
      `${apiBase.value}/dashboard/messages/recipients`,
      {
        headers: getAuthHeader(),
        query: {
          q: recipientSearchQuery.value,
          page: recipientCurrentPage.value,
          limit: recipientPageSize,
        },
      },
    );

    const response = data as {
      items: any[];
      total: number;
      page: number;
      totalPages: number;
      limit: number;
    };

    recipientItems.value = response.items ?? [];
    recipientTotal.value = Number(response.total ?? 0);
    recipientCurrentPage.value =
      Number(response.page ?? recipientCurrentPage.value) || 1;
    recipientTotalPages.value = Number(response.totalPages ?? 1) || 1;
    recipientSliderValue.value = recipientCurrentPage.value;
  } catch (err) {
    console.error("서버 통신 오류(fetch) message recipients:", err);
    recipientItems.value = [];
    recipientTotal.value = 0;
    recipientTotalPages.value = 1;
  } finally {
    recipientLoading.value = false;
  }
};

const openComposeModal = () => {
  if (userRoleId.value === "") return;
  showComposeModal.value = true;
  selectedRecipient.value = null;
  composeContent.value = "";
  noticeMessage.value = "";
  composeRecipientPreset.value = false;
  recipientSearchInput.value = "";
  recipientSearchQuery.value = "";
  recipientCurrentPage.value = 1;
  recipientSliderValue.value = 1;
  void loadRecipients();
};

const openComposeWithRecipient = (user: any) => {
  if (userRoleId.value === "") return;
  showComposeModal.value = true;
  selectedRecipient.value = user;
  composeContent.value = "";
  noticeMessage.value = "";
  composeRecipientPreset.value = true;
  recipientItems.value = [];
  recipientLoading.value = false;
  recipientSearchInput.value = "";
  recipientSearchQuery.value = "";
  recipientCurrentPage.value = 1;
  recipientSliderValue.value = 1;
  recipientTotal.value = 0;
  recipientTotalPages.value = 1;
};

const closeComposeModal = () => {
  showComposeModal.value = false;
  emit("compose-dismissed");
};

const applyRecipientSearch = async () => {
  recipientSearchQuery.value = recipientSearchInput.value.trim();
  recipientCurrentPage.value = 1;
  recipientSliderValue.value = 1;
  await loadRecipients();
};

const clearRecipientSearch = async () => {
  recipientSearchInput.value = "";
  recipientSearchQuery.value = "";
  recipientCurrentPage.value = 1;
  recipientSliderValue.value = 1;
  await loadRecipients();
};

const handleRecipientSliderInput = (event: Event) => {
  recipientSliderValue.value = Number((event.target as HTMLInputElement).value);
};

const commitRecipientSliderValue = async () => {
  recipientCurrentPage.value = Math.min(
    Math.max(recipientSliderValue.value, 1),
    recipientTotalPages.value,
  );
  await loadRecipients();
};

const selectRecipient = (user: any) => {
  selectedRecipient.value = user;
  noticeMessage.value = "";
};

const sendMessage = async () => {
  if (!selectedRecipient.value) {
    noticeMessage.value = "받는 사람을 선택해 주세요.";
    return;
  }

  const content = composeContent.value.trim();
  if (!content) {
    noticeMessage.value = "메시지 내용을 입력해 주세요.";
    return;
  }

  sendingMessage.value = true;

  try {
    const result = await $fetch(`${apiBase.value}/dashboard/messages`, {
      method: "POST",
      headers: getAuthHeader(),
      body: {
        receiverUserNo: selectedRecipient.value.user_no,
        content,
      },
    });

    noticeMessage.value =
      (result as { message?: string }).message || "메시지를 전송했습니다.";
    composeContent.value = "";
    selectedRecipient.value = null;
    await loadMessages();
    if (!composeRecipientPreset.value) {
      await loadRecipients();
    }
    emit("compose-consumed");
  } catch (err: any) {
    const message =
      err?.data?.message || err?.message || "메시지 전송에 실패했습니다.";
    noticeMessage.value = String(message);
  } finally {
    sendingMessage.value = false;
  }
};

watch(
  () => props.composeTarget,
  async (target) => {
    if (!target) return;
    openComposeWithRecipient(target);
    await Promise.resolve();
    emit("compose-consumed");
  },
  { immediate: true },
);

watch(
  () => props.threadTarget,
  async (target) => {
    activeThreadTarget.value = target ?? null;
    if (!target) return;

    messageView.value = "received";
    messageSearchInput.value = "";
    messageSearchQuery.value = "";
    messageCurrentPage.value = 1;
    messageSliderValue.value = 1;
    await loadMessages();
    emit("thread-consumed");
  },
  { immediate: true },
);

onMounted(() => {
  void loadMessages();
});
</script>

<template>
  <div class="message-manager">
    <div class="manager-header">
      <div class="header-copy">
        <div class="header-title-row">
          <h2><IconMessage class="section-icon" /> 메시지 함</h2>
          <div class="message-tabs">
            <button
              class="message-tab"
              :class="{ active: messageView === 'received' }"
              @click="switchMessageView('received')"
            >
              받은 메시지
            </button>
            <button
              class="message-tab"
              :class="{ active: messageView === 'sent' }"
              @click="switchMessageView('sent')"
            >
              보낸 메시지
            </button>
          </div>
        </div>
        <p class="manager-subtitle">{{ messageSummary }}</p>
        <p v-if="messageThreadTitle" class="thread-title">
          {{ messageThreadTitle }}
        </p>
      </div>
      <button
        class="btn-compose"
        :disabled="userRoleId === ''"
        @click="openComposeModal"
      >
        새 메시지 작성
      </button>
    </div>

    <div class="pagination-panel-border">
      <div class="slider-panel">
        <div class="search-row">
          <label class="search-box">
            <IconSearch class="search-icon-svg" />
            <input
              v-model="messageSearchInput"
              type="search"
              placeholder="이름, 아이디, 내용으로 검색하세요"
              @keyup.enter="applyMessageSearch"
            />
          </label>
          <button class="btn-search" @click="applyMessageSearch">검색</button>
          <button
            v-if="messageSearchQuery"
            class="btn-reset-search"
            @click="clearMessageSearch"
          >
            초기화
          </button>
        </div>

        <div v-if="messageTotal > 0" class="slider-row">
          <span class="summary-text">총 {{ messageTotal }}건</span>
          <div class="page-slider-section">
            <div
              class="slider-wrapper"
              :class="{ disabled: messageIsSliderDisabled }"
            >
              <span class="slider-limit">1</span>
              <div class="slider-track-container">
                <input
                  type="range"
                  :min="1"
                  :max="messageTotalPages"
                  :value="messageSliderValue"
                  class="page-slider"
                  :disabled="messageIsSliderDisabled"
                  @input="handleMessageSliderInput"
                  @change="commitMessageSliderValue"
                />
                <div
                  class="slider-fill"
                  :style="{ width: messageSliderPercentage + '%' }"
                ></div>
                <div
                  class="slider-tooltip"
                  :style="{ left: messageSliderPercentage + '%' }"
                >
                  {{ messageSliderValue }}
                </div>
              </div>
              <span class="slider-limit">{{ messageTotalPages }}</span>
            </div>
          </div>
          <span class="range-text"
            >{{ messagePageStartItem }}-{{ messagePageEndItem }}번째 항목 표시
            중</span
          >
        </div>
      </div>
    </div>

    <div v-if="messageLoading" class="loading">불러오는 중...</div>
    <div v-else-if="messageTotal === 0" class="empty">
      검색 결과가 없습니다.
    </div>
    <TransitionGroup v-else name="message-slide" tag="div" class="message-list">
      <div
        v-for="message in messages"
        :key="message.message_id"
        class="message-item"
      >
        <div class="message-top">
          <span class="message-direction" :class="message.direction">
            {{ messageDirectionLabel(message) }}
          </span>
          <div class="message-line">
            <span class="message-name">{{
              message.counterpart?.username ||
              message.sender?.username ||
              "알 수 없음"
            }}</span>
            <span class="message-id">{{
              message.counterpart?.user_id || message.sender?.user_id
            }}</span>
            <span class="message-role">{{
              roleLabel(message.counterpart?.role_id || message.sender?.role_id)
            }}</span>
          </div>
          <span class="message-date">{{
            formatDateTime(message.created_at)
          }}</span>
        </div>

        <div class="message-body">
          <p class="message-content">{{ message.content }}</p>
        </div>
      </div>
    </TransitionGroup>

    <p v-if="noticeMessage" class="notice-message">{{ noticeMessage }}</p>

    <div
      v-if="showComposeModal"
      class="modal-overlay"
      @click.self="closeComposeModal"
    >
      <div class="modal-card">
        <div class="modal-header">
          <div>
            <h3>새 메시지 작성</h3>
            <p class="modal-desc">
              연결된 상대를 찾아 바로 메시지를 보낼 수 있습니다.
            </p>
          </div>
          <button class="btn-close" @click="closeComposeModal">
            <IconClose class="close-icon" />
          </button>
        </div>

        <div class="modal-body">
          <div v-if="!composeRecipientPreset" class="recipient-panel">
            <div class="recipient-search-row">
              <label class="search-box">
                <IconSearch class="search-icon-svg" />
                <input
                  v-model="recipientSearchInput"
                  type="search"
                  placeholder="이름 또는 아이디로 상대방을 찾으세요"
                  @keyup.enter="applyRecipientSearch"
                />
              </label>
              <button class="btn-search" @click="applyRecipientSearch">
                검색
              </button>
              <button
                v-if="recipientSearchQuery"
                class="btn-reset-search"
                @click="clearRecipientSearch"
              >
                초기화
              </button>
            </div>

            <div class="slider-row">
              <span class="summary-text">총 {{ recipientTotal }}명</span>
              <div class="page-slider-section">
                <div
                  class="slider-wrapper"
                  :class="{ disabled: recipientIsSliderDisabled }"
                >
                  <span class="slider-limit">1</span>
                  <div class="slider-track-container">
                    <input
                      type="range"
                      :min="1"
                      :max="recipientTotalPages"
                      :value="recipientSliderValue"
                      class="page-slider"
                      :disabled="recipientIsSliderDisabled"
                      @input="handleRecipientSliderInput"
                      @change="commitRecipientSliderValue"
                    />
                    <div
                      class="slider-fill"
                      :style="{ width: recipientSliderPercentage + '%' }"
                    ></div>
                    <div
                      class="slider-tooltip"
                      :style="{ left: recipientSliderPercentage + '%' }"
                    >
                      {{ recipientSliderValue }}
                    </div>
                  </div>
                  <span class="slider-limit">{{ recipientTotalPages }}</span>
                </div>
              </div>
              <span class="range-text"
                >{{ recipientPageStartItem }}-{{ recipientPageEndItem }}번째
                항목 표시 중</span
              >
            </div>

            <div v-if="recipientLoading" class="loading compact">
              상대방을 찾는 중...
            </div>
            <div v-else-if="recipientTotal === 0" class="empty compact">
              검색 결과가 없습니다.
            </div>
            <TransitionGroup
              v-else
              name="recipient-slide"
              tag="div"
              class="recipient-list"
            >
              <button
                v-for="user in recipientItems"
                :key="user.user_no"
                class="recipient-item"
                :class="{
                  selected: selectedRecipient?.user_no === user.user_no,
                }"
                @click="selectRecipient(user)"
              >
                <div class="recipient-row">
                  <div class="recipient-user">
                    <span class="recipient-name">{{ user.username }}</span>
                    <span class="recipient-id">{{ user.user_id }}</span>
                  </div>
                  <span class="recipient-role">{{
                    roleLabel(user.role_id)
                  }}</span>
                </div>
              </button>
            </TransitionGroup>
          </div>

          <div v-else class="recipient-summary">
            <span class="recipient-summary-label">받는 사람</span>
            <span class="recipient-summary-name">
              {{ selectedRecipient?.username }} ·
              {{ selectedRecipient?.user_id }}
            </span>
          </div>

          <div class="compose-panel">
            <div class="compose-copy">
              <div>
                <span class="compose-eyebrow">전송 내용</span>
                <p>선택한 상대에게 보낼 메시지를 입력하세요.</p>
              </div>
              <span v-if="selectedRecipient" class="selected-chip">
                {{ selectedRecipient.username }} ·
                {{ selectedRecipient.user_id }}
              </span>
            </div>

            <textarea
              v-model="composeContent"
              class="compose-input"
              rows="5"
              placeholder="메시지 내용을 입력하세요"
            />

            <div class="compose-actions">
              <button
                class="btn-send"
                :disabled="sendingMessage || !selectedRecipient"
                @click="sendMessage"
              >
                {{ sendingMessage ? "전송 중..." : "전송" }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.message-manager {
  display: flex;
  flex-direction: column;
  gap: 1.4rem;
}

.manager-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.header-copy {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.manager-header h2 {
  font-size: 1.25rem;
  color: #f8fafc;
  margin: 0;
  font-weight: 800;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.header-title-row {
  display: flex;
  align-items: center;
  gap: 0.8rem;
  flex-wrap: wrap;
}

.message-tabs {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.message-tab {
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.05);
  color: #cbd5e1;
  border-radius: 999px;
  padding: 0.45rem 0.9rem;
  font-size: 0.82rem;
  font-weight: 800;
  cursor: pointer;
}

.message-tab.active {
  background: linear-gradient(90deg, #6366f1, #a855f7);
  color: #fff;
  border-color: transparent;
}

.manager-subtitle {
  color: #94a3b8;
  margin: 0;
  font-size: 0.92rem;
}

.thread-title {
  margin: 0;
  color: #a5b4fc;
  font-size: 0.85rem;
  font-weight: 700;
}

.btn-compose {
  background: #c084fc;
  color: white;
  border: none;
  padding: 0.62rem 1.15rem;
  border-radius: 10px;
  font-weight: 700;
  cursor: pointer;
  transition:
    transform 0.2s,
    opacity 0.2s,
    background 0.2s;
  white-space: nowrap;
}

.btn-compose:hover:not(:disabled) {
  background: #a855f7;
  transform: translateY(-1px);
}

.btn-compose:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.pagination-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 12px;
  padding: 1rem 1.05rem;
  background: rgba(15, 23, 42, 0.72);
  box-shadow: 0 20px 60px -22px rgba(15, 23, 42, 1);
}

.slider-panel {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.search-row,
.recipient-search-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.search-box {
  flex: 1;
  min-width: 220px;
  display: flex;
  align-items: center;
  gap: 0.55rem;
  background: rgba(15, 23, 42, 0.56);
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 10px;
  padding: 0.65rem 0.9rem;
}

.search-box input {
  width: 100%;
  background: transparent;
  border: none;
  color: #e2e8f0;
  outline: none;
}

.search-box input::placeholder {
  color: #64748b;
}

.search-icon-svg {
  color: #94a3b8;
}

.section-icon,
.search-icon-svg,
.close-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.btn-search,
.btn-reset-search,
.btn-secondary,
.btn-send {
  border: none;
  border-radius: 10px;
  padding: 0.58rem 3rem;
  font-weight: 700;
  cursor: pointer;
}

.btn-search {
  background: #6366f1;
  color: #fff;
}

.btn-search:hover {
  background: #4f46e5;
}

.btn-reset-search,
.btn-secondary {
  background: rgba(255, 255, 255, 0.08);
  color: #e2e8f0;
  border: 1px solid rgba(255, 255, 255, 0.12);
}

.btn-send {
  background: #a855f7;
  color: #fff;
}

.btn-send:hover:not(:disabled) {
  background: #9333ea;
}

.btn-send:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.slider-row {
  display: flex;
  align-items: center;
  gap: 0.9rem;
  justify-content: space-between;
  flex-wrap: nowrap;
}

.summary-text,
.range-text {
  font-size: 0.85rem;
  color: #cbd5f5;
  font-weight: 500;
  white-space: nowrap;
  flex-shrink: 0;
}

.page-slider-section {
  flex: 1;
  min-width: 0;
}

.slider-wrapper {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  width: 100%;
}

.slider-wrapper.disabled {
  pointer-events: none;
  opacity: 0.6;
}

.slider-limit {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 700;
  min-width: 20px;
  text-align: center;
}

.slider-track-container {
  position: relative;
  flex: 1;
  height: 32px;
  display: flex;
  align-items: center;
}

.page-slider {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
  outline: none;
  cursor: pointer;
  z-index: 2;
  position: relative;
  touch-action: none;
}

.page-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  background: #6366f1;
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 0 15px rgba(99, 102, 241, 0.4);
  border: 2px solid #fff;
}

.slider-fill {
  position: absolute;
  height: 6px;
  background: linear-gradient(90deg, #6366f1, #a855f7);
  border-radius: 3px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  z-index: 1;
}

.slider-tooltip {
  position: absolute;
  top: -24px;
  transform: translateX(-50%);
  background: #6366f1;
  color: white;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 800;
  pointer-events: none;
  white-space: nowrap;
}

.slider-tooltip::after {
  content: "";
  position: absolute;
  bottom: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-top: 4px solid #6366f1;
}

.message-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.9rem;
}

.message-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  padding: 1rem 1.05rem;
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
  min-height: 80px;
}

.message-top {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 0.75rem;
  min-width: 0;
  flex-wrap: nowrap;
}

.message-name {
  font-weight: 800;
  color: #c7d2fe;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.message-id {
  color: #94a3b8;
  font-size: 0.8rem;
  font-weight: 600;
  white-space: nowrap;
  flex-shrink: 0;
}

.message-line {
  display: flex;
  align-items: center;
  gap: 0.45rem;
  min-width: 0;
  overflow: hidden;
  flex: 1;
}

.message-direction {
  display: inline-flex;
  align-items: center;
  padding: 0.14rem 0.48rem;
  border-radius: 999px;
  background: rgba(129, 140, 248, 0.12);
  color: #a5b4fc;
  font-size: 0.7rem;
  font-weight: 800;
  white-space: nowrap;
  flex-shrink: 0;
}

.message-direction.received {
  background: rgba(34, 197, 94, 0.12);
  color: #86efac;
}

.message-date {
  font-size: 0.78rem;
  color: #64748b;
  white-space: nowrap;
  flex-shrink: 0;
}

.message-body {
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
}

.message-role {
  display: inline-flex;
  width: fit-content;
  align-items: center;
  padding: 0.16rem 0.5rem;
  border-radius: 999px;
  background: rgba(168, 85, 247, 0.12);
  color: #d8b4fe;
  font-size: 0.72rem;
  font-weight: 800;
}

.message-content {
  margin: 0;
  color: #cbd5e1;
  line-height: 1.55;
  word-break: break-word;
}

.loading,
.empty {
  text-align: center;
  padding: 2rem 1rem;
  color: #64748b;
}

.compact {
  padding-top: 1rem;
  padding-bottom: 1rem;
}

.notice-message {
  margin: 0;
  color: #cbd5e1;
  font-size: 0.9rem;
}

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 23, 0.78);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.modal-card {
  width: min(1080px, 100%);
  max-height: 90vh;
  background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  box-shadow: 0 28px 80px -30px rgba(0, 0, 0, 0.65);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal-header {
  padding: 1rem 1.2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.07);
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.modal-header h3 {
  font-size: 1.2rem;
  color: #f8fafc;
  font-weight: 800;
  margin: 0;
}

.modal-desc {
  margin: 0.35rem 0 0;
  color: #94a3b8;
  font-size: 0.9rem;
}

.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 2rem;
  line-height: 1;
  cursor: pointer;
}

.modal-body {
  padding: 1.2rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.recipient-panel,
.compose-panel {
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
}

.recipient-list {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.7rem;
}

.recipient-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  padding: 0.7rem 0.8rem;
  text-align: left;
  cursor: pointer;
  transition:
    transform 0.2s,
    border-color 0.2s,
    background 0.2s;
}

.recipient-item:hover {
  transform: translateY(-1px);
  border-color: rgba(129, 140, 248, 0.45);
}

.recipient-item.selected {
  border-color: rgba(129, 140, 248, 0.8);
  background: rgba(129, 140, 248, 0.1);
}

.recipient-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.8rem;
  min-width: 0;
}

.recipient-user {
  display: flex;
  align-items: baseline;
  gap: 0.4rem;
  min-width: 0;
  overflow: hidden;
}

.recipient-name {
  color: #c7d2fe;
  font-weight: 800;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.recipient-id {
  color: #94a3b8;
  font-size: 0.78rem;
  font-weight: 600;
  white-space: nowrap;
  flex-shrink: 0;
}

.recipient-role {
  display: inline-flex;
  align-items: center;
  padding: 0.14rem 0.48rem;
  border-radius: 999px;
  background: rgba(129, 140, 248, 0.12);
  color: #a5b4fc;
  font-size: 0.7rem;
  font-weight: 800;
  white-space: nowrap;
  flex-shrink: 0;
}

.compose-copy {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.compose-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  color: #a5b4fc;
  font-size: 0.8rem;
  font-weight: 800;
  letter-spacing: 0.02em;
  text-transform: uppercase;
}

.compose-copy p {
  margin: 0.35rem 0 0;
  color: #cbd5e1;
  font-size: 0.92rem;
}

.selected-chip {
  display: inline-flex;
  align-items: center;
  padding: 0.22rem 0.58rem;
  border-radius: 999px;
  background: rgba(168, 85, 247, 0.14);
  color: #c7d2fe;
  font-size: 0.78rem;
  font-weight: 700;
  white-space: nowrap;
}

.compose-input {
  min-height: 160px;
  resize: vertical;
  border-radius: 12px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  background: rgba(15, 23, 42, 0.58);
  color: #e2e8f0;
  padding: 0.9rem 1rem;
  outline: none;
  line-height: 1.55;
}

.compose-input::placeholder {
  color: #64748b;
}

.compose-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.message-slide-enter-active,
.message-slide-leave-active,
.message-slide-move,
.recipient-slide-enter-active,
.recipient-slide-leave-active,
.recipient-slide-move {
  transition:
    opacity 0.22s ease,
    transform 0.22s ease;
}

.message-slide-enter-from,
.message-slide-leave-to,
.recipient-slide-enter-from,
.recipient-slide-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

@media (max-width: 760px) {
  .manager-header,
  .message-top,
  .recipient-row,
  .compose-copy,
  .slider-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .message-list,
  .recipient-list {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }

  .modal-card {
    max-height: 92vh;
  }

  .search-box,
  .page-slider-section {
    width: 100%;
  }

  .message-meta {
    align-items: flex-start;
  }

  .range-text {
    align-self: flex-end;
  }
}
</style>
