<script setup lang="ts">
import { computed } from "vue";

const props = withDefaults(
  defineProps<{
    modelValue: number;
    min?: number;
    max: number;
    disabled?: boolean;
    postfix?: string;
  }>(),
  {
    min: 1,
    disabled: false,
    postfix: "",
  },
);

const emit = defineEmits<{
  (event: "update:modelValue", value: number): void;
  (event: "commit", value: number): void;
}>();

const safeMax = computed(() => Math.max(props.max, props.min));
const percentage = computed(() => {
  if (safeMax.value <= props.min) return 0;
  return ((props.modelValue - props.min) / (safeMax.value - props.min)) * 100;
});

const handleInput = (event: Event) => {
  emit("update:modelValue", Number((event.target as HTMLInputElement).value));
};

const handleChange = (event: Event) => {
  const value = Number((event.target as HTMLInputElement).value);
  emit("update:modelValue", value);
  emit("commit", value);
};
</script>

<template>
  <div class="page-slider-control" :class="{ disabled }">
    <span class="slider-limit">{{ min }}</span>
    <div class="slider-track-container">
      <input
        type="range"
        :min="min"
        :max="safeMax"
        :value="modelValue"
        class="page-slider"
        :disabled="disabled"
        @input="handleInput"
        @change="handleChange"
      />
      <div class="slider-fill" :style="{ width: percentage + '%' }"></div>
      <div
        v-if="!disabled"
        class="slider-tooltip"
        :style="{ left: percentage + '%' }"
      >
        {{ modelValue }}{{ postfix }}
      </div>
    </div>
    <span class="slider-limit">{{ safeMax }}</span>
  </div>
</template>

<style scoped>
.page-slider-control {
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
  background: #6366f1;
  border-radius: 50%;
  cursor: pointer;
  box-shadow: 0 0 15px rgba(99, 102, 241, 0.4);
  border: 2px solid #fff;
}

.slider-fill {
  position: absolute;
  height: 6px;
  background: linear-gradient(90deg, #6366f1, #a855f7);
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
  background: #6366f1;
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
  border-bottom: 4px solid #6366f1;
}
</style>
