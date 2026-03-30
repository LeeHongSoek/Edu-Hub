<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import StudentDashboard from '~/components/dashboard/StudentDashboard.vue';
import TeacherDashboard from '~/components/dashboard/TeacherDashboard.vue';
import ParentDashboard from '~/components/dashboard/ParentDashboard.vue';
import StudyLogViewer from '~/components/dashboard/StudyLogViewer.vue';
import RelationManager from '~/components/dashboard/RelationManager.vue';
import MessageManager from '~/components/dashboard/MessageManager.vue';
import QuestionBookManager from '~/components/dashboard/QuestionBookManager.vue';
import ExamListManager from '~/components/dashboard/ExamListManager.vue';

const userCookie = useCookie('user_info');
const userInfo = computed(() => {
  if (!userCookie.value) return null;
  try {
    return typeof userCookie.value === 'string'
      ? JSON.parse(userCookie.value)
      : userCookie.value;
  } catch { return null; }
});

const activeTab = ref('stats'); // 'stats', 'relations', 'messages', 'logs', 'question-books', 'exams'

onMounted(() => {
  if (!userInfo.value) {
    navigateTo('/');
  }
});
</script>

<template>
  <div v-if="userInfo" class="dashboard-page">
    <div class="dashboard-header">
      <div class="welcome-section">
        <h1 class="welcome-title">
          안녕하세요,
          <span class="role-badge-inline" :class="'role-' + userInfo.role">
            <span v-if="userInfo.role === 'S'">🎓</span>
            <span v-else-if="userInfo.role === 'T'">👨‍🏫</span>
            <span v-else>🏠</span>
            {{ userInfo.role === 'T' ? '선생님' : userInfo.role === 'P' ? '학부모' : '학생' }}
          </span>
          <span class="username">{{ userInfo.username }}</span>님!
          <!-- 대시보드 내 네비게이션 버튼 (타이틀 바로 뒤) -->
          <div v-if="userInfo.role_id !== 'P'" class="quick-nav">
            <NuxtLink to="/questions?mine=true" class="nav-btn">
              <span class="nav-icon">📄</span>
              <span>나의 문제목록</span>
            </NuxtLink>
            <NuxtLink to="/question-books" class="nav-btn">
              <span class="nav-icon">📚</span>
              <span>나의 문제집목록</span>
            </NuxtLink>
            <NuxtLink to="/exams" class="nav-btn">
              <span class="nav-icon">📝</span>
              <span>나의 고사집목록</span>
            </NuxtLink>
          </div>
        </h1>
        <p class="welcome-sub">오늘도 지식을 완성하는 하루 되세요.</p>
      </div>
    </div>

    <!-- 대시보드 탭 네비게이션 -->
    <div class="dashboard-tabs">
      <button 
        :class="{ active: activeTab === 'stats' }" 
        @click="activeTab = 'stats'"
      >📊 요약 통계</button>
      <button 
        :class="{ active: activeTab === 'relations' }" 
        @click="activeTab = 'relations'"
      >👥 관계 관리</button>
      <button 
        :class="{ active: activeTab === 'messages' }" 
        @click="activeTab = 'messages'"
      >💬 메시지 함</button>
      <button 
        v-if="userInfo.role_id === 'S'"
        :class="{ active: activeTab === 'logs' }" 
        @click="activeTab = 'logs'"
      >🕒 학습 활동 로그</button>
    </div>

    <div class="dashboard-content">
      <div v-if="activeTab === 'stats'">
        <TeacherDashboard v-if="userInfo.role_id === 'T'" />
        <ParentDashboard v-else-if="userInfo.role_id === 'P'" />
        <StudentDashboard v-else />
      </div>
      
      <div v-else-if="activeTab === 'relations'">
        <RelationManager />
      </div>
      
      <div v-else-if="activeTab === 'messages'">
        <MessageManager />
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
  color: #818cf8;
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
  font-size: 1rem;
  line-height: 1;
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

.role-S { color: #4ade80 !important; border-color: rgba(34, 197, 94, 0.3) !important; background: rgba(34, 197, 94, 0.05) !important; }
.role-T { color: #818cf8 !important; border-color: rgba(99, 102, 241, 0.3) !important; background: rgba(99, 102, 241, 0.05) !important; }
.role-P { color: #fbbf24 !important; border-color: rgba(245, 158, 11, 0.3) !important; background: rgba(245, 158, 11, 0.05) !important; }

.dashboard-tabs {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  padding-bottom: 1rem;
}

.dashboard-tabs button {
  background: none;
  border: none;
  color: #64748b;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  padding: 0.5rem 1rem;
  transition: all 0.2s;
  border-radius: 8px;
}

.dashboard-tabs button:hover {
  color: #f8fafc;
  background: rgba(255, 255, 255, 0.05);
}

.dashboard-tabs button.active {
  color: #818cf8;
  background: rgba(129, 140, 248, 0.1);
}

.dashboard-content {
  background: rgba(30, 41, 59, 0.5);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.05);
  padding: 2rem;
  min-height: 400px;
}
</style>
