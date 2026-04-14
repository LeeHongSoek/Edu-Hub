<!--
파일 개요:
- 역할: 문제집 생성 전용 모달 래퍼 컴포넌트입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { computed } from "vue";
import QuestionBookUpsertModal from "./QuestionBookUpsertModal.vue";

type QuestionBookForm = {
  name: string;
  description: string;
};

const props = defineProps<{
  show: boolean;
  selectedCount: number;
}>();

const emit = defineEmits<{
  close: [];
  submit: [form: QuestionBookForm];
}>();

const initialForm = computed(() => ({
  book_name: "",
  description: "",
}));

const handleSubmit = (payload: { form: { book_name: string; description: string } }) => {
  emit("submit", {
    name: payload.form.book_name,
    description: payload.form.description,
  });
};
</script>

<template>
  <QuestionBookUpsertModal
    :show="show"
    title="문제집 만들기"
    submit-label="문제집 생성"
    :initial-form="initialForm"
    :selected-count="selectedCount"
    @close="emit('close')"
    @submit="handleSubmit"
  />
</template>
