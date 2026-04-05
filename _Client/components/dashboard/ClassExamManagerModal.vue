<script setup lang="ts">
import { computed, ref, watch } from "vue";
import IconClose from "~/assets/icons/IconClose.svg?component";

type ClassCard = {
  classId: string;
  className: string;
  examCount: number;
};

type ExamItem = {
  examId: string;
  examName: string;
  questionCount: number;
  linkedClassName: string | null;
};

const props = defineProps<{
  open: boolean;
  classItem: ClassCard | null;
}>();

const emit = defineEmits<{
  (event: "close"): void;
  (event: "saved"): void;
}>();

const { apiBase, getAuthHeader } = useApi();

const loading = ref(false);
const saving = ref(false);
const errorMessage = ref("");
const assignedExams = ref<ExamItem[]>([]);
const availableExams = ref<ExamItem[]>([]);
const initialAssignedKeys = ref<string[]>([]);
const draggedExam = ref<{ exam: ExamItem; source: "assigned" | "available" } | null>(null);

const classTitle = computed(() => props.classItem?.className || "클래스");
const hasChanges = computed(() => {
  const current = assignedExams.value.map((exam) => exam.examId).sort();
  const initial = [...initialAssignedKeys.value].sort();
  if (current.length !== initial.length) return true;
  return current.some((key, index) => key !== initial[index]);
});

const sortExams = (items: ExamItem[]) =>
  [...items].sort((a, b) => a.examName.localeCompare(b.examName, "ko"));

const loadClassExams = async () => {
  if (!props.classItem) return;
  loading.value = true;
  errorMessage.value = "";

  try {
    const data = await $fetch<{
      classId: string;
      className: string;
      assignedExams: ExamItem[];
      availableExams: ExamItem[];
    }>(`${apiBase.value}/dashboard/classes/${props.classItem.classId}/exams`, {
      headers: getAuthHeader(),
    });

    assignedExams.value = sortExams(data.assignedExams || []);
    availableExams.value = sortExams(data.availableExams || []);
    initialAssignedKeys.value = assignedExams.value.map((exam) => exam.examId);
  } catch (error) {
    console.error("클래스 고사 조회 실패:", error);
    errorMessage.value = "클래스 연결 고사 정보를 불러오지 못했습니다.";
  } finally {
    loading.value = false;
  }
};

watch(
  () => [props.open, props.classItem?.classId],
  ([open]) => {
    if (!open) return;
    void loadClassExams();
  },
  { immediate: true },
);

const removeFromSource = (examId: string, source: "assigned" | "available") => {
  if (source === "assigned") {
    assignedExams.value = assignedExams.value.filter((exam) => exam.examId !== examId);
    return;
  }
  availableExams.value = availableExams.value.filter((exam) => exam.examId !== examId);
};

const addToTarget = (exam: ExamItem, target: "assigned" | "available") => {
  const nextExam = {
    ...exam,
    linkedClassName: target === "assigned" ? classTitle.value : exam.linkedClassName,
  };

  if (target === "assigned") {
    assignedExams.value = sortExams([...assignedExams.value, nextExam]);
    return;
  }
  availableExams.value = sortExams([...availableExams.value, nextExam]);
};

const moveExam = (exam: ExamItem, source: "assigned" | "available", target: "assigned" | "available") => {
  if (source === target) return;
  removeFromSource(exam.examId, source);
  addToTarget(exam, target);
};

const handleDragStart = (exam: ExamItem, source: "assigned" | "available") => {
  draggedExam.value = { exam, source };
};

const handleDrop = (target: "assigned" | "available") => {
  if (!draggedExam.value) return;
  moveExam(draggedExam.value.exam, draggedExam.value.source, target);
  draggedExam.value = null;
};

const handleDragEnd = () => {
  draggedExam.value = null;
};

const saveExams = async () => {
  if (!props.classItem) return;
  saving.value = true;
  errorMessage.value = "";

  try {
    await $fetch(`${apiBase.value}/dashboard/classes/${props.classItem.classId}/exams`, {
      method: "PUT",
      headers: getAuthHeader(),
      body: {
        examIds: assignedExams.value.map((exam) => exam.examId),
      },
    });
    emit("saved");
    emit("close");
  } catch (error) {
    console.error("클래스 고사 저장 실패:", error);
    errorMessage.value = "클래스 연결 고사 저장에 실패했습니다.";
  } finally {
    saving.value = false;
  }
};
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="open" class="exam-modal-overlay" @click.self="emit('close')">
        <div class="exam-modal-card">
          <div class="exam-modal-header">
            <div>
              <h2>{{ classTitle }} 고사 연결 관리</h2>
              <p>고사를 드래그해서 이 클래스에 연결하거나 해제할 수 있습니다.</p>
            </div>
            <button class="btn-close" @click="emit('close')">
              <IconClose class="close-icon" />
            </button>
          </div>

          <div v-if="loading" class="exam-modal-state">고사 목록을 불러오는 중...</div>
          <div v-else class="exam-modal-body">
            <div v-if="errorMessage" class="exam-modal-error">{{ errorMessage }}</div>

            <div class="exam-lists">
              <section
                class="exam-list-panel"
                @dragover.prevent
                @drop.prevent="handleDrop('assigned')"
              >
                <div class="exam-list-header">
                  <strong>이 클래스에 연결된 고사</strong>
                  <span>{{ assignedExams.length }}개</span>
                </div>
                <div class="exam-list">
                  <button
                    v-for="exam in assignedExams"
                    :key="`assigned-${exam.examId}`"
                    class="exam-chip"
                    draggable="true"
                    @dragstart="handleDragStart(exam, 'assigned')"
                    @dragend="handleDragEnd"
                  >
                    <span class="exam-name">{{ exam.examName }}</span>
                    <span class="exam-meta">문항 {{ exam.questionCount }}개</span>
                  </button>
                  <div v-if="assignedExams.length === 0" class="exam-empty">
                    아직 연결된 고사가 없습니다.
                  </div>
                </div>
              </section>

              <div class="exam-transfer-hint">드래그하여 이동</div>

              <section
                class="exam-list-panel"
                @dragover.prevent
                @drop.prevent="handleDrop('available')"
              >
                <div class="exam-list-header">
                  <strong>내 다른 고사</strong>
                  <span>{{ availableExams.length }}개</span>
                </div>
                <div class="exam-list">
                  <button
                    v-for="exam in availableExams"
                    :key="`available-${exam.examId}`"
                    class="exam-chip"
                    draggable="true"
                    @dragstart="handleDragStart(exam, 'available')"
                    @dragend="handleDragEnd"
                  >
                    <span class="exam-name">{{ exam.examName }}</span>
                    <span class="exam-meta">
                      문항 {{ exam.questionCount }}개
                      <template v-if="exam.linkedClassName">
                        · 현재 {{ exam.linkedClassName }}
                      </template>
                      <template v-else>
                        · 미연결
                      </template>
                    </span>
                  </button>
                  <div v-if="availableExams.length === 0" class="exam-empty">
                    이동 가능한 고사가 없습니다.
                  </div>
                </div>
              </section>
            </div>

            <div class="exam-modal-actions">
              <button class="btn-secondary" @click="emit('close')">닫기</button>
              <button class="btn-primary" :disabled="saving || !hasChanges" @click="saveExams">
                {{ saving ? "저장 중..." : "저장" }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.exam-modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 2000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  background: rgba(2, 6, 23, 0.72);
  backdrop-filter: blur(10px);
}

.exam-modal-card {
  width: min(960px, 100%);
  border-radius: 20px;
  border: 1px solid rgba(148, 163, 184, 0.18);
  background:
    linear-gradient(180deg, rgba(30, 41, 59, 0.96), rgba(15, 23, 42, 0.96));
  box-shadow: 0 28px 70px rgba(2, 6, 23, 0.45);
  overflow: hidden;
}

.exam-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  padding: 1.25rem 1.4rem 1rem;
  border-bottom: 1px solid rgba(148, 163, 184, 0.12);
}

.exam-modal-header h2 {
  margin: 0 0 0.3rem;
  color: #f8fafc;
  font-size: 1.2rem;
  font-weight: 800;
}

.exam-modal-header p {
  margin: 0;
  color: #94a3b8;
  font-size: 0.9rem;
}

.btn-close {
  appearance: none;
  border: 1px solid rgba(148, 163, 184, 0.18);
  background: rgba(15, 23, 42, 0.72);
  color: #e2e8f0;
  border-radius: 10px;
  width: 38px;
  height: 38px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.close-icon {
  width: 1rem;
  height: 1rem;
}

.exam-modal-state,
.exam-modal-error {
  padding: 1.2rem 1.4rem;
  color: #cbd5e1;
}

.exam-modal-error {
  color: #fda4af;
  padding-bottom: 0;
}

.exam-modal-body {
  padding: 1rem 1.4rem 1.4rem;
}

.exam-lists {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 90px minmax(0, 1fr);
  gap: 1rem;
  align-items: stretch;
}

.exam-list-panel {
  border-radius: 16px;
  border: 1px solid rgba(99, 102, 241, 0.2);
  background: rgba(15, 23, 42, 0.6);
  min-height: 420px;
  display: flex;
  flex-direction: column;
}

.exam-list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1rem 0.85rem;
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
  color: #cbd5f5;
}

.exam-list-header strong {
  font-size: 0.98rem;
  font-weight: 800;
}

.exam-list-header span {
  color: #a5b4fc;
  font-size: 0.82rem;
  font-weight: 700;
}

.exam-list {
  flex: 1;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
}

.exam-chip {
  appearance: none;
  border: 1px solid rgba(148, 163, 184, 0.16);
  background: rgba(30, 41, 59, 0.84);
  color: #f8fafc;
  border-radius: 12px;
  padding: 0.8rem 0.9rem;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.15rem;
  text-align: left;
  cursor: grab;
}

.exam-chip:active {
  cursor: grabbing;
}

.exam-name {
  font-size: 0.95rem;
  font-weight: 700;
}

.exam-meta {
  font-size: 0.78rem;
  color: #94a3b8;
}

.exam-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: #64748b;
  font-size: 0.88rem;
  min-height: 160px;
}

.exam-transfer-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: #a5b4fc;
  font-size: 0.85rem;
  font-weight: 800;
  border-radius: 16px;
  border: 1px dashed rgba(99, 102, 241, 0.3);
  background: rgba(15, 23, 42, 0.42);
  min-height: 420px;
}

.exam-modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  margin-top: 1rem;
}

.btn-primary,
.btn-secondary {
  appearance: none;
  border-radius: 12px;
  padding: 0.72rem 1.1rem;
  font-size: 0.92rem;
  font-weight: 700;
  cursor: pointer;
}

.btn-primary {
  border: 1px solid rgba(99, 102, 241, 0.35);
  background: rgba(99, 102, 241, 0.2);
  color: #eef2ff;
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  border: 1px solid rgba(148, 163, 184, 0.16);
  background: rgba(30, 41, 59, 0.84);
  color: #e2e8f0;
}

.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.18s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

@media (max-width: 900px) {
  .exam-lists {
    grid-template-columns: 1fr;
  }

  .exam-transfer-hint {
    min-height: 64px;
  }

  .exam-list-panel {
    min-height: 280px;
  }
}
</style>
