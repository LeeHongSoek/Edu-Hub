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

let timerInterval: any = null;

const startTimer = () => {
  if (timeLeft.value > 0) {
    timerInterval = setInterval(() => {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        clearInterval(timerInterval);
        handleFinish();
      }
    }, 1000);
  }
};

const formatTime = (seconds: number) => {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m}:${s < 10 ? '0' : ''}${s}`;
};

const handleFinish = () => {
  isFinished.value = true;
  clearInterval(timerInterval);
  
  // 채점 로직
  if (props.question.question_type_id === 'M') {
    // 객관식: 선택된 보기의 is_answer 확인
    const correctOption = props.question.options?.find(opt => opt.is_answer);
    isCorrect.value = selectedOptionId.value === correctOption?.option_id;
  } else {
    // 주관식: 입력값과 정답 비교 (공백 제거 및 대소문자 무시)
    const cleanUserAnswer = userAnswer.value.trim().toLowerCase();
    const cleanCorrectAnswer = props.question.answer.trim().toLowerCase();
    isCorrect.value = cleanUserAnswer === cleanCorrectAnswer;
  }
  
  showResult.value = true;
  
  // 알림창 표시
  if (isCorrect.value) {
    alert('정답입니다! 🎉');
  } else {
    alert(`아쉽게도 틀렸습니다. 😢\n정답: ${props.question.answer}`);
  }
};

onMounted(() => {
  startTimer();
});

onUnmounted(() => {
  if (timerInterval) clearInterval(timerInterval);
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
          <div class="timer-text">{{ formatTime(timeLeft) }}</div>
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

        <!-- 객관식 보기 영역 -->
        <div v-if="question.question_type_id === 'M'" class="options-list">
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
          @click="handleFinish"
        >
          정답 확인
        </button>
        <button v-else class="btn-primary" @click="emit('close')">목록으로 돌아가기</button>
      </div>
    </div>
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
  font-size: 0.7rem;
  color: #64748b;
  font-weight: 500;
  letter-spacing: 0.02em;
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
  padding: 2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.solver-title {
  margin: 0.5rem 0 0 0;
  font-size: 1.25rem;
  color: #fff;
}

.timer-container {
  text-align: right;
  min-width: 120px;
}

.timer-text {
  font-family: monospace;
  font-size: 1.5rem;
  font-weight: 700;
  color: #6366f1;
  margin-bottom: 0.5rem;
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

.question-content {
  background: rgba(255, 255, 255, 0.03);
  padding: 1.5rem;
  border-radius: 12px;
  border-left: 4px solid #6366f1;
  color: #94a3b8;
  margin-bottom: 2rem;
  font-size: 1rem;
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
  text-transform: uppercase;
}
</style>
