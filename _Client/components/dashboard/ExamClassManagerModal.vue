<!--
파일 개요:
- 역할: 고사와 클래스의 연결 관계를 관리하는 모달입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { computed, ref, watch } from "vue";
import IconClose from "~/assets/icons/IconClose.svg?component";
import IconTransferArrows from "~/assets/icons/IconTransferArrows.svg?component";

type ClassItem = {
  classId: string;
  className: string;
};

type ExamClassManagerPayload = {
  examId: string;
  examName: string;
  assignedClasses: ClassItem[];
  availableClasses: ClassItem[];
};

const props = defineProps<{
  open: boolean;
  examItem: ExamClassManagerPayload | null;
}>();

const emit = defineEmits<{
  close: [];
  saved: [];
}>();

const { apiBase, getAuthHeader } = useApi();

const loading = ref(false);
const saving = ref(false);
const errorMessage = ref("");
const assignedClasses = ref<ClassItem[]>([]);
const availableClasses = ref<ClassItem[]>([]);
const initialAssignedKeys = ref<string[]>([]);
const draggedClass = ref<{
  classItem: ClassItem;
  source: "assigned" | "available";
} | null>(null);

const examTitle = computed(() => props.examItem?.examName || "고사");
const hasChanges = computed(() => {
  const current = assignedClasses.value.map((item) => item.classId).sort();
  const initial = [...initialAssignedKeys.value].sort();
  if (current.length !== initial.length) return true;
  return current.some((key, index) => key !== initial[index]);
});

const sortClasses = (items: ClassItem[]) =>
  [...items].sort((a, b) => a.className.localeCompare(b.className, "ko"));

const loadExamClasses = async () => {
  if (!props.examItem) return;
  loading.value = true;
  errorMessage.value = "";

  try {
    const data = await $fetch<{
      examId: string;
      examName: string;
      assignedClasses: ClassItem[];
      availableClasses: ClassItem[];
    }>(`${apiBase.value}/dashboard/exams/${props.examItem.examId}/classes`, {
      headers: getAuthHeader(),
    });

    assignedClasses.value = sortClasses(data.assignedClasses || []);
    availableClasses.value = sortClasses(data.availableClasses || []);
    initialAssignedKeys.value = assignedClasses.value.map((item) => item.classId);
  } catch (error) {
    console.error("고사 클래스 조회 실패:", error);
    errorMessage.value = "고사 연결 클래스를 불러오지 못했습니다.";
  } finally {
    loading.value = false;
  }
};

watch(
  () => [props.open, props.examItem?.examId],
  ([open]) => {
    if (!open) return;
    void loadExamClasses();
  },
  { immediate: true },
);

const removeFromSource = (classId: string, source: "assigned" | "available") => {
  if (source === "assigned") {
    assignedClasses.value = assignedClasses.value.filter(
      (item) => item.classId !== classId,
    );
    return;
  }
  availableClasses.value = availableClasses.value.filter(
    (item) => item.classId !== classId,
  );
};

const addToTarget = (classItem: ClassItem, target: "assigned" | "available") => {
  if (target === "assigned") {
    assignedClasses.value = sortClasses([...assignedClasses.value, classItem]);
    return;
  }
  availableClasses.value = sortClasses([...availableClasses.value, classItem]);
};

const moveClass = (
  classItem: ClassItem,
  source: "assigned" | "available",
  target: "assigned" | "available",
) => {
  if (source === target) return;
  removeFromSource(classItem.classId, source);
  addToTarget(classItem, target);
};

const handleDragStart = (
  classItem: ClassItem,
  source: "assigned" | "available",
) => {
  draggedClass.value = { classItem, source };
};

const handleDrop = (target: "assigned" | "available") => {
  if (!draggedClass.value) return;
  moveClass(draggedClass.value.classItem, draggedClass.value.source, target);
  draggedClass.value = null;
};

const handleDragEnd = () => {
  draggedClass.value = null;
};

const saveClasses = async () => {
  if (!props.examItem) return;
  saving.value = true;
  errorMessage.value = "";

  try {
    await $fetch(`${apiBase.value}/dashboard/exams/${props.examItem.examId}/classes`, {
      method: "PUT",
      headers: getAuthHeader(),
      body: {
        classIds: assignedClasses.value.map((item) => item.classId),
      },
    });
    emit("saved");
    emit("close");
  } catch (error) {
    console.error("고사 클래스 저장 실패:", error);
    errorMessage.value = "고사 연결 클래스 저장에 실패했습니다.";
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
              <h2>{{ examTitle }} 클래스 연결 관리</h2>
              <p>
                클래스를 드래그해서 이 고사에 연결하거나 해제할 수 있습니다.
              </p>
            </div>
            <button class="btn-close" @click="emit('close')">
              <IconClose class="close-icon" />
            </button>
          </div>

          <div v-if="loading" class="exam-modal-state">
            클래스 목록을 불러오는 중...
          </div>
          <div v-else class="exam-modal-body">
            <div v-if="errorMessage" class="exam-modal-error">
              {{ errorMessage }}
            </div>

            <div class="exam-lists">
              <section
                class="exam-list-panel"
                @dragover.prevent
                @drop.prevent="handleDrop('assigned')">
                <div class="exam-list-header">
                  <strong>이 고사에 연결된 클래스</strong>
                  <span>{{ assignedClasses.length }}개</span>
                </div>
                <div class="exam-list">
                  <button
                    v-for="classItem in assignedClasses"
                    :key="`assigned-${classItem.classId}`"
                    class="exam-chip exam-chip--selected"
                    type="button"
                    draggable="true"
                    @dragstart="handleDragStart(classItem, 'assigned')"
                    @dragend="handleDragEnd">
                    <span class="exam-name">{{ classItem.className }}</span>
                    <span class="exam-meta">연결됨</span>
                  </button>
                  <div v-if="assignedClasses.length === 0" class="exam-empty">
                    아직 연결된 클래스가 없습니다.
                  </div>
                </div>
              </section>

              <div class="exam-transfer-hint" aria-hidden="true">
                <IconTransferArrows class="transfer-arrows" />
              </div>

              <section
                class="exam-list-panel"
                @dragover.prevent
                @drop.prevent="handleDrop('available')">
                <div class="exam-list-header">
                  <strong>연결 가능한 다른 클래스</strong>
                  <span>{{ availableClasses.length }}개</span>
                </div>
                <div class="exam-list">
                  <button
                    v-for="classItem in availableClasses"
                    :key="`available-${classItem.classId}`"
                    class="exam-chip"
                    type="button"
                    draggable="true"
                    @dragstart="handleDragStart(classItem, 'available')"
                    @dragend="handleDragEnd">
                    <span class="exam-name">{{ classItem.className }}</span>
                    <span class="exam-meta">연결 가능</span>
                  </button>
                  <div v-if="availableClasses.length === 0" class="exam-empty">
                    연결 가능한 클래스가 없습니다.
                  </div>
                </div>
              </section>
            </div>

            <div class="exam-modal-actions">
              <button class="btn-secondary" type="button" @click="emit('close')">
                닫기
              </button>
              <button
                class="btn-primary"
                type="button"
                :disabled="saving || !hasChanges"
                @click="saveClasses">
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
  z-index: 10010;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  background: rgba(2, 6, 23, 0.72);
  backdrop-filter: blur(10px);
}

.exam-modal-card {
  width: min(960px, 100%);
  border-radius: 10px;
  border: 1px solid rgba(148, 163, 184, 0.18);
  background: linear-gradient(
    180deg,
    rgba(30, 41, 59, 0.96),
    rgba(15, 23, 42, 0.96)
  );
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
  grid-template-columns: minmax(0, 1fr) 38px minmax(0, 1fr);
  gap: 1rem;
  align-items: stretch;
}

.exam-list-panel {
  border-radius: 10px;
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
  border-radius: 10px;
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

.exam-chip--selected {
  border-color: rgba(99, 102, 241, 0.4);
  background: rgba(99, 102, 241, 0.16);
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
  border-radius: 10px;
  border: 1px dashed rgba(99, 102, 241, 0.3);
  background: rgba(15, 23, 42, 0.42);
  min-height: 420px;
  padding: 0.2rem 0.1rem;
}

.transfer-arrows {
  width: 24px;
  height: 24px;
}

:deep(.transfer-arrows path) {
  stroke: #a5b4fc;
  stroke-width: 1.7;
  stroke-linecap: round;
  stroke-linejoin: round;
}

:deep(.transfer-arrows .transfer-arrows-center) {
  stroke: rgba(165, 180, 252, 0.6);
  stroke-dasharray: 2 3;
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
  border-radius: 10px;
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
    display: none;
  }
}
</style>
