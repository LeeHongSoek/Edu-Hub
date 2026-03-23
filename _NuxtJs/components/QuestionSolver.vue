<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue';
import type { Question } from '~/types';

const props = defineProps<{
  question: Question;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
}>();

const userAnswer = ref('');
const selectedOptionId = ref<string | number | null>(null);
const timeLeft = ref(props.question.time_limit || 0);
const isFinished = ref(false);
const showResult = ref(false);
const isCorrect = ref(false);
const showModal = ref(false);
const modalTitle = ref('');
const modalMessage = ref('');
const modalType = ref<'success' | 'error' | 'warning'>('success');

let timerInterval: any = null;

const startTimer = () => {
  if (timeLeft.value > 0) {
    timerInterval = setInterval(() => {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        clearInterval(timerInterval);
        handleFinish(true);
      }
    }, 1000);
  }
};

const formatTime = (seconds: number) => {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}:${s < 10 ? '0' : ''}${s}`;
};

const handleFinish = (isTimeOver = false) => {
  if (isFinished.value) return;
  
  isFinished.value = true;
  clearInterval(timerInterval);
  
  if (isTimeOver) {
    isCorrect.value = false;
  } else {
    // 채점 로직
    if (props.question.question_type_id?.toUpperCase() === 'M') {
      const correctOption = props.question.options?.find(opt => opt.is_answer);
      isCorrect.value = selectedOptionId.value == correctOption?.option_id;
    } else {
      const cleanUserAnswer = userAnswer.value.trim().toLowerCase();
      const cleanCorrectAnswer = props.question.answer.trim().toLowerCase();
      isCorrect.value = cleanUserAnswer === cleanCorrectAnswer;
    }
  }
  
  showResult.value = true;
  
  if (isTimeOver) {
    modalType.value = 'warning';
    modalTitle.value = '시간 초과! ⏰';
    modalMessage.value = '제한 시간이 다 되어 오답 처리되었습니다.';
  } else if (isCorrect.value) {
    modalType.value = 'success';
    modalTitle.value = '정답입니다! 🎉';
    modalMessage.value = '정말 잘하셨어요! 다음 문제도 도전해 보세요.';
  } else {
    modalType.value = 'error';
    modalTitle.value = '아쉽게도 틀렸습니다. 😢';
    modalMessage.value = `정답은 "${props.question.answer || '해설 참조'}" 입니다. 해설을 확인해 보세요.`;
  }
  showModal.value = true;
};

const handleKeyDown = (e: KeyboardEvent) => {
  if (e.key === 'Escape') {
    emit('close');
  }
};

onMounted(() => {
  console.log('Solve Screen Data:', props.question); // 데이터 검증용 로그
  startTimer();
  window.addEventListener('keydown', handleKeyDown);
});

onUnmounted(() => {
  if (timerInterval) clearInterval(timerInterval);
  window.removeEventListener('keydown', handleKeyDown);
});

const progressWidth = computed(() => {
  if (!props.question.time_limit) return '100%';
  return `${(timeLeft.value / props.question.time_limit) * 100}%`;
});
const formatGroupPath = (group: any) => {
  const parts: string[] = [];
  let current = group;
  while (current) {
    parts.unshift(current.name);
    current = current.parent_group;
  }
  return parts.join(' / ');
};
</script>

<template>
  <div class="solver-overlay">
    <div class="solver-card">
      <div class="solver-top-actions">
        <div v-if="question.group" class="solver-group-path">
          {{ formatGroupPath(question.group) }}
        </div>
        <button class="btn-close" @click="emit('close')">&times;</button>
      </div>
      
      <div class="solver-header">
        <div class="question-info">
          <span class="badge-type">{{ question.type.type_name }}</span>
          <h2 class="solver-title">{{ question.title }}</h2>
        </div>
        
        <div v-if="question.time_limit" class="timer-container">
          <div class="timer-text">
            <span class="timer-label">제한시간:</span> {{ formatTime(timeLeft) }}
          </div>
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: progressWidth }"></div>
          </div>
        </div>
      </div>

      <div class="solver-body">
        <div class="question-text">
          <LatexRenderer :text="question.question" />
        </div>
        
        <div v-if="question.content" class="question-content">
          <LatexRenderer :text="question.content" />
        </div>

        <!-- 객관식 보기 영역 (M: 객관식) -->
        <div v-if="question.question_type_id?.toUpperCase() === 'M'" class="options-list">
          <div v-if="!question.options || question.options.length === 0" class="no-options">
            등록된 보기가 없습니다.
          </div>
          <div 
            v-for="opt in question.options" 
            :key="opt.option_id"
            class="option-item"
            :class="{ 
              'is-selected': selectedOptionId === opt.option_id,
              'is-correct': showResult && opt.is_answer,
              'is-wrong': showResult && selectedOptionId === opt.option_id && !opt.is_answer
            }"
            @click="!isFinished && (selectedOptionId = opt.option_id)"
          >
            <span class="option-number">{{ opt.option_number }}</span>
            <span class="option-text">{{ opt.content }}</span>
          </div>
        </div>

        <!-- 주관식 입력 영역 -->
        <div v-else class="answer-input-container">
          <input 
            v-model="userAnswer" 
            type="text" 
            placeholder="정답을 입력하세요" 
            class="answer-input"
            :disabled="isFinished"
            @keyup.enter="!isFinished && handleFinish()"
          />
        </div>
      </div>

      <div class="solver-footer">
        <div v-if="showResult" class="explanation-box">
          <h4>해설</h4>
          <p>{{ question.explanation || '등록된 해설이 없습니다.' }}</p>
        </div>
        
        <button 
          v-if="!isFinished" 
          class="btn-submit" 
          :disabled="question.question_type_id === 'M' ? !selectedOptionId : !userAnswer"
          @click="handleFinish()"
        >
          정답 확인
        </button>
        <button v-else class="btn-primary" @click="emit('close')">목록으로 돌아가기</button>
      </div>
    </div>

    <!-- 커스텀 알림 모달 -->
    <Transition name="fade">
      <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
        <div class="modal-content" :class="modalType">
          <div class="modal-icon">
            <span v-if="modalType === 'success'">✅</span>
            <span v-else-if="modalType === 'error'">❌</span>
            <span v-else>⏰</span>
          </div>
          <h3 class="modal-title">{{ modalTitle }}</h3>
          <p class="modal-message">{{ modalMessage }}</p>
          <button class="btn-modal-close" @click="showModal = false">확인</button>
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.solver-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.9);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 2rem;
}

.solver-card {
  background: #1e293b;
  width: 100%;
  max-width: 800px;
  max-height: 90vh;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-direction: column;
  position: relative;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  overflow: hidden;
}

.solver-top-actions {
  position: absolute;
  top: 1rem;
  right: 1.5rem;
  left: 1.5rem;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 1rem;
  pointer-events: none;
  z-index: 10;
}

.solver-group-path {
  font-size: 0.75rem;
  color: #94a3b8;
  font-weight: 600;
  letter-spacing: 0.05em;
  background: rgba(255, 255, 255, 0.05);
  padding: 0.3rem 0.8rem;
  border-radius: 999px;
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  pointer-events: auto;
}

.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 2rem;
  cursor: pointer;
  pointer-events: auto;
  line-height: 1;
}

.solver-header {
  padding: 4rem 2rem 2rem 2rem; /* 상단 여백 확보 */
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: flex-end; /* 아래로 정렬하여 타이머와 제목 균형 유지 */
}

.solver-title {
  margin: 0.5rem 0 0 0;
  font-size: 1.25rem;
  color: #fff;
}

.timer-container {
  text-align: right;
  min-width: 200px;
}

.timer-text {
  font-family: 'JetBrains Mono', monospace;
  font-size: 3.3rem; /* 1.5배 확대 */
  font-weight: 800;
  color: #a5b4fc;
  text-shadow: 0 0 15px rgba(99, 102, 241, 0.4);
  line-height: 1;
  margin-bottom: 0.5rem;
  display: flex;
  align-items: baseline;
  justify-content: flex-end;
  gap: 0.8rem;
}

.timer-label {
  font-size: 1.2rem; /* 1.5배 확대 */
  font-weight: 700;
  color: #818cf8;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  opacity: 0.8;
  text-shadow: none;
}

.progress-bar {
  height: 4px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 2px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: #6366f1;
  transition: width 1s linear;
  margin-left: auto; /* 반대 방향으로 깎이도록 우측 정렬 */
}

.solver-body {
  padding: 2rem;
  overflow-y: auto;
  flex: 1;
}

.question-text {
  font-size: 1.5rem;
  font-weight: 700;
  color: #fff;
  line-height: 1.4;
  margin-bottom: 2rem;
}

.no-options {
  text-align: center;
  padding: 2rem;
  background: rgba(255, 255, 255, 0.02);
  border: 1px dashed rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  color: #64748b;
}

.options-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.option-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.option-item:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(99, 102, 241, 0.5);
}

.option-item.is-selected {
  background: rgba(99, 102, 241, 0.15);
  border-color: #6366f1;
}

.option-item.is-correct {
  background: rgba(34, 197, 94, 0.15);
  border-color: #22c55e;
}

.option-item.is-wrong {
  background: rgba(239, 68, 68, 0.15);
  border-color: #ef4444;
}

.option-number {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  font-size: 0.85rem;
  font-weight: 600;
  color: #94a3b8;
}

.is-selected .option-number {
  background: #6366f1;
  color: #fff;
}

.option-text {
  font-size: 1.1rem;
  color: #cbd5e1;
}

.answer-input-container {
  margin-top: 1rem;
}

.answer-input {
  width: 100%;
  padding: 1rem 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border: 2px solid rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  color: #fff;
  font-size: 1.1rem;
  outline: none;
  transition: all 0.2s;
}

.answer-input:focus {
  border-color: #6366f1;
  background: rgba(255, 255, 255, 0.08);
}

.solver-footer {
  padding: 2rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.explanation-box {
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.2);
  padding: 1.5rem;
  border-radius: 12px;
}

.explanation-box h4 {
  color: #fbbf24;
  margin: 0 0 0.5rem 0;
}

.explanation-box p {
  color: #d1d5db;
  margin: 0;
  line-height: 1.5;
}

.btn-submit, .btn-primary {
  width: 100%;
  padding: 1rem;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-submit {
  background: #6366f1;
  color: #fff;
}

.btn-submit:hover:not(:disabled) {
  background: #4f46e5;
  transform: translateY(-2px);
}

.btn-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.badge-type {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  background: rgba(99, 102, 241, 0.1);
  color: #818cf8;
  border: 1px solid rgba(99, 102, 241, 0.3);
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 600;
}

/* 커스텀 모달 스타일 */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 2rem;
}

.modal-content {
  background: rgba(30, 41, 59, 0.95);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 24px;
  padding: 2.5rem;
  width: 100%;
  max-width: 400px;
  text-align: center;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  transform: translateY(0);
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.modal-icon {
  font-size: 3.5rem;
  margin-bottom: 1.5rem;
  filter: drop-shadow(0 0 10px rgba(255, 255, 255, 0.2));
}

.modal-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: #fff;
  margin: 0 0 0.75rem 0;
  letter-spacing: -0.02em;
}

.modal-message {
  font-size: 1rem;
  color: #94a3b8;
  margin: 0 0 2rem 0;
  line-height: 1.6;
}

.btn-modal-close {
  width: 100%;
  padding: 1rem;
  background: #6366f1;
  color: #fff;
  border: none;
  border-radius: 12px;
  font-size: 1.1rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 10px 15px -3px rgba(99, 102, 241, 0.3);
}

.btn-modal-close:hover {
  background: #4f46e5;
  transform: translateY(-2px);
  box-shadow: 0 15px 20px -5px rgba(99, 102, 241, 0.4);
}

/* 모달 타입별 강조 색상 */
.modal-content.success { border-top: 5px solid #22c55e; }
.modal-content.error { border-top: 5px solid #ef4444; }
.modal-content.warning { border-top: 5px solid #f59e0b; }

/* 애니메이션 */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.3s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

.fade-enter-active .modal-content {
  animation: modal-in 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes modal-in {
  from { transform: translateY(30px) scale(0.9); opacity: 0; }
  to { transform: translateY(0) scale(1); opacity: 1; }
}
</style>
