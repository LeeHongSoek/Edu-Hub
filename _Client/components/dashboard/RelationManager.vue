<script setup lang="ts">
import { computed, onMounted, reactive, ref } from "vue";
import IconUsers from "~/assets/icons/IconUsers.svg?component";
import IconSearch from "~/assets/icons/IconSearch.svg?component";
import IconClose from "~/assets/icons/IconClose.svg?component";

type RelationRoleId = "S" | "T" | "P";
type TargetKey = "parents" | "teachers" | "students";

interface RelationTarget {
  key: TargetKey;
  label: string;
  roleId: RelationRoleId;
  description: string;
}

interface SearchPanelState {
  searchInput: string;
  searchQuery: string;
  currentPage: number;
  sliderValue: number;
  total: number;
  totalPages: number;
  items: any[];
  loading: boolean;
}

const pageSize = 6;
const relationPageSize = 8;
const relations = ref<any[]>([]);
const relationLoading = ref(true);
const relationSearchInput = ref("");
const relationSearchQuery = ref("");
const relationCurrentPage = ref(1);
const relationSliderValue = ref(1);
const relationTotal = ref(0);
const relationTotalPages = ref(1);
const showConnectModal = ref(false);
const activeTargetKey = ref<TargetKey | "">("");
const submittingUserId = ref<string>("");
const feedbackMessage = ref("");
const emit = defineEmits<{
  (event: "compose-message", user: any): void;
  (event: "open-message-thread", user: any): void;
}>();

const panelStates = reactive<Record<TargetKey, SearchPanelState>>({
  parents: createPanelState(),
  teachers: createPanelState(),
  students: createPanelState(),
});

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

const userRoleId = computed<RelationRoleId | "">(() => {
  const role = userInfo.value?.role_id ?? userInfo.value?.role ?? "";
  return ["S", "T", "P"].includes(role) ? role : "";
});

const relationTargets = computed<RelationTarget[]>(() => {
  if (userRoleId.value === "S") {
    return [
      {
        key: "parents",
        label: "학부모",
        roleId: "P",
        description: "이름으로 학부모를 검색하고 바로 연결할 수 있습니다.",
      },
      {
        key: "teachers",
        label: "선생님",
        roleId: "T",
        description: "이름으로 선생님을 검색하고 바로 연결할 수 있습니다.",
      },
    ];
  }

  if (userRoleId.value === "P") {
    return [
      {
        key: "students",
        label: "학생",
        roleId: "S",
        description: "이름으로 학생을 검색하고 자녀 연결을 만들 수 있습니다.",
      },
    ];
  }

  if (userRoleId.value === "T") {
    return [
      {
        key: "students",
        label: "학생",
        roleId: "S",
        description: "이름으로 학생을 검색하고 수업 대상과 연결할 수 있습니다.",
      },
    ];
  }

  return [];
});

const activeTarget = computed(
  () =>
    relationTargets.value.find(
      (target) => target.key === activeTargetKey.value,
    ) ?? null,
);
const activePanel = computed(() => {
  if (!activeTarget.value) return null;
  return getPanelState(activeTarget.value.key);
});

const totalPages = computed(() => {
  if (!activePanel.value) return 1;
  return Math.max(
    1,
    activePanel.value.totalPages ||
      Math.ceil(activePanel.value.total / pageSize) ||
      1,
  );
});

const isSliderDisabled = computed(
  () => totalPages.value <= 1 || !activePanel.value,
);
const sliderPercentage = computed(() => {
  if (!activePanel.value || totalPages.value <= 1) return 0;
  return ((activePanel.value.sliderValue - 1) / (totalPages.value - 1)) * 100;
});

const pageStartItem = computed(() => {
  if (!activePanel.value || activePanel.value.total === 0) return 0;
  return (activePanel.value.currentPage - 1) * pageSize + 1;
});

const pageEndItem = computed(() => {
  if (!activePanel.value) return 0;
  return Math.min(
    activePanel.value.currentPage * pageSize,
    activePanel.value.total,
  );
});

const relationTotalPagesComputed = computed(() =>
  Math.max(1, relationTotalPages.value),
);
const relationIsSliderDisabled = computed(
  () => relationTotalPagesComputed.value <= 1,
);
const relationSliderPercentage = computed(() => {
  if (relationTotalPagesComputed.value <= 1) return 0;
  return (
    ((relationSliderValue.value - 1) / (relationTotalPagesComputed.value - 1)) *
    100
  );
});
const relationPageStartItem = computed(() => {
  if (relationTotal.value === 0) return 0;
  return (relationCurrentPage.value - 1) * relationPageSize + 1;
});
const relationPageEndItem = computed(() =>
  Math.min(relationCurrentPage.value * relationPageSize, relationTotal.value),
);

const relationSummary = computed(() => {
  if (userRoleId.value === "S") {
    return "학생은 학부모와 선생님을 이름으로 따로 찾아 연결할 수 있습니다.";
  }
  if (userRoleId.value === "P") {
    return "학부모는 학생을 이름으로 찾아 연결할 수 있습니다.";
  }
  if (userRoleId.value === "T") {
    return "선생님은 학생을 이름으로 찾아 연결할 수 있습니다.";
  }
  return "연결 관리 기능을 사용할 수 없습니다.";
});

function createPanelState(): SearchPanelState {
  return {
    searchInput: "",
    searchQuery: "",
    currentPage: 1,
    sliderValue: 1,
    total: 0,
    totalPages: 1,
    items: [],
    loading: false,
  };
}

function getPanelState(key: TargetKey) {
  if (!panelStates[key]) {
    panelStates[key] = createPanelState();
  }
  return panelStates[key];
}

const roleLabel = (roleId?: string) => {
  if (roleId === "T") return "선생님";
  if (roleId === "P") return "학부모";
  if (roleId === "S") return "학생";
  return "미확인";
};

const relationBadgeLabel = (relation: any) => {
  const otherRoleId = String(relation?.user2?.role_id || "");
  const relationTypeId = String(relation?.relation_type_id || "");

  if (relationTypeId === "FRIEND") {
    return "친구";
  }

  if (relationTypeId === "PARENT_CHILD" || relationTypeId === "CHILD_PARENT") {
    if (userRoleId.value === "S") return "부모";
    if (userRoleId.value === "P") return "자녀";
    return otherRoleId === "S" ? "학생" : roleLabel(otherRoleId);
  }

  if (
    relationTypeId === "PUPIL_TEACHER" ||
    relationTypeId === "TEACHER_PUPIL"
  ) {
    if (userRoleId.value === "S") return "선생";
    if (userRoleId.value === "T") return "학생";
    return otherRoleId === "T" ? "선생님" : roleLabel(otherRoleId);
  }

  if (otherRoleId === "T") {
    return userRoleId.value === "S" ? "선생" : "선생님";
  }

  if (otherRoleId === "P") {
    return userRoleId.value === "S" ? "부모" : "학부모";
  }

  if (otherRoleId === "S") {
    return userRoleId.value === "P" ? "자녀" : "학생";
  }

  return relation?.relation_type?.description || "관계 없음";
};

const loadRelations = async () => {
  try {
    relationLoading.value = true;
    const data = await $fetch(`${apiBase.value}/dashboard/relations`, {
      headers: getAuthHeader(),
      query: {
        q: relationSearchQuery.value,
        page: relationCurrentPage.value,
        limit: relationPageSize,
      },
    });
    const response = data as {
      items: any[];
      total: number;
      page: number;
      totalPages: number;
      limit: number;
    };

    relations.value = response.items ?? [];
    relationTotal.value = Number(response.total ?? 0);
    relationCurrentPage.value =
      Number(response.page ?? relationCurrentPage.value) || 1;
    relationTotalPages.value = Number(response.totalPages ?? 1) || 1;
    relationSliderValue.value = relationCurrentPage.value;
  } catch (err) {
    console.error("서버 통신 오류(fetch) relations:", err);
  } finally {
    relationLoading.value = false;
  }
};

const applyRelationSearch = async () => {
  relationSearchQuery.value = relationSearchInput.value.trim();
  relationCurrentPage.value = 1;
  relationSliderValue.value = 1;
  await loadRelations();
};

const clearRelationSearch = async () => {
  relationSearchInput.value = "";
  relationSearchQuery.value = "";
  relationCurrentPage.value = 1;
  relationSliderValue.value = 1;
  await loadRelations();
};

const handleRelationSliderInput = (event: Event) => {
  relationSliderValue.value = Number((event.target as HTMLInputElement).value);
};

const commitRelationSliderValue = async () => {
  relationCurrentPage.value = Math.min(
    Math.max(relationSliderValue.value, 1),
    relationTotalPagesComputed.value,
  );
  await loadRelations();
};

const fetchCandidates = async (targetKey = activeTargetKey.value) => {
  if (!targetKey) return;
  const target = relationTargets.value.find((item) => item.key === targetKey);
  if (!target) return;

  const panel = getPanelState(targetKey);
  panel.loading = true;

  try {
    const data = await $fetch(
      `${apiBase.value}/dashboard/relations/candidates`,
      {
        headers: getAuthHeader(),
        query: {
          role: target.roleId,
          q: panel.searchQuery,
          page: panel.currentPage,
          limit: pageSize,
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

    panel.items = response.items ?? [];
    panel.total = Number(response.total ?? 0);
    panel.currentPage = Number(response.page ?? panel.currentPage) || 1;
    panel.totalPages = Number(response.totalPages ?? 1) || 1;
    panel.sliderValue = panel.currentPage;
  } catch (err) {
    console.error("서버 통신 오류(fetch) relation candidates:", err);
    panel.items = [];
    panel.total = 0;
    panel.totalPages = 1;
  } finally {
    panel.loading = false;
  }
};

const openConnectModal = () => {
  if (relationTargets.value.length === 0) return;
  showConnectModal.value = true;
  activeTargetKey.value = relationTargets.value[0].key;
  feedbackMessage.value = "";
  void fetchCandidates(activeTargetKey.value);
};

const closeConnectModal = () => {
  showConnectModal.value = false;
  feedbackMessage.value = "";
};

const selectTarget = (targetKey: TargetKey) => {
  if (activeTargetKey.value === targetKey) return;
  activeTargetKey.value = targetKey;
  if (showConnectModal.value) {
    void fetchCandidates(targetKey);
  }
};

const applySearch = async () => {
  if (!activeTargetKey.value) return;
  const panel = getPanelState(activeTargetKey.value);
  panel.searchQuery = panel.searchInput.trim();
  panel.currentPage = 1;
  panel.sliderValue = 1;
  await fetchCandidates(activeTargetKey.value);
};

const clearSearch = async () => {
  if (!activeTargetKey.value) return;
  const panel = getPanelState(activeTargetKey.value);
  panel.searchInput = "";
  panel.searchQuery = "";
  panel.currentPage = 1;
  panel.sliderValue = 1;
  await fetchCandidates(activeTargetKey.value);
};

const handleSliderInput = (event: Event) => {
  if (!activePanel.value) return;
  activePanel.value.sliderValue = Number(
    (event.target as HTMLInputElement).value,
  );
};

const commitSliderValue = async () => {
  if (!activePanel.value || !activeTargetKey.value) return;
  const panel = activePanel.value;
  panel.currentPage = Math.min(
    Math.max(panel.sliderValue, 1),
    totalPages.value,
  );
  await fetchCandidates(activeTargetKey.value);
};

const toggleCandidateRelation = async (user: any, event: Event) => {
  if (!activeTarget.value) return;
  const checked = (event.target as HTMLInputElement).checked;
  submittingUserId.value = String(user.user_no);

  try {
    const result = checked
      ? await $fetch(`${apiBase.value}/dashboard/relations`, {
          method: "POST",
          headers: getAuthHeader(),
          body: {
            targetUserNo: user.user_no,
            targetRoleId: activeTarget.value.roleId,
          },
        })
      : await $fetch(`${apiBase.value}/dashboard/relations/${user.user_no}`, {
          method: "DELETE",
          headers: getAuthHeader(),
        });

    feedbackMessage.value =
      (result as { message?: string }).message ||
      (checked
        ? `${user.username} 님과 연결했습니다.`
        : `${user.username} 님과의 연결을 해제했습니다.`);
    await loadRelations();
    await fetchCandidates(activeTarget.value.key);
  } catch (err: any) {
    const message =
      err?.data?.message || err?.message || "연결에 실패했습니다.";
    feedbackMessage.value = String(message);
  } finally {
    submittingUserId.value = "";
  }
};

watch(
  relationTargets,
  (targets) => {
    if (targets.length === 0) {
      activeTargetKey.value = "";
      return;
    }

    if (!targets.some((target) => target.key === activeTargetKey.value)) {
      activeTargetKey.value = targets[0].key;
    }
  },
  { immediate: true },
);

onMounted(loadRelations);
</script>

<template>
  <div class="relation-manager">
    <div class="manager-header">
      <div class="header-copy">
        <h3><IconUsers class="section-icon" /> 나의 인맥 관리</h3>
        <p class="manager-subtitle">{{ relationSummary }}</p>
      </div>
      <button
        class="btn-add"
        :disabled="relationTargets.length === 0"
        @click="openConnectModal"
      >
        + 연결 관리
      </button>
    </div>

    <div class="pagination-panel-border">
      <div class="slider-panel">
        <div class="search-row">
          <label class="search-box">
            <IconSearch class="search-icon-svg" />
            <input
              v-model="relationSearchInput"
              type="search"
              placeholder="이름 또는 아이디를 입력하세요"
              @keyup.enter="applyRelationSearch"
            />
          </label>
          <button class="btn-search" @click="applyRelationSearch">검색</button>
          <button
            v-if="relationSearchQuery"
            class="btn-reset-search"
            @click="clearRelationSearch"
          >
            초기화
          </button>
        </div>

        <div v-if="relationTotal > 0" class="slider-row">
          <span class="summary-text">총 {{ relationTotal }}건</span>
          <div class="page-slider-section">
            <div
              class="slider-wrapper"
              :class="{ disabled: relationIsSliderDisabled }"
            >
              <span class="slider-limit">1</span>
              <div class="slider-track-container">
                <input
                  type="range"
                  :min="1"
                  :max="relationTotalPagesComputed"
                  :value="relationSliderValue"
                  class="page-slider"
                  :disabled="relationIsSliderDisabled"
                  @input="handleRelationSliderInput"
                  @change="commitRelationSliderValue"
                />
                <div
                  class="slider-fill"
                  :style="{ width: relationSliderPercentage + '%' }"
                ></div>
                <div
                  class="slider-tooltip"
                  :style="{ left: relationSliderPercentage + '%' }"
                >
                  {{ relationSliderValue }}
                </div>
              </div>
              <span class="slider-limit">{{ relationTotalPagesComputed }}</span>
            </div>
          </div>
          <span class="range-text"
            >{{ relationPageStartItem }}-{{ relationPageEndItem }}번째 항목 표시
            중</span
          >
        </div>
      </div>
    </div>

    <div v-if="relationLoading" class="loading">불러오는 중...</div>
    <div v-else-if="relationTotal === 0" class="empty">
      {{
        relationSearchQuery
          ? "검색 결과가 없습니다."
          : "연결된 사용자가 없습니다. 이름으로 찾아서 바로 연결해 보세요."
      }}
    </div>
    <TransitionGroup
      v-else
      name="relation-slide"
      tag="div"
      class="relation-list"
    >
      <div
        v-for="rel in relations"
        :key="rel.relation_id"
        class="relation-item"
      >
        <div class="relation-row">
          <div class="relation-user">
            <button
              type="button"
              class="user-name-button"
              @click="emit('open-message-thread', rel.user2)"
            >
              <span class="user-name">{{ rel.user2.username }}</span>
            </button>
            <span class="user-id">{{ rel.user2.user_id }}</span>
          </div>
          <div class="relation-actions">
            <span class="relation-badge">{{ relationBadgeLabel(rel) }}</span>
            <button
              class="relation-message-btn"
              @click="emit('compose-message', rel.user2)"
            >
              메시지
            </button>
          </div>
        </div>
      </div>
    </TransitionGroup>

    <div
      v-if="showConnectModal"
      class="modal-overlay"
      @click.self="closeConnectModal"
    >
      <div class="modal-card">
        <div class="modal-header">
          <div>
            <h2>연결 관리</h2>
            <p class="modal-desc">{{ relationSummary }}</p>
          </div>
          <div class="modal-header-actions">
            <div class="target-tabs">
              <button
                v-for="target in relationTargets"
                :key="target.key"
                class="target-tab"
                :class="{ active: activeTargetKey === target.key }"
                @click="selectTarget(target.key)"
              >
                {{ target.label }}
              </button>
            </div>
            <button class="btn-close" @click="closeConnectModal">
              <IconClose class="close-icon" />
            </button>
          </div>
        </div>

        <div class="modal-body">
          <Transition name="section-slide" mode="out-in">
            <div
              v-if="activeTarget && activePanel"
              :key="activeTarget.key"
              class="target-panel"
            >
              <div class="pagination-panel-border">
                <div class="slider-panel">
                  <div class="search-row">
                    <label class="search-box">
                      <span class="search-icon">⌕</span>
                      <input
                        v-model="activePanel.searchInput"
                        type="search"
                        :placeholder="`${activeTarget.label} 이름 또는 아이디를 입력하세요`"
                        @keyup.enter="applySearch"
                      />
                    </label>
                    <button class="btn-search" @click="applySearch">
                      검색
                    </button>
                    <button
                      v-if="activePanel.searchQuery"
                      class="btn-reset-search"
                      @click="clearSearch"
                    >
                      초기화
                    </button>
                  </div>

                  <div class="slider-row">
                    <span class="summary-text"
                      >총 {{ activePanel.total }}명</span
                    >
                    <div class="page-slider-section">
                      <div
                        class="slider-wrapper"
                        :class="{ disabled: isSliderDisabled }"
                      >
                        <span class="slider-limit">1</span>
                        <div class="slider-track-container">
                          <input
                            type="range"
                            :min="1"
                            :max="totalPages"
                            :value="activePanel.sliderValue"
                            class="page-slider"
                            :disabled="isSliderDisabled"
                            @input="handleSliderInput"
                            @change="commitSliderValue"
                          />
                          <div
                            class="slider-fill"
                            :style="{ width: sliderPercentage + '%' }"
                          ></div>
                          <div
                            class="slider-tooltip"
                            :style="{ left: sliderPercentage + '%' }"
                          >
                            {{ activePanel.sliderValue }}
                          </div>
                        </div>
                        <span class="slider-limit">{{ totalPages }}</span>
                      </div>
                    </div>
                    <span class="range-text"
                      >{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시
                      중</span
                    >
                  </div>
                </div>
              </div>

              <div v-if="activePanel.loading" class="loading compact">
                불러오는 중...
              </div>
              <div v-else-if="activePanel.total === 0" class="empty compact">
                검색 결과가 없습니다.
              </div>
              <TransitionGroup
                v-else
                name="candidate-slide"
                tag="div"
                class="candidate-list"
              >
                <div
                  v-for="user in activePanel.items"
                  :key="user.user_no"
                  class="candidate-item"
                >
                  <label class="candidate-row">
                    <input
                      class="relation-checkbox"
                      type="checkbox"
                      :checked="user.isConnected"
                      :disabled="submittingUserId === user.user_no"
                      @change="toggleCandidateRelation(user, $event)"
                    />
                    <span class="candidate-name">{{ user.username }}</span>
                    <span class="candidate-id">{{ user.user_id }}</span>
                  </label>
                </div>
              </TransitionGroup>

              <p v-if="feedbackMessage" class="feedback-message">
                {{ feedbackMessage }}
              </p>
            </div>
          </Transition>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.relation-manager {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
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

.manager-header h3 {
  color: #f8fafc;
  margin: 0;
  font-size: 1.25rem;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.section-icon,
.search-icon-svg,
.close-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.manager-subtitle {
  color: #94a3b8;
  margin: 0;
  font-size: 0.92rem;
}

.btn-add {
  background: #818cf8;
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

.btn-add:hover:not(:disabled) {
  background: #6366f1;
  transform: translateY(-1px);
}

.btn-add:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.relation-list {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 0.9rem;
}

.relation-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  padding: 0.5rem 0.65rem;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 0.4rem;
  transition:
    transform 0.2s,
    border-color 0.2s;
  min-height: 46px;
}

.relation-item:hover {
  transform: translateY(-2px);
  border-color: rgba(129, 140, 248, 0.45);
}

.relation-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  min-width: 0;
  width: 100%;
}

.relation-user {
  display: flex;
  align-items: baseline;
  gap: 0.45rem;
  min-width: 0;
  overflow: hidden;
}

.relation-actions {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  flex-shrink: 0;
}

.relation-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.16rem 0.5rem;
  border-radius: 999px;
  background: rgba(129, 140, 248, 0.12);
  color: #a5b4fc;
  font-size: 0.7rem;
  font-weight: 800;
  white-space: nowrap;
  flex-shrink: 0;
}

.relation-message-btn {
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.05);
  color: #e2e8f0;
  border-radius: 999px;
  padding: 0.18rem 0.55rem;
  font-size: 0.72rem;
  font-weight: 800;
  cursor: pointer;
}

.relation-message-btn:hover {
  background: rgba(129, 140, 248, 0.14);
  border-color: rgba(129, 140, 248, 0.28);
}

.user-name {
  font-weight: 700;
  color: #c7d2fe;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user-name-button {
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  text-align: left;
  min-width: 0;
}

.user-name-button:hover .user-name {
  text-decoration: underline;
}

.user-id {
  color: #94a3b8;
  font-size: 0.8rem;
  font-weight: 600;
  white-space: nowrap;
  flex-shrink: 0;
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
  width: min(920px, 100%);
  max-height: 88vh;
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

.modal-header-actions {
  display: flex;
  align-items: flex-start;
  gap: 0.65rem;
  margin-left: auto;
}

.modal-header h2 {
  font-size: 1.25rem;
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
}

.target-tabs {
  display: flex;
  gap: 0.6rem;
  margin-bottom: 0;
  align-items: center;
  flex-wrap: wrap;
}

.target-tab {
  border: 1px solid rgba(255, 255, 255, 0.11);
  background: rgba(255, 255, 255, 0.05);
  color: #cbd5e1;
  border-radius: 999px;
  padding: 0.55rem 1rem;
  font-weight: 700;
  cursor: pointer;
}

.target-tab.active {
  color: #fff;
  background: linear-gradient(90deg, #6366f1, #818cf8);
  border-color: transparent;
}

.target-panel {
  display: flex;
  flex-direction: column;
  gap: 0.95rem;
}

.target-copy {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.target-eyebrow {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  color: #a5b4fc;
  font-size: 0.8rem;
  font-weight: 800;
  letter-spacing: 0.02em;
  text-transform: uppercase;
}

.target-copy p {
  margin: 0.35rem 0 0;
  color: #cbd5e1;
  font-size: 0.92rem;
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

.search-row {
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

.btn-search,
.btn-reset-search,
.btn-secondary,
.btn-connect {
  border: none;
  border-radius: 10px;
  padding: 0.58rem 1rem;
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
  transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.page-slider:hover::-webkit-slider-thumb {
  transform: scale(1.15);
  box-shadow: 0 0 20px rgba(99, 102, 241, 0.6);
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

.candidate-list {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 0.7rem;
}

.candidate-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 12px;
  padding: 0.5rem 0.65rem;
  min-height: 44px;
  display: flex;
  align-items: center;
}

.candidate-name {
  color: #c7d2fe;
  margin: 0;
  font-size: 1rem;
  font-weight: 700;
  min-width: 0;
}

.candidate-id {
  color: #94a3b8;
  font-size: 0.82rem;
  font-weight: 600;
  white-space: nowrap;
  flex-shrink: 0;
}

.candidate-row {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 0.5rem;
  min-width: 0;
  width: 100%;
  overflow: hidden;
}

.relation-badge {
  display: inline-flex;
  align-items: center;
  padding: 0.16rem 0.5rem;
  border-radius: 999px;
  background: rgba(129, 140, 248, 0.12);
  color: #a5b4fc;
  font-size: 0.7rem;
  font-weight: 800;
  white-space: nowrap;
  flex-shrink: 0;
}

.feedback-message {
  margin: 0.1rem 0 0;
  color: #cbd5e1;
  font-size: 0.9rem;
  padding-left: 0.2rem;
}

.loading,
.empty {
  text-align: center;
  padding: 2rem 1rem;
  color: #64748b;
}

.compact {
  padding-top: 1.2rem;
  padding-bottom: 1.2rem;
}

.section-slide-enter-active,
.section-slide-leave-active {
  transition:
    opacity 0.22s ease,
    transform 0.22s ease;
}

.section-slide-enter-from,
.section-slide-leave-to {
  opacity: 0;
  transform: translateX(18px);
}

.candidate-slide-enter-active,
.candidate-slide-leave-active,
.candidate-slide-move,
.relation-slide-enter-active,
.relation-slide-leave-active,
.relation-slide-move {
  transition:
    opacity 0.22s ease,
    transform 0.22s ease;
}

.candidate-slide-enter-from,
.candidate-slide-leave-to,
.relation-slide-enter-from,
.relation-slide-leave-to {
  opacity: 0;
  transform: translateY(10px);
}

@media (max-width: 760px) {
  .relation-list {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .manager-header,
  .target-copy,
  .slider-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .modal-card {
    max-height: 92vh;
  }

  .search-box,
  .page-slider-section {
    width: 100%;
  }

  .candidate-list {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .modal-header {
    align-items: flex-start;
  }

  .modal-header-actions {
    flex-wrap: wrap;
    justify-content: flex-end;
  }

  .target-tabs {
    justify-content: flex-end;
  }

  .range-text {
    align-self: flex-end;
  }
}

@media (max-width: 480px) {
  .relation-list {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }

  .candidate-list {
    grid-template-columns: repeat(1, minmax(0, 1fr));
  }
}
</style>
