<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from "vue";
import type { QuestionListResponse } from "~/types";
import LatexRenderer from "~/components/LatexRenderer.vue";
import DailyQuestionsModal from "~/components/DailyQuestionsModal.vue";
import VuePdfEmbed from "vue-pdf-embed";
import manualPdfUrl from "~/assets/Edu-Hub_Project_Manual.pdf?url";
import IconShield from "~/assets/icons/IconShield.svg?component";
import IconCheck from "~/assets/icons/IconCheck.svg?component";
import IconSparkle from "~/assets/icons/IconSparkle.svg?component";
import IconCamera from "~/assets/icons/IconCamera.svg?component";
import IconRobot from "~/assets/icons/IconRobot.svg?component";
import IconMail from "~/assets/icons/IconMail.svg?component";
import IconRocket from "~/assets/icons/IconRocket.svg?component";
import IconHome from "~/assets/icons/IconHome.svg?component";
import IconUser from "~/assets/icons/IconUser.svg?component";
import IconLogout from "~/assets/icons/IconLogout.svg?component";
import IconEye from "~/assets/icons/IconEye.svg?component";
import IconEyeOff from "~/assets/icons/IconEyeOff.svg?component";
import IconArrowRight from "~/assets/icons/IconArrowRight.svg?component";
import IconClose from "~/assets/icons/IconClose.svg?component";
import IconInfo from "~/assets/icons/IconInfo.svg?component";
import IconManual from "~/assets/icons/IconManual.svg?component";
import NumberAnimation from "vue-number-animation";

const { apiBase } = useApi();

definePageMeta({ layout: false });

// 페이드인 상태
const isLoaded = ref(false);

// 소개 모달
const showIntro = ref(false);
const showManual = ref(false);
const manualPdfSrc = manualPdfUrl;
let introTimer: any = null;

function syncBodyScrollLock() {
  document.body.style.overflow =
    showIntro.value || showRegister.value || showManual.value ? "hidden" : "";
}

function openIntro() {
  showIntro.value = true;
  syncBodyScrollLock();
  // 10초 뒤 자동 닫기
  if (introTimer) clearTimeout(introTimer);
  introTimer = setTimeout(closeIntro, 10000);
}

function closeIntro() {
  showIntro.value = false;
  syncBodyScrollLock();
  if (introTimer) {
    clearTimeout(introTimer);
    introTimer = null;
  }
}

function openManual() {
  showManual.value = true;
  syncBodyScrollLock();
}

function closeManual() {
  showManual.value = false;
  syncBodyScrollLock();
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === "Escape") {
    closeManual();
    closeIntro();
    closeRegister();
  }
}
onMounted(() => window.addEventListener("keydown", onKeydown));
onUnmounted(() => window.removeEventListener("keydown", onKeydown));

// 타이핑 애니메이션
const typedText = ref("");
const showCursor = ref(true);
const phrases = [
  "문제를 풀며 지식을 완성한다는 인류",
  "매일 도전하고, 매일 성장하는 인류",
  "질문이 지식이 되고, 지식이 힘이 되는 인류",
];
let phraseIdx = 0;
let charIdx = 0;
let deleting = false;

function typeLoop() {
  const cur = phrases[phraseIdx];
  if (!deleting) {
    typedText.value = cur.slice(0, ++charIdx);
    if (charIdx === cur.length) {
      deleting = true;
      setTimeout(typeLoop, 2400);
      return;
    }
  } else {
    typedText.value = cur.slice(0, --charIdx);
    if (charIdx === 0) {
      deleting = false;
      phraseIdx = (phraseIdx + 1) % phrases.length;
    }
  }
  setTimeout(typeLoop, deleting ? 35 : 80);
}

// 로그인 상태
const userIdInput = ref("");
const passwordInput = ref("");
const isLoggingIn = ref(false);
const authError = ref("");

// 세션 사용자 정보
const userCookie = useCookie("user_info");
const loggedInUser = computed(() => {
  if (!userCookie.value) return null;
  try {
    return typeof userCookie.value === "string"
      ? JSON.parse(userCookie.value)
      : userCookie.value;
  } catch {
    return null;
  }
});

const showUserModal = ref(false);

function handleLogout() {
  const token = useCookie("auth_token");
  token.value = null;
  userCookie.value = null;
}

// 비밀번호 표시 토글
const showLoginPw = ref(false);
const showRegPw = ref(false);
const showRegPwConfirm = ref(false);

// 통계 데이터
const stats = ref({
  questions: 0,
  teachers: 0,
  students: 0,
  parents: 0,
});
const statsVisible = ref(false);

const animatedStats = computed(() => {
  return {
    questions: statsVisible.value ? stats.value.questions : 0,
    teachers: statsVisible.value ? stats.value.teachers : 0,
    students: statsVisible.value ? stats.value.students : 0,
    parents: statsVisible.value ? stats.value.parents : 0,
  };
});

const fetchStats = async () => {
  const url = `${apiBase.value}/stats`;
  console.log("[fetchStats] Fetching from:", url);
  try {
    const data = await $fetch(url);
    console.log("[fetchStats] Success:", data);
    if (data) {
      stats.value = data as any;
    }
  } catch (err: any) {
    console.error("[fetchStats] Error:", err);
    if (err.data) console.error("[fetchStats] Error data:", err.data);
  }
};

const formatStats = (val: number) => Math.floor(val).toLocaleString();

// 티커 데이터
const showTicker = ref(false);
const tickerQuestions = ref<any[]>([]);

const fetchTickerData = async () => {
  console.log("[ticker] Starting fetch...");
  try {
    const data = await $fetch<QuestionListResponse>(
      `${apiBase.value}/questions`,
      {
        method: "POST",
        body: {
          page: 1,
          limit: 10,
        },
      },
    );
    console.log("[ticker] Data received:", data?.items?.length ?? 0);
    if (Array.isArray(data?.items) && data.items.length > 0) {
      const sorted = [...data.items].sort(
        (a, b) => Number(b.question_id) - Number(a.question_id),
      );
      tickerQuestions.value = sorted;
      showTicker.value = true;
      console.log(
        "[ticker] All Questions selected:",
        tickerQuestions.value.map((q) => q.question_id),
      );
    }
  } catch (err) {
    console.error("[fetchTickerData] Error:", err);
  }
};

const dailyQuestions = ref<any[]>([]);
const showDailyModal = ref(false);

const checkDailyRefresh = async () => {
  try {
    const data = await $fetch<any>(`${apiBase.value}/question-books/daily/refresh`);
    if (data && data.items) {
      dailyQuestions.value = data.items.map((it: any) => it.question);
    }
  } catch (err) {
    console.error("[checkDailyRefresh] Error:", err);
  }
};

const handlePublicQuestions = () => {
  if (dailyQuestions.value.length > 0) {
    showDailyModal.value = true;
  } else {
    // 만약 데이터가 없으면 강제 리프레시 시도 후 오픈
    checkDailyRefresh().then(() => {
      if (dailyQuestions.value.length > 0) {
        showDailyModal.value = true;
      } else {
        alert("오늘의 공개문제를 불러올 수 없거나, 오늘 문제가 아직 준비되지 않았습니다!");
      }
    }).catch(err => {
      alert("공개문제 호출 오류: " + err.message);
    });
  }
};

const handleLogin = async () => {
  if (!userIdInput.value || !passwordInput.value) {
    authError.value = "아이디와 비밀번호를 입력해주세요.";
    return;
  }

  isLoggingIn.value = true;
  authError.value = "";

  try {
    // 클라이언트 : [POST] /auth/login
    const { data, error } = await useFetch(`${apiBase.value}/auth/login`, {
      method: "POST",
      body: {
        userId: userIdInput.value,
        password: passwordInput.value,
      },
    });

    if (error.value) {
      authError.value =
        error.value.data?.message || "로그인 중 오류가 발생했습니다.";
      return;
    }

    if (data.value) {
      // JWT 토큰 저장
      const token = useCookie("auth_token");
      token.value = (data.value as any).access_token;

      const user = useCookie("user_info");
      user.value = JSON.stringify((data.value as any).user);

      console.log('[사용자 정보] user.value = ',user.value);

      navigateTo("/dashboard");
    }
  } catch (err) {
    authError.value = "서버 연결에 실패했습니다.";
  } finally {
    isLoggingIn.value = false;
  }
};

// 회원가입 모달
const showRegister = ref(false);
const regUserId = ref("");
const regPassword = ref("");
const regPasswordConfirm = ref("");
const regUsername = ref("");
const regEmail = ref("");
const regRole = ref("S"); // 기본값 S (Student)

const isIdChecked = ref(false);
const isIdAvailable = ref(false);
const checkingId = ref(false);

const isRegistering = ref(false);
const regError = ref("");

function openRegister() {
  showRegister.value = true;
  authError.value = "";
  isIdChecked.value = false;
  isIdAvailable.value = false;
  syncBodyScrollLock();
}

const checkId = async () => {
  if (!regUserId.value) {
    regError.value = "아이디를 입력해주세요.";
    return;
  }

  checkingId.value = true;
  regError.value = "";

  try {
    const { data } = await useFetch(
      `${apiBase.value}/auth/check-id/${regUserId.value}`,
    );

    if (data.value) {
      isIdAvailable.value = (data.value as any).isAvailable;
      isIdChecked.value = true;
      if (!isIdAvailable.value) {
        regError.value = "이미 사용 중인 아이디입니다.";
      }
    }
  } catch (err) {
    regError.value = "중복 확인 실패";
  } finally {
    checkingId.value = false;
  }
};

const handleRegister = async () => {
  if (
    !regUserId.value ||
    !regPassword.value ||
    !regUsername.value ||
    !regEmail.value
  ) {
    regError.value = "모든 필드를 입력해주세요.";
    return;
  }

  if (!isIdChecked.value || !isIdAvailable.value) {
    regError.value = "아이디 중복 확인을 해주세요.";
    return;
  }

  if (regPassword.value !== regPasswordConfirm.value) {
    regError.value = "비밀번호가 일치하지 않습니다.";
    return;
  }

  isRegistering.value = true;
  regError.value = "";

  try {
    const { data, error } = await useFetch(`${apiBase.value}/auth/register`, {
      method: "POST",
      body: {
        userId: regUserId.value,
        password: regPassword.value,
        username: regUsername.value,
        email: regEmail.value,
        roleId: regRole.value,
      },
    });

    if (error.value) {
      regError.value =
        error.value.data?.message || "회원가입 중 오류가 발생했습니다.";
      return;
    }

    alert("회원가입이 완료되었습니다. 로그인해주세요.");
    closeRegister();
    userIdInput.value = regUserId.value; // 가입한 아이디 채워주기
  } catch (err) {
    regError.value = "서버 연결에 실패했습니다.";
  } finally {
    isRegistering.value = false;
  }
};

function closeRegister() {
  showRegister.value = false;
  syncBodyScrollLock();
}

onMounted(() => {
  // 이미 로그인 상태면 문제 목록으로 리디렉트
  const authToken = useCookie("auth_token");
  if (authToken.value) {
    navigateTo("/dashboard");
    return;
  }

  setTimeout(() => {
    isLoaded.value = true;
    // 커튼이 사라지는 연출(2.8s)과 어느 정도 맞춰서 숫자 애니메이션 시작
    setTimeout(() => {
      statsVisible.value = true;
    }, 1200);
  }, 80);

  setTimeout(typeLoop, 1600);
  fetchStats();
  setInterval(() => {
    showCursor.value = !showCursor.value;
  }, 530);
  // 즉시 티커 노출
  fetchTickerData();
  // 오늘의 공개문제 리프레시 및 준비
  checkDailyRefresh();
});
</script>

<template>
  <div class="page">
    <!-- ══════════════════════════════════════
         검은 → 투명으로 스윽 밝아지는 커튼
    ══════════════════════════════════════ -->
    <div :class="['curtain', { 'curtain--open': isLoaded }]"></div>

    <!-- ══════════════════════════════════════
         전체 배경: 책 이미지
    ══════════════════════════════════════ -->
    <div class="bg-image" :class="{ 'bg-image--visible': isLoaded }">
      <!-- public/hero-image.jpg 가 없으면 gradient로 대체 -->
    </div>

    <!-- 배경 위 어두운 그라데이션 겹침 (가독성 확보) -->
    <div class="bg-overlay"></div>

    <!-- ══════════════════════════════════════
         실제 콘텐츠 레이어
    ══════════════════════════════════════ -->
    <div class="content" :class="{ 'content--visible': isLoaded }">
      <!-- ─── 상단 로고/네비 ─── -->
      <header class="top-bar">
        <div class="logo">
          <span class="logo-icon">📘</span>
          <span class="logo-text">Edu<em>Hub</em></span>
        </div>
        <nav class="nav-links">
          <a
            v-if="!loggedInUser"
            href="#"
            @click.prevent="openIntro"
            class="intro-link"
          >
            <IconInfo class="icon-info" />소개
          </a>
          <a
            v-if="!loggedInUser"
            href="#"
            @click.prevent="openManual"
            class="intro-link manual-link"
          >
            <IconManual class="icon-manual" />메뉴얼
          </a>
          <template v-if="loggedInUser">
            <div class="nav-path-box">
              <span class="path-home"><IconHome class="icon-home" />홈</span>
              <span class="path-sep">&gt;</span>
              <NuxtLink to="/questions" class="path-current"
                >문제 목록</NuxtLink
              >
            </div>
            <a
              href="#"
              class="user-greeting"
              @click.prevent="showUserModal = true"
            >
              <IconUser class="icon-user" />
              {{ loggedInUser.username }}님
            </a>
            <a href="#" class="logout-link" @click.prevent="handleLogout">
              <IconLogout class="icon-logout" />
              로그아웃
            </a>
          </template>
        </nav>
      </header>

      <!-- ─── 중앙 히어로 + 우측 로그인 ─── -->
      <div class="main-row">
        <!-- 왼쪽: 히어로 카피 -->
        <section class="hero">
          <p class="eyebrow">✦ &nbsp;AI 시대의 지식 혁명 플랫폼</p>

          <!-- 사전 표제어 스타일 타이틀 -->
          <div class="dict-entry" role="heading" aria-level="1">
            <div class="dict-headword">
              <span class="dict-word">호모</span>
              <span class="dict-sep">-</span>
              <span class="dict-word accent">문풀</span>
              <span class="dict-sep dict-sep--ipa">ː</span>
              <span class="dict-word">리언스</span>
            </div>
            <div class="dict-meta">
              <span class="dict-pron">[ho·mo mun·pul·li·eon·seu]</span>
              <span class="dict-pos">명사 · <em>homo solvens</em></span>
            </div>
          </div>

          <p class="typed-wrap">
            <span class="typed-text">{{ typedText }}</span>
            <span class="caret" :class="{ invisible: !showCursor }">│</span>
          </p>

          <div class="hero-desc-container">
            <p class="hero-desc">
              문제를 풀수록 지식이 쌓이고,<br />
              지식이 쌓일수록 세상이 보입니다.
            </p>

            <!-- 즉시 흐르는 티커 -->
            <transition name="fade">
              <div
                v-if="showTicker && tickerQuestions.length > 0"
                class="ticker-box"
              >
                <div class="ticker-label">
                  <span class="ticker-dot"></span>
                  최신 등록문제 리스트
                </div>
                <div class="ticker-window">
                  <div class="ticker-track">
                    <div
                      v-for="(q, idx) in [
                        ...tickerQuestions,
                        ...tickerQuestions,
                      ]"
                      :key="idx"
                      class="ticker-item"
                    >
                      <span class="t-id">#{{ q.question_id }}</span>
                      <LatexRenderer
                        class="t-text"
                        :text="
                          q.content?.trim() ||
                          q.explanation?.trim() ||
                          q.answer?.trim() ||
                          '지식을 완성하는 문제'
                        "
                        :strip-newlines="true"
                      />
                      <span class="t-new">NEW</span>
                    </div>
                  </div>
                </div>
              </div>
            </transition>
          </div>

          <!-- 칩은 제거하고 통계는 유지 (간격 7px 고정) -->
          <div style="height: 7px; margin-top: -1.2rem"></div>

          <div class="stats-row">
            <div class="vbar"></div>
            <div class="stat special">
              <b>
                <ClientOnly>
                  <NumberAnimation
                    :from="0"
                    :to="animatedStats.questions"
                    :duration="1.5"
                    :format="formatStats"
                    easing="linear"
                  />
                </ClientOnly>
              </b>
              <small>등록 문제</small>
            </div>
            <div class="vbar"></div>
            <div class="stat">
              <b>
                <ClientOnly>
                  <NumberAnimation
                    :from="0"
                    :to="animatedStats.teachers"
                    :duration="1.5"
                    :format="formatStats"
                    easing="linear"
                  />
                </ClientOnly>
              </b>
              <small>선생님</small>
            </div>
            <div class="vbar"></div>
            <div class="stat">
              <b>
                <ClientOnly>
                  <NumberAnimation
                    :from="0"
                    :to="animatedStats.students"
                    :duration="1.5"
                    :format="formatStats"
                    easing="linear"
                  />
                </ClientOnly>
              </b>
              <small>학생</small>
            </div>
            <div class="vbar"></div>
            <div class="stat">
              <b>
                <ClientOnly>
                  <NumberAnimation
                    :from="0"
                    :to="animatedStats.parents"
                    :duration="1.5"
                    :format="formatStats"
                    easing="linear"
                  />
                </ClientOnly>
              </b>
              <small>학부모</small>
            </div>
            <div class="vbar"></div>
          </div>
        </section>

        <!-- 오른쪽: 로그인 카드 -->
        <aside class="auth-box">
          <div class="auth-card">
            <h2 class="auth-title">시작하기</h2>
            <p class="auth-sub">
              무료 가입 전
              <button
                type="button"
                class="btn-public"
                @click="handlePublicQuestions"
              >오늘의 공개문제</button>를 풀어보세요
            </p>
           

            <form @submit.prevent="handleLogin" class="form">
              <div class="field">
                <label for="email">이메일/ID</label>
                <input
                  id="email"
                  v-model="userIdInput"
                  type="text"
                  placeholder="아이디를 입력하세요"
                  required
                  style="ime-mode: inactive"
                  inputmode="url"
                  autocapitalize="none"
                />
              </div>
              <div class="field">
                <label for="pw">비밀번호</label>
                <div class="pw-wrap">
                  <input
                    id="pw"
                    v-model="passwordInput"
                    :type="showLoginPw ? 'text' : 'password'"
                    required
                  />
                  <button
                    type="button"
                    class="pw-toggle"
                    @click="showLoginPw = !showLoginPw"
                    aria-label="비밀번호 보기"
                  >
                    <IconEye v-if="!showLoginPw" width="18" height="18" />
                    <IconEyeOff v-else width="18" height="18" />
                  </button>
                </div>
              </div>
              <div class="auth-error-msg">{{ authError }}&nbsp;</div>
               <p class="auth-sub auth-sub-sample">
              셈플 계정으로 로그인해보세요<br />학생 [id:s pw:x], 교사[id:t pw:x], 부모 [id:p pw:x]
            </p>
              <div class="row-util">
                <label class="chk"><input type="checkbox" />로그인 유지</label>
                <a href="#" class="link-sm">비밀번호 찾기</a>
              </div>
              <button class="btn-login" :disabled="isLoggingIn">
                {{ isLoggingIn ? "로그인 중..." : "로그인" }}
                <IconArrowRight v-if="!isLoggingIn" width="16" height="16" />
              </button>
            </form>

            <div class="divider"><span>또는</span></div>

            <button class="btn-google">
              <img
                src="https://www.svgrepo.com/show/475656/google-color.svg"
                alt=""
                width="18"
              />
              Google로 계속하기
            </button>

            <p class="join-text">
              계정이 없으신가요?&nbsp;
              <a href="#" class="link-accent" @click.prevent="openRegister"
                >무료 회원가입 →</a
              >
            </p>

            <div class="badge-row">
              <span><IconShield class="badge-icon" /> SSL 보안</span>
              <span><IconCheck class="badge-icon" /> 개인정보보호</span>
              <span><IconSparkle class="badge-icon" /> 무료 플랜</span>
            </div>
          </div>
        </aside>
      </div>
      <!-- /main-row -->
    </div>
    <!-- /content -->

    <!-- ══════════════════════════════════════
         소개 모달
    ══════════════════════════════════════ -->
    <Transition name="modal">
      <div v-if="showIntro" class="modal-backdrop" @click.self="closeIntro">
        <div
          class="modal-box"
          role="dialog"
          aria-modal="true"
          aria-label="AI Edu-Hub 소개"
        >
          <button class="modal-close" @click="closeIntro" aria-label="닫기">
            <IconClose width="20" height="20" />
          </button>

          <div class="modal-header">
             <span class="modal-badge"
              ><IconBook class="badge-icon" /> AI Edu-Hub 소개</span
            >
            <h2 class="modal-title">
              사진 한 장으로 시작하는<br /><em>우리 반 맞춤형 스마트 학습지</em>
            </h2>
            <p class="modal-lead">
              안녕하세요! AI Edu-Hub는 선생님의 문제 출제를 도와주고,
              여러분에게는 나만의 AI 튜터를 부모님께는 학습 리포트를 제공하는
              스마트 학습 플랫폼이에요!
            </p>
          </div>

          <div class="modal-grid">
            <div class="modal-features">
              <div class="feat-card">
                <div class="feat-icon">
                  <IconCamera class="feat-icon-svg" />
                </div>
                <div class="feat-body">
                  <h3>1초 문제 등록</h3>
                  <p>
                    선생님이 문제집 사진을 찍으면, AI가 읽어서 바로 디지털
                    문제로 바꿔줘요. 타이핑 없이 쉽게 시험지를 만들 수 있어요!
                  </p>
                </div>
              </div>
              <div class="feat-card">
                <div class="feat-icon"><IconRobot class="feat-icon-svg" /></div>
                <div class="feat-body">
                  <h3>포기 없는 학습</h3>
                  <p>
                    AI가 즉시 채점하고 틀린 이유를 설명해줘요. 복습까지 확실히
                    도와주니 성적이 쑥쑥!
                  </p>
                </div>
              </div>
              <div class="feat-card">
                <div class="feat-icon"><IconMail class="feat-icon-svg" /></div>
                <div class="feat-body">
                  <h3>부모님 안심 리포트</h3>
                  <p>
                    시험이 끝나면 점수와 분석 리포트가 부모님께 자동 발송되어
                    어떤 부분이 약한지 한눈에 보여줍니다.
                  </p>
                </div>
              </div>
            </div>

            <div class="modal-steps">
              <h3 class="steps-title">
                <IconRocket class="steps-title-icon" /> 이렇게 사용해요!
              </h3>
              <div class="steps-list">
                <div class="step-item">
                  <span class="step-num">1</span>
                  <div>
                    <strong>선생님</strong>이 자료를 찍어
                    <strong>'우리 반 교실'</strong>에 올려요.
                  </div>
                </div>
                <div class="step-item">
                  <span class="step-num">2</span>
                  <div>
                    <strong>학생</strong>은 앱으로 접속해 게임처럼 문제를 풀고
                    친구들과 토론해요!
                  </div>
                </div>
                <div class="step-item">
                  <span class="step-num">3</span>
                  <div>
                    <strong>부모님</strong>은 리포트를 보고 따뜻한 격려를
                    건네요.
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <p class="modal-slogan">
              AI Edu-Hub와 함께라면 공부가 더 이상 숙제가 아닌
              <strong>즐거운 경험</strong>이 됩니다!
            </p>
          </div>
        </div>
      </div>
    </Transition>

    <Transition name="modal">
      <div v-if="showManual" class="modal-backdrop" @click.self="closeManual">
        <div
          class="modal-box manual-modal"
          role="dialog"
          aria-modal="true"
          aria-label="Edu-Hub 프로젝트 메뉴얼"
        >
          <div class="modal-header manual-modal-header">
            <span class="modal-badge">Edu-Hub 매뉴얼 </span>
            <!-- <h2 class="modal-title">Edu-Hub_Project_Manual.pdf</h2> -->
            <button class="modal-close" @click="closeManual" aria-label="닫기">
              <IconClose width="20" height="20" />
            </button>
          </div>

          <div class="manual-pdf-wrap">
            <ClientOnly>
              <VuePdfEmbed class="manual-pdf" :source="manualPdfSrc" />
              <template #fallback>
                <div class="manual-loading">메뉴얼을 불러오는 중입니다...</div>
              </template>
            </ClientOnly>
          </div>
        </div>
      </div>
    </Transition>

    <!-- ══════════════════════════════════════
         회원가입 모달
    ══════════════════════════════════════ -->
    <Transition name="modal">
      <div
        v-if="showRegister"
        class="modal-backdrop"
        @click.self="closeRegister"
      >
        <div
          class="modal-box reg-modal"
          role="dialog"
          aria-modal="true"
          aria-label="회원가입"
        >
          <button class="modal-close" @click="closeRegister" aria-label="닫기">
            <IconClose width="20" height="20" />
          </button>

          <div class="modal-header">
            <span class="modal-badge"
              ><IconSparkle class="badge-icon" /> 환영합니다</span
            >
            <h2 class="modal-title">EduHub 회원가입</h2>
            <p class="modal-lead">
              쉽고 빠른 가입으로 스마트한 학습을 시작하세요.
            </p>
          </div>

          <form @submit.prevent="handleRegister" class="reg-form">
            <div class="reg-grid">
              <div class="field full-width id-field">
                <label>아이디</label>
                <div class="input-with-btn">
                  <input
                    v-model="regUserId"
                    type="text"
                    placeholder="10자 이내"
                    required
                    @input="isIdChecked = false"
                    style="ime-mode: inactive"
                    inputmode="url"
                    autocapitalize="none"
                  />
                  <button
                    type="button"
                    class="btn-check"
                    @click="checkId"
                    :disabled="checkingId"
                  >
                    {{ checkingId ? "..." : "중복확인" }}
                  </button>
                </div>
                <p
                  v-if="isIdChecked"
                  :class="['id-status', isIdAvailable ? 'success' : 'fail']"
                >
                  {{
                    isIdAvailable
                      ? "사용 가능한 아이디입니다."
                      : "이미 사용 중인 아이디입니다."
                  }}
                </p>
              </div>
              <div class="field">
                <label>이름</label>
                <input
                  v-model="regUsername"
                  type="text"
                  placeholder="이름 입력"
                  required
                />
              </div>
              <div class="field">
                <label>이메일</label>
                <input
                  v-model="regEmail"
                  type="email"
                  placeholder="example@mail.com"
                  required
                />
              </div>
              <div class="field">
                <label>비밀번호</label>
                <div class="pw-wrap">
                  <input
                    v-model="regPassword"
                    :type="showRegPw ? 'text' : 'password'"
                    required
                  />
                  <button
                    type="button"
                    class="pw-toggle"
                    @click="showRegPw = !showRegPw"
                    aria-label="비밀번호 보기"
                  >
                    <IconEye v-if="!showRegPw" width="18" height="18" />
                    <IconEyeOff v-else width="18" height="18" />
                  </button>
                </div>
              </div>
              <div class="field">
                <label>비밀번호 확인</label>
                <div class="pw-wrap">
                  <input
                    v-model="regPasswordConfirm"
                    :type="showRegPwConfirm ? 'text' : 'password'"
                    required
                  />
                  <button
                    type="button"
                    class="pw-toggle"
                    @click="showRegPwConfirm = !showRegPwConfirm"
                    aria-label="비밀번호 보기"
                  >
                    <IconEye v-if="!showRegPwConfirm" width="18" height="18" />
                    <IconEyeOff v-else width="18" height="18" />
                  </button>
                </div>
              </div>
              <div class="field full-width">
                <label>가입 유형</label>
                <div class="role-selector">
                  <label
                    ><input type="radio" v-model="regRole" value="S" />
                    학생</label
                  >
                  <label
                    ><input type="radio" v-model="regRole" value="T" />
                    선생님</label
                  >
                  <label
                    ><input type="radio" v-model="regRole" value="P" />
                    학부모</label
                  >
                </div>
              </div>
            </div>

            <div v-if="regError" class="auth-error-msg reg-err">
              {{ regError }}
            </div>

            <button class="btn-login btn-reg" :disabled="isRegistering">
              {{ isRegistering ? "처리 중..." : "회원가입 완료" }}
            </button>
          </form>

          <p class="modal-footer-text">
            이미 계정이 있으신가요?
            <a href="#" @click.prevent="closeRegister">로그인으로 돌아가기</a>
          </p>
        </div>
      </div>
    </Transition>

    <!-- 오늘의 공개문제 전용 모달 -->
    <DailyQuestionsModal
      v-if="showDailyModal"
      :questions="dailyQuestions"
      @close="showDailyModal = false"
    />
  </div>
</template>

<style scoped>
@import url("https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=Nanum+Myeongjo:wght@400;700;800&display=swap");

/* ─── 리셋 ────── */
*,
*::before,
*::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* ─── 루트 페이지 ─── */
.page {
  font-family: "Noto Sans KR", "Apple SD Gothic Neo", sans-serif;
  height: 100vh;
  width: 100%;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  color: #f0f4ff;
}

/* ─────────────────────────────────────
   전체 배경: 책 이미지
───────────────────────────────────── */
.bg-image {
  position: fixed;
  inset: 0;
  z-index: 0;
  background:
    url("/hero-image.jpg") center center / cover no-repeat,
    /* 이미지 없을 때 fallback */
    linear-gradient(160deg, #1a0e05 0%, #3b2a14 40%, #0d0a05 100%);
  transform: scale(1.08);
  filter: brightness(0.55) saturate(0.9);
  transition:
    transform 6s cubic-bezier(0.25, 0.46, 0.45, 0.94),
    filter 3s ease;
}
.bg-image--visible {
  transform: scale(1);
  filter: brightness(0.72) saturate(1.05);
}

/* 배경 위 겹치는 그라디언트 오버레이 */
.bg-overlay {
  position: fixed;
  inset: 0;
  z-index: 1;
  background:
    linear-gradient(
      to right,
      rgba(5, 3, 1, 0.82) 0%,
      rgba(5, 3, 1, 0.5) 55%,
      rgba(5, 3, 1, 0.2) 100%
    ),
    linear-gradient(to top, rgba(5, 3, 1, 0.75) 0%, transparent 50%);
}

/* ─────────────────────────────────────
   페이드인 커튼 (검정 → 투명)
───────────────────────────────────── */
.curtain {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: #000;
  pointer-events: none;
  transition: opacity 2.8s cubic-bezier(0.22, 1, 0.36, 1);
}
.curtain--open {
  opacity: 0;
}

/* ─────────────────────────────────────
   콘텐츠 레이어
───────────────────────────────────── */
.content {
  position: relative;
  z-index: 10;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  height: 100vh;
  opacity: 0;
  transform: translateY(20px);
  transition:
    opacity 1.8s cubic-bezier(0.22, 1, 0.36, 1) 0.6s,
    transform 1.8s cubic-bezier(0.22, 1, 0.36, 1) 0.6s;
}
.content--visible {
  opacity: 1;
  transform: translateY(0);
}

/* ─── 상단 바 ─── */
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 2rem 5rem;
}
.logo {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.5rem;
  font-weight: 900;
  letter-spacing: -0.03em;
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
.nav-links a:hover {
  color: #f0f4ff;
}
.intro-link {
  display: flex !important;
  align-items: center;
  gap: 0.35rem;
}

.icon-info {
  width: 17px;
  height: 17px;
  color: inherit;
}

.icon-manual {
  width: 17px;
  height: 17px;
  color: inherit;
}

/* ─── 메인 행 ─── */
.main-row {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4rem;
  padding: 0 5rem 2rem;
  width: 100%;
  max-width: 1400px;
  margin: 0 auto;
   min-height: 0;
}

/* ─── 히어로 ─── */
.hero {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
  max-width: 640px;
}

.eyebrow {
  font-size: 0.88rem;
  font-weight: 700;
  letter-spacing: 0.1em;
  color: #f59e0b;
  text-transform: uppercase;
  animation: fadeUp 0.8s ease 0.9s both;
}

/* ─── 사전 표제어 스타일 타이틀 ─── */
.dict-entry {
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
  animation: fadeUp 0.8s ease 1.1s both;
}

.dict-headword {
  display: flex;
  align-items: baseline;
  flex-wrap: nowrap;
  white-space: nowrap;
  gap: 0.08em;
  line-height: 1;
  text-shadow: 0 4px 32px rgba(0, 0, 0, 0.6);
}

.dict-word {
  font-family:
    "Nanum Myeongjo", "궁서", "GungSeo", "AppleMyungjo", Georgia, serif;
  font-size: clamp(2rem, 4vw, 4rem);
  font-weight: 800;
  letter-spacing: 0.01em;
  color: #f8fafc;
}
/* 강조 음절: 그라디언트 색상 */
.dict-word.accent {
  background: linear-gradient(135deg, #e0e7ff 0%, #a5b4fc 50%, #c084fc 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* 구분 기호 (- :) */
.dict-sep {
  font-family: "Nanum Myeongjo", "궁서", Georgia, serif;
  font-size: clamp(1.6rem, 3.2vw, 3.2rem);
  font-weight: 400;
  color: rgba(165, 180, 252, 0.55);
  letter-spacing: 0;
  margin: 0 0.05em;
}
/* IPA 삼각형 콜론 ː — 1.5배 크게 */
.dict-sep--ipa {
  font-size: clamp(2.4rem, 4.8vw, 4.8rem);
  font-family: "Georgia", "DejaVu Serif", serif;
  line-height: 0.85;
  vertical-align: middle;
  color: rgba(165, 180, 252, 0.7);
  margin: 0 -0.36em 0 0.04em;
}

/* 발음기호 + 품사 행 */
.dict-meta {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}
.dict-pron {
  font-size: 0.88rem;
  font-weight: 500;
  color: rgba(165, 180, 252, 0.6);
  letter-spacing: 0.06em;
  font-family: "Georgia", "Times New Roman", serif;
  border: 1px solid rgba(165, 180, 252, 0.2);
  border-radius: 4px;
  padding: 0.1rem 0.5rem;
  background: rgba(165, 180, 252, 0.06);
}
.dict-pos {
  font-size: 0.82rem;
  font-weight: 600;
  color: rgba(240, 244, 255, 0.4);
  letter-spacing: 0.04em;
}
.dict-pos em {
  font-style: italic;
  color: rgba(192, 132, 252, 0.6);
}

.typed-wrap {
  font-size: clamp(1.05rem, 2vw, 1.4rem);
  font-weight: 600;
  color: #a5b4fc;
  min-height: 2rem;
  animation: fadeUp 0.8s ease 1.3s both;
}
.caret {
  color: #818cf8;
  transition: opacity 0.1s;
}
.invisible {
  opacity: 0;
}

.hero-desc-container {
  background: rgba(255, 255, 255, 0.03);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(14px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 4px;
  padding: 1rem 1.1rem;
  margin-top: 0.2rem;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  animation: fadeUp 0.8s ease 1.5s both;
  box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.3);
}

.hero-desc {
  font-size: clamp(0.92rem, 1.4vw, 1.08rem);
  color: rgba(240, 244, 255, 0.72);
  line-height: 1.9;
  text-shadow: 0 1px 8px rgba(0, 0, 0, 0.5);
}

.ticker-box {
  margin-top: auto;
  padding-top: 0.6rem;
  border-top: 1px dashed rgba(255, 255, 255, 0.15);
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
  overflow: hidden;
  flex: 1;
}

.ticker-label {
  font-size: 0.65rem;
  font-weight: 800;
  color: #10b981;
  letter-spacing: 0.18em;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.ticker-dot {
  width: 6px;
  height: 6px;
  background: #10b981;
  border-radius: 50%;
  box-shadow: 0 0 10px #10b981;
  animation: pulse 1.8s infinite;
}

.ticker-window {
  height: 220px;
  overflow: hidden;
  position: relative;
}

.ticker-track {
  display: flex;
  flex-direction: column;
  animation: ticker-marquee 18s linear infinite;
}

.ticker-item {
  height: 30px;
  display: flex;
  align-items: center;
  gap: 1.2rem;
  font-family: "JetBrains Mono", "Menlo", monospace;
  font-size: 0.95rem;
  overflow: hidden;
  flex-shrink: 0;
  white-space: nowrap;
}

.t-id {
  color: rgba(255, 255, 255, 0.35);
  font-size: 0.8rem;
}
.t-text {
  color: #e0e7ff;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  display: inline-block;
  max-width: 540px;
  vertical-align: middle;
  line-height: 30px;
}
.t-text :deep(.katex-display) {
  display: inline;
  margin: 0;
  text-align: left;
}
.t-text :deep(.katex-display > .katex) {
  display: inline;
}
.t-new {
  font-size: 0.6rem;
  font-weight: 700;
  background: rgba(16, 185, 129, 0.12);
  color: #10b981;
  padding: 0.1rem 0.4rem;
  border-radius: 4px;
  border: 1px solid rgba(16, 185, 129, 0.3);
  flex-shrink: 0;
}

@keyframes ticker-marquee {
  0% {
    transform: translateY(0);
  }
  100% {
    transform: translateY(-50%);
  }
}

@keyframes pulse {
  0% {
    opacity: 0.3;
    transform: scale(0.9);
  }
  50% {
    opacity: 1;
    transform: scale(1.1);
  }
  100% {
    opacity: 0.3;
    transform: scale(0.9);
  }
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 1s;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.hero-desc strong {
  color: #e0e7ff;
  font-weight: 700;
}

.feature-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.65rem;
  animation: fadeUp 0.8s ease 1.7s both;
}
.feature-chips span {
  background: rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.14);
  border-radius: 10px;
  padding: 0.4rem 1rem;
  font-size: 0.82rem;
  font-weight: 600;
  color: rgba(240, 244, 255, 0.85);
  white-space: nowrap;
}

.stats-row {
  display: flex;
  align-items: center;
  gap: 0;
  width: 100%;
  padding-left: 2px;
  animation: fadeUp 0.8s ease 1.9s both;
}
.stat {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  align-items: flex-end;
  padding: 0 1.2rem;
}
.stat.special {
  flex: 2;
  padding-right: 2.5rem;
}
.stat b {
  font-size: 1.7rem;
  font-weight: 900;
  line-height: 1;
  background: linear-gradient(135deg, #e0e7ff, #a5b4fc);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}
.stat b sup {
  font-size: 0.65em;
  vertical-align: super;
}
.stat small {
  font-size: 0.78rem;
  color: rgba(240, 244, 255, 0.5);
  font-weight: 500;
}
.vbar {
  width: 1px;
  height: 36px;
  background: rgba(255, 255, 255, 0.18);
}

/* ─── 로그인 카드 ─── */
.auth-box {
  flex: 0 0 auto;
  width: 100%;
  max-width: 420px;
  animation: fadeUp 0.8s ease 1.2s both;
}

.auth-card {
  background: rgba(5, 8, 18, 0.72);
  backdrop-filter: blur(36px);
  -webkit-backdrop-filter: blur(36px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 2.75rem 2.5rem 2rem;
  box-shadow:
    0 0 0 1px rgba(129, 140, 248, 0.08),
    0 40px 80px -20px rgba(0, 0, 0, 0.7),
    inset 0 1px 0 rgba(255, 255, 255, 0.06);
}

.auth-title {
  font-size: 1.75rem;
  font-weight: 900;
  color: #f8fafc;
  margin-bottom: 0.35rem;
  letter-spacing: -0.03em;
}
.auth-sub {
  font-size: 0.88rem;
  color: #cbd5e1;
  margin-bottom: 1.2rem;
  line-height: 1.5;
}
.auth-sub-sample {
  margin-bottom: 0;
}

.btn-public {
  background: rgba(99, 102, 241, 0.15);
  border: 1px solid rgba(129, 140, 248, 0.4);
  color: #a5b4fc;
  padding: 0.15rem 0.6rem;
  border-radius: 6px;
  font-weight: 800;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  display: inline-flex;
  align-items: center;
  font-family: inherit;
  margin: 0 0.25rem;
  box-shadow: 0 0 12px rgba(99, 102, 241, 0.2);
}

.btn-public:hover {
  background: rgba(99, 102, 241, 0.3);
  border-color: rgba(129, 140, 248, 0.6);
  color: #fff;
  transform: translateY(-1.5px);
  box-shadow: 0 0 20px rgba(99, 102, 241, 0.4);
}

.form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}
.field label {
  font-size: 0.8rem;
  font-weight: 700;
  color: #94a3b8;
  letter-spacing: 0.04em;
}
.field input {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 0.82rem 1rem;
  height: 3rem;
  font-size: 0.95rem;
  color: #f1f5f9;
  font-family: inherit;
  outline: none;
  transition:
    border-color 0.25s,
    background 0.25s,
    box-shadow 0.25s;
}
.field input::placeholder {
  color: #1e293b;
}
.field input:focus {
  border-color: rgba(129, 140, 248, 0.55);
  background: rgba(255, 255, 255, 1);
  box-shadow: 0 0 0 3px rgba(129, 140, 248, 0.18);
  color: #000;
}

/* 비밀번호 입력 래퍼 */
.pw-wrap {
  position: relative;
  display: flex;
  align-items: center;
}
.pw-wrap input {
  width: 100%;
  padding-right: 2.8rem;
}
.pw-toggle {
  position: absolute;
  right: 0.6rem;
  background: none;
  border: none;
  cursor: pointer;
  color: #64748b;
  padding: 0.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color 0.2s;
}
.pw-toggle:hover {
  color: #a5b4fc;
}

/* 비밀번호 폰트 크기 확대 */
input[type="password"] {
  font-size: 1.5rem !important;
  letter-spacing: 0.1em;
}

.row-util {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.8rem;
  margin-top: -0.25rem;
}
.form .auth-sub-sample + .row-util {
  margin-top: -0.65rem;
}
.chk {
  display: flex;
  gap: 0.35rem;
  align-items: center;
  color: #64748b;
  cursor: pointer;
}
.chk input {
  accent-color: #818cf8;
}
.link-sm {
  color: #818cf8;
  text-decoration: none;
  font-weight: 600;
}
.link-sm:hover {
  text-decoration: underline;
}

.btn-login {
  width: 100%;
  padding: 0.9rem;
  border-radius: 10px;
  border: none;
  background: linear-gradient(135deg, #4f46e5, #7c3aed);
  color: #fff;
  font-size: 1rem;
  font-weight: 700;
  font-family: inherit;
  letter-spacing: 0.02em;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  box-shadow: 0 8px 24px -8px rgba(99, 102, 241, 0.65);
  transition:
    transform 0.2s,
    box-shadow 0.2s,
    filter 0.2s;
  margin-top: 0.3rem;
}
.btn-login:hover {
  transform: translateY(-2px);
  box-shadow: 0 16px 32px -8px rgba(99, 102, 241, 0.8);
  filter: brightness(1.1);
}
.btn-login:active {
  transform: translateY(0);
}

.divider {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 1.25rem 0 1rem;
  color: #334155;
  font-size: 0.8rem;
}
.divider::before,
.divider::after {
  content: "";
  flex: 1;
  height: 1px;
  background: rgba(255, 255, 255, 0.08);
}

.btn-google {
  width: 100%;
  padding: 0.8rem;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.04);
  color: #e2e8f0;
  font-size: 0.93rem;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.55rem;
  transition:
    background 0.2s,
    border-color 0.2s;
}
.btn-google:hover {
  background: rgba(255, 255, 255, 0.09);
  border-color: rgba(255, 255, 255, 0.22);
}

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
  border-radius: 10px;
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
  text-decoration: none;
}
.user-greeting {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  color: #c7d2fe !important;
  font-size: 0.95rem !important;
  font-weight: 600 !important;
  margin-left: 0.5rem;
  text-decoration: none;
  padding: 0.4rem 0.8rem;
  border-radius: 10px;
  transition: all 0.2s;
}
.user-greeting:hover {
  background: rgba(99, 102, 241, 0.1);
  color: #c7d2fe !important;
}
.logout-link {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.3rem;
  color: #ef4444;
  font-size: 0.8rem;
  font-weight: 500;
  margin-top: 0.5rem;
  text-decoration: none;
}
.logout-link:hover {
  text-decoration: underline;
}
.icon-user,
.icon-logout {
  width: 1.1rem;
  height: 1.1rem;
}

.auth-error-msg {
  color: #ef4444;
  font-size: 0.8rem;
  font-weight: 500;
  margin-top: -0.25rem;
  min-height: 1.4rem;
  line-height: 1.4rem;
}

.btn-login:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* ─── 회원가입 모달 전용 ─── */
.reg-modal {
  max-width: 500px;
  padding: 3rem 2.5rem 2.5rem;
}
.reg-form {
  margin-top: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.2rem;
}
.reg-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}
.reg-grid .full-width {
  grid-column: span 2;
}
.role-selector {
  display: flex;
  gap: 1.5rem;
  margin-top: 0.5rem;
  background: rgba(255, 255, 255, 0.04);
  padding: 0.8rem;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.08);
}
.role-selector label {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  color: #f1f5f9;
  font-size: 0.9rem;
  font-weight: 500;
  cursor: pointer;
}
.role-selector input {
  accent-color: #818cf8;
}
.reg-err {
  margin: 0;
  text-align: center;
}
.btn-reg {
  margin-top: 1rem;
}

/* 아이디 중복확인 관련 */
.input-with-btn {
  display: flex;
  gap: 0.5rem;
}
.input-with-btn input {
  flex: 1;
}
.btn-check {
  padding: 0 1rem;
  border-radius: 10px;
  border: 1px solid rgba(129, 140, 248, 0.3);
  background: rgba(129, 140, 248, 0.1);
  color: #a5b4fc;
  font-size: 0.82rem;
  font-weight: 600;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s;
}
.btn-check:hover:not(:disabled) {
  background: rgba(129, 140, 248, 0.2);
  border-color: rgba(129, 140, 248, 0.5);
}
.id-status {
  font-size: 0.75rem;
  margin-top: 0.25rem;
  padding-left: 0.25rem;
}
.id-status.success {
  color: #10b981;
}
.id-status.fail {
  color: #ef4444;
}

.modal-footer-text {
  text-align: center;
  margin-top: 1.5rem;
  font-size: 0.85rem;
  color: #64748b;
}
.modal-footer-text a {
  color: #818cf8;
  font-weight: 700;
  text-decoration: none;
}
.modal-footer-text a:hover {
  text-decoration: underline;
}

.join-text {
  text-align: center;
  font-size: 0.83rem;
  color: #475569;
  margin-top: 1.1rem;
}
.link-accent {
  color: #818cf8;
  font-weight: 700;
  text-decoration: none;
}
.link-accent:hover {
  text-decoration: underline;
}

.badge-row {
  display: flex;
  justify-content: center;
  gap: 1rem;
  flex-wrap: wrap;
  margin-top: 1.1rem;
  padding-top: 1rem;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
}
.badge-row span {
  font-size: 0.7rem;
  color: #334155;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
}

.badge-icon {
  width: 0.9rem;
  height: 0.9rem;
  flex-shrink: 0;
}

/* ─── 스크롤 인디케이터 ─── */
.scroll-hint {
  position: absolute;
  bottom: 2rem;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.4rem;
  animation: fadeUp 0.8s ease 2.5s both;
}
.scroll-hint span {
  font-size: 0.7rem;
  letter-spacing: 0.15em;
  color: rgba(240, 244, 255, 0.3);
  text-transform: uppercase;
}
.scroll-arrow {
  width: 1px;
  height: 28px;
  background: linear-gradient(to bottom, rgba(255, 255, 255, 0.4), transparent);
  animation: scrollDown 1.5s ease-in-out infinite;
}
@keyframes scrollDown {
  0%,
  100% {
    transform: scaleY(1);
    opacity: 0.5;
  }
  50% {
    transform: scaleY(1.4);
    opacity: 1;
  }
}

/* ─── 공통 애니메이션 ─── */
@keyframes fadeUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ─── 반응형 ─── */
@media (max-width: 1100px) {
  .main-row {
    flex-direction: column;
    padding: 2rem 3rem 4rem;
    gap: 3rem;
  }
  .hero {
    max-width: 100%;
    align-items: center;
    text-align: center;
  }
  .feature-chips {
    justify-content: center;
  }
  .stats-row {
    justify-content: center;
  }
  .auth-box {
    max-width: 480px;
    width: 100%;
  }
  .top-bar {
    padding: 1.5rem 3rem;
  }
}
@media (max-width: 640px) {
  .top-bar {
    padding: 1.25rem 1.5rem;
  }
  .nav-links {
    gap: 1.5rem;
  }
  .main-row {
    padding: 1.5rem 1.5rem 4rem;
    gap: 2rem;
  }
  .auth-card {
    padding: 2rem 1.5rem 1.5rem;
  }
  .hero-title {
    font-size: 2.8rem;
  }
}

/* ════════════════════════════════
   소개 모달
════════════════════════════════ */
.modal-backdrop {
  position: fixed;
  inset: 0;
  z-index: 10000;
  background: rgba(0, 0, 0, 0.72);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
}

.modal-box {
  position: relative;
  background: rgba(10, 12, 28, 0.92);
  backdrop-filter: blur(40px);
  -webkit-backdrop-filter: blur(40px);
  border: 1px solid rgba(165, 180, 252, 0.18);
  border-radius: 10px;
  padding: 1.75rem 1.5rem 1.5rem 1.5rem;
  max-width: 884px; /* 1.3배 폭 증가 (680 * 1.3) */
  width: 95%;
  max-height: 95vh;
  overflow-y: hidden; /* 데스크톱에서 스크롤 방지 */
  box-shadow:
    0 0 0 1px rgba(129, 140, 248, 0.1),
    0 40px 100px -20px rgba(0, 0, 0, 0.9),
    inset 0 1px 0 rgba(255, 255, 255, 0.06);
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.modal-close {
  position: absolute;
  top: 1.25rem;
  right: 1.25rem;
  background: rgba(255, 255, 255, 0.07);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(240, 244, 255, 0.6);
  cursor: pointer;
  transition:
    background 0.2s,
    color 0.2s;
}
.modal-close:hover {
  background: rgba(255, 255, 255, 0.14);
  color: #f0f4ff;
}

.modal-grid {
  display: flex;
  gap: 2rem;
  align-items: stretch;
}

.modal-features {
  flex: 1.2;
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
}

.modal-steps {
  flex: 0.8;
  height: fit-content;
  background: rgba(129, 140, 248, 0.06);
  border: 1px solid rgba(129, 140, 248, 0.15);
  border-radius: 10px;
  padding: 1.4rem 1.5rem;
}

@media (max-width: 850px) {
  .modal-grid {
    flex-direction: column;
  }
  .modal-box {
    overflow-y: auto;
    overflow-x: hidden;
  }
}

.modal-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.15rem;
  background: linear-gradient(
    135deg,
    rgba(79, 70, 229, 0.3),
    rgba(124, 58, 237, 0.3)
  );
  border: 1px solid rgba(165, 180, 252, 0.25);
  border-radius: 10px;
  padding: 0.3rem 0.9rem;
  font-size: 0.78rem;
  font-weight: 700;
  color: #a5b4fc;
  letter-spacing: 0.04em;
}

.modal-lead {
  font-size: 0.93rem;
  color: rgba(240, 244, 255, 0.7);
  line-height: 1.8;
  margin-bottom: 0.5rem;
}

.manual-modal {
  max-width: min(1180px, 98vw);
  width: 98%;
  max-height: 92vh;
  padding-bottom: 1.5rem;
  overflow-x: hidden;
}

.manual-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  padding-right: 0;
}

.manual-modal-header .modal-badge {
  display: inline-flex;
  align-items: center;
  justify-content: flex-start;
  margin-bottom: 0;
  min-height: auto;
  padding: 0;
  font-size: 1.45rem;
  font-weight: 800;
  line-height: 1.3;
  color: #f8fafc;
  background: transparent;
  border: none;
  border-radius: 0;
  letter-spacing: 0.70em;
  text-decoration: underline;
  text-decoration-color: rgba(165, 180, 252, 0.85);
  text-decoration-thickness: 2px;
  text-underline-offset: 8px;
  box-shadow: none;
}

.manual-modal-header .modal-close {
  position: static;
  top: auto;
  right: auto;
  flex-shrink: 0;
}

.manual-pdf-wrap {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 5px;
  padding: 1rem;
  scrollbar-width: auto;
  scrollbar-color: rgba(165, 180, 252, 0.9) rgba(255, 255, 255, 0.08);
}

.manual-pdf-wrap::-webkit-scrollbar {
  width: 52px;
}

.manual-pdf-wrap::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.08);
  border-radius: 18px;
}

.manual-pdf-wrap::-webkit-scrollbar-thumb {
  background: linear-gradient(
    180deg,
    rgba(224, 231, 255, 0.96),
    rgba(129, 140, 248, 0.92)
  );
  border-radius: 18px;
  border: 8px solid rgba(15, 23, 42, 0.18);
  min-height: 96px;
}

.manual-pdf-wrap::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(
    180deg,
    rgba(240, 244, 255, 0.98),
    rgba(129, 140, 248, 1)
  );
}

.manual-pdf {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.manual-pdf :deep(.vue-pdf-embed__page) {
  width: 100%;
  display: flex;
  justify-content: center;
}

.manual-pdf :deep(canvas) {
  display: block;
  margin: 0 auto;
  max-width: 100%;
  height: auto !important;
}

.manual-loading {
  min-height: 240px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(240, 244, 255, 0.7);
  font-size: 0.95rem;
}

@media (max-width: 850px) {
  .manual-modal {
    width: 100%;
    max-height: 94vh;
    padding: 2.75rem 1rem 1rem;
  }

  .manual-pdf-wrap {
    padding: 0.5rem;
  }
}

.feat-card {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  background: rgba(255, 255, 255, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 10px;
  padding: 1.1rem 1.2rem;
  transition:
    background 0.2s,
    border-color 0.2s;
}
.feat-card:hover {
  background: rgba(129, 140, 248, 0.08);
  border-color: rgba(165, 180, 252, 0.2);
}

.feat-icon {
  font-size: 2rem;
  line-height: 1;
  flex-shrink: 0;
  margin-top: 0.1rem;
}

.feat-icon-svg {
  width: 1.35rem;
  height: 1.35rem;
}

.feat-body h3 {
  font-size: 1rem;
  font-weight: 700;
  color: #e0e7ff;
  margin-bottom: 0.35rem;
}
.feat-body p {
  font-size: 0.85rem;
  color: rgba(240, 244, 255, 0.62);
  line-height: 1.65;
}

.steps-title {
  font-size: 1rem;
  font-weight: 800;
  color: #a5b4fc;
  margin-bottom: 1rem;
  letter-spacing: -0.01em;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.steps-title-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.steps-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.step-item {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  font-size: 0.9rem;
  color: rgba(240, 244, 255, 0.75);
  line-height: 1.6;
}
.step-item strong {
  color: #e0e7ff;
}

.step-num {
  min-width: 28px;
  height: 28px;
  background: linear-gradient(135deg, #4f46e5, #7c3aed);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  font-weight: 900;
  color: #fff;
  flex-shrink: 0;
  margin-top: 0.1rem;
  box-shadow: 0 4px 12px -4px rgba(99, 102, 241, 0.5);
}

.modal-footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.1rem;
  padding-top: 0.8rem;
  border-top: 1px solid rgba(255, 255, 255, 0.07);
}

.modal-slogan {
  text-align: center;
  font-size: 0.92rem;
  color: rgba(240, 244, 255, 0.65);
  line-height: 1.6;
}
.modal-slogan strong {
  color: #c084fc;
}

/* 모달 트랜지션 */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}
.modal-enter-active .modal-box,
.modal-leave-active .modal-box {
  transition:
    opacity 0.3s ease,
    transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}
.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}
.modal-enter-from .modal-box,
.modal-leave-to .modal-box {
  opacity: 0;
  transform: scale(0.92) translateY(20px);
}
</style>
