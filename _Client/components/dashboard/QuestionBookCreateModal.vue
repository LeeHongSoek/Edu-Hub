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
