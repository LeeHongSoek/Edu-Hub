<script setup lang="ts">
import { computed, ref, watch } from "vue";

const props = withDefaults(
  defineProps<{
    modelValue: number;
    min?: number;
    max: number;
    disabled?: boolean;
    postfix?: string;
    showLimits?: boolean;
  }>(),
  {
    min: 1,
    disabled: false,
    postfix: "",
    showLimits: true,
  },
);

const emit = defineEmits<{
  (event: "update:modelValue", value: number): void;
  (event: "commit", value: number): void;
}>();

const localValue = ref(props.modelValue);
const isDragging = ref(false);
const sliderElement = ref<HTMLInputElement | null>(null);

watch(
  () => props.modelValue,
  (newVal) => {
    if (!isDragging.value) {
      localValue.value = newVal;
    }
  }
);

const safeMax = computed(() => Math.max(props.max, props.min));
const percentage = computed(() => {
  if (safeMax.value <= props.min) return 0;
  return ((localValue.value - props.min) / (safeMax.value - props.min)) * 100;
});

const displayValue = computed(() => Math.round(localValue.value));

const handleInput = (event: Event) => {
  isDragging.value = true;
  localValue.value = Number((event.target as HTMLInputElement).value);
  emit("update:modelValue", Math.round(localValue.value));
};

const handleChange = (event: Event) => {
  isDragging.value = false;
  const finalValue = Math.round(Number((event.target as HTMLInputElement).value));
  localValue.value = finalValue;
  emit("update:modelValue", finalValue);
  emit("commit", finalValue);
};

const handlePointerUp = () => {
  if (isDragging.value) {
    const finalValue = Math.round(localValue.value);
    localValue.value = finalValue;
    emit("update:modelValue", finalValue);
    isDragging.value = false;
  }
};

const handleKeyDown = (event: KeyboardEvent) => {
  if (props.disabled) return;

  if (event.key === "ArrowLeft" || event.key === "ArrowDown") {
    event.preventDefault();
    const nextValue = Math.max(props.min, Math.round(localValue.value) - 1);
    localValue.value = nextValue;
    emit("update:modelValue", nextValue);
    emit("commit", nextValue);
  }

  if (event.key === "ArrowRight" || event.key === "ArrowUp") {
    event.preventDefault();
    const nextValue = Math.min(safeMax.value, Math.round(localValue.value) + 1);
    localValue.value = nextValue;
    emit("update:modelValue", nextValue);
    emit("commit", nextValue);
  }
};

defineExpose({
  focus: () => sliderElement.value?.focus(),
});
</script>

<template>
  <div class="page-slider-control" :class="{ disabled }">
    <span v-if="showLimits" class="slider-limit">{{ min }}</span>
    <div class="slider-track-container">
      <input
        ref="sliderElement"
        type="range"
        :min="min"
        :max="safeMax"
        step="0.01"
        :value="localValue"
        class="page-slider"
        :disabled="disabled"
        @input="handleInput"
        @change="handleChange"
        @pointerup="handlePointerUp"
        @touchend="handlePointerUp"
        @keydown="handleKeyDown"
      />
      <div class="slider-fill" :style="{ width: percentage + '%' }"></div>
      <div
        v-if="!disabled"
        class="slider-tooltip"
        :style="{ left: percentage + '%' }">
        {{ displayValue }}{{ postfix }}
      </div>
    </div>
    <span v-if="showLimits" class="slider-limit">{{ safeMax }}</span>
  </div>
</template>

<style scoped>
.page-slider-control {
  --slider-accent: rgba(92, 96, 222, 0.7);
  display: flex;
  align-items: center;
  gap: 0.85rem;
  width: 100%;
  max-width: none;
}

.page-slider-control.disabled {
  opacity: 0.6;
}

.page-slider-control.disabled .page-slider {
  cursor: not-allowed;
}

.slider-limit {
  font-size: 0.75rem;
  color: #64748b;
  font-weight: 600;
  min-width: 20px;
  text-align: center;
}

.slider-track-container {
  position: relative;
  flex: 1;
  height: 32px;
  display: flex;
  align-items: center;
}

.page-slider {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 3px;
  outline: none;
  cursor: pointer;
  z-index: 2;
  position: relative;
  touch-action: none;
}

.page-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  background: var(--slider-accent);
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 0 12px rgba(99, 102, 241, 0.22);
  border: 2px solid #fff;
}

.slider-fill {
  position: absolute;
  height: 6px;
  background: var(--slider-accent);
  border-radius: 3px;
  top: 50%;
  transform: translateY(-50%);
  pointer-events: none;
  z-index: 1;
}

.slider-tooltip {
  position: absolute;
  top: 32px;
  transform: translateX(-50%);
  background: var(--slider-accent);
  color: white;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 800;
  pointer-events: none;
  white-space: nowrap;
  box-shadow:
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
  z-index: 10;
}

.slider-tooltip::after {
  content: "";
  position: absolute;
  top: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-bottom: 4px solid var(--slider-accent);
}
</style>
