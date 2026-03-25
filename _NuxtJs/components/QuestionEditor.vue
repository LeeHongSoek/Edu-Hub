<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import type { Question, QuestionOption, Group } from '~/types';

const props = defineProps<{
  question: Question;
}>();

const emit = defineEmits<{
  (e: 'close'): void;
  (e: 'updated'): void;
}>();

const editData = ref({
  title: props.question.title,
  question: props.question.question,
  content: props.question.content || '',
  passage: props.question.passage?.content_md || '',
  question_type_id: props.question.question_type_id || 'M',
  answer: props.question.answer || '',
  explanation: props.question.explanation || '',
  hint: props.question.hint || '',
  difficulty: props.question.difficulty || 1,
  time_limit: props.question.time_limit || 0,
  rating: props.question.rating || 0,
  group_id: props.question.group_id,
  options: props.question.options ? JSON.parse(JSON.stringify(props.question.options)) : []
});

const groups = ref<Group[]>([]);
const isSaving = ref(false);

const fetchGroups = async () => {
  try {
    const data = await $fetch<Group[]>('http://localhost:4000/groups');
    groups.value = data;
  } catch (error) {
    console.error('Failed to fetch groups:', error);
  }
};

onMounted(() => {
  fetchGroups();
});

const addOption = () => {
  const nextNum = editData.value.options.length + 1;
  editData.value.options.push({
    option_number: nextNum,
    content: '',
    is_answer: false
  });
};

const removeOption = (index: number) => {
  editData.value.options.splice(index, 1);
  // Re-number options
  editData.value.options.forEach((opt: any, i: number) => {
    opt.option_number = i + 1;
  });
};

const handleSave = async () => {
  isSaving.value = true;
  try {
    await $fetch(`http://localhost:4000/questions/${props.question.question_id}`, {
      method: 'PATCH',
      body: editData.value
    });
    alert('수정되었습니다! ✨');
    emit('updated');
    emit('close');
  } catch (error) {
    console.error('Failed to save question:', error);
    alert('저장 중 오류가 발생했습니다. 😢');
  } finally {
    isSaving.value = false;
  }
};

const handleDelete = async () => {
  if (!confirm('정말 이 문제를 삭제하시겠습니까?')) return;
  
  isSaving.value = true;
  try {
    await $fetch(`http://localhost:4000/questions/${props.question.question_id}`, {
      method: 'DELETE'
    });
    alert('삭제되었습니다.');
    emit('updated');
    emit('close');
  } catch (error) {
    console.error('Failed to delete question:', error);
    alert('삭제 중 오류가 발생했습니다.');
  } finally {
    isSaving.value = false;
  }
};
</script>

<template>
  <div class="editor-overlay">
    <div class="editor-card">
      <div class="editor-header">
        <div class="header-left">
          <span class="badge">문제 수정</span>
          <h2 class="editor-title">{{ question.title }}</h2>
        </div>
        <button class="btn-close" @click="emit('close')">&times;</button>
      </div>

      <div class="editor-body">
        <div class="form-section">
          <h3>기본 정보</h3>
          <div class="form-group">
            <label>문제 제목</label>
            <input v-model="editData.title" type="text" placeholder="제목을 입력하세요" />
          </div>
          
          <div class="form-row">
            <div class="form-group flex-2">
              <label>문제 유형</label>
              <select v-model="editData.question_type_id">
                <option value="M">객관식 (Multiple Choice)</option>
                <option value="S">주관식 (Short Answer)</option>
              </select>
            </div>
            <div class="form-group flex-small">
              <label>난이도 (1-5)</label>
              <input v-model.number="editData.difficulty" type="number" min="1" max="5" class="input-small" />
            </div>
            <div class="form-group flex-small">
              <label>제한 시간 (초)</label>
              <input v-model.number="editData.time_limit" type="number" min="0" class="input-small" />
            </div>
            <div class="form-group flex-small">
              <label>평점 (0-5)</label>
              <input v-model.number="editData.rating" type="number" min="0" max="5" class="input-small" />
            </div>
          </div>

          <div class="form-group">
            <label>소속 그룹</label>
            <select v-model="editData.group_id">
              <optgroup v-for="g1 in groups" :key="g1.group_id" :label="g1.name">
                <option :value="g1.group_id">{{ g1.name }} (L1)</option>
                <template v-for="g2 in g1.child_groups" :key="g2.group_id">
                  <option :value="g2.group_id">&nbsp;&nbsp;↳ {{ g2.name }} (L2)</option>
                  <option 
                    v-for="g3 in g2.child_groups" 
                    :key="g3.group_id" 
                    :value="g3.group_id"
                  >
                    &nbsp;&nbsp;&nbsp;&nbsp;↳ {{ g3.name }} (L3)
                  </option>
                </template>
              </optgroup>
            </select>
          </div>
        </div>

        <div class="form-section">
          <h3>문제 내용</h3>
          <div class="form-group">
            <label>지문 (Passage - 마크다운 및 이미지 지원)</label>
            <client-only>
              <v-md-editor v-model="editData.passage" height="400px" placeholder="독해 지문이나 긴 형식의 문제를 작성하세요"></v-md-editor>
            </client-only>
          </div>
          <div class="form-group">
            <label>질문 (Question)</label>
            <textarea v-model="editData.question" rows="3" placeholder="질문 내용을 입력하세요 (Markdown/LaTeX 지원)"></textarea>
          </div>
          <div class="form-group">
            <label>지문 (Content - 선택사항)</label>
            <textarea v-model="editData.content" rows="4" placeholder="지문이나 부가 설명이 필요한 경우 입력하세요"></textarea>
          </div>
        </div>

        <div v-if="editData.question_type_id === 'M'" class="form-section">
          <div class="section-header">
            <h3>객관식 보기</h3>
            <button class="btn-add-opt" @click="addOption">+ 보기 추가</button>
          </div>
          <div class="options-edit-list">
            <div v-for="(opt, index) in editData.options" :key="index" class="option-edit-item">
              <div class="opt-num">{{ (index as number) + 1 }}</div>
              <input v-model="opt.content" type="text" placeholder="보기 내용" class="flex-1" />
              <label class="opt-correct">
                <input 
                  type="checkbox" 
                  v-model="opt.is_answer"
                />
                정답
              </label>
              <button class="btn-remove-opt" @click="removeOption(index as number)">&times;</button>
            </div>
          </div>
        </div>

        <div v-else class="form-section">
          <h3>주관식 정답</h3>
          <div class="form-group">
            <input v-model="editData.answer" type="text" placeholder="정답을 입력하세요" />
          </div>
        </div>

        <div class="form-section">
          <h3>해설 및 힌트</h3>
          <div class="form-group">
            <label>상세 해설</label>
            <textarea v-model="editData.explanation" rows="3"></textarea>
          </div>
          <div class="form-group">
            <label>힌트</label>
            <input v-model="editData.hint" type="text" />
          </div>
        </div>
      </div>

      <div class="editor-footer">
        <button class="btn-delete" :disabled="isSaving" @click="handleDelete">삭제</button>
        <div class="footer-right">
          <button class="btn-secondary" @click="emit('close')">취소</button>
          <button class="btn-primary" :disabled="isSaving" @click="handleSave">
            {{ isSaving ? '저장 중...' : '변경사항 저장' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.editor-overlay {
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
  z-index: 2000;
  padding: 2rem;
}

.editor-card {
  background: #1e293b;
  width: 100%;
  max-width: 900px;
  max-height: 90vh;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  flex-direction: column;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
}

.editor-header {
  padding: 1.5rem 2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.editor-title {
  margin: 0.5rem 0 0 0;
  font-size: 1.25rem;
  color: #fff;
}

.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 2rem;
  cursor: pointer;
}

.editor-body {
  padding: 2rem 2.5rem 2rem 2rem;
  overflow-y: auto;
  overflow-x: hidden;
  flex: 1;
}

/* 커스텀 스크롤바 스타일 */
.editor-body::-webkit-scrollbar {
  width: 8px;
}

.editor-body::-webkit-scrollbar-track {
  background: rgba(15, 23, 42, 0.3);
  border-radius: 4px;
}

.editor-body::-webkit-scrollbar-thumb {
  background: rgba(99, 102, 241, 0.4);
  border-radius: 4px;
}

.editor-body::-webkit-scrollbar-thumb:hover {
  background: rgba(99, 102, 241, 0.6);
}

.form-section {
  margin-bottom: 2.5rem;
}

.form-section h3 {
  font-size: 1rem;
  color: #818cf8;
  margin-bottom: 1.25rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid rgba(129, 140, 248, 0.2);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.25rem;
}

.section-header h3 {
  margin-bottom: 0;
  border: none;
  padding: 0;
}

.form-group {
  margin-bottom: 1.25rem;
}

.form-group label {
  display: block;
  font-size: 0.85rem;
  color: #94a3b8;
  margin-bottom: 0.5rem;
}

.form-row {
  display: flex;
  gap: 1.5rem;
  width: 100%;
  flex-wrap: wrap;
}

.flex-1 { flex: 1; min-width: 200px; }
.flex-2 { flex: 2; min-width: 300px; }
.flex-small { flex: 0 0 120px; }

.input-small {
  max-width: 120px;
}

input[type="text"],
input[type="number"],
select,
textarea {
  width: 100%;
  box-sizing: border-box;
  padding: 0.75rem 1rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  color: #fff;
  font-size: 1rem;
  outline: none;
  transition: all 0.2s;
}

input:focus, select:focus, textarea:focus {
  border-color: #6366f1;
  background: rgba(255, 255, 255, 0.08);
}

.options-edit-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.option-edit-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
}

.opt-num {
  width: 24px;
  height: 24px;
  background: rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 0.8rem;
  font-weight: 600;
  color: #94a3b8;
}

.opt-correct {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: #94a3b8;
  cursor: pointer;
  white-space: nowrap;
}

.btn-add-opt {
  padding: 0.4rem 0.8rem;
  background: rgba(99, 102, 241, 0.1);
  color: #818cf8;
  border: 1px solid rgba(99, 102, 241, 0.3);
  border-radius: 10px;
  cursor: pointer;
  font-size: 0.85rem;
}

.btn-remove-opt {
  background: none;
  border: none;
  color: #ef4444;
  font-size: 1.5rem;
  cursor: pointer;
}

.editor-footer {
  padding: 1.5rem 2rem;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.footer-right {
  display: flex;
  gap: 1rem;
}

.btn-primary {
  padding: 0.75rem 2rem;
  background: #6366f1;
  color: #fff;
  border: none;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
}

.btn-secondary {
  padding: 0.75rem 2rem;
  background: rgba(255, 255, 255, 0.05);
  color: #94a3b8;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  cursor: pointer;
}

.btn-delete {
  padding: 0.75rem 2rem;
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  border: 1px solid rgba(239, 68, 68, 0.2);
  border-radius: 10px;
  cursor: pointer;
}

.btn-delete:hover:not(:disabled) {
  background: rgba(239, 68, 68, 0.2);
}

.badge {
  display: inline-block;
  padding: 0.2rem 0.6rem;
  background: rgba(99, 102, 241, 0.1);
  color: #818cf8;
  border: 1px solid rgba(99, 102, 241, 0.3);
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 600;
}
</style>
