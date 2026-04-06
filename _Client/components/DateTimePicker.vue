<script setup lang="ts">
import { computed, onBeforeUnmount, reactive, ref } from "vue";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";

type CalendarCell = {
  key: string;
  label: number;
  value: string;
  isCurrentMonth: boolean;
  isToday: boolean;
};

const props = withDefaults(
  defineProps<{
    modelValue?: string;
    placeholder?: string;
    align?: "left" | "right";
    size?: 1 | 2 | 3 | 4;
  }>(),
  {
    modelValue: "",
    placeholder: "연도. 월. 일. --:--",
    align: "left",
    size: 2,
  },
);

const emit = defineEmits<{
  "update:modelValue": [value: string];
}>();

const isOpen = ref(false);
const rootRef = ref<HTMLElement | null>(null);
const pickerDraft = reactive({
  year: 0,
  month: 0,
  day: 0,
  hour: 9,
  minute: 0,
});

const hourOptions = Array.from({ length: 24 }, (_, hour) => hour);
const minuteOptions = Array.from({ length: 60 }, (_, minute) => minute);
const dayNames = ["일", "월", "화", "수", "목", "금", "토"];

const pad2 = (value: number) => String(value).padStart(2, "0");

const buildDateTimeLocal = (
  year: number,
  month: number,
  day: number,
  hour: number,
  minute: number,
) => `${year}-${pad2(month)}-${pad2(day)}T${pad2(hour)}:${pad2(minute)}`;

const parseDateTimeLocal = (value?: string) => {
  if (!value) return null;
  const match = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})$/);
  if (!match) return null;
  return {
    year: Number(match[1]),
    month: Number(match[2]),
    day: Number(match[3]),
    hour: Number(match[4]),
    minute: Number(match[5]),
  };
};

const syncPickerDraft = () => {
  const parsed = parseDateTimeLocal(props.modelValue);
  const baseDate = parsed
    ? new Date(
        parsed.year,
        parsed.month - 1,
        parsed.day,
        parsed.hour,
        parsed.minute,
      )
    : new Date();

  pickerDraft.year = baseDate.getFullYear();
  pickerDraft.month = baseDate.getMonth() + 1;
  pickerDraft.day = baseDate.getDate();
  pickerDraft.hour = baseDate.getHours();
  pickerDraft.minute = baseDate.getMinutes();
};

const displayValue = computed(() => {
  const parsed = parseDateTimeLocal(props.modelValue);
  if (!parsed) return props.placeholder;
  return `${parsed.year}. ${pad2(parsed.month)}. ${pad2(parsed.day)}. ${pad2(parsed.hour)}:${pad2(parsed.minute)}`;
});

const normalizedSize = computed(() => {
  if ([1, 2, 3, 4].includes(props.size)) return props.size;
  return 2;
});

const pickerMonthLabel = computed(
  () => `${pickerDraft.year}년 ${pickerDraft.month}월`,
);

const calendarCells = computed<CalendarCell[]>(() => {
  const firstDay = new Date(pickerDraft.year, pickerDraft.month - 1, 1);
  const startWeekday = firstDay.getDay();
  const startDate = new Date(firstDay);
  startDate.setDate(firstDay.getDate() - startWeekday);
  const today = new Date();

  return Array.from({ length: 42 }, (_, index) => {
    const cellDate = new Date(startDate);
    cellDate.setDate(startDate.getDate() + index);
    const year = cellDate.getFullYear();
    const month = cellDate.getMonth() + 1;
    const day = cellDate.getDate();
    return {
      key: `${year}-${month}-${day}`,
      label: day,
      value: `${year}-${pad2(month)}-${pad2(day)}`,
      isCurrentMonth: month === pickerDraft.month,
      isToday:
        year === today.getFullYear() &&
        month === today.getMonth() + 1 &&
        day === today.getDate(),
    };
  });
});

const isSelectedCalendarDay = (cell: CalendarCell) =>
  cell.value ===
  `${pickerDraft.year}-${pad2(pickerDraft.month)}-${pad2(pickerDraft.day)}`;

const openPicker = () => {
  syncPickerDraft();
  isOpen.value = !isOpen.value;
};

const closePicker = () => {
  isOpen.value = false;
};

const applyPicker = () => {
  emit(
    "update:modelValue",
    buildDateTimeLocal(
      pickerDraft.year,
      pickerDraft.month,
      pickerDraft.day,
      pickerDraft.hour,
      pickerDraft.minute,
    ),
  );
  closePicker();
};

const shiftPickerMonth = (offset: number) => {
  const next = new Date(pickerDraft.year, pickerDraft.month - 1 + offset, 1);
  pickerDraft.year = next.getFullYear();
  pickerDraft.month = next.getMonth() + 1;
  const maxDay = new Date(pickerDraft.year, pickerDraft.month, 0).getDate();
  pickerDraft.day = Math.min(pickerDraft.day, maxDay);
};

const selectPickerDay = (value: string, shouldApply = false) => {
  const parsed = parseDateTimeLocal(
    `${value}T${pad2(pickerDraft.hour)}:${pad2(pickerDraft.minute)}`,
  );
  if (!parsed) return;
  pickerDraft.year = parsed.year;
  pickerDraft.month = parsed.month;
  pickerDraft.day = parsed.day;
  if (shouldApply) {
    applyPicker();
  }
};

const handleDocumentClick = (event: MouseEvent) => {
  const target = event.target as Node | null;
  if (!target || !rootRef.value?.contains(target)) {
    closePicker();
  }
};

const handleWindowKeydown = (event: KeyboardEvent) => {
  if (event.key === "Escape") {
    closePicker();
  }
};

if (typeof document !== "undefined") {
  document.addEventListener("click", handleDocumentClick);
}

if (typeof window !== "undefined") {
  window.addEventListener("keydown", handleWindowKeydown);
}

onBeforeUnmount(() => {
  if (typeof document !== "undefined") {
    document.removeEventListener("click", handleDocumentClick);
  }
  if (typeof window !== "undefined") {
    window.removeEventListener("keydown", handleWindowKeydown);
  }
});
</script>

<template>
  <div ref="rootRef" class="datetime-picker" :class="`size-${normalizedSize}`">
    <button
      type="button"
      class="form-input form-input-datetime form-input-datetime-trigger"
      @click.stop="openPicker">
      <span class="datetime-trigger-value">{{ displayValue }}</span>
      <IconCalendar class="datetime-trigger-icon" />
    </button>

    <div
      v-if="isOpen"
      class="datetime-popover"
      :class="{ 'align-right': align === 'right' }"
      @click.stop>
      <div class="datetime-popover-header">
        <button
          type="button"
          class="picker-nav-btn"
          @click="shiftPickerMonth(-1)">
          ‹
        </button>
        <strong>{{ pickerMonthLabel }}</strong>
        <button
          type="button"
          class="picker-nav-btn"
          @click="shiftPickerMonth(1)">
          ›
        </button>
      </div>

      <div class="calendar-grid calendar-weekdays">
        <span v-for="dayName in dayNames" :key="dayName">{{ dayName }}</span>
      </div>

      <div class="calendar-grid">
        <button
          v-for="cell in calendarCells"
          :key="cell.key"
          type="button"
          class="calendar-cell"
          :class="{
            'is-muted': !cell.isCurrentMonth,
            'is-selected': isSelectedCalendarDay(cell),
            'is-today': cell.isToday,
          }"
          @click="selectPickerDay(cell.value)"
          @dblclick="selectPickerDay(cell.value, true)">
          {{ cell.label }}
        </button>
      </div>

      <div class="datetime-time-row">
        <label class="picker-select-wrap">
          <span>시</span>
          <select v-model="pickerDraft.hour" class="picker-select">
            <option v-for="hour in hourOptions" :key="hour" :value="hour">
              {{ pad2(hour) }}
            </option>
          </select>
        </label>

        <label class="picker-select-wrap">
          <span>분</span>
          <select v-model="pickerDraft.minute" class="picker-select">
            <option
              v-for="minute in minuteOptions"
              :key="minute"
              :value="minute">
              {{ pad2(minute) }}
            </option>
          </select>
        </label>
      </div>

      <div class="datetime-popover-actions">
        <button
          type="button"
          class="picker-action-btn picker-action-subtle"
          @click="closePicker">
          취소
        </button>
        <button
          type="button"
          class="picker-action-btn picker-action-confirm"
          @click="applyPicker">
          완료
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.datetime-picker {
  position: relative;
  --picker-trigger-font: 0.84rem;
  --picker-trigger-min-height: 38px;
  --picker-trigger-padding-y: 0.42rem;
  --picker-trigger-padding-x: 0.58rem;
  --picker-trigger-gap: 0.5rem;
  --picker-icon-size: 0.95rem;
  --picker-popover-top: 0.38rem;
  --picker-popover-width: 264px;
  --picker-popover-min-width: 252px;
  --picker-popover-radius: 12px;
  --picker-popover-padding: 0.62rem;
  --picker-header-gap: 0.4rem;
  --picker-header-margin-bottom: 0.48rem;
  --picker-header-font: 0.8rem;
  --picker-nav-size: 24px;
  --picker-nav-radius: 7px;
  --picker-grid-gap: 0.24rem;
  --picker-weekdays-margin: 0.24rem;
  --picker-weekdays-font: 0.63rem;
  --picker-cell-radius: 7px;
  --picker-cell-height: 27px;
  --picker-cell-font: 0.74rem;
  --picker-time-gap: 0.45rem;
  --picker-time-margin-top: 0.58rem;
  --picker-select-label-gap: 0.2rem;
  --picker-select-label-font: 0.66rem;
  --picker-select-radius: 8px;
  --picker-select-padding-y: 0.38rem;
  --picker-select-padding-x: 0.46rem;
  --picker-select-font: 0.76rem;
  --picker-actions-gap: 0.4rem;
  --picker-actions-margin-top: 0.62rem;
  --picker-action-radius: 8px;
  --picker-action-padding-y: 0.38rem;
  --picker-action-padding-x: 0.62rem;
  --picker-action-font: 0.74rem;
}

.datetime-picker.size-1 {
  --picker-trigger-font: 0.78rem;
  --picker-trigger-min-height: 34px;
  --picker-trigger-padding-y: 0.34rem;
  --picker-trigger-padding-x: 0.48rem;
  --picker-trigger-gap: 0.4rem;
  --picker-icon-size: 0.85rem;
  --picker-popover-width: 236px;
  --picker-popover-min-width: 224px;
  --picker-popover-radius: 10px;
  --picker-popover-padding: 0.52rem;
  --picker-header-gap: 0.32rem;
  --picker-header-margin-bottom: 0.38rem;
  --picker-header-font: 0.74rem;
  --picker-nav-size: 22px;
  --picker-nav-radius: 6px;
  --picker-grid-gap: 0.2rem;
  --picker-weekdays-margin: 0.18rem;
  --picker-weekdays-font: 0.58rem;
  --picker-cell-radius: 6px;
  --picker-cell-height: 24px;
  --picker-cell-font: 0.68rem;
  --picker-time-gap: 0.38rem;
  --picker-time-margin-top: 0.48rem;
  --picker-select-label-gap: 0.16rem;
  --picker-select-label-font: 0.6rem;
  --picker-select-radius: 7px;
  --picker-select-padding-y: 0.3rem;
  --picker-select-padding-x: 0.38rem;
  --picker-select-font: 0.7rem;
  --picker-actions-gap: 0.34rem;
  --picker-actions-margin-top: 0.5rem;
  --picker-action-radius: 7px;
  --picker-action-padding-y: 0.32rem;
  --picker-action-padding-x: 0.5rem;
  --picker-action-font: 0.68rem;
}

.datetime-picker.size-3 {
  --picker-trigger-font: 0.9rem;
  --picker-trigger-min-height: 42px;
  --picker-trigger-padding-y: 0.48rem;
  --picker-trigger-padding-x: 0.68rem;
  --picker-trigger-gap: 0.56rem;
  --picker-icon-size: 1rem;
  --picker-popover-width: 292px;
  --picker-popover-min-width: 278px;
  --picker-popover-radius: 13px;
  --picker-popover-padding: 0.74rem;
  --picker-header-gap: 0.46rem;
  --picker-header-margin-bottom: 0.54rem;
  --picker-header-font: 0.86rem;
  --picker-nav-size: 26px;
  --picker-nav-radius: 8px;
  --picker-grid-gap: 0.28rem;
  --picker-weekdays-margin: 0.28rem;
  --picker-weekdays-font: 0.67rem;
  --picker-cell-radius: 8px;
  --picker-cell-height: 30px;
  --picker-cell-font: 0.78rem;
  --picker-time-gap: 0.52rem;
  --picker-time-margin-top: 0.68rem;
  --picker-select-label-gap: 0.24rem;
  --picker-select-label-font: 0.7rem;
  --picker-select-radius: 9px;
  --picker-select-padding-y: 0.42rem;
  --picker-select-padding-x: 0.54rem;
  --picker-select-font: 0.8rem;
  --picker-actions-gap: 0.46rem;
  --picker-actions-margin-top: 0.7rem;
  --picker-action-radius: 8px;
  --picker-action-padding-y: 0.42rem;
  --picker-action-padding-x: 0.7rem;
  --picker-action-font: 0.78rem;
}

.datetime-picker.size-4 {
  --picker-trigger-font: 0.96rem;
  --picker-trigger-min-height: 46px;
  --picker-trigger-padding-y: 0.54rem;
  --picker-trigger-padding-x: 0.76rem;
  --picker-trigger-gap: 0.62rem;
  --picker-icon-size: 1.05rem;
  --picker-popover-width: 320px;
  --picker-popover-min-width: 304px;
  --picker-popover-radius: 14px;
  --picker-popover-padding: 0.86rem;
  --picker-header-gap: 0.5rem;
  --picker-header-margin-bottom: 0.6rem;
  --picker-header-font: 0.92rem;
  --picker-nav-size: 28px;
  --picker-nav-radius: 8px;
  --picker-grid-gap: 0.32rem;
  --picker-weekdays-margin: 0.32rem;
  --picker-weekdays-font: 0.7rem;
  --picker-cell-radius: 8px;
  --picker-cell-height: 33px;
  --picker-cell-font: 0.82rem;
  --picker-time-gap: 0.56rem;
  --picker-time-margin-top: 0.74rem;
  --picker-select-label-gap: 0.26rem;
  --picker-select-label-font: 0.72rem;
  --picker-select-radius: 9px;
  --picker-select-padding-y: 0.46rem;
  --picker-select-padding-x: 0.56rem;
  --picker-select-font: 0.84rem;
  --picker-actions-gap: 0.5rem;
  --picker-actions-margin-top: 0.76rem;
  --picker-action-radius: 9px;
  --picker-action-padding-y: 0.46rem;
  --picker-action-padding-x: 0.76rem;
  --picker-action-font: 0.8rem;
}

.form-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.12);
  border-radius: 10px;
  color: #f1f5f9;
  width: 100%;
  box-sizing: border-box;
}

.form-input-datetime {
  min-width: 0;
  padding: 0;
  font-size: var(--picker-trigger-font);
  letter-spacing: -0.01em;
}

.form-input-datetime-trigger {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--picker-trigger-gap);
  min-height: var(--picker-trigger-min-height);
  padding: var(--picker-trigger-padding-y) var(--picker-trigger-padding-x);
  text-align: left;
  cursor: pointer;
}

.datetime-trigger-value {
  min-width: 0;
  color: #e2e8f0;
  font-variant-numeric: tabular-nums;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.datetime-trigger-icon {
  width: var(--picker-icon-size);
  height: var(--picker-icon-size);
  color: #cbd5f5;
  flex-shrink: 0;
}

.datetime-popover {
  position: absolute;
  top: calc(100% + var(--picker-popover-top));
  left: 0;
  z-index: 30;
  width: min(100%, var(--picker-popover-width));
  min-width: var(--picker-popover-min-width);
  background: rgba(30, 41, 59, 0.98);
  border: 1px solid rgba(148, 163, 184, 0.24);
  border-radius: var(--picker-popover-radius);
  padding: var(--picker-popover-padding);
  box-shadow: 0 20px 40px rgba(2, 6, 23, 0.45);
}

.datetime-popover.align-right {
  left: auto;
  right: 0;
}

.datetime-popover-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--picker-header-gap);
  margin-bottom: var(--picker-header-margin-bottom);
  color: #f8fafc;
  font-size: var(--picker-header-font);
}

.picker-nav-btn {
  width: var(--picker-nav-size);
  height: var(--picker-nav-size);
  border: 1px solid rgba(148, 163, 184, 0.22);
  border-radius: var(--picker-nav-radius);
  background: rgba(255, 255, 255, 0.04);
  color: #e2e8f0;
  cursor: pointer;
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  gap: var(--picker-grid-gap);
}

.calendar-weekdays {
  margin-bottom: var(--picker-weekdays-margin);
}

.calendar-weekdays span {
  font-size: var(--picker-weekdays-font);
  color: #94a3b8;
  text-align: center;
  font-weight: 700;
}

.calendar-cell {
  border: 1px solid rgba(148, 163, 184, 0.12);
  border-radius: var(--picker-cell-radius);
  background: rgba(255, 255, 255, 0.03);
  color: #e2e8f0;
  min-height: var(--picker-cell-height);
  font-size: var(--picker-cell-font);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.16s ease;
}

.calendar-cell:hover {
  border-color: rgba(99, 102, 241, 0.45);
  background: rgba(99, 102, 241, 0.16);
}

.calendar-cell.is-muted {
  color: #64748b;
  background: rgba(15, 23, 42, 0.45);
}

.calendar-cell.is-today {
  border-color: rgba(96, 165, 250, 0.5);
}

.calendar-cell.is-selected {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border-color: transparent;
  color: #fff;
  box-shadow: 0 8px 18px rgba(99, 102, 241, 0.22);
}

.datetime-time-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--picker-time-gap);
  margin-top: var(--picker-time-margin-top);
}

.picker-select-wrap {
  display: flex;
  flex-direction: column;
  gap: var(--picker-select-label-gap);
  color: #94a3b8;
  font-size: var(--picker-select-label-font);
  font-weight: 700;
}

.picker-select {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(148, 163, 184, 0.16);
  color: #f8fafc;
  border-radius: var(--picker-select-radius);
  padding: var(--picker-select-padding-y) var(--picker-select-padding-x);
  font-size: var(--picker-select-font);
  outline: none;
}

.datetime-popover-actions {
  display: flex;
  justify-content: flex-end;
  gap: var(--picker-actions-gap);
  margin-top: var(--picker-actions-margin-top);
}

.picker-action-btn {
  border: none;
  border-radius: var(--picker-action-radius);
  padding: var(--picker-action-padding-y) var(--picker-action-padding-x);
  font-size: var(--picker-action-font);
  font-weight: 700;
  cursor: pointer;
}

.picker-action-subtle {
  background: rgba(255, 255, 255, 0.06);
  color: #cbd5f5;
}

.picker-action-confirm {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  color: #fff;
}

@media (max-width: 600px) {
  .datetime-popover,
  .datetime-popover.align-right {
    left: 0;
    right: auto;
    min-width: 0;
    width: 100%;
  }
}
</style>
