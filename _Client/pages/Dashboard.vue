<script setup lang="ts">
import { ref, onMounted, computed, nextTick } from "vue";
import StudentDashboard from "~/components/dashboard/StudentDashboard.vue";
import TeacherDashboard from "~/components/dashboard/TeacherDashboard.vue";
import ParentDashboard from "~/components/dashboard/ParentDashboard.vue";
import StudyLogViewer from "~/components/dashboard/StudyLogViewer.vue";
import RelationManager from "~/components/dashboard/RelationManager.vue";
import MessageManager from "~/components/dashboard/MessageManager.vue";
import QuestionBookManager from "~/components/dashboard/QuestionBookManager.vue";
import ExamListManager from "~/components/dashboard/ExamListManager.vue";
import IconGraduationCap from "~/assets/icons/IconGraduationCap.svg?component";
import IconBoard from "~/assets/icons/IconBoard.svg?component";
import IconHome from "~/assets/icons/IconHome.svg?component";
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconBook from "~/assets/icons/IconBook.svg?component";
import IconPencil from "~/assets/icons/IconPencil.svg?component";
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
const currentRoleId = computed(() => userInfo.value?.role_id || userInfo.value?.role || "");

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

onMounted(() => {
  if (!userInfo.value) {
    navigateTo("/");
    return;
  }

  fetchClassList();
});
</script>

<template>
  <div v-if="userInfo" class="dashboard-page">
    <div class="dashboard-header">
      <div class="welcome-section">
        <h1 class="welcome-title">
          안녕하세요,
          <span class="role-badge-inline" :class="'role-' + userInfo.role">
            <IconGraduationCap v-if="userInfo.role === 'S'" class="role-icon" />
            <IconBoard v-else-if="userInfo.role === 'T'" class="role-icon" />
            <IconHome v-else class="role-icon" />
            {{
              userInfo.role === "T"
                ? "선생님"
                : userInfo.role === "P"
                  ? "학부모"
                  : "학생"
            }}
          </span>
          <span class="username">{{ userInfo.username }}</span>님!
          <!-- 대시보드 내 네비게이션 버튼 (타이틀 바로 뒤) -->
          <div v-if="userInfo.role_id !== 'P'" class="quick-nav">
            <NuxtLink to="/questions?mine=true" class="nav-btn">
              <IconFileText class="nav-icon" />
              <span>문제 목록</span>
            </NuxtLink>
            <NuxtLink to="/question-books" class="nav-btn">
              <IconBook class="nav-icon" />
              <span>문제집 목록</span>
            </NuxtLink>
            <NuxtLink to="/exams" class="nav-btn">
              <IconPencil class="nav-icon" />
              <span>고사집 목록</span>
            </NuxtLink>
          </div>
        </h1>
        <p class="welcome-sub">오늘도 지식을 완성하는 하루 되세요.</p>
      </div>
    </div>

    <!-- 대시보드 탭 네비게이션 -->
    <div class="dashboard-folder">
      <div class="dashboard-tabs" aria-label="대시보드 섹션">
        <button
          :class="{ active: activeTab === 'stats' }"
          :aria-pressed="activeTab === 'stats'"
          @click="activeTab = 'stats'"
        >
          <IconChart class="tab-icon" /> 요약 통계
        </button>
        <button
          :class="{ active: activeTab === 'relations' }"
          :aria-pressed="activeTab === 'relations'"
          @click="activeTab = 'relations'"
        >
          <IconUsers class="tab-icon" /> 관계 관리
        </button>
        <button
          :class="{ active: activeTab === 'messages' }"
          :aria-pressed="activeTab === 'messages'"
          @click="activeTab = 'messages'"
        >
          <IconMessage class="tab-icon" /> 메시지 함
        </button>
        <button
          v-if="shouldShowClassList"
          :class="{ active: activeTab === 'classes' }"
          :aria-pressed="activeTab === 'classes'"
          @click="activeTab = 'classes'"
        >
          <IconClassRoom class="tab-icon" /> {{ classTabLabel }}
        </button>

        <button
          v-if="userInfo.role_id === 'S'"
          :class="{ active: activeTab === 'logs' }"
          :aria-pressed="activeTab === 'logs'"
          @click="activeTab = 'logs'"
        >
          <IconCalendar class="tab-icon" /> 학습 활동 로그
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
            <div v-else-if="classList.length === 0" class="class-list-state empty">
              표시할 클래스가 없습니다.
            </div>
            <div v-else class="class-list-grid">
              <article
                v-for="item in classList"
                :key="item.classId"
                class="class-card"
              >
                <div class="class-card-top">
                  <button class="class-link" @click="openClassExams(item)">
                    {{ item.className }}
                  </button>
                  <span>{{ item.examCount }}개</span>
                </div>
                <p v-if="userInfo.role_id === 'S'" class="class-card-meta">
                  담당 선생님:
                  {{ item.teacherName || `#${item.teacherNo ?? "-"}` }}
                </p>
                <p v-else class="class-card-meta">수강생 수: {{ item.studentCount }}명</p>
              </article>
            </div>
          </section>
        </div>

        <div v-else-if="activeTab === 'logs'">
          <StudyLogViewer />
        </div>

        <div v-else-if="activeTab === 'question-books'">
          <QuestionBookManager />
        </div>

        <div v-else-if="activeTab === 'exams'">
          <ExamListManager />
        </div>
      </div>
    </div>
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
  margin-bottom: 2rem;
}

.welcome-title {
  font-size: 2rem;
  font-weight: 800;
  color: #f8fafc;
  margin-bottom: 0.5rem;
  display: flex !important;
  flex-direction: row !important;
  align-items: center !important;
  gap: 0.4rem !important; /* Reduced from 2rem */
  white-space: nowrap;
}

.welcome-title .username {
  color: #c7d2fe;
}

.welcome-sub {
  color: #94a3b8;
  font-size: 1.1rem;
  margin-bottom: 0;
}

.quick-nav {
  display: flex !important;
  flex-direction: row !important;
  align-items: center !important;
  gap: 0.75rem;
  margin-left: 1rem;
}

.nav-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
  background: rgba(129, 140, 248, 0.1);
  border: 1px solid rgba(129, 140, 248, 0.2);
  color: #818cf8;
  padding: 0.6rem 1.2rem;
  border-radius: 10px;
  font-weight: 600;
  font-size: 0.9rem;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.2s;
}

.nav-btn:hover {
  background: rgba(129, 140, 248, 0.2);
  transform: translateY(-2px);
}

.nav-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
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
