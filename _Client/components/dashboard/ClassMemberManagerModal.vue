<script setup lang="ts">
import { computed, ref, watch } from "vue";
import IconClose from "~/assets/icons/IconClose.svg?component";

type ClassCard = {
  classId: string;
  className: string;
  studentCount: number;
};

type StudentItem = {
  userNo: string;
  username: string;
  userId: string;
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
const assignedStudents = ref<StudentItem[]>([]);
const availableStudents = ref<StudentItem[]>([]);
const initialAssignedKeys = ref<string[]>([]);
const draggedStudent = ref<{ student: StudentItem; source: "assigned" | "available" } | null>(null);

const classTitle = computed(() => props.classItem?.className || "클래스");
const hasChanges = computed(() => {
  const current = assignedStudents.value.map((student) => student.userNo).sort();
  const initial = [...initialAssignedKeys.value].sort();
  if (current.length !== initial.length) return true;
  return current.some((key, index) => key !== initial[index]);
});

const sortStudents = (items: StudentItem[]) =>
  [...items].sort((a, b) => {
    const byName = a.username.localeCompare(b.username, "ko");
    if (byName !== 0) return byName;
    return a.userId.localeCompare(b.userId, "ko");
  });

const loadClassMembers = async () => {
  if (!props.classItem) return;
  loading.value = true;
  errorMessage.value = "";

  try {
    const data = await $fetch<{
      classId: string;
      className: string;
      assignedStudents: StudentItem[];
      availableStudents: StudentItem[];
    }>(`${apiBase.value}/dashboard/classes/${props.classItem.classId}/members`, {
      headers: getAuthHeader(),
    });

    assignedStudents.value = sortStudents(data.assignedStudents || []);
    availableStudents.value = sortStudents(data.availableStudents || []);
    initialAssignedKeys.value = assignedStudents.value.map((student) => student.userNo);
  } catch (error) {
    console.error("클래스 구성원 조회 실패:", error);
    errorMessage.value = "클래스 구성원 정보를 불러오지 못했습니다.";
  } finally {
    loading.value = false;
  }
};

watch(
  () => [props.open, props.classItem?.classId],
  ([open]) => {
    if (!open) return;
    void loadClassMembers();
  },
  { immediate: true },
);

const removeFromSource = (studentNo: string, source: "assigned" | "available") => {
  if (source === "assigned") {
    assignedStudents.value = assignedStudents.value.filter((student) => student.userNo !== studentNo);
    return;
  }
  availableStudents.value = availableStudents.value.filter((student) => student.userNo !== studentNo);
};

const addToTarget = (student: StudentItem, target: "assigned" | "available") => {
  if (target === "assigned") {
    assignedStudents.value = sortStudents([...assignedStudents.value, student]);
    return;
  }
  availableStudents.value = sortStudents([...availableStudents.value, student]);
};

const moveStudent = (student: StudentItem, source: "assigned" | "available", target: "assigned" | "available") => {
  if (source === target) return;
  removeFromSource(student.userNo, source);
  addToTarget(student, target);
};

const handleDragStart = (student: StudentItem, source: "assigned" | "available") => {
  draggedStudent.value = { student, source };
};

const handleDrop = (target: "assigned" | "available") => {
  if (!draggedStudent.value) return;
  moveStudent(draggedStudent.value.student, draggedStudent.value.source, target);
  draggedStudent.value = null;
};

const handleDragEnd = () => {
  draggedStudent.value = null;
};

const saveMembers = async () => {
  if (!props.classItem) return;
  saving.value = true;
  errorMessage.value = "";

  try {
    await $fetch(`${apiBase.value}/dashboard/classes/${props.classItem.classId}/members`, {
      method: "PUT",
      headers: getAuthHeader(),
      body: {
        studentNos: assignedStudents.value.map((student) => student.userNo),
      },
    });
    emit("saved");
    emit("close");
  } catch (error) {
    console.error("클래스 구성원 저장 실패:", error);
    errorMessage.value = "클래스 구성원 저장에 실패했습니다.";
  } finally {
    saving.value = false;
  }
};
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div v-if="open" class="member-modal-overlay" @click.self="emit('close')">
        <div class="member-modal-card">
          <div class="member-modal-header">
            <div>
              <h2>{{ classTitle }} 구성원 관리</h2>
              <p>드래그해서 학생을 클래스 안팎으로 이동할 수 있습니다.</p>
            </div>
            <button class="btn-close" @click="emit('close')">
              <IconClose class="close-icon" />
            </button>
          </div>

          <div v-if="loading" class="member-modal-state">학생 목록을 불러오는 중...</div>
          <div v-else class="member-modal-body">
            <div v-if="errorMessage" class="member-modal-error">{{ errorMessage }}</div>

            <div class="member-lists">
              <section
                class="member-list-panel"
                @dragover.prevent
                @drop.prevent="handleDrop('assigned')"
              >
                <div class="member-list-header">
                  <strong>클래스 소속 학생</strong>
                  <span>{{ assignedStudents.length }}명</span>
                </div>
                <div class="member-list">
                  <button
                    v-for="student in assignedStudents"
                    :key="`assigned-${student.userNo}`"
                    class="member-chip"
                    draggable="true"
                    @dragstart="handleDragStart(student, 'assigned')"
                    @dragend="handleDragEnd"
                  >
                    <span class="member-name">{{ student.username }}</span>
                    <span class="member-id">{{ student.userId }}</span>
                  </button>
                  <div v-if="assignedStudents.length === 0" class="member-empty">
                    아직 배정된 학생이 없습니다.
                  </div>
                </div>
              </section>

              <div class="member-transfer-hint">드래그하여 이동</div>

              <section
                class="member-list-panel"
                @dragover.prevent
                @drop.prevent="handleDrop('available')"
              >
                <div class="member-list-header">
                  <strong>담당 학생 중 미배정</strong>
                  <span>{{ availableStudents.length }}명</span>
                </div>
                <div class="member-list">
                  <button
                    v-for="student in availableStudents"
                    :key="`available-${student.userNo}`"
                    class="member-chip"
                    draggable="true"
                    @dragstart="handleDragStart(student, 'available')"
                    @dragend="handleDragEnd"
                  >
                    <span class="member-name">{{ student.username }}</span>
                    <span class="member-id">{{ student.userId }}</span>
                  </button>
                  <div v-if="availableStudents.length === 0" class="member-empty">
                    이동 가능한 담당 학생이 없습니다.
                  </div>
                </div>
              </section>
            </div>

            <div class="member-modal-actions">
              <button class="btn-secondary" @click="emit('close')">닫기</button>
              <button class="btn-primary" :disabled="saving || !hasChanges" @click="saveMembers">
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
.member-modal-overlay {
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

.member-modal-card {
  width: min(960px, 100%);
  border-radius: 20px;
  border: 1px solid rgba(148, 163, 184, 0.18);
  background:
    linear-gradient(180deg, rgba(30, 41, 59, 0.96), rgba(15, 23, 42, 0.96));
  box-shadow: 0 28px 70px rgba(2, 6, 23, 0.45);
  overflow: hidden;
}

.member-modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  padding: 1.25rem 1.4rem 1rem;
  border-bottom: 1px solid rgba(148, 163, 184, 0.12);
}

.member-modal-header h2 {
  margin: 0 0 0.3rem;
  color: #f8fafc;
  font-size: 1.2rem;
  font-weight: 800;
}

.member-modal-header p {
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

.member-modal-state,
.member-modal-error {
  padding: 1.2rem 1.4rem;
  color: #cbd5e1;
}

.member-modal-error {
  color: #fda4af;
  padding-bottom: 0;
}

.member-modal-body {
  padding: 1rem 1.4rem 1.4rem;
}

.member-lists {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 90px minmax(0, 1fr);
  gap: 1rem;
  align-items: stretch;
}

.member-list-panel {
  border-radius: 16px;
  border: 1px solid rgba(99, 102, 241, 0.2);
  background: rgba(15, 23, 42, 0.6);
  min-height: 420px;
  display: flex;
  flex-direction: column;
}

.member-list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1rem 0.85rem;
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
  color: #cbd5f5;
}

.member-list-header strong {
  font-size: 0.98rem;
  font-weight: 800;
}

.member-list-header span {
  color: #a5b4fc;
  font-size: 0.82rem;
  font-weight: 700;
}

.member-list {
  flex: 1;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.7rem;
}

.member-chip {
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

.member-chip:active {
  cursor: grabbing;
}

.member-name {
  font-size: 0.95rem;
  font-weight: 700;
}

.member-id {
  font-size: 0.78rem;
  color: #94a3b8;
}

.member-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: #64748b;
  font-size: 0.88rem;
  min-height: 160px;
}

.member-transfer-hint {
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

.member-modal-actions {
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
  .member-lists {
    grid-template-columns: 1fr;
  }

  .member-transfer-hint {
    min-height: 64px;
  }

  .member-list-panel {
    min-height: 280px;
  }
}
</style>
