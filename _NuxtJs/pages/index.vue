<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';

// 페이드인 상태
const isLoaded = ref(false);

// 소개 모달
const showIntro = ref(false);
let introTimer: any = null;

function openIntro() {
  showIntro.value = true;
  document.body.style.overflow = 'hidden';
  // 10초 뒤 자동 닫기
  if (introTimer) clearTimeout(introTimer);
  introTimer = setTimeout(closeIntro, 10000);
}

function closeIntro() {
  showIntro.value = false;
  document.body.style.overflow = '';
  if (introTimer) {
    clearTimeout(introTimer);
    introTimer = null;
  }
}

function onKeydown(e: KeyboardEvent) { if (e.key === 'Escape') closeIntro(); }
onMounted(() => window.addEventListener('keydown', onKeydown));
onUnmounted(() => window.removeEventListener('keydown', onKeydown));

// 타이핑 애니메이션
const typedText = ref('');
const showCursor = ref(true);
const phrases = [
  '문제를 풀며 지식을 완성한다는 인류',
  '매일 도전하고, 매일 성장하는 인류',
  '질문이 지식이 되고, 지식이 힘이 되는 인류',
];
let phraseIdx = 0;
let charIdx   = 0;
let deleting  = false;

function typeLoop() {
  const cur = phrases[phraseIdx];
  if (!deleting) {
    typedText.value = cur.slice(0, ++charIdx);
    if (charIdx === cur.length) {
      deleting = true;
      setTimeout(typeLoop, 2400); return;
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
const userIdInput = ref('');
const passwordInput = ref('');
const isLoggingIn = ref(false);
const authError = ref('');

const handleLogin = async () => {
  if (!userIdInput.value || !passwordInput.value) {
    authError.value = '이미일과 비밀번호를 입력해주세요.';
    return;
  }
  
  isLoggingIn.value = true;
  authError.value = '';
  
  try {
    const config = useRuntimeConfig();
    const { data, error } = await useFetch(`${config.public.apiBase}/auth/login`, {
      method: 'POST',
      body: {
        userId: userIdInput.value,
        password: passwordInput.value,
      },
    });

    if (error.value) {
      authError.value = error.value.data?.message || '로그인 중 오류가 발생했습니다.';
      return;
    }

    if (data.value) {
      // JWT 토큰 저장
      const token = useCookie('auth_token');
      token.value = (data.value as any).access_token;
      
      const user = useCookie('user_info');
      user.value = JSON.stringify((data.value as any).user);

      alert(`${(data.value as any).user.username}님, 환영합니다!`);
      // 필요 시 페이지 이동
      // window.location.href = '/questions';
    }
  } catch (err) {
    authError.value = '서버 연결에 실패했습니다.';
  } finally {
    isLoggingIn.value = false;
  }
};

onMounted(() => {
  setTimeout(() => { isLoaded.value = true; }, 80);
  setTimeout(typeLoop, 1600);
  setInterval(() => { showCursor.value = !showCursor.value; }, 530);
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
          <a href="#">문제 풀기</a>
          <a href="#">랭킹</a>
          <a href="#" @click.prevent="openIntro">소개</a>
        </nav>
      </header>

      <!-- ─── 중앙 히어로 + 우측 로그인 ─── -->
      <div class="main-row">

        <!-- 왼쪽: 히어로 카피 -->
        <section class="hero">
          <p class="eyebrow">✦ &nbsp;2026 지식 혁명의 플랫폼</p>

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
              <span class="dict-pos">명사 ·  <em>homo solvens</em></span>
            </div>
          </div>

          <p class="typed-wrap">
            <span class="typed-text">{{ typedText }}</span>
            <span class="caret" :class="{ invisible: !showCursor }">│</span>
          </p>

          <p class="hero-desc">
            문제를 풀수록 지식이 쌓이고,<br>
            지식이 쌓일수록 세상이 보입니다.<br><br>
            Edu-Hub는 단순한 학습 앱이 아닙니다.<br>
            당신 안의 <strong>호모 문풀리언스</strong>를 깨우는<br>
            지식 완성의 여정을 함께합니다.
          </p>

          <div class="feature-chips">
            <span>⚡ AI 맞춤 추천</span>
            <span>📊 성취 대시보드</span>
            <span>🏆 전국 랭킹</span>
            <span>🔔 오늘의 도전</span>
          </div>

          <div class="stats-row">
            <div class="stat"><b>12,400<sup>+</sup></b><small>등록 문제</small></div>
            <div class="vbar"></div>
            <div class="stat"><b>38,000<sup>+</sup></b><small>학습자</small></div>
            <div class="vbar"></div>
            <div class="stat"><b>97%</b><small>만족도</small></div>
          </div>
        </section>

        <!-- 오른쪽: 로그인 카드 -->
        <aside class="auth-box">
          <div class="auth-card">
            <h2 class="auth-title">시작하기</h2>
            <p class="auth-sub">무료 가입 후 오늘의 문제를 풀어보세요</p>

            <form @submit.prevent="handleLogin" class="form">
              <div class="field">
                <label for="email">이메일/ID</label>
                <input id="email" v-model="userIdInput" type="text" placeholder="아이디를 입력하세요" required />
              </div>
              <div class="field">
                <label for="pw">비밀번호</label>
                <input id="pw" v-model="passwordInput" type="password" placeholder="비밀번호를 입력하세요" required />
              </div>
              <div v-if="authError" class="auth-error-msg">{{ authError }}</div>
              <div class="row-util">
                <label class="chk"><input type="checkbox" />로그인 유지</label>
                <a href="#" class="link-sm">비밀번호 찾기</a>
              </div>
              <button class="btn-login" :disabled="isLoggingIn">
                {{ isLoggingIn ? '로그인 중...' : '로그인' }}
                <svg v-if="!isLoggingIn" viewBox="0 0 24 24" width="16" height="16"><path d="M13.172 12l-4.95-4.95 1.414-1.414L16 12l-6.364 6.364-1.414-1.414z" fill="currentColor"/></svg>
              </button>
            </form>

            <div class="divider"><span>또는</span></div>

            <button class="btn-google">
              <img src="https://www.svgrepo.com/show/475656/google-color.svg" alt="" width="18" />
              Google로 계속하기
            </button>

            <p class="join-text">
              계정이 없으신가요?&nbsp;
              <a href="#" class="link-accent">무료 회원가입 →</a>
            </p>

            <div class="badge-row">
              <span>🔒 SSL 보안</span>
              <span>✅ 개인정보보호</span>
              <span>🆓 무료 플랜</span>
            </div>
          </div>
        </aside>

      </div><!-- /main-row -->
    </div><!-- /content -->

    <!-- ══════════════════════════════════════
         소개 모달
    ══════════════════════════════════════ -->
    <Transition name="modal">
      <div v-if="showIntro" class="modal-backdrop" @click.self="closeIntro">
        <div class="modal-box" role="dialog" aria-modal="true" aria-label="AI Edu-Hub 소개">

          <button class="modal-close" @click="closeIntro" aria-label="닫기">
            <svg viewBox="0 0 24 24" width="20" height="20"><path d="M18 6L6 18M6 6l12 12" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/></svg>
          </button>

          <div class="modal-header">
            <span class="modal-badge">📚 AI Edu-Hub 소개</span>
            <h2 class="modal-title">사진 한 장으로 시작하는<br><em>우리 반 맞춤형 스마트 학습지</em></h2>
            <p class="modal-lead">안녕하세요! AI Edu-Hub는 선생님의 문제 출제를 도와주고, 여러분에게는 나만의 AI 튜터를 부모님께는 학습 리포트를 제공하는 스마트 학습 플랫폼이에요!</p>
          </div>

          <div class="modal-grid">
            <div class="modal-features">
              <div class="feat-card">
                <div class="feat-icon">📸</div>
                <div class="feat-body">
                  <h3>1초 문제 등록</h3>
                  <p>선생님이 문제집 사진을 찍으면, AI가 읽어서 바로 디지털 문제로 바꿔줘요. 타이핑 없이 쉽게 시험지를 만들 수 있어요!</p>
                </div>
              </div>
              <div class="feat-card">
                <div class="feat-icon">🤖</div>
                <div class="feat-body">
                  <h3>포기 없는 학습</h3>
                  <p>AI가 즉시 채점하고 틀린 이유를 설명해줘요. 복습까지 확실히 도와주니 성적이 쑥쑥!</p>
                </div>
              </div>
              <div class="feat-card">
                <div class="feat-icon">📧</div>
                <div class="feat-body">
                  <h3>부모님 안심 리포트</h3>
                  <p>시험이 끝나면 점수와 분석 리포트가 부모님께 자동 발송되어 어떤 부분이 약한지 한눈에 보여줍니다.</p>
                </div>
              </div>
            </div>

            <div class="modal-steps">
              <h3 class="steps-title">🚀 이렇게 사용해요!</h3>
              <div class="steps-list">
                <div class="step-item">
                  <span class="step-num">1</span>
                  <div><strong>선생님</strong>이 자료를 찍어 <strong>'우리 반 교실'</strong>에 올려요.</div>
                </div>
                <div class="step-item">
                  <span class="step-num">2</span>
                  <div><strong>학생</strong>은 앱으로 접속해 게임처럼 문제를 풀고 친구들과 토론해요!</div>
                </div>
                <div class="step-item">
                  <span class="step-num">3</span>
                  <div><strong>부모님</strong>은 리포트를 보고 따뜻한 격려를 건네요. 😊</div>
                </div>
              </div>
            </div>
          </div>

          <div class="modal-footer">
            <p class="modal-slogan">AI Edu-Hub와 함께라면 공부가 더 이상 숙제가 아닌 <strong>즐거운 경험</strong>이 됩니다! 🌟</p>
          </div>

        </div>
      </div>
    </Transition>

  </div>
</template>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=Nanum+Myeongjo:wght@400;700;800&display=swap');

/* ─── 리셋 ────── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

/* ─── 루트 페이지 ─── */
.page {
  font-family: 'Noto Sans KR', 'Apple SD Gothic Neo', sans-serif;
  min-height: 100vh;
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
    url('/hero-image.jpg') center center / cover no-repeat,
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
      rgba(5, 3, 1, 0.50) 55%,
      rgba(5, 3, 1, 0.20) 100%
    ),
    linear-gradient(
      to top,
      rgba(5, 3, 1, 0.75) 0%,
      transparent 50%
    );
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
  justify-content: center;   /* 수직 중앙 */
  padding-bottom: 14vh;      /* 중심점을 위로 이동 */
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
  gap: 2.5rem;
}
.nav-links a {
  color: rgba(240,244,255,0.65);
  text-decoration: none;
  font-size: 0.95rem;
  font-weight: 500;
  letter-spacing: 0.03em;
  transition: color 0.25s;
}
.nav-links a:hover { color: #f0f4ff; }

/* ─── 메인 행 ─── */
.main-row {
  display: flex;
  align-items: center;
  justify-content: center;   /* 수평 중앙 */
  gap: 4rem;
  padding: 2rem 5rem;
  width: 100%;
  max-width: 1400px;
  margin: 0 auto;
}

/* ─── 히어로 ─── */
.hero {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1.8rem;
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
  text-shadow: 0 4px 32px rgba(0,0,0,0.6);
}

.dict-word {
  font-family: 'Nanum Myeongjo', '궁서', 'GungSeo', 'AppleMyungjo', Georgia, serif;
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
  font-family: 'Nanum Myeongjo', '궁서', Georgia, serif;
  font-size: clamp(1.6rem, 3.2vw, 3.2rem);
  font-weight: 400;
  color: rgba(165,180,252,0.55);
  letter-spacing: 0;
  margin: 0 0.05em;
}
/* IPA 삼각형 콜론 ː — 1.5배 크게 */
.dict-sep--ipa {
  font-size: clamp(2.4rem, 4.8vw, 4.8rem);
  font-family: 'Georgia', 'DejaVu Serif', serif;
  line-height: 0.85;
  vertical-align: middle;
  color: rgba(165,180,252,0.7);
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
  color: rgba(165,180,252,0.6);
  letter-spacing: 0.06em;
  font-family: 'Georgia', 'Times New Roman', serif;
  border: 1px solid rgba(165,180,252,0.2);
  border-radius: 4px;
  padding: 0.1rem 0.5rem;
  background: rgba(165,180,252,0.06);
}
.dict-pos {
  font-size: 0.82rem;
  font-weight: 600;
  color: rgba(240,244,255,0.4);
  letter-spacing: 0.04em;
}
.dict-pos em {
  font-style: italic;
  color: rgba(192,132,252,0.6);
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
.invisible { opacity: 0; }

.hero-desc {
  font-size: clamp(0.92rem, 1.4vw, 1.08rem);
  color: rgba(240,244,255,0.72);
  line-height: 1.9;
  text-shadow: 0 1px 8px rgba(0,0,0,0.5);
  animation: fadeUp 0.8s ease 1.5s both;
}
.hero-desc strong { color: #e0e7ff; font-weight: 700; }

.feature-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.65rem;
  animation: fadeUp 0.8s ease 1.7s both;
}
.feature-chips span {
  background: rgba(255,255,255,0.08);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255,255,255,0.14);
  border-radius: 999px;
  padding: 0.4rem 1rem;
  font-size: 0.82rem;
  font-weight: 600;
  color: rgba(240,244,255,0.85);
  white-space: nowrap;
}

.stats-row {
  display: flex;
  align-items: center;
  gap: 2rem;
  animation: fadeUp 0.8s ease 1.9s both;
}
.stat {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
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
.stat b sup { font-size: 0.65em; vertical-align: super; }
.stat small { font-size: 0.78rem; color: rgba(240,244,255,0.5); font-weight: 500; }
.vbar { width: 1px; height: 36px; background: rgba(255,255,255,0.18); }

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
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 28px;
  padding: 2.75rem 2.5rem 2rem;
  box-shadow:
    0 0 0 1px rgba(129,140,248,0.08),
    0 40px 80px -20px rgba(0,0,0,0.7),
    inset 0 1px 0 rgba(255,255,255,0.06);
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
  color: #64748b;
  margin-bottom: 1.75rem;
}

.form { display: flex; flex-direction: column; gap: 1rem; }

.field { display: flex; flex-direction: column; gap: 0.35rem; }
.field label {
  font-size: 0.8rem;
  font-weight: 700;
  color: #94a3b8;
  letter-spacing: 0.04em;
}
.field input {
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 10px;
  padding: 0.82rem 1rem;
  font-size: 0.95rem;
  color: #f1f5f9;
  font-family: inherit;
  outline: none;
  transition: border-color 0.25s, background 0.25s, box-shadow 0.25s;
}
.field input::placeholder { color: #1e293b; }
.field input:focus {
  border-color: rgba(129,140,248,0.55);
  background: rgba(255,255,255,0.1);
  box-shadow: 0 0 0 3px rgba(129,140,248,0.18);
}

.row-util {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.8rem;
  margin-top: -0.25rem;
}
.chk {
  display: flex;
  gap: 0.35rem;
  align-items: center;
  color: #64748b;
  cursor: pointer;
}
.chk input { accent-color: #818cf8; }
.link-sm { color: #818cf8; text-decoration: none; font-weight: 600; }
.link-sm:hover { text-decoration: underline; }

.btn-login {
  width: 100%;
  padding: 0.9rem;
  border-radius: 11px;
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
  box-shadow: 0 8px 24px -8px rgba(99,102,241,0.65);
  transition: transform 0.2s, box-shadow 0.2s, filter 0.2s;
  margin-top: 0.3rem;
}
.btn-login:hover {
  transform: translateY(-2px);
  box-shadow: 0 16px 32px -8px rgba(99,102,241,0.8);
  filter: brightness(1.1);
}
.btn-login:active { transform: translateY(0); }

.divider {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 1.25rem 0 1rem;
  color: #334155;
  font-size: 0.8rem;
}
.divider::before, .divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: rgba(255,255,255,0.08);
}

.btn-google {
  width: 100%;
  padding: 0.8rem;
  border-radius: 11px;
  border: 1px solid rgba(255,255,255,0.12);
  background: rgba(255,255,255,0.04);
  color: #e2e8f0;
  font-size: 0.93rem;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.55rem;
  transition: background 0.2s, border-color 0.2s;
}
.btn-google:hover {
  background: rgba(255,255,255,0.09);
  border-color: rgba(255,255,255,0.22);
}

.auth-error-msg {
  color: #ef4444;
  font-size: 0.8rem;
  font-weight: 500;
  margin-top: -0.25rem;
}

.btn-login:disabled {
  opacity: 0.5;
  cursor: not-allowed;
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
.link-accent:hover { text-decoration: underline; }

.badge-row {
  display: flex;
  justify-content: center;
  gap: 1rem;
  flex-wrap: wrap;
  margin-top: 1.1rem;
  padding-top: 1rem;
  border-top: 1px solid rgba(255,255,255,0.06);
}
.badge-row span {
  font-size: 0.7rem;
  color: #334155;
  font-weight: 500;
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
  color: rgba(240,244,255,0.3);
  text-transform: uppercase;
}
.scroll-arrow {
  width: 1px;
  height: 28px;
  background: linear-gradient(to bottom, rgba(255,255,255,0.4), transparent);
  animation: scrollDown 1.5s ease-in-out infinite;
}
@keyframes scrollDown {
  0%, 100% { transform: scaleY(1); opacity: 0.5; }
  50%       { transform: scaleY(1.4); opacity: 1; }
}

/* ─── 공통 애니메이션 ─── */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* ─── 반응형 ─── */
@media (max-width: 1100px) {
  .main-row {
    flex-direction: column;
    padding: 2rem 3rem 4rem;
    gap: 3rem;
  }
  .hero { max-width: 100%; align-items: center; text-align: center; }
  .feature-chips { justify-content: center; }
  .stats-row { justify-content: center; }
  .auth-box { max-width: 480px; width: 100%; }
  .top-bar { padding: 1.5rem 3rem; }
}
@media (max-width: 640px) {
  .top-bar { padding: 1.25rem 1.5rem; }
  .nav-links { gap: 1.5rem; }
  .main-row { padding: 1.5rem 1.5rem 4rem; gap: 2rem; }
  .auth-card { padding: 2rem 1.5rem 1.5rem; }
  .hero-title { font-size: 2.8rem; }
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
  border-radius: 28px;
  padding: 2.75rem 2.5rem 2.5rem;
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
  background: rgba(255,255,255,0.07);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 50%;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(240,244,255,0.6);
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}
.modal-close:hover { background: rgba(255,255,255,0.14); color: #f0f4ff; }

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
  border-radius: 16px;
  padding: 1.4rem 1.5rem;
}

@media (max-width: 850px) {
  .modal-grid { flex-direction: column; }
  .modal-box { overflow-y: auto; overflow-x: hidden; }
}

.modal-badge {
  display: inline-block;
  background: linear-gradient(135deg, rgba(79,70,229,0.3), rgba(124,58,237,0.3));
  border: 1px solid rgba(165,180,252,0.25);
  border-radius: 999px;
  padding: 0.3rem 0.9rem;
  font-size: 0.78rem;
  font-weight: 700;
  color: #a5b4fc;
  letter-spacing: 0.04em;
  margin-bottom: 0.85rem;
}

.modal-title {
  font-family: 'Nanum Myeongjo', '궁서', Georgia, serif;
  font-size: clamp(1.45rem, 3vw, 1.9rem);
  font-weight: 800;
  color: #f8fafc;
  line-height: 1.35;
  margin-bottom: 0.9rem;
  letter-spacing: -0.02em;
}
.modal-title em {
  font-style: normal;
  background: linear-gradient(135deg, #818cf8, #c084fc);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.modal-lead {
  font-size: 0.93rem;
  color: rgba(240,244,255,0.7);
  line-height: 1.8;
  margin-bottom: 0.5rem;
}

.feat-card {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 16px;
  padding: 1.1rem 1.2rem;
  transition: background 0.2s, border-color 0.2s;
}
.feat-card:hover {
  background: rgba(129,140,248,0.08);
  border-color: rgba(165,180,252,0.2);
}

.feat-icon {
  font-size: 2rem;
  line-height: 1;
  flex-shrink: 0;
  margin-top: 0.1rem;
}

.feat-body h3 {
  font-size: 1rem;
  font-weight: 700;
  color: #e0e7ff;
  margin-bottom: 0.35rem;
}
.feat-body p {
  font-size: 0.85rem;
  color: rgba(240,244,255,0.62);
  line-height: 1.65;
}

.steps-title {
  font-size: 1rem;
  font-weight: 800;
  color: #a5b4fc;
  margin-bottom: 1rem;
  letter-spacing: -0.01em;
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
  color: rgba(240,244,255,0.75);
  line-height: 1.6;
}
.step-item strong { color: #e0e7ff; }

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
  box-shadow: 0 4px 12px -4px rgba(99,102,241,0.5);
}

.modal-footer {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.1rem;
  padding-top: 0.8rem;
  border-top: 1px solid rgba(255,255,255,0.07);
}

.modal-slogan {
  text-align: center;
  font-size: 0.92rem;
  color: rgba(240,244,255,0.65);
  line-height: 1.6;
}
.modal-slogan strong { color: #c084fc; }

/* 모달 트랜지션 */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}
.modal-enter-active .modal-box,
.modal-leave-active .modal-box {
  transition: opacity 0.3s ease, transform 0.3s cubic-bezier(0.34,1.56,0.64,1);
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
