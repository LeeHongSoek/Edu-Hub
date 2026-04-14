<!--
파일 개요:
- 역할: 오늘의 공개문제 또는 문제 재생 흐름을 담당하는 공통 모달 컴포넌트입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { ref, computed, watch, nextTick, onUnmounted } from "vue";
import type { Question } from "~/types";
import LatexRenderer from "~/components/LatexRenderer.vue";
import IconDailySpark from "~/assets/icons/IconDailySpark.svg?component";
import IconHintBulb from "~/assets/icons/IconHintBulb.svg?component";
import IconDailyAward from "~/assets/icons/IconDailyAward.svg?component";
const { apiBase, token, getAuthHeader } = useApi();

const props = defineProps<{
  questions: Question[];
  title?: string;
  logType?: string;
  logObjectId?: string | number | bigint | null;
  logContent?: string;
}>();

const emit = defineEmits<{
  (e: "close"): void;
}>();

const currentIndex = ref(0);
const isQuizFinished = ref(false);
const showHint = ref(false);
const scoreBannerRef = ref<HTMLElement | null>(null);
const scoreGradeRef = ref<HTMLElement | null>(null);
const scoreGradeStyle = ref<Record<string, string>>({
  transform: "translate3d(0, 0, 0)",
});
const logSaved = ref(false);

const selectedOptions = ref<(string | number | null)[]>(
  Array(props.questions.length).fill(null),
);

const currentQuestion = computed(() => props.questions[currentIndex.value]);
const currentSelectedOpt = computed(
  () => selectedOptions.value[currentIndex.value],
);
const hasCurrentHint = computed(() => Boolean(currentQuestion.value?.hint));

const selectOption = (optId: string | number) => {
  if (isQuizFinished.value) return; // 제출 완료 시 터치 금지
  selectedOptions.value[currentIndex.value] = optId;
};

const goPrev = () => {
  if (currentIndex.value > 0) currentIndex.value--;
};

const goNext = () => {
  if (currentIndex.value < props.questions.length - 1) currentIndex.value++;
};

const handleSliderKeyDown = (event: KeyboardEvent) => {
  if (event.key === "ArrowUp" || event.key === "ArrowDown") {
    event.preventDefault();
    return;
  }

  if (event.key === "ArrowLeft") {
    event.preventDefault();
    goPrev();
  }

  if (event.key === "ArrowRight") {
    event.preventDefault();
    goNext();
  }
};

const unsolvedCount = computed(
  () => selectedOptions.value.filter((v) => v === null).length,
);

const correctCount = computed(() => {
  let count = 0;
  props.questions.forEach((q, i) => {
    const selected = selectedOptions.value[i];
    const correctOpt = q.options?.find((o) => o.is_answer);
    if (selected && correctOpt && selected === correctOpt.option_id) count++;
  });
  return count;
});

const wrongCount = computed(
  () => props.questions.length - correctCount.value - unsolvedCount.value,
);

const totalScore = computed(() =>
  Math.round((correctCount.value / props.questions.length) * 100),
);

const gradeResult = computed(() => {
  const score = totalScore.value;
  if (score >= 90) return "수 (秀)";
  if (score >= 80) return "우 (優)";
  if (score >= 70) return "미 (美)";
  if (score >= 60) return "양 (良)";
  return "가 (可)";
});

const gradeMessage = computed(() => {
  const score = totalScore.value;
  if (score >= 90) return "완벽에 가까운 실력입니다! 최고 수준입니다.";
  if (score >= 80) return "훌륭합니다. 다음 번엔 만점을 노려보세요!";
  if (score >= 70) return "기본기가 잘 잡혀 있습니다. 화이팅!";
  if (score >= 60) return "노력이 조금 더 필요합니다. 다시 도전해볼까요?";
  return "포기하지 마세요! 기초부터 차근차근 복습해 봅시다.";
});

const submitAnswers = () => {
  isQuizFinished.value = true;
};

const getResultStatus = (idx: number) => {
  const selected = selectedOptions.value[idx];
  if (selected === null) return "unsolved";
  const correctOpt = props.questions[idx].options?.find((o) => o.is_answer);
  return correctOpt && selected === correctOpt.option_id ? "correct" : "wrong";
};

const getResultClass = (idx: number) => {
  const status = getResultStatus(idx);
  if (status === "correct") return "res-correct";
  if (status === "wrong") return "res-wrong";
  return "res-unsolved";
};

const getResultText = (idx: number) => {
  const status = getResultStatus(idx);
  if (status === "correct") return "정답 (O)";
  if (status === "wrong") return "오답 (X)";
  return "안 풂 (-)";
};

const maskName = (name: string | undefined) => {
  if (!name) return "관리자";
  // 한국어 이름 3글자인 경우 "이**" 처럼 나오고 싶어함
  if (name.length >= 3) {
    return name.charAt(0) + "**";
  }
  return name.charAt(0) + "*";
};

const getDifficultyLabel = (diff: number | null | undefined) => {
  if (!diff) return "중";
  if (diff <= 1) return "하";
  if (diff === 2) return "중";
  return "상";
};

const getQuestionTypeLabel = (question: Question | undefined) => {
  if (!question) return "객관식";

  const typeId = String(question.question_type_id || "").toUpperCase();
  const typeName = question.type?.type_name || "";

  // 객관식(M) 계열은 정답 보기 수로 선단/선다를 구분합니다.
  const isMultipleChoice = typeId === "M" || typeName.includes("객관식");

  if (isMultipleChoice) {
    const answerCount = (question.options || []).filter((opt) => {
      const raw = (opt as any).is_answer;
      return (
        raw === true || raw === 1 || raw === "1" || raw === "Y" || raw === "y"
      );
    }).length;

    if (answerCount >= 2) return "객관식_선다";
    if (answerCount === 1) return "객관식_선단";
    return "객관식";
  }

  return typeName || "객관식";
};

const formatGroupPath = (group: any) => {
  if (!group) return "일반";

  const parts: string[] = [];
  let current = group;

  while (current) {
    if (current.name) {
      parts.unshift(current.name);
    }
    current = current.parent_group;
  }

  return parts.length > 0 ? parts.join(" / ") : "일반";
};

const getQuestionIdSummary = () =>
  props.questions.map((question) => question.question_id).join(", ");

const saveSessionLog = async () => {
  if (
    logSaved.value ||
    !token.value ||
    !props.logType ||
    props.logObjectId === null ||
    props.logObjectId === undefined
  ) {
    return;
  }

  try {
    await $fetch(
      `${apiBase.value}/user-logs/${props.logType}/${props.logObjectId}`,
      {
        method: "POST",
        headers: getAuthHeader(),
        body: {
          user_content:
            props.logContent ||
            `${props.title || "학습 세트"} 풀이 완료 (총 ${props.questions.length}문항, 문제번호: ${getQuestionIdSummary()})`,
          score: correctCount.value,
          total_score: props.questions.length,
          score100: totalScore.value,
        },
      },
    );
    logSaved.value = true;
  } catch (err) {
    console.warn("서버 통신 오류(save) user-logs:", err);
  }
};

const finishDaily = async () => {
  await saveSessionLog();
  emit("close");
};

const floatState = {
  x: 0,
  y: 0,
  vx: 0,
  vy: 0,
  rotation: 0,
  targetX: 0,
  targetY: 0,
  targetUntil: 0,
  phaseX: Math.random() * Math.PI * 2,
  phaseY: Math.random() * Math.PI * 2,
  lastTs: 0,
};

let scoreGradeRafId: number | null = null;
const FIXED_FLOAT_SPEED = 0.22;

const randomBetween = (min: number, max: number) =>
  min + Math.random() * (max - min);

const stopScoreGradeMotion = () => {
  if (scoreGradeRafId !== null) {
    cancelAnimationFrame(scoreGradeRafId);
    scoreGradeRafId = null;
  }
};

const resetScoreGradeMotion = () => {
  const banner = scoreBannerRef.value;
  const grade = scoreGradeRef.value;
  if (!banner || !grade) return;

  const overflowX = grade.offsetWidth / 3;
  const overflowY = grade.offsetHeight / 3;
  const minX = -overflowX;
  const minY = -overflowY;
  const maxX = banner.clientWidth - grade.offsetWidth + overflowX;
  const maxY = banner.clientHeight - grade.offsetHeight + overflowY;

  floatState.x = (banner.clientWidth - grade.offsetWidth) * 0.5;
  floatState.y = (banner.clientHeight - grade.offsetHeight) * 0.45;
  floatState.vx = FIXED_FLOAT_SPEED;
  floatState.vy = FIXED_FLOAT_SPEED * 0.58;
  floatState.rotation = randomBetween(-10, 10);
  floatState.targetX = randomBetween(minX, maxX);
  floatState.targetY = randomBetween(minY, maxY);
  floatState.targetUntil = performance.now() + randomBetween(3200, 5200);
  floatState.phaseX = Math.random() * Math.PI * 2;
  floatState.phaseY = Math.random() * Math.PI * 2;
  floatState.lastTs = 0;
};

// 점수 등급 텍스트가 배너 내부를 넓게 휘젓도록, 이동 목표점을 계속 갈아타는 부유 운동입니다.
const animateScoreGrade = (ts: number) => {
  const banner = scoreBannerRef.value;
  const grade = scoreGradeRef.value;
  if (!banner || !grade) return;

  const overflowX = grade.offsetWidth / 3;
  const overflowY = grade.offsetHeight / 3;
  const minX = -overflowX;
  const minY = -overflowY;
  const maxX = banner.clientWidth - grade.offsetWidth + overflowX;
  const maxY = banner.clientHeight - grade.offsetHeight + overflowY;
  const dt = Math.min(
    0.03,
    floatState.lastTs ? (ts - floatState.lastTs) / 1000 : 0.016,
  );
  floatState.lastTs = ts;

  if (ts >= floatState.targetUntil) {
    floatState.targetX = randomBetween(minX, maxX);
    floatState.targetY = randomBetween(minY, maxY);
    floatState.targetUntil = ts + randomBetween(3200, 5600);
  }

  const wanderX =
    Math.sin(ts * 0.00032 + floatState.phaseX) * 10 +
    Math.cos(ts * 0.00015 + floatState.phaseY) * 7;
  const wanderY =
    Math.cos(ts * 0.00028 + floatState.phaseY) * 9 +
    Math.sin(ts * 0.0005 + floatState.phaseX) * 6;

  const targetForceX = (floatState.targetX - floatState.x) * 0.018;
  const targetForceY = (floatState.targetY - floatState.y) * 0.016;

  floatState.vx += (wanderX * 0.05 + targetForceX) * dt * 3.2;
  floatState.vy += (wanderY * 0.05 + targetForceY) * dt * 3.2;

  const currentSpeed = Math.hypot(floatState.vx, floatState.vy);
  if (currentSpeed > 0.0001) {
    floatState.vx = (floatState.vx / currentSpeed) * FIXED_FLOAT_SPEED;
    floatState.vy = (floatState.vy / currentSpeed) * FIXED_FLOAT_SPEED;
  }

  floatState.x += floatState.vx * dt * 60;
  floatState.y += floatState.vy * dt * 60;

  if (floatState.x <= minX) {
    floatState.x = minX;
    floatState.vx = Math.abs(floatState.vx);
  } else if (floatState.x >= maxX) {
    floatState.x = maxX;
    floatState.vx = -Math.abs(floatState.vx);
  }

  if (floatState.y <= minY) {
    floatState.y = minY;
    floatState.vy = Math.abs(floatState.vy);
  } else if (floatState.y >= maxY) {
    floatState.y = maxY;
    floatState.vy = -Math.abs(floatState.vy);
  }

  floatState.rotation =
    Math.sin(ts * 0.00038 + floatState.phaseX) * 4.5 + floatState.vx * 0.7;

  const bobble = 1 + Math.sin(ts * 0.00065 + floatState.phaseY) * 0.015;
  scoreGradeStyle.value = {
    transform: `translate3d(${floatState.x}px, ${floatState.y}px, 0) rotate(${floatState.rotation}deg) scale(${bobble})`,
  };

  scoreGradeRafId = requestAnimationFrame(animateScoreGrade);
};

const startScoreGradeMotion = async () => {
  stopScoreGradeMotion();
  await nextTick();
  resetScoreGradeMotion();
  scoreGradeRafId = requestAnimationFrame(animateScoreGrade);
};

watch(
  () => currentQuestion.value?.question_id,
  () => {
    showHint.value = false;
  },
);

watch(
  () => props.questions,
  () => {
    currentIndex.value = 0;
    isQuizFinished.value = false;
    showHint.value = false;
    selectedOptions.value = Array(props.questions.length).fill(null);
    logSaved.value = false;
  },
  { deep: true },
);

watch(isQuizFinished, async (finished) => {
  if (finished) {
    await startScoreGradeMotion();
    return;
  }
  stopScoreGradeMotion();
});

onUnmounted(() => {
  stopScoreGradeMotion();
});
</script>

<template>
  <div class="daily-modal-overlay">
    <div class="daily-modal-content">
      <div class="daily-header">
        <div class="daily-title">
          <IconDailySpark class="daily-icon" />
          {{ props.title || "오늘의 공개문제" }}
        </div>
        <div class="daily-progress">
          <div class="progress-info">
            문항 {{ Number(currentIndex) + 1 }} / {{ questions.length }}
            <span class="slider-hint">(원하는 번호로 이동)</span>
          </div>
          <div class="slider-wrapper">
            <input
              type="range"
              class="question-slider"
              min="0"
              :max="questions.length - 1"
              v-model.number="currentIndex"
              @keydown="handleSliderKeyDown"
            />
          </div>
        </div>
        <div class="header-actions">
          <button class="btn-submit-top" @click="submitAnswers">
            답안 제출
          </button>
          <button class="btn-close" @click="emit('close')">&times;</button>
        </div>
      </div>

      <div class="daily-body">
        <div v-if="currentQuestion" class="custom-solver">
          <div class="q-header">
            <div class="q-header-left">
              <span class="q-type">{{
                getQuestionTypeLabel(currentQuestion)
              }}</span>
              <h2 class="q-title">{{ currentQuestion.title }}</h2>
            </div>
            <div class="q-header-right">
              <span class="q-badge">
                {{ formatGroupPath((currentQuestion as any).group) }} :
                {{ maskName((currentQuestion as any).creator?.username) }}</span>
            </div>
          </div>

          <LatexRenderer :text="currentQuestion.question" />

          <div v-if="currentQuestion.passage" class="q-passage">
            <client-only>
              <v-md-preview
                :text="currentQuestion.passage.content_md"
              ></v-md-preview>
            </client-only>
          </div>

          <div class="q-options">
            <div
              v-for="opt in currentQuestion.options || []"
              :key="opt.option_id"
              class="opt-item"
              :class="{
                'is-selected': currentSelectedOpt === opt.option_id,
              }"
              @click="selectOption(opt.option_id)">
              <span class="opt-num">{{ opt.option_number }}</span>
              <span class="opt-text"
                ><LatexRenderer :text="opt.content"
              /></span>
            </div>
          </div>
        </div>
      </div>

      <div class="daily-footer">
        <div class="footer-left-actions">
          <button
            class="btn-action prev-btn"
            :disabled="currentIndex === 0"
            @click="goPrev">
            &larr; 이전 문제
          </button>
        </div>

        <div class="footer-hint-wrapper">
          <Transition name="fade" mode="out-in">
            <button
              v-if="hasCurrentHint && !showHint"
              class="btn-hint-toggle"
              :key="`hint-toggle-${currentQuestion.question_id}`"
              @click="showHint = true">
              힌트보기
            </button>
            <div
              v-else-if="showHint && currentQuestion.hint"
              class="footer-hint"
              :key="currentQuestion.question_id">
              <div class="hint-body">
                <IconHintBulb class="hint-icon" />
                <span class="hint-text">{{ currentQuestion.hint }}</span>
              </div>
              <button class="hint-close-btn" @click="showHint = false">
                ✕
              </button>
            </div>
          </Transition>
        </div>

        <button
          class="btn-action next-btn"
          :disabled="currentIndex === questions.length - 1"
          @click="goNext">
          다음 문제 &rarr;
        </button>
      </div>
    </div>

    <!-- 결과 화면 (문제창 위에 오버레이) -->
    <div v-if="isQuizFinished" class="result-overlay">
      <div class="result-card mini-card">
        <div class="result-header">
          <IconDailyAward class="result-icon" />
          <div class="result-header-text">
            <h2>학습 완료!</h2>
            <p>오늘의 도전을 모두 마쳤습니다.</p>
          </div>
        </div>

        <div class="result-stats">
          <div class="stat-summary">
            <div class="stat-item">
              <span class="stat-label">정답</span>
              <span class="stat-val text-green">{{ correctCount }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">오답</span>
              <span class="stat-val text-red">{{ wrongCount }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">미해결</span>
              <span class="stat-val text-gray">{{ unsolvedCount }}</span>
            </div>
          </div>
          <div ref="scoreBannerRef" class="score-banner">
            <div class="score-number">{{ totalScore }}점</div>
            <div
              ref="scoreGradeRef"
              class="score-grade"
              :class="gradeResult.charAt(0)"
              :style="scoreGradeStyle">
              {{ gradeResult }}
            </div>
          </div>
        </div>

        <div class="result-details custom-scrollbar">
          <div
            v-for="(q, i) in questions"
            :key="q.question_id"
            class="detail-item">
            <div class="detail-title">
              <span class="detail-num">{{ i + 1 }}번</span>
              <span class="detail-name">{{ q.title }}</span>
            </div>
            <div class="detail-res" :class="getResultClass(i)">
              {{ getResultText(i) }}
            </div>
          </div>
        </div>

        <div class="result-footer">
          <button class="btn-finish" @click="finishDaily">완료 및 닫기</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.daily-modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(5, 8, 18, 0.9);
  backdrop-filter: blur(20px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.daily-modal-content {
  background: #0f172a;
  width: 100%;
  max-width: 1000px;
  height: 85vh;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 50px 100px -20px rgba(0, 0, 0, 0.8);
  position: relative;
}

.daily-header {
  padding: 0.8rem 1.5rem;
  background: rgba(255, 255, 255, 0.03);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  align-items: center;
  justify-content: space-between;
  position: relative;
}

.daily-title {
  font-size: 1.2rem;
  font-weight: 800;
  color: #f8fafc;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  white-space: nowrap;
}

.daily-icon {
  width: 1.15rem;
  height: 1.15rem;
  color: #fbbf24;
  flex-shrink: 0;
}

.daily-progress {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 400px;
  margin: 0 2rem;
}

.progress-info {
  font-size: 0.9rem;
  color: #94a3b8;
  font-weight: 600;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
}

.slider-hint {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 500;
}

.slider-wrapper {
  width: 100%;
  padding: 0.5rem 0;
}

.question-slider {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 8px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  outline: none;
  cursor: pointer;
}

.question-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #6366f1;
  box-shadow: 0 0 10px rgba(99, 102, 241, 0.5);
  cursor: pointer;
  transition: transform 0.1s;
}

.question-slider::-webkit-slider-thumb:hover {
  transform: scale(1.2);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.btn-submit-top {
  background: linear-gradient(135deg, #10b981, #059669);
  color: #fff;
  border: none;
  padding: 0.5rem 1.2rem;
  border-radius: 8px;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 4px 10px rgba(16, 185, 129, 0.3);
  transition: all 0.2s;
}

.btn-submit-top:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 15px rgba(16, 185, 129, 0.4);
}

.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 1.8rem;
  cursor: pointer;
  line-height: 1;
  transition: color 0.2s;
}
.btn-close:hover {
  color: #fff;
}

/* Custom Solver Container */
.daily-body {
  flex: 1;
  overflow-y: auto;
  padding: 1.5rem 2rem;
  display: flex;
  flex-direction: column;
}

.custom-solver {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  width: 100%;
  max-width: 800px;
  margin: 0 auto;
  flex: 1;
}

.q-header {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
}

.q-header-left {
  display: flex;
  align-items: center;
  gap: 0.8rem;
}

.q-header-right {
  display: flex;
  align-items: center;
  gap: 0.6rem;
}

.q-badge {
  background: rgba(255, 255, 255, 0.05);
  padding: 0.3rem 0.6rem;
  border-radius: 6px;
  font-size: 0.8rem;
  color: #cbd5e1;
  display: flex;
  align-items: center;
  gap: 0.3rem;
  border: 1px solid rgba(255, 255, 255, 0.05);
  white-space: nowrap;
}

.q-badge.diff-상 {
  color: #f87171;
  background: rgba(248, 113, 113, 0.1);
  border-color: rgba(248, 113, 113, 0.2);
}
.q-badge.diff-중 {
  color: #fbbf24;
  background: rgba(251, 191, 36, 0.1);
  border-color: rgba(251, 191, 36, 0.2);
}
.q-badge.diff-하 {
  color: #60a5fa;
  background: rgba(96, 165, 250, 0.1);
  border-color: rgba(96, 165, 250, 0.2);
}

.q-type {
  font-size: 0.8rem;
  font-weight: 700;
  color: #fff;
  background: linear-gradient(135deg, #6366f1, #a5b4fc);
  padding: 0.3rem 0.8rem;
  border-radius: 10px;
  flex-shrink: 0;
}

.q-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: #e2e8f0;
  line-height: 1.4;
}

.q-text {
  font-size: 1.05rem;
  line-height: 1.6;
  color: #f1f5f9;
  font-weight: 500;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
}

.q-passage {
  background: rgba(255, 255, 255, 0.03);
  padding: 1rem;
  border-radius: 10px;
  font-size: 0.95rem;
}

.q-options {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.2rem;
  margin-top: auto;
}

.opt-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.8rem 1rem;
  background: rgba(255, 255, 255, 0.04);
  border: 2px solid transparent;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
}

.opt-item:hover:not(.is-selected) {
  background: rgba(255, 255, 255, 0.08);
}

.opt-num {
  font-size: 1.1rem;
  font-weight: 800;
  color: #94a3b8;
  background: rgba(255, 255, 255, 0.1);
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  flex-shrink: 0;
}

.opt-text {
  font-size: 1rem;
  color: #cbd5e1;
  line-height: 1.5;
}

/* Option States */
.opt-item.is-selected {
  background: rgba(99, 102, 241, 0.1);
  border-color: #6366f1;
}
.opt-item.is-selected .opt-num {
  background: #6366f1;
  color: #fff;
}
.opt-item.is-selected .opt-text {
  color: #fff;
  font-weight: 600;
}

/* Footer Section */
.daily-footer {
  padding: 0.8rem 1.5rem;
  background: rgba(255, 255, 255, 0.03);
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1.5rem;
}

.footer-left-actions {
  display: flex;
  align-items: center;
  gap: 0.9rem;
  flex-shrink: 0;
}

.footer-hint-wrapper {
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.8rem;
  min-height: 64px;
  width: min(100%, 540px);
  margin: 0 auto;
}

.btn-hint-toggle {
  border: 1px solid rgba(245, 158, 11, 0.28);
  background: rgba(245, 158, 11, 0.1);
  color: #fbbf24;
  padding: 0.55rem 0.95rem;
  border-radius: 10px;
  font-size: 0.88rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 92px;
}

.btn-hint-toggle:hover {
  background: rgba(245, 158, 11, 0.16);
  border-color: rgba(245, 158, 11, 0.4);
}

.footer-hint {
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.2);
  padding: 0.6rem 1rem;
  border-radius: 10px;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 0.6rem;
  max-width: 500px;
  width: 100%;
  min-height: 52px;
}

.hint-body {
  display: flex;
  align-items: flex-start;
  gap: 0.6rem;
  min-width: 0;
}

.hint-icon {
  color: #f59e0b;
  flex-shrink: 0;
  width: 1rem;
  height: 1rem;
  margin-top: 0.1rem;
}

.hint-text {
  color: #fbbf24;
  font-size: 0.9rem;
  line-height: 1.5;
  white-space: pre-wrap;
  word-break: break-all;
}

.hint-close-btn {
  border: none;
  background: transparent;
  color: #fbbf24;
  font-size: 0.95rem;
  font-weight: 800;
  cursor: pointer;
  line-height: 1;
  padding: 0.1rem;
  flex-shrink: 0;
}

.btn-action {
  font-family: inherit;
  font-size: 1rem;
  font-weight: 700;
  padding: 0.6rem 2rem;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
}

.btn-action:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  pointer-events: none;
}

.prev-btn {
  background: rgba(255, 255, 255, 0.05);
  color: #cbd5e1;
  border: 1px solid rgba(255, 255, 255, 0.1);
}
.prev-btn:hover {
  background: rgba(255, 255, 255, 0.1);
}

.next-btn {
  background: rgba(99, 102, 241, 0.15);
  color: #818cf8;
  border: 1px solid rgba(99, 102, 241, 0.3);
}
.next-btn:hover {
  background: rgba(99, 102, 241, 0.25);
}

/* Result Overlay & Mini Card */
.result-overlay {
  position: absolute;
  inset: 0;
  background: rgba(15, 23, 42, 0.85); /* Slightly transparent dark background */
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
  border-radius: 10px;
}

.result-card.mini-card {
  background: #111827;
  padding: 1.5rem 1.5rem;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.15);
  box-shadow: 0 30px 60px rgba(0, 0, 0, 0.6);
  text-align: center;
  width: 100%;
  max-width: 440px;
  animation: scaleIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

@keyframes scaleIn {
  from {
    opacity: 0;
    transform: scale(0.9);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.result-header {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 1rem;
  text-align: left;
}

.result-icon {
  width: 2.2rem;
  height: 2.2rem;
  margin: 0;
  color: #a5b4fc;
  flex-shrink: 0;
}
.result-header-text h2 {
  font-size: 1.4rem;
  font-weight: 900;
  color: #fff;
  margin: 0;
  line-height: 1.2;
}
.result-header-text p {
  color: #94a3b8;
  font-size: 0.85rem;
  margin: 0;
  margin-top: 0.2rem;
}

.result-stats {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.stat-summary {
  display: flex;
  gap: 0.5rem;
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0.6rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 10px;
}

.stat-label {
  color: #94a3b8;
  font-weight: 600;
  font-size: 0.95rem;
}
.stat-val {
  font-weight: 800;
  font-size: 1.05rem;
}
.stat-val.text-green {
  color: #10b981;
}
.stat-val.text-red {
  color: #ef4444;
}
.stat-val.text-gray {
  color: #94a3b8;
}

.score-banner {
  margin-top: 0.8rem;
  padding: 1rem 1.2rem;
  background: rgba(99, 102, 241, 0.05);
  border: 1px solid rgba(99, 102, 241, 0.2);
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.2rem;
  position: relative;
  overflow: hidden;
  min-height: 78px;
}

.score-number {
  font-size: 2.8rem;
  font-weight: 900;
  color: #fff;
  line-height: 1;
  position: relative;
  z-index: 2;
}

.score-grade {
  position: absolute;
  left: 0;
  top: 0;
  font-size: 4rem;
  font-weight: 900;
  opacity: 0.14;
  color: #818cf8;
  pointer-events: none;
  white-space: nowrap;
  user-select: none;
  will-change: transform;
  text-shadow: 0 0 20px rgba(129, 140, 248, 0.16);
}

.score-grade.수 {
  color: #10b981;
}
.score-grade.우 {
  color: #3b82f6;
}
.score-grade.미 {
  color: #f59e0b;
}
.score-grade.양 {
  color: #f97316;
}
.score-grade.가 {
  color: #ef4444;
}

.score-grade-label.수 {
  color: #10b981;
}
.score-grade-label.우 {
  color: #3b82f6;
}
.score-grade-label.미 {
  color: #f59e0b;
}
.score-grade-label.양 {
  color: #f97316;
}
.score-grade-label.가 {
  color: #ef4444;
}

/* Scrollable Details */
.result-details {
  max-height: 350px;
  overflow-y: auto;
  margin: 1rem 0;
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  background: rgba(0, 0, 0, 0.15);
  border-radius: 10px;
  padding: 0.8rem;
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.result-details::-webkit-scrollbar {
  width: 6px;
}
.result-details::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.15);
  border-radius: 10px;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.6rem 0.8rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 8px;
}

.detail-title {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  text-align: left;
  flex: 1;
  overflow: hidden;
}

.detail-num {
  font-weight: 800;
  color: #94a3b8;
  font-size: 0.85rem;
  flex-shrink: 0;
}

.detail-name {
  color: #f1f5f9;
  font-size: 0.9rem;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.detail-res {
  font-weight: 800;
  font-size: 0.85rem;
  flex-shrink: 0;
  padding: 0.3rem 0.6rem;
  border-radius: 6px;
}

.res-correct {
  color: #10b981;
  background: rgba(16, 185, 129, 0.1);
}
.res-wrong {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.1);
}
.res-unsolved {
  color: #94a3b8;
  background: rgba(255, 255, 255, 0.1);
}

.btn-finish {
  width: 100%;
  background: linear-gradient(135deg, #f8fafc, #e2e8f0);
  color: #0f172a;
  border: none;
  padding: 1rem;
  border-radius: 10px;
  font-weight: 800;
  font-size: 1.05rem;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
}

.btn-finish:hover {
  transform: scale(1.02);
  box-shadow: 0 6px 15px rgba(0, 0, 0, 0.3);
}
</style>
