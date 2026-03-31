<script setup lang="ts">
import { ref } from "vue";

const props = defineProps<{
  user: {
    userId: string;
    username: string;
    email: string;
    role: string;
  };
}>();

const emit = defineEmits<{
  (e: "close"): void;
  (e: "updated", newUsername: string): void;
}>();

// API 설정 통합
const { apiBase, getAuthHeader } = useApi();

const editUsername = ref(props.user.username);
const editPassword = ref("");
const isUpdating = ref(false);
const errorMessage = ref("");
const successMessage = ref("");

const handleUpdate = async () => {
  errorMessage.value = "";
  successMessage.value = "";
  isUpdating.value = true;

  try {
    const token = useCookie("auth_token").value;
    const body: any = { username: editUsername.value };
    if (editPassword.value) {
      body.password = editPassword.value;
    }

    const apiUrl = `${apiBase.value}/auth/profile`;

    const { data, error } = await useFetch(apiUrl, {
      method: "PUT",
      headers: getAuthHeader(),
      body,
    });

    if (error.value) {
      errorMessage.value = error.value.data?.message || "수정에 실패했습니다.";
    } else if (data.value) {
      const userCookie = useCookie("user_info");
      userCookie.value = JSON.stringify((data.value as any).user);

      successMessage.value = "성공적으로 수정되었습니다.";
      emit("updated", (data.value as any).user.username);
      setTimeout(() => emit("close"), 1500);
    }
  } catch (err) {
    errorMessage.value = "서버 통신 오류가 발생했습니다.";
  } finally {
    isUpdating.value = false;
  }
};
</script>

<template>
  <div class="modal-backdrop" @click="emit('close')">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2>사용자 정보 수정</h2>
        <button class="btn-close" @click="emit('close')">X</button>
      </div>

      <form @submit.prevent="handleUpdate" class="form">
        <div class="field disabled-field">
          <label>아이디</label>
          <input type="text" :value="user.userId" disabled />
        </div>

        <div class="field disabled-field">
          <label>이메일</label>
          <input type="text" :value="user.email" disabled />
        </div>

        <div class="field">
          <label>이름 (닉네임)</label>
          <input v-model="editUsername" type="text" required />
        </div>

        <div class="field">
          <label>새 비밀번호 (변경 시에만 입력)</label>
          <input
            v-model="editPassword"
            type="password"
            placeholder="변경하지 않으시면 비워두세요"
          />
        </div>

        <div v-if="errorMessage" class="error-msg">{{ errorMessage }}</div>
        <div v-if="successMessage" class="success-msg">
          {{ successMessage }}
        </div>

        <div class="actions">
          <button type="button" class="btn-cancel" @click="emit('close')">
            취소
          </button>
          <button type="submit" class="btn-submit" :disabled="isUpdating">
            {{ isUpdating ? "수정 중..." : "수정" }}
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.7);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}
.modal-content {
  background: rgba(30, 41, 59, 1);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  width: 90%;
  max-width: 400px;
  padding: 2rem;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  font-family: "Noto Sans KR", sans-serif;
  color: #f0f4ff;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}
.modal-header h2 {
  font-size: 1.25rem;
  color: #fff;
  margin: 0;
}
.btn-close {
  background: none;
  border: none;
  color: #94a3b8;
  font-size: 1.2rem;
  cursor: pointer;
}
.btn-close:hover {
  color: #fff;
}
.form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.field {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.field label {
  font-size: 0.85rem;
  color: #cbd5e1;
  font-weight: 500;
}
.field input {
  padding: 0.75rem;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #fff;
  font-family: inherit;
  font-size: 0.95rem;
}
.field input:focus {
  outline: none;
  border-color: #6366f1;
  background: rgba(255, 255, 255, 0.1);
}
.field.disabled-field input {
  cursor: not-allowed;
  opacity: 0.6;
}
.error-msg {
  color: #f87171;
  font-size: 0.85rem;
  font-weight: 500;
}
.success-msg {
  color: #34d399;
  font-size: 0.85rem;
  font-weight: 500;
}
.actions {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}
.btn-cancel,
.btn-submit {
  flex: 1;
  padding: 0.75rem;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all 0.2s;
  font-size: 0.95rem;
}
.btn-cancel {
  background: rgba(255, 255, 255, 0.1);
  color: #e2e8f0;
}
.btn-cancel:hover {
  background: rgba(255, 255, 255, 0.2);
}
.btn-submit {
  background: #6366f1;
  color: #fff;
}
.btn-submit:hover:not(:disabled) {
  background: #4f46e5;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}
.btn-submit:disabled {
  opacity: 0.7;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}
</style>
