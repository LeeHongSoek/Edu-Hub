<!--
파일 개요:
- 역할: 문제에서 고사를 생성하거나 고사 생성 흐름을 연결하는 모달입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { computed } from "vue";
import ExamUpsertModal from "~/components/dashboard/ExamUpsertModal.vue";

type AssignableClass = {
  classId: string;
  className: string;
};

type QuestionExamForm = {
  classId: string;
  classIds: string[];
  name: string;
  description: string;
  start_time: string;
  end_time: string;
  location: string;
  is_auto_score: boolean;
};

const props = withDefaults(
  defineProps<{
    show: boolean;
    assignableClasses?: AssignableClass[];
    selectedCount: number;
  }>(),
  {
    assignableClasses: () => [],
  },
);

const emit = defineEmits<{
  close: [];
  submit: [form: QuestionExamForm];
}>();

const initialForm = computed(() => ({
  exam_name: "",
  description: "",
  start_time: "",
  end_time: "",
  location: "",
  is_auto_score: true,
}));

const handleSubmit = (payload: {
  form: {
    exam_name: string;
    description: string;
    start_time: string;
    end_time: string;
    location: string;
    is_auto_score: boolean;
  };
  classIds: string[];
}) => {
  emit("submit", {
    classId: payload.classIds[0] || "",
    classIds: payload.classIds,
    name: payload.form.exam_name,
    description: payload.form.description,
    start_time: payload.form.start_time,
    end_time: payload.form.end_time,
    location: payload.form.location,
    is_auto_score: payload.form.is_auto_score,
  });
};
</script>

<template>
  <ExamUpsertModal
    :show="show"
    title="새 고사집 만들기"
    submit-label="고사 생성"
    :initial-form="initialForm"
    :initial-assigned-classes="[]"
    :initial-available-classes="assignableClasses"
    :selected-count="selectedCount"
    @close="emit('close')"
    @submit="handleSubmit"
  />
</template>
