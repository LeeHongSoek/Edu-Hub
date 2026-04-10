<!--
파일 개요:
- 역할: 고사 생성 및 수정 입력을 처리하는 업서트 모달입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { computed, ref, watch } from "vue";
import DateTimePicker from "~/components/DateTimePicker.vue";
import IconTransferArrows from "~/assets/icons/IconTransferArrows.svg?component";

type ExamForm = {
  exam_name: string;
  description: string;
  start_time: string;
  end_time: string;
  location: string;
  is_auto_score: boolean;
};

type ClassItem = {
  classId: string;
  className: string;
};

const props = withDefaults(
  defineProps<{
    show: boolean;
    title: string;
    submitLabel: string;
    loading?: boolean;
    errorMessage?: string;
    initialForm: ExamForm;
    initialAssignedClasses?: ClassItem[];
    initialAvailableClasses?: ClassItem[];
    selectedCount?: number | null;
  }>(),
  {
    loading: false,
    errorMessage: "",
    initialAssignedClasses: () => [],
    initialAvailableClasses: () => [],
    selectedCount: null,
  },
);

const emit = defineEmits<{
  close: [];
  submit: [{ form: ExamForm; classIds: string[] }];
}>();

const localForm = ref<ExamForm>({
  exam_name: "",
  description: "",
  start_time: "",
  end_time: "",
  location: "",
  is_auto_score: true,
});
const assignedClasses = ref<ClassItem[]>([]);
const availableClasses = ref<ClassItem[]>([]);
const draggedClass = ref<{
  classItem: ClassItem;
  source: "assigned" | "available";
} | null>(null);

const assignedClassCount = computed(() => assignedClasses.value.length);

const sortClasses = (items: ClassItem[]) =>
  [...items].sort((a, b) => a.className.localeCompare(b.className, "ko"));

const resetFromProps = () => {
  localForm.value = {
    exam_name: props.initialForm.exam_name || "",
    description: props.initialForm.description || "",
    start_time: props.initialForm.start_time || "",
    end_time: props.initialForm.end_time || "",
    location: props.initialForm.location || "",
    is_auto_score: props.initialForm.is_auto_score ?? true,
  };
  assignedClasses.value = sortClasses(
    (props.initialAssignedClasses || []).map((item) => ({ ...item })),
  );
  availableClasses.value = sortClasses(
    (props.initialAvailableClasses || []).map((item) => ({ ...item })),
  );
  draggedClass.value = null;
};

watch(
  () => props.show,
  (show) => {
    if (show) resetFromProps();
  },
  { immediate: true },
);

const moveClass = (
  classItem: ClassItem,
  source: "assigned" | "available",
  target: "assigned" | "available",
) => {
  if (source === target) return;

  if (source === "assigned") {
    assignedClasses.value = assignedClasses.value.filter(
      (item) => item.classId !== classItem.classId,
    );
  } else {
    availableClasses.value = availableClasses.value.filter(
      (item) => item.classId !== classItem.classId,
    );
  }

  const next = { ...classItem };
  if (target === "assigned") {
    assignedClasses.value = sortClasses([...assignedClasses.value, next]);
  } else {
    availableClasses.value = sortClasses([...availableClasses.value, next]);
  }
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

const submit = () => {
  emit("submit", {
    form: { ...localForm.value },
    classIds: assignedClasses.value.map((item) => item.classId),
  });
};
</script>

<template>
  <Teleport to="body">
    <Transition name="modal-fade">
      <div
        v-if="show"
        class="modal-backdrop"
        @click.self="emit('close')">
        <div
          class="modal-box"
          role="dialog"
          aria-modal="true"
          aria-labelledby="modal-title">
          <div class="modal-header">
            <h2 id="modal-title" class="modal-title">{{ title }}</h2>
            <div class="modal-actions">
              <button
                type="button"
                class="btn-cancel"
                @click="emit('close')"
                :disabled="loading">
                취소
              </button>
              <button
                type="submit"
                class="btn-submit"
                :disabled="loading"
                @click="submit">
                <span v-if="loading" class="loading-spinner"></span>
                {{ submitLabel }}
              </button>
            </div>
          </div>

          <form class="modal-form" @submit.prevent="submit">
            <div class="form-group">
              <label for="exam-class-manager" class="form-label">
                클래스 연결
                <span class="optional">(선택)</span>
              </label>
              <div class="exam-lists">
                <section class="exam-list-panel">
                  <div class="exam-list-header">
                    <strong>이 고사에 연결된 나의 클래스</strong>
                    <span>{{ assignedClassCount }}개</span>
                  </div>
                  <div
                    class="exam-pick-list"
                    @dragover.prevent
                    @drop.prevent="handleDrop('assigned')">
                    <button
                      v-for="classItem in assignedClasses"
                      :key="`assigned-${classItem.classId}`"
                      class="exam-chip exam-chip--selected"
                      type="button"
                      draggable="true"
                      @dragstart="handleDragStart(classItem, 'assigned')"
                      @dragend="handleDragEnd">
                      <span class="exam-name">{{ classItem.className }}</span>
                    </button>
                    <div v-if="assignedClasses.length === 0" class="exam-empty">
                      아직 연결된 클래스가 없습니다.
                    </div>
                  </div>
                </section>

                <div class="exam-transfer-hint" aria-hidden="true">
                  <IconTransferArrows class="transfer-arrows" />
                </div>

                <section class="exam-list-panel">
                  <div class="exam-list-header">
                    <strong>연결 가능한 다른 나의 클래스</strong>
                    <span>{{ availableClasses.length }}개</span>
                  </div>
                  <div
                    class="exam-pick-list"
                    @dragover.prevent
                    @drop.prevent="handleDrop('available')">
                    <button
                      v-for="classItem in availableClasses"
                      :key="`available-${classItem.classId}`"
                      class="exam-chip"
                      type="button"
                      draggable="true"
                      @dragstart="handleDragStart(classItem, 'available')"
                      @dragend="handleDragEnd">
                      <span class="exam-name">{{ classItem.className }}</span>
                    </button>
                    <div v-if="availableClasses.length === 0" class="exam-empty">
                      연결 가능한 클래스가 없습니다.
                    </div>
                  </div>
                </section>
              </div>
              <p class="form-help form-help-inline">
                한 고사에는 여러 클래스를 연결하거나 해제할 수 있습니다.
              </p>
            </div>

            <div class="form-group">
              <label for="exam-name" class="form-label">
                고사 이름 <span class="required">*</span>
              </label>
              <input
                id="exam-name"
                :value="localForm.exam_name"
                type="text"
                class="form-input"
                placeholder="예) 2024년 1학기 중간고사"
                maxlength="255"
                autocomplete="off"
                @input="
                  localForm.exam_name = ($event.target as HTMLInputElement).value
                "
              />
            </div>

            <div class="form-row form-row-datetime">
              <div class="form-group">
                <label for="exam-start" class="form-label">
                  시작 일시 <span class="required">*</span>
                </label>
                <DateTimePicker
                  id="exam-start"
                  :model-value="localForm.start_time"
                  :size="1"
                  @update:model-value="localForm.start_time = $event"
                />
              </div>
              <div class="form-group">
                <label for="exam-end" class="form-label">
                  종료 일시 <span class="required">*</span>
                </label>
                <DateTimePicker
                  id="exam-end"
                  :model-value="localForm.end_time"
                  align="right"
                  :size="1"
                  @update:model-value="localForm.end_time = $event"
                />
              </div>
            </div>
            <p class="form-help">
              날짜를 더블클릭하면 바로 확정되고, 하단 완료 버튼으로도 저장할 수
              있습니다.
            </p>

            <div class="form-group">
              <label for="exam-location" class="form-label">
                장소 <span class="optional">(선택)</span>
              </label>
              <input
                id="exam-location"
                :value="localForm.location"
                type="text"
                class="form-input"
                placeholder="예) 1학년 1반 교실"
                maxlength="100"
                autocomplete="off"
                @input="
                  localForm.location = ($event.target as HTMLInputElement).value
                "
              />
            </div>

            <div class="form-group form-group-check">
              <label class="form-check-label" for="exam-auto-score">
                <input
                  id="exam-auto-score"
                  :checked="localForm.is_auto_score"
                  type="checkbox"
                  class="form-checkbox"
                  @change="
                    localForm.is_auto_score = (
                      $event.target as HTMLInputElement
                    ).checked
                  "
                />
                <span class="check-text">자동 채점 활성화</span>
              </label>
            </div>

            <div class="form-group">
              <label for="exam-description" class="form-label">
                설명 <span class="optional">(선택)</span>
              </label>
              <textarea
                id="exam-description"
                :value="localForm.description"
                class="form-input form-textarea"
                placeholder="고사집에 대한 설명을 적어주세요."
                maxlength="1000"
                @input="
                  localForm.description = (
                    $event.target as HTMLTextAreaElement
                  ).value
                "
              ></textarea>
            </div>

            <p v-if="selectedCount !== null" class="form-help">
              선택된 문제 {{ selectedCount }}개를 한 번에 저장합니다.
            </p>

            <div v-if="errorMessage" class="form-error">{{ errorMessage }}</div>
          </form>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(2, 6, 23, 0.75);
  backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 1rem;
}

.modal-box {
  background: linear-gradient(
    145deg,
    rgba(15, 23, 42, 0.98),
    rgba(30, 41, 59, 0.98)
  );
  border: 1px solid rgba(99, 102, 241, 0.3);
  border-radius: 10px;
  padding: 2rem;
  width: 100%;
  max-width: 676px;
  box-shadow:
    0 25px 60px rgba(0, 0, 0, 0.6),
    0 0 0 1px rgba(255, 255, 255, 0.04) inset;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.2rem;
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 800;
  color: #f1f5f9;
  margin: 0;
}

.modal-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.form-row-datetime {
  gap: 0.75rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.45rem;
  min-width: 0;
}

.form-group-check {
  flex-direction: row;
  align-items: center;
}

.form-label {
  font-size: 0.88rem;
  font-weight: 600;
  color: #94a3b8;
}

.form-help-inline {
  margin-top: -0.15rem;
}

.required {
  color: #f87171;
}

.optional {
  color: #64748b;
  font-weight: 400;
  font-size: 0.82rem;
}

.form-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  color: #f1f5f9;
  padding: 0.6rem 0.85rem;
  font-size: 0.92rem;
  outline: none;
  width: 100%;
  box-sizing: border-box;
}

.form-input:focus {
  border-color: rgba(99, 102, 241, 0.6);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.12);
}

.form-textarea {
  min-height: 96px;
  resize: vertical;
}

.form-help {
  margin: -0.35rem 0 0.1rem;
  font-size: 0.76rem;
  color: #94a3b8;
  line-height: 1.45;
}

.exam-lists {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 38px minmax(0, 1fr);
  gap: 0.75rem;
  align-items: stretch;
}

.exam-list-panel {
  border-radius: 10px;
  border: 1px solid rgba(99, 102, 241, 0.18);
  background: rgba(15, 23, 42, 0.5);
  min-height: 230px;
  display: flex;
  flex-direction: column;
}

.exam-list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 0.75rem;
  padding: 0.85rem 0.95rem 0.75rem;
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
  color: #cbd5f5;
}

.exam-list-header strong {
  font-size: 0.92rem;
  font-weight: 800;
}

.exam-list-header span {
  color: #a5b4fc;
  font-size: 0.8rem;
  font-weight: 700;
}

.exam-pick-list {
  flex: 1;
  padding: 0.85rem;
  display: flex;
  flex-direction: column;
  gap: 0.55rem;
}

.exam-chip {
  appearance: none;
  border: 1px solid rgba(148, 163, 184, 0.16);
  background: rgba(30, 41, 59, 0.84);
  color: #f8fafc;
  border-radius: 10px;
  padding: 0.75rem 0.9rem;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 0.12rem;
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
  font-size: 0.92rem;
  font-weight: 700;
}

.exam-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: #64748b;
  font-size: 0.86rem;
  min-height: 120px;
}

.exam-transfer-hint {
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: #a5b4fc;
  font-size: 0.68rem;
  font-weight: 800;
  border-radius: 10px;
  border: 1px dashed rgba(99, 102, 241, 0.28);
  background: rgba(15, 23, 42, 0.36);
  min-height: 230px;
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

.form-check-label {
  display: inline-flex;
  align-items: center;
  gap: 0.6rem;
  cursor: pointer;
}

.form-checkbox {
  width: 1rem;
  height: 1rem;
  accent-color: #6366f1;
  cursor: pointer;
}

.check-text {
  font-size: 0.9rem;
  color: #94a3b8;
  font-weight: 500;
}

.form-error {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: 8px;
  padding: 0.6rem 0.9rem;
  font-size: 0.88rem;
  color: #fca5a5;
  font-weight: 500;
}

.modal-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
}

.btn-cancel {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.12);
  color: #94a3b8;
  padding: 0.6rem 1.4rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
}

.btn-submit {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border: none;
  color: #fff;
  padding: 0.6rem 1.6rem;
  border-radius: 10px;
  font-size: 0.9rem;
  font-weight: 700;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.loading-spinner {
  width: 14px;
  height: 14px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.2s ease;
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

@media (max-width: 600px) {
  .form-row {
    grid-template-columns: 1fr;
  }

  .form-row-datetime {
    gap: 1rem;
  }

  .modal-box {
    padding: 1.5rem 1.25rem;
  }
}
</style>
