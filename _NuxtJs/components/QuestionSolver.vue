<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue';
import type { Question, QuestionReview } from '~/types';
import LatexRenderer from '~/components/LatexRenderer.vue';
import IconClock from '~/assets/icons/IconClock.svg?component';

const props = defineProps<{
  question: Question;
  hasPrev?: boolean;
  hasNext?: boolean;
  currentIndex?: number;
  totalQuestions?: number;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
  (e: 'prev'): void;
  (e: 'next'): void;
}>();

const userAnswer = ref('');
const selectedOptionIds = ref<(string | number)[]>([]);
const timeLeft = ref(props.question.time_limit || 0);
const isFinished = ref(false);
const showResult = ref(false);
const isCorrect = ref(false);
const showModal = ref(false);
const modalTitle = ref('');
const modalMessage = ref('');
const modalType = ref<'success' | 'error' | 'warning'>('success');

// 리뷰 관련 상태
const showReviewModal = ref(false);
const reviews = ref<QuestionReview[]>([]);
const reviewsLoading = ref(false);
const newReviewContent = ref('');
const newRating = ref(5);
const isSubmittingReview = ref(false);

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

const toggleOption = (id: string | number) => {
  if (isFinished.value) return;
  const index = selectedOptionIds.value.indexOf(id);
  if (index === -1) {
    selectedOptionIds.value.push(id);
  } else {
    selectedOptionIds.value.splice(index, 1);
  }
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
      const correctOptions = props.question.options?.filter(opt => opt.is_answer) || [];
      const correctOptionIds = correctOptions.map(opt => opt.option_id);
      
      if (correctOptionIds.length === 0) {
        // DB에 정답이 없는 경우 예외처리
        isCorrect.value = selectedOptionIds.value.length === 0;
      } else if (correctOptionIds.length === selectedOptionIds.value.length) {
        // 개수가 같고, 선택한 모든 항목이 정답 목록에 포함되는지 확인
        isCorrect.value = selectedOptionIds.value.every(id => correctOptionIds.includes(id as NonNullable<string | number>));
      } else {
        isCorrect.value = false;
      }
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

const openReviewModal = async () => {
  showReviewModal.value = true;
  await fetchReviews();
};

const fetchReviews = async () => {
  reviewsLoading.value = true;
  try {
    const data = await $fetch<QuestionReview[]>(`http://localhost:4000/questions/${props.question.question_id}/reviews`);
    // 백엔드의 BigInt 호환 문제 처리 (JS로 받을 때 Number형 변환 등)
    reviews.value = data;
  } catch (err) {
    console.error('Failed to fetch reviews:', err);
  } finally {
    reviewsLoading.value = false;
  }
};

const submitReview = async () => {
  if (!newReviewContent.value.trim()) return;
  isSubmittingReview.value = true;
  try {
    await $fetch(`http://localhost:4000/questions/${props.question.question_id}/reviews`, {
      method: 'POST',
      body: {
        content: newReviewContent.value,
        rating: newRating.value,
        user_no: 2 // 임시: 김철수(2) 아이디로 전송
      }
    });
    newReviewContent.value = '';
    newRating.value = 5;
    await fetchReviews();
    
    // 평균 별점 업데이트 (임시로 클라이언트 계산)
    if (props.question && reviews.value.length > 0) {
      props.question.rating = Math.round(reviews.value.reduce((sum, r) => sum + r.rating, 0) / reviews.value.length);
    }
  } catch (error) {
    console.error('Failed to submit review:', error);
  } finally {
    isSubmittingReview.value = false;
  }
};
</script>

<template>
  <div class="solver-overlay">
    <div class="solver-card">
      <div class="solver-header-compact">
        <div class="compact-top">
          <div class="compact-top-left">
            <span class="badge-type">{{ question.type.type_name }}</span>
          </div>
          <div class="compact-top-right">
            <div v-if="question.group" class="solver-group-path">
              {{ formatGroupPath(question.group) }}
            </div>
            <div v-if="question.time_limit" class="timer-wrapper">
              <div class="compact-timer">
                <IconClock class="icon-clock" />
                <span class="timer-label">제한시간:</span>
                <span class="timer-val">{{ formatTime(timeLeft) }}</span>
              </div>
              <div class="progress-bar compact-progress">
                <div class="progress-fill" :style="{ width: progressWidth }"></div>
              </div>
            </div>
            <button class="btn-close" @click="emit('close')">&times;</button>
          </div>
        </div>
        <h2 class="solver-title">{{ question.title }}</h2>
      </div>

      <div class="solver-body">
        <div class="question-text">
          <LatexRenderer :text="question.question" />
        </div>
        
        <div v-if="question.passage" class="question-passage">
          <client-only>
            <v-md-preview :text="question.passage.content_md"></v-md-preview>
          </client-only>
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
              'is-selected': selectedOptionIds.includes(opt.option_id),
              'is-correct': showResult && opt.is_answer,
              'is-wrong': showResult && selectedOptionIds.includes(opt.option_id) && !opt.is_answer
            }"
            @click="toggleOption(opt.option_id)"
          >
            <span class="option-number">{{ opt.option_number }}</span>
            <span class="option-text">
              <LatexRenderer :text="opt.content" />
            </span>
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
          <div class="explanation-header">
            <div class="header-left-group">
              <h4>해설</h4>
            </div>
            <div class="rating-container">
              <span class="rating-label">전체 평균 평점</span>
              <div class="stars readonly">
                <span 
                  v-for="i in 5" 
                  :key="i" 
                  class="star" 
                  :class="{ 'is-active': i <= (question.rating || 0) }"
                >★</span>
              </div>
              <button class="btn-inline-comment" @click="openReviewModal">
                💬 의견 남기기
              </button>
            </div>
          </div>
          <p>{{ question.explanation || '등록된 해설이 없습니다.' }}</p>
        </div>
        
        <button 
          v-if="!isFinished" 
          class="btn-submit" 
          :disabled="question.question_type_id === 'M' ? selectedOptionIds.length === 0 : !userAnswer"
          @click="handleFinish()"
        >
          정답 확인
        </button>
        <div v-else class="footer-nav-buttons">
          <button class="btn-nav" :disabled="!hasPrev" @click="emit('prev')">
            이전문제
          </button>
          <button class="btn-primary" @click="emit('close')">
            목록으로 돌아가기
            <span v-if="currentIndex !== undefined && totalQuestions !== undefined" class="nav-count">
              ({{ currentIndex + 1 }}/{{ totalQuestions }})
            </span>
          </button>
          <button class="btn-nav" :disabled="!hasNext" @click="emit('next')">
            다음문제
          </button>
        </div>
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

    <!-- 의견(리뷰) 모달 -->
    <Transition name="fade">
      <div v-if="showReviewModal" class="modal-overlay" @click.self="showReviewModal = false">
        <div class="modal-content review-modal-content">
          <div class="modal-header">
            <h3 class="modal-title">문제 의견 및 평가</h3>
            <button class="btn-close-sm" @click="showReviewModal = false">&times;</button>
          </div>
          
          <div class="review-form">
            <div class="rating-input">
              <span class="rating-label">내 평점:</span>
              <div class="stars">
                <span 
                  v-for="i in 5" 
                  :key="i" 
                  class="star" 
                  :class="{'is-active': i <= newRating}" 
                  @click="newRating = i"
                >★</span>
              </div>
            </div>
            <textarea v-model="newReviewContent" placeholder="이 문제에 대한 의견을 남겨주세요. (단축키 없음, 안전하게 드래그 가능)" rows="3"></textarea>
            <button class="btn-primary" @click="submitReview" :disabled="isSubmittingReview">
              {{ isSubmittingReview ? '등록 중...' : '작성하기' }}
            </button>
          </div>

          <div class="reviews-list">
            <div v-if="reviewsLoading" class="loading">의견을 불러오는 중...</div>
            <div v-else-if="reviews.length === 0" class="empty-msg">아직 등록된 의견이 없어요. 첫 번째 의견을 남겨주세요!</div>
            <div v-else class="review-items">
              <div v-for="review in reviews" :key="review.review_id" class="review-item">
                <div class="review-header">
                  <span class="review-author">{{ review.user?.username || '익명' }}</span>
                  <div class="stars readonly-small">
                    <span v-for="i in 5" :key="i" class="star-small" :class="{'is-active': i <= review.rating}">★</span>
                  </div>
                  <span class="review-date">{{ new Date(review.created_at).toLocaleDateString() }}</span>
                </div>
                <p class="review-content">{{ review.content }}</p>
              </div>
            </div>
          </div>
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
  height: 90vh; /* Fixed to 90vh */
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-direction: column;
  position: relative;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  overflow: hidden;
}

.solver-header-compact {
  padding: 1.5rem 2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-direction: column;
  gap: 0.8rem;
}

.compact-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.compact-top-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.timer-wrapper {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.1rem;
}

.compact-timer {
  display: flex;
  align-items: baseline;
  gap: 0.4rem;
  font-family: 'JetBrains Mono', monospace;
  color: #a5b4fc;
}

.icon-clock {
  width: 15px;
  height: 15px;
  color: #818cf8;
  transform: translateY(2px);
}

.timer-label {
  font-size: 0.85rem;
  font-weight: 700;
  color: #818cf8;
}

.timer-val {
  font-size: 1.25rem;
  font-weight: 800;
  letter-spacing: 0.5px;
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
}

.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 2rem;
  cursor: pointer;
  line-height: 1;
  padding: 0;
}

.btn-close:hover {
  color: #fff;
}

.solver-title {
  margin: 0;
  font-size: 1.3rem;
  color: #fff;
  line-height: 1.4;
  word-break: keep-all;
}

.progress-bar {
  height: 4px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 2px;
  overflow: hidden;
  margin-top: 0.5rem;
}

.compact-progress {
  width: 100%;
  margin-top: 0;
  height: 3px;
}

.progress-fill {
  height: 100%;
  background: #6366f1;
  transition: width 1s linear;
  margin-left: auto;
}

.solver-body {
  padding: 2rem;
  overflow-y: auto;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.solver-body::-webkit-scrollbar {
  width: 6px;
}
.solver-body::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 3px;
}
.solver-body::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
}

.question-text {
  font-size: 1.25rem;
  font-weight: 600;
  color: #fff;
  line-height: 1.5;
  margin-bottom: auto; /* Pushes the rest of the content to the bottom */
}

.question-passage {
  margin-top: 1.5rem; /* Ensure spacing if question text is very short */
  background: #fff;
  color: #333;
  border-radius: 10px;
  padding: 1rem;
  margin-bottom: 2rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}
/* v-md-editor 기본 스타일 보완 */
.question-passage :deep(.v-md-plugin-markdown-it) {
  font-family: 'Noto Sans KR', sans-serif;
  font-size: 1.05rem;
  line-height: 1.6;
}

.no-options {
  text-align: center;
  padding: 2rem;
  background: rgba(255, 255, 255, 0.02);
  border: 1px dashed rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  color: #64748b;
}

.options-list {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem;
}

.option-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  min-height: 52px;
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
  font-size: 1rem;
  color: #cbd5e1;
}

@media (max-width: 640px) {
  .options-list {
    grid-template-columns: 1fr;
  }
}

.answer-input-container {
  margin-top: 1rem;
}

.answer-input {
  width: 100%;
  padding: 1rem 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border: 2px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
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
  padding: 1.5rem 2rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.explanation-box {
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.2);
  padding: 1rem 1.25rem;
  border-radius: 10px;
}

.explanation-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.75rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.header-left-group {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.btn-inline-comment {
  background: rgba(99, 102, 241, 0.1);
  border: 1px solid rgba(99, 102, 241, 0.2);
  color: #818cf8;
  padding: 0.25rem 0.75rem;
  border-radius: 10px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-inline-comment:hover {
  background: rgba(99, 102, 241, 0.2);
  border-color: rgba(99, 102, 241, 0.4);
  color: #fff;
}

.explanation-box h4 {
  color: #fbbf24;
  margin: 0;
}

.rating-container {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.rating-label {
  font-size: 0.8rem;
  color: #94a3b8;
}

.stars {
  display: flex;
  gap: 0.25rem;
}

.star {
  font-size: 1.5rem;
  color: rgba(255, 255, 255, 0.03); /* 70% 어둡게 배경과 더 섞이도록 */
  cursor: pointer;
  transition: all 0.2s;
}

.star.is-active {
  color: rgba(251, 191, 36, 0.4); /* 너무 밝은 별색을 좀 더 톤다운 */
}

.star:hover {
  transform: scale(1.2);
}

.explanation-box p {
  color: #d1d5db;
  margin: 0;
  line-height: 1.5;
}

.comment-panel {
  margin-top: 1.5rem;
  padding: 1rem;
  background: rgba(15, 23, 42, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
}

.comment-panel textarea {
  width: 100%;
  background: none;
  border: none;
  color: #fff;
  font-size: 0.95rem;
  resize: none;
  outline: none;
}

.comment-panel-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 0.5rem;
}

.btn-post-comment {
  padding: 0.4rem 1rem;
  background: #6366f1;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
}

.slide-down-enter-active, .slide-down-leave-active {
  transition: all 0.3s ease-out;
}
.slide-down-enter-from, .slide-down-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.btn-submit, .btn-primary {
  width: 100%;
  padding: 1rem;
  border: none;
  border-radius: 10px;
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

.footer-nav-buttons {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.btn-nav {
  padding: 1rem 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  color: #a5b4fc;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  flex: 0 0 auto;
}

.btn-nav:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  border-color: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.btn-nav:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.footer-nav-buttons .btn-primary {
  flex: 1;
}

.nav-count {
  font-size: 0.85em;
  opacity: 0.8;
  margin-left: 0.3rem;
  font-weight: 500;
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
  border-radius: 10px;
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
  border-radius: 10px;
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
  border-radius: 10px;
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

/* 의견(리뷰) 모달 스타일 */
.review-modal-content {
  width: 90%;
  max-width: 600px;
  max-height: 85vh;
  display: flex;
  flex-direction: column;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  color: #fff;
}

.btn-close-sm {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 1.75rem;
  cursor: pointer;
  padding: 0;
  line-height: 1;
  transition: color 0.2s;
}

.btn-close-sm:hover {
  color: #fff;
}

.review-form {
  background: rgba(255, 255, 255, 0.03);
  padding: 1rem;
  border-radius: 10px;
  margin-bottom: 1.5rem;
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.rating-input {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.review-form textarea {
  width: 100%;
  box-sizing: border-box;
  background: rgba(15, 23, 42, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #fff;
  padding: 0.75rem;
  border-radius: 10px;
  font-size: 0.95rem;
  resize: vertical;
  margin-bottom: 1rem;
  outline: none;
}

.review-form textarea:focus {
  border-color: #6366f1;
}

.reviews-list {
  flex: 1;
  overflow-y: auto;
  padding-right: 0.5rem;
}

.reviews-list::-webkit-scrollbar {
  width: 6px;
}
.reviews-list::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 3px;
}
.reviews-list::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
}

.review-items {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.review-item {
  background: rgba(255, 255, 255, 0.02);
  padding: 1rem;
  border-radius: 10px;
  border-left: 3px solid #6366f1;
}

.review-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.review-author {
  font-weight: 600;
  color: #e2e8f0;
  font-size: 0.9rem;
}

.review-date {
  font-size: 0.75rem;
  color: #64748b;
  margin-left: auto;
}

.review-content {
  font-size: 0.9rem;
  color: #cbd5e1;
  line-height: 1.5;
  margin: 0;
}

.readonly .star, .readonly-small .star-small {
  cursor: default;
}
.readonly .star:hover {
  transform: none;
}

.star-small {
  font-size: 1rem;
  color: rgba(255, 255, 255, 0.03);
}
.star-small.is-active {
  color: rgba(251, 191, 36, 0.4);
}

.empty-msg {
  text-align: center;
  color: #94a3b8;
  padding: 2rem 0;
  font-size: 0.9rem;
}

.loading {
  text-align: center;
  color: #818cf8;
  padding: 2rem 0;
  font-weight: 600;
}
</style>
