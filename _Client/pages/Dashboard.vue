<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed, nextTick } from "vue";
import StudentDashboard from "~/components/dashboard/StudentDashboard.vue";
import TeacherDashboard from "~/components/dashboard/TeacherDashboard.vue";
import ParentDashboard from "~/components/dashboard/ParentDashboard.vue";
import UsersLogViewer from "~/components/dashboard/UsersLogViewer.vue";
import RelationManager from "~/components/dashboard/RelationManager.vue";
import MessageManager from "~/components/dashboard/MessageManager.vue";
import QuestionBookManager from "~/components/dashboard/QuestionBookManager.vue";
import ExamListManager from "~/components/dashboard/ExamListManager.vue";
import ClassMemberManagerModal from "~/components/dashboard/ClassMemberManagerModal.vue";
import ClassExamManagerModal from "~/components/dashboard/ClassExamManagerModal.vue";
import ManagerNav from "~/components/dashboard/ManagerNav.vue";
import IconGraduationCap from "~/assets/icons/IconGraduationCap.svg?component";
import IconBoard from "~/assets/icons/IconBoard.svg?component";
import IconHome from "~/assets/icons/IconHome.svg?component";
import IconChart from "~/assets/icons/IconChart.svg?component";
import IconUsers from "~/assets/icons/IconUsers.svg?component";
import IconMessage from "~/assets/icons/IconMessage.svg?component";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";
import IconClassRoom from "~/assets/icons/IconClassRoom.svg?component";

type UserCookiePayload = {
  user_no: string;
  userId?: string;
  user_id?: string;
  username?: string;
  role?: string;
  role_id?: string;
  msgAlert?: string;
};

type DashboardClassItem = {
  classId: string;
  className: string;
  teacherNo: string | null;
  teacherName: string | null;
  studentCount: number;
  examCount: number;
  createdAt?: string | null;
};

const userCookie = useCookie<UserCookiePayload | string | null>("user_info");
const { apiBase, getAuthHeader } = useApi();
const userInfo = computed<UserCookiePayload | null>(() => {
  if (!userCookie.value) return null;
  try {
    const parsed =
      typeof userCookie.value === "string"
        ? (JSON.parse(userCookie.value) as UserCookiePayload)
        : userCookie.value;
    const normalizedRole = parsed?.role_id || parsed?.role || "";
    const normalizedUser = {
      ...parsed,
      role: normalizedRole,
      role_id: normalizedRole,
    };

    console.log("[사용자 정보] =", normalizedUser);

    return normalizedUser;
  } catch {
    return null;
  }
});

const activeTab = ref("stats"); // 'stats', 'relations', 'messages', 'classes', 'logs', 'question-books', 'exams'
const composeMessageTarget = ref<any | null>(null);
const composeReturnTab = ref<"relations" | null>(null);
const messageThreadTarget = ref<any | null>(null);
const classList = ref<DashboardClassItem[]>([]);
const classListLoading = ref(false);
const classListError = ref("");
const showClassMemberManager = ref(false);
const selectedClassForMembers = ref<DashboardClassItem | null>(null);
const showClassExamManager = ref(false);
const selectedClassForExams = ref<DashboardClassItem | null>(null);
const currentRoleId = computed(
  () => userInfo.value?.role_id || userInfo.value?.role || "",
);

const shouldShowClassList = computed(
  () => currentRoleId.value === "S" || currentRoleId.value === "T",
);
const classTabLabel = computed(() =>
  currentRoleId.value === "T" ? "담당 클래스" : "소속 클래스",
);
const classListTitle = computed(() =>
  currentRoleId.value === "T" ? "내 클래스 목록" : "소속 클래스 목록",
);

const fetchClassList = async () => {
  if (!shouldShowClassList.value) {
    classList.value = [];
    return;
  }

  classListLoading.value = true;
  classListError.value = "";

  try {
    const data = await $fetch<DashboardClassItem[]>(
      `${apiBase.value}/dashboard/classes`,
      {
        headers: getAuthHeader(),
      },
    );
    classList.value = Array.isArray(data) ? data : [];
  } catch (error) {
    console.error("클래스 목록 조회 실패:", error);
    classListError.value = "클래스 목록을 불러오지 못했습니다.";
    classList.value = [];
  } finally {
    classListLoading.value = false;
  }
};

const openClassExams = async (item: DashboardClassItem) => {
  await navigateTo({
    path: "/exams",
    query: {
      scope: "all",
      classId: item.classId,
      className: item.className,
    },
  });
};

const openClassMemberManager = (item: DashboardClassItem) => {
  selectedClassForMembers.value = item;
  showClassMemberManager.value = true;
};

const closeClassMemberManager = () => {
  showClassMemberManager.value = false;
  selectedClassForMembers.value = null;
};

const handleClassMembersSaved = async () => {
  await fetchClassList();
};

const openClassExamManager = (item: DashboardClassItem) => {
  selectedClassForExams.value = item;
  showClassExamManager.value = true;
};

const closeClassExamManager = () => {
  showClassExamManager.value = false;
  selectedClassForExams.value = null;
};

const handleClassExamsSaved = async () => {
  await fetchClassList();
};

const openMessageCompose = async (user: any) => {
  composeMessageTarget.value = user;
  composeReturnTab.value = "relations";
  activeTab.value = "messages";
  await nextTick();
};

const clearMessageComposeTarget = () => {
  composeMessageTarget.value = null;
};

const handleMessageComposeDismissed = () => {
  composeMessageTarget.value = null;
  if (composeReturnTab.value) {
    activeTab.value = composeReturnTab.value;
    composeReturnTab.value = null;
  }
};

const openMessageThread = async (user: any) => {
  messageThreadTarget.value = user;
  activeTab.value = "messages";
  await nextTick();
};

const clearMessageThreadTarget = () => {
  messageThreadTarget.value = null;
};

const phrases = [
  "오늘도 지식을 한 단계 더 완성해 나가는 의미 있는 하루가 되기를 기원합니다.",
  "당신의 끊임없는 성장이 훗날 커다란 결실을 맺을 것임을 굳게 믿고 응원합니다.",
  "새로운 배움이 기다리는 즐거운 오늘, 후회 없이 당신만의 특별한 하루를 만들어보세요.",
  "비록 지금은 작은 노력일지라도, 그 노력이 차곡차곡 쌓여 가장 밝게 빛나는 내일이 될 것입니다.",
  "오늘 하루도 알차고 보람차게 채워가며, 어제보다 더 나은 당신이 되기를 바랍니다.",
];

const typedText = ref("");
const showCursor = ref(true);
let cursorInterval: any = null;
const isTypingActive = ref(false);

const fetchAdvice = async () => {
  try {
    const data = await $fetch<any>(
      "https://korean-advice-open-api.vercel.app/api/advice",
    );
    if (data && data.message) {
      return `${data.message} - ${data.author}`;
    }
    return phrases[Math.floor(Math.random() * phrases.length)];
  } catch (error) {
    console.error("명언 조회 실패:", error);
    return phrases[Math.floor(Math.random() * phrases.length)];
  }
};

const typePhrase = async () => {
  if (!isTypingActive.value) return;

  const currentPhrase = await fetchAdvice();
  typedText.value = "";

  for (let i = 0; i < currentPhrase.length; i++) {
    if (!isTypingActive.value) return;
    typedText.value += currentPhrase[i];
    await new Promise((resolve) => setTimeout(resolve, 60));
  }

  if (!isTypingActive.value) return;
  await new Promise((resolve) => setTimeout(resolve, 3000));

  for (let i = currentPhrase.length; i > 0; i--) {
    if (!isTypingActive.value) return;
    typedText.value = typedText.value.slice(0, -1);
    await new Promise((resolve) => setTimeout(resolve, 30));
  }

  if (!isTypingActive.value) return;
  await new Promise((resolve) => setTimeout(resolve, 500));

  typePhrase();
};

type PendingRelation = {
  user_no: string;
  username: string;
  user_id: string;
  role_id: string;
  relation_type_id: string;
  description: string;
  created_at: string;
};

const pendingRelations = ref<PendingRelation[]>([]);
const currentPendingRequest = computed(() => pendingRelations.value[0] || null);
const isPendingActionLoading = ref(false);

const fetchPendingRelations = async () => {
  try {
    const data = await $fetch<PendingRelation[]>(
      `${apiBase.value}/dashboard/relations/pending`,
      { headers: getAuthHeader() },
    );
    pendingRelations.value = Array.isArray(data) ? data : [];
  } catch (err) {
    console.error("수락 대기 요청 조회 실패:", err);
  }
};

const handlePendingAction = async (action: "accept" | "reject") => {
  if (!currentPendingRequest.value) return;
  isPendingActionLoading.value = true;
  try {
    await $fetch(
      `${apiBase.value}/dashboard/relations/${currentPendingRequest.value.user_no}/approval`,
      {
        method: "PUT",
        headers: getAuthHeader(),
        body: { action },
      },
    );
    // 성공 후 리스트에서 제거
    pendingRelations.value.shift();
  } catch (err) {
    console.error("요청 처리 실패:", err);
    alert("처리 중 오류가 발생했습니다.");
  } finally {
    isPendingActionLoading.value = false;
  }
};

onMounted(() => {
  if (!userInfo.value) {
    navigateTo("/");
    return;
  }

  fetchClassList();
  fetchPendingRelations();

  isPendingActionLoading.value = false;
  isTypingActive.value = true;
  cursorInterval = setInterval(() => {
    showCursor.value = !showCursor.value;
  }, 500);
  typePhrase();
});

onUnmounted(() => {
  isTypingActive.value = false;
  if (cursorInterval) clearInterval(cursorInterval);
});
</script>

<template>
  <div v-if="userInfo" class="dashboard-page">
    <div class="dashboard-header">
      <div class="welcome-section">
        <div class="welcome-top-row">
          <h1 class="welcome-title">
            <span class="welcome-text">
              안녕하세요,
              <span class="role-badge-inline" :class="'role-' + userInfo.role">
                <IconGraduationCap
                  v-if="userInfo.role === 'S'"
                  class="role-icon"
                />
                <IconBoard
                  v-else-if="userInfo.role === 'T'"
                  class="role-icon"
                />
                <IconHome v-else class="role-icon" />
                {{
                  userInfo.role === "T"
                    ? "선생님"
                    : userInfo.role === "P"
                      ? "학부모"
                      : "학생"
                }}
              </span>
              <span class="username">{{ userInfo.username }}</span
              >님!
            </span>
          </h1>
          <ManagerNav v-if="userInfo.role_id !== 'P'" :is-dashboard="true" />
        </div>
        <p class="typed-wrap">
          <span class="typed-text">{{ typedText }}</span>
          <span class="caret" :class="{ invisible: !showCursor }">│</span>
        </p>
      </div>
    </div>

    <!-- 대시보드 탭 네비게이션 -->
    <div class="dashboard-folder">
      <div class="dashboard-tabs" aria-label="대시보드 섹션">
        <button
          :class="{ active: activeTab === 'stats' }"
          :aria-pressed="activeTab === 'stats'"
          @click="activeTab = 'stats'">
          <IconChart class="tab-icon" /> 요약 통계
        </button>
        <button
          :class="{ active: activeTab === 'relations' }"
          :aria-pressed="activeTab === 'relations'"
          @click="activeTab = 'relations'">
          <IconUsers class="tab-icon" /> 관계 관리
        </button>
        <button
          :class="{ active: activeTab === 'messages' }"
          :aria-pressed="activeTab === 'messages'"
          @click="activeTab = 'messages'">
          <IconMessage class="tab-icon" /> 메시지 함
        </button>
        <button
          v-if="shouldShowClassList"
          :class="{ active: activeTab === 'classes' }"
          :aria-pressed="activeTab === 'classes'"
          @click="activeTab = 'classes'">
          <IconClassRoom class="tab-icon" /> {{ classTabLabel }}
        </button>

        <button
          v-if="userInfo.role_id === 'S'"
          :class="{ active: activeTab === 'logs' }"
          :aria-pressed="activeTab === 'logs'"
          @click="activeTab = 'logs'">
          <IconCalendar class="tab-icon" /> 활동 로그
        </button>
      </div>

      <div class="dashboard-content">
        <div v-if="activeTab === 'stats'">
          <TeacherDashboard v-if="userInfo.role_id === 'T'" />
          <ParentDashboard v-else-if="userInfo.role_id === 'P'" />
          <StudentDashboard v-else />
        </div>

        <div v-else-if="activeTab === 'relations'">
          <RelationManager
            @compose-message="openMessageCompose"
            @open-message-thread="openMessageThread"
          />
        </div>

        <div v-else-if="activeTab === 'messages'">
          <MessageManager
            :compose-target="composeMessageTarget"
            :thread-target="messageThreadTarget"
            @compose-consumed="clearMessageComposeTarget"
            @compose-dismissed="handleMessageComposeDismissed"
            @thread-consumed="clearMessageThreadTarget"
          />
        </div>

        <div v-else-if="activeTab === 'classes'">
          <section v-if="shouldShowClassList" class="class-list-panel">
            <div class="class-list-header">
              <h3>{{ classListTitle }}</h3>
              <span class="class-list-count">{{ classList.length }}개</span>
            </div>

            <div v-if="classListLoading" class="class-list-state">
              클래스 목록을 불러오는 중...
            </div>
            <div v-else-if="classListError" class="class-list-state error">
              {{ classListError }}
            </div>
            <div
              v-else-if="classList.length === 0"
              class="class-list-state empty">
              표시할 클래스가 없습니다.
            </div>
            <div v-else class="class-list-grid">
              <article
                v-for="item in classList"
                :key="item.classId"
                class="class-card">
                <div class="class-card-top">
                  <button class="class-link">
                    {{ item.className }}
                  </button>
                </div>
                <p v-if="userInfo.role_id === 'S'" class="class-card-meta">
                  담당 선생님:
                  {{ item.teacherName || `#${item.teacherNo ?? "-"}` }}
                </p>
                <div v-else class="class-card-meta-row">
                  <button
                    class="class-manage-btn"
                    @click="openClassExamManager(item)">
                    연결 고사 ({{ item.examCount }})관리
                  </button>
                  <button
                    class="class-manage-btn"
                    @click="openClassMemberManager(item)">
                    클래스 구성원 ({{ item.studentCount }})관리
                  </button>
                </div>
              </article>
            </div>
          </section>
        </div>

        <div v-else-if="activeTab === 'logs'">
          <UsersLogViewer />
        </div>

        <div v-else-if="activeTab === 'question-books'">
          <QuestionBookManager />
        </div>

        <div v-else-if="activeTab === 'exams'">
          <ExamListManager />
        </div>
      </div>
    </div>

    <ClassMemberManagerModal
      :open="showClassMemberManager"
      :class-item="selectedClassForMembers"
      @close="closeClassMemberManager"
      @saved="handleClassMembersSaved"
    />

    <ClassExamManagerModal
      :open="showClassExamManager"
      :class-item="selectedClassForExams"
      @close="closeClassExamManager"
      @saved="handleClassExamsSaved"
    />

    <!-- 수락 대기 요청 모달 -->
    <Teleport to="body">
      <Transition name="modal-fade">
        <div v-if="currentPendingRequest" class="alert-modal-overlay">
          <div class="alert-modal-card">
            <div class="alert-modal-header">
              <IconUsers class="alert-icon" />
              <h2>새로운 관계 요청</h2>
            </div>
            <div class="alert-modal-body">
              <p>
                <strong>{{ currentPendingRequest.username }}</strong>
                ({{ currentPendingRequest.description || "인맥" }}) 님이 연결을
                요청했습니다.
              </p>
              <p class="alert-subtext">수락하시겠습니까?</p>
            </div>
            <div class="alert-modal-actions">
              <button
                class="btn-reject"
                :disabled="isPendingActionLoading"
                @click="handlePendingAction('reject')">
                거절
              </button>
              <button
                class="btn-accept"
                :disabled="isPendingActionLoading"
                @click="handlePendingAction('accept')">
                {{ isPendingActionLoading ? "처리중..." : "수락" }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </Teleport>
  </div>
</template>

<style scoped>
.dashboard-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.welcome-section {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
  margin: 0;
  padding: 0;
  align-items: flex-start;
  text-align: left;
  width: 100%;
}

.welcome-top-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  width: 100%;
}

.welcome-title {
  font-size: 2rem;
  font-weight: 800;
  color: #f8fafc;
  margin: 0;
  display: flex !important;
  align-items: center !important;
  flex: 0 1 auto;
}

.welcome-title .username {
  color: #c7d2fe;
}

.welcome-text {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  white-space: nowrap;
}

.typed-wrap {
  color: #94a3b8;
  font-size: 1.1rem;
  margin: 0;
  display: flex;
  align-items: center;
  min-height: 1.6rem;
  width: 100%;
}

.typed-text {
  white-space: pre-wrap;
}

.caret {
  color: #818cf8;
  font-weight: 700;
  margin-left: 2px;
  transition: opacity 0.1s;
}

.invisible {
  opacity: 0;
}

.tab-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.role-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.role-badge-inline {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.2rem 0.5rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 6px;
  backdrop-filter: blur(4px);
  font-weight: 600;
  font-size: 0.8rem;
  margin: 0 0.2rem; /* Reduced from 0.5rem */
  transition: all 0.2s;
  cursor: default;
}

.role-S {
  color: #4ade80 !important;
  border-color: rgba(34, 197, 94, 0.3) !important;
  background: rgba(34, 197, 94, 0.05) !important;
}
.role-T {
  color: #818cf8 !important;
  border-color: rgba(99, 102, 241, 0.3) !important;
  background: rgba(99, 102, 241, 0.05) !important;
}
.role-P {
  color: #fbbf24 !important;
  border-color: rgba(245, 158, 11, 0.3) !important;
  background: rgba(245, 158, 11, 0.05) !important;
}

.dashboard-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 0.55rem;
  margin-bottom: 0;
  padding: 0.6rem 0.2rem 0;
  position: relative;
  z-index: 2;
}

.dashboard-folder {
  position: relative;
  padding: 0;
  overflow: visible;
}

.dashboard-tabs button {
  position: relative;
  z-index: 1;
  background: #121a2b;
  border: 1px solid rgba(148, 163, 184, 0.14);
  border-bottom: none;
  color: #7f8da6;
  font-size: 0.98rem;
  font-weight: 600;
  cursor: pointer;
  padding: 0.78rem 1.1rem 0.85rem;
  min-height: 3rem;
  transition:
    transform 0.2s ease,
    color 0.2s ease,
    background 0.2s ease,
    box-shadow 0.2s ease,
    border-color 0.2s ease;
  border-radius: 8px 8px 0 0;
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  box-shadow: none;
}

.dashboard-tabs button:hover {
  color: #dbe4f0;
  transform: translateY(-1px);
  background: #172033;
  border-color: rgba(129, 140, 248, 0.26);
  border-bottom: none;
}

.dashboard-tabs button.active {
  color: #eef2ff;
  background: #1e293b;
  border-color: rgba(129, 140, 248, 0.34);
  border-bottom: none;
  margin-bottom: 0;
  transform: none;
  z-index: 3;
  box-shadow: none;
}

.dashboard-tabs button:focus-visible {
  outline: 2px solid rgba(129, 140, 248, 0.7);
  outline-offset: 2px;
}

.dashboard-content {
  background: #1e293b;
  border-radius: 0 8px 8px 8px;
  border: 1px solid rgba(129, 140, 248, 0.34);
  border-top: none;
  margin-top: -1px;
  padding: 1.75rem 1.8rem 1.9rem;
  min-height: 400px;
  box-shadow: 0 12px 28px rgba(2, 6, 23, 0.22);
}

.class-list-panel {
  margin-top: 1.75rem;
  padding: 1.2rem;
  border-radius: 14px;
  border: 1px solid rgba(129, 140, 248, 0.18);
  background: rgba(15, 23, 42, 0.35);
}

.class-list-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.class-list-header h3 {
  margin: 0;
  color: #f8fafc;
  font-size: 1rem;
}

.class-list-count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 2.4rem;
  padding: 0.3rem 0.65rem;
  border-radius: 999px;
  background: rgba(99, 102, 241, 0.14);
  color: #c7d2fe;
  font-size: 0.82rem;
  font-weight: 700;
}

.class-list-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 0.85rem;
}

.class-card {
  padding: 1rem 1.05rem;
  border-radius: 12px;
  border: 1px solid rgba(148, 163, 184, 0.14);
  background: rgba(30, 41, 59, 0.72);
}

.class-card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  margin-bottom: 0.45rem;
  color: #f8fafc;
}

.class-card-top strong {
  font-size: 0.98rem;
}

.class-link {
  appearance: none;
  background: transparent;
  border: none;
  padding: 0;
  color: #f8fafc;
  font-size: 0.98rem;
  font-weight: 700;
  text-align: left;
  cursor: pointer;
  transition: color 0.2s ease;
}

.class-link:hover {
  color: #a5b4fc;
}

.class-card-top span {
  color: #a5b4fc;
  font-size: 0.85rem;
  font-weight: 700;
}

.class-card-meta {
  margin: 0;
  color: #94a3b8;
  font-size: 0.9rem;
}

.class-card-meta-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.class-manage-btn {
  appearance: none;
  border: 1px solid rgba(99, 102, 241, 0.24);
  background: rgba(99, 102, 241, 0.12);
  color: #c7d2fe;
  border-radius: 999px;
  padding: 0.42rem 0.78rem;
  font-size: 0.8rem;
  font-weight: 700;
  cursor: pointer;
}

.class-manage-btn:hover {
  background: rgba(99, 102, 241, 0.18);
}

.class-list-state {
  padding: 1rem 0.25rem;
  color: #94a3b8;
}

.class-list-state.error {
  color: #fda4af;
}

.class-list-state.empty {
  color: #64748b;
}
</style>
