<!--
파일 개요:
- 역할: 문제집을 생성하거나 수정하는 공통 업서트 모달입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { ref, watch } from "vue";

type BookForm = {
  book_name: string;
  description: string;
};

const props = withDefaults(
  defineProps<{
    show: boolean;
    title: string;
    submitLabel: string;
    loading?: boolean;
    errorMessage?: string;
    initialForm: BookForm;
    selectedCount?: number | null;
  }>(),
  {
    loading: false,
    errorMessage: "",
    selectedCount: null,
  },
);

const emit = defineEmits<{
  close: [];
  submit: [{ form: BookForm }];
}>();

const localForm = ref<BookForm>({
  book_name: "",
  description: "",
});

const resetFromProps = () => {
  localForm.value = {
    book_name: props.initialForm.book_name || "",
    description: props.initialForm.description || "",
  };
};

watch(
  () => props.show,
  (show) => {
    if (show) resetFromProps();
  },
  { immediate: true },
);

const submit = () => {
  emit("submit", { form: { ...localForm.value } });
};
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="show" class="modal-overlay" @click.self="emit('close')">
        <div class="modal-content" role="dialog" aria-modal="true">
          <div class="modal-header">
            <h3>{{ title }}</h3>
            <button
              class="modal-close"
              @click="emit('close')"
              aria-label="닫기">
              ✕
            </button>
          </div>

          <form class="modal-form" @submit.prevent="submit">
            <div class="form-group">
              <label class="form-label">문제집 이름</label>
              <input
                :value="localForm.book_name"
                type="text"
                class="form-input"
                placeholder="예: 2024 정보처리기사 핵심문항"
                @input="
                  localForm.book_name = (
                    $event.target as HTMLInputElement
                  ).value
                "
              />
            </div>
            <div class="form-group">
              <label class="form-label">설명</label>
              <textarea
                :value="localForm.description"
                class="form-input form-textarea"
                placeholder="문제집에 대한 설명을 적어주세요."
                @input="
                  localForm.description = (
                    $event.target as HTMLTextAreaElement
                  ).value
                "
              ></textarea>
            </div>

            <p v-if="selectedCount !== null" class="bundle-modal-help">
              선택된 문제 {{ selectedCount }}개를 한 번에 저장합니다.
            </p>

            <div v-if="errorMessage" class="form-error">{{ errorMessage }}</div>

            <div class="modal-actions">
              <button
                type="button"
                class="btn-secondary"
                @click="emit('close')"
                :disabled="loading">
                취소
              </button>
              <button
                type="submit"
                class="btn-primary"
                :disabled="loading">
                {{ submitLabel }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 23, 0.72);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
  z-index: 9999;
}

.modal-content {
  width: min(520px, 100%);
  background: linear-gradient(180deg, rgba(30, 41, 59, 0.98), rgba(15, 23, 42, 0.98));
  border: 1px solid rgba(129, 140, 248, 0.22);
  border-radius: 10px;
  box-shadow: 0 24px 60px rgba(0, 0, 0, 0.45);
  padding: 1.25rem;
  color: #e2e8f0;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1rem;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.15rem;
  font-weight: 800;
  color: #f8fafc;
}

.modal-close {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 1.25rem;
  cursor: pointer;
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 0.9rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.45rem;
}

.form-label {
  color: #e2e8f0;
  font-size: 0.92rem;
  font-weight: 700;
}

.form-input {
  width: 100%;
  border: 1px solid rgba(148, 163, 184, 0.22);
  border-radius: 10px;
  background: rgba(15, 23, 42, 0.72);
  color: #f8fafc;
  padding: 0.75rem 0.9rem;
  font-size: 0.95rem;
  outline: none;
  box-sizing: border-box;
}

.form-input:focus {
  border-color: rgba(99, 102, 241, 0.7);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.16);
}

.form-textarea {
  min-height: 110px;
  resize: vertical;
}

.bundle-modal-help {
  margin: 0;
  color: #94a3b8;
  font-size: 0.88rem;
}

.form-error {
  margin: 0;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: 8px;
  padding: 0.55rem 0.75rem;
  font-size: 0.86rem;
  color: #fca5a5;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.65rem;
  margin-top: 0.35rem;
}

.btn-secondary,
.btn-primary {
  border: none;
  border-radius: 10px;
  height: 40px;
  padding: 0 1rem;
  font-weight: 700;
  cursor: pointer;
}

.btn-secondary {
  background: rgba(148, 163, 184, 0.12);
  color: #cbd5e1;
}

.btn-primary {
  background: linear-gradient(135deg, #6366f1, #818cf8);
  color: #fff;
}

.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.2s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}
</style>
