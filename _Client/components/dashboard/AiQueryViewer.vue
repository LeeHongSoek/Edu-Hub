  <!--
파일 개요: AI 질의 뷰어입니다.    
- 역할: AI server.py와 통신하여 AI 질의를 처리합니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
- 사용법:  #  uvicorn server:app --reload --port 3500

up_OdsaftbcovAx2UQgJWls5dtp79ISS
-->
<script setup lang="ts">
import { ref, computed } from "vue";
import IconMessage from "~/assets/icons/IconMessage.svg?component";

const promptText = ref("");
const responseText = ref("");
const isLoading = ref(false);
const apiKey = ref("");

const aiProviders = [
  { id: "openai", name: "OpenAI (ChatGPT)" },
  { id: "anthropic", name: "Anthropic (Claude)" },
  { id: "google", name: "Google (Gemini)" },
  { id: "deepseek", name: "DeepSeek" },
  { id: "groq", name: "Groq (초고속 추론)" },
  { id: "xai", name: "xAI (Grok)" },
  { id: "together", name: "Together AI (오픈소스)" },
  { id: "upstage", name: "Upstage (Solar)" }
];
const selectedProviderId = ref("openai");

const allModels = {
  openai: [
    { id: "gpt-4o-mini", name: "GPT-4o mini", description: "매우 빠르고 가성비가 좋은 소형 모델" },
    { id: "gpt-4o", name: "GPT-4o", description: "현존 최상위 성능의 다재다능 모델" },
    { id: "o1-mini", name: "o1 Mini", description: "강력한 추론 능력을 갖춘 최신 모델" }
  ],
  anthropic: [
    { id: "claude-3-5-sonnet-latest", name: "Claude 3.5 Sonnet", description: "가장 코딩과 추론 능력이 뛰어난 모델" },
    { id: "claude-3-opus-latest", name: "Claude 3 Opus", description: "매우 복잡한 문제를 해결하는 거대 모델" },
    { id: "claude-3-5-haiku-latest", name: "Claude 3.5 Haiku", description: "빠르고 가벼운 모델" }
  ],
  google: [
    { id: "gemini-2.0-flash", name: "Gemini 2.0 Flash", description: "응답 속도가 매우 빠르고 가벼운 모델" },
    { id: "gemini-2.5-pro", name: "Gemini 2.5 Pro", description: "구글의 최고 성능 모델" }
  ],
  deepseek: [
    { id: "deepseek-chat", name: "DeepSeek Chat (V3)", description: "오픈소스 최고 수준의 가성비와 코딩 성능" },
    { id: "deepseek-reasoner", name: "DeepSeek Reasoner (R1)", description: "수학과 논리에 강력한 추론 특화 모델" }
  ],
  groq: [
    { id: "llama-3.3-70b-versatile", name: "Llama 3.3 70B", description: "초고속 LPU로 구동되는 Llama 3.3" },
    { id: "mixtral-8x7b-32768", name: "Mixtral 8x7B", description: "속도와 성능의 밸런스가 좋은 혼합 모델" },
    { id: "gemma2-9b-it", name: "Gemma 2 9B", description: "구글의 경량형 오픈 모델" }
  ],
  xai: [
    { id: "grok-2-latest", name: "Grok 2", description: "xAI의 고성능 최신 AI 모델" },
    { id: "grok-beta", name: "Grok Beta", description: "실험적인 기능이 적용된 베타 모델" }
  ],
  together: [
    { id: "meta-llama/Llama-3.3-70B-Instruct-Turbo", name: "Llama 3.3 70B", description: "초거대 오픈소스 최고 성능 모델" },
    { id: "Qwen/Qwen2.5-72B-Instruct", name: "Qwen 2.5 72B", description: "매우 뛰어난 한국어 및 종합 성능" }
  ],
  upstage: [
    { id: "solar-1-mini-chat", name: "Solar 1 Mini", description: "빠르고 가성비가 좋은 한국어 특화 모델" },
    { id: "solar-pro", name: "Solar Pro", description: "고도화된 추론을 위한 Upstage의 상위 모델" }
  ]
};

const currentModels = computed(() => {
  return allModels[selectedProviderId.value as keyof typeof allModels] || [];
});

const selectedModelId = ref("grok-2-latest");

const handleProviderChange = () => {
  if (currentModels.value.length > 0) {
    selectedModelId.value = currentModels.value[0].id;
  }
};

const currentModelInfo = computed(() => {
  return currentModels.value.find(m => m.id === selectedModelId.value) || currentModels.value[0];
});

const submitQuery = async () => {
  if (!promptText.value.trim()) return;
  if (!apiKey.value.trim()) {
      alert("API 키를 입력해주세요!");
      return;
  }

  isLoading.value = true;
  responseText.value = "";

  try {
    const res = await $fetch<any>("http://localhost:3500/py/ask", {
      method: "POST",
      body: { 
        prompt: promptText.value.trim(),
        model: selectedModelId.value,
        provider: selectedProviderId.value,
        api_key: apiKey.value.trim()
      },
    });
    
    if (res.error) {
      responseText.value = `[처리 오류]\n\n- 발생 원인: ${res.error}\n- 해결 방법: 입력값 및 설정을 확인하고 다시 시도해 주세요.`;
    } else {
      responseText.value = res.answer || "응답이 없습니다.";
    }
  } catch (error: any) {
    console.error("AI 질의 실패:", error);

    const statusCode = error.response?.status;
    const serverMessage = error.response?._data?.detail || error.response?._data?.error || error.message;

    let errorTitle = "[알 수 없는 오류]";
    let errorResolution = "잠시 후 다시 시도하거나 관리자에게 문의해 주세요.";

    if (!error.response) {
      errorTitle = "[네트워크 연결 오류]";
      errorResolution = "AI 백엔드 서버(localhost:3500)가 정상적으로 실행 중인지 확인해 주세요.";
    } else if (statusCode === 401 || statusCode === 403) {
      errorTitle = "[권한/인증 오류]";
      errorResolution = "API 키가 올바른지 확인하거나 사용할 수 있는 권한이 있는지 점검해 주세요.";
    } else if (statusCode === 404) {
      errorTitle = "[API 경로 오류]";
      errorResolution = "해당하는 AI 제공자의 API 엔드포인트 주소를 찾을 수 없습니다.";
    } else if (statusCode === 422) {
      errorTitle = "[입력 형식 오류]";
      errorResolution = "서버로 전송된 데이터 양식이 올바르지 않습니다.";
    } else if (statusCode === 429) {
      errorTitle = "[요청 한도 초과]";
      errorResolution = "사용량(Quota)을 초과했거나 단기 요청이 너무 많습니다. 잠시 후 시도하거나 API 계정 상태를 확인하세요.";
    } else if (statusCode >= 500) {
      errorTitle = "[서버 내부 오류]";
      errorResolution = "AI 서비스 제공자의 서버 상태가 불안정하거나 모델이 응답할 수 없습니다.";
    }

    let formattedErrorMessage = `${errorTitle}\n\n- 발생 원인: ${serverMessage || '알 수 없음'}\n- 해결 방법: ${errorResolution}`;
    
    if (statusCode) {
      formattedErrorMessage += `\n\n(참고 코드: HTTP ${statusCode})`;
    }

    responseText.value = formattedErrorMessage;
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <section class="ai-query-panel">
    <div class="panel-header">
      <h3><IconMessage class="header-icon" /> AI 어시스턴트</h3>
      <div class="panel-header-controls">
        <div class="controls-left">
          <div class="model-selector-wrap">
            <span class="description">제공자:</span>
            <select id="ai-provider-select" v-model="selectedProviderId" @change="handleProviderChange" class="model-select">
              <option v-for="provider in aiProviders" :key="provider.id" :value="provider.id">
                {{ provider.name }}
              </option>
            </select>

            <span class="description ml-2">모델:</span>
            <select id="ai-model-select" v-model="selectedModelId" class="model-select">
              <option v-for="model in currentModels" :key="model.id" :value="model.id">
                {{ model.name }}
              </option>
            </select>
            
            <span class="description ml-2">API Key:</span>
            <input type="password" v-model="apiKey" placeholder="API 키 입력" class="api-key-input" />
          </div>
          <p class="model-features">
            <span class="badge">특징</span> {{ currentModelInfo.description }}
          </p>
        </div>
        <div class="actions">
          <button class="btn-ask" :disabled="isLoading || !promptText.trim()" @click="submitQuery">
            {{ isLoading ? "생성 중..." : "질문 보내기" }}
          </button>
        </div>
      </div>
    </div>

    <div class="ai-query-input-area">
      <textarea
        v-model="promptText"
        placeholder="질문을 입력하세요... (Ctrl+Enter로 전송)"
        @keydown.ctrl.enter="submitQuery"
      ></textarea>
      
    </div>
    
    <div v-if="responseText || isLoading" class="ai-query-response-area">
      <h4>답변:</h4>
      <div v-if="isLoading" class="loading-state">
        <div class="spinner"></div> AI가 답변을 작성하고 있습니다...
      </div>
      <div v-else class="response-content">
        {{ responseText }}
      </div>
    </div>
  </section>
</template>

<style scoped>
.ai-query-panel {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1.25rem;
  background: rgba(15, 23, 42, 0.6);
  border: 1px solid rgba(148, 163, 184, 0.3);
  border-radius: 10px;
  box-shadow: none;
}

.panel-header {
  border-bottom: 1px solid rgba(148, 163, 184, 0.3);
  padding-bottom: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.panel-header h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0 0 4px 0;
  font-size: 1.25rem;
  color: #f8fafc;
}

.panel-header-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.controls-left {
  display: flex;
  flex-direction: column;
}

.header-icon {
  width: 24px;
  height: 24px;
  color: #94a3b8;
}

.model-selector-wrap {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
}

.description {
  margin: 0;
  color: #cbd5e1;
  font-size: 0.95rem;
}

.model-select {
  background: rgba(15, 23, 42, 0.9);
  color: #e2e8f0;
  border: 1px solid rgba(148, 163, 184, 0.5);
  border-radius: 4px;
  padding: 4px 8px;
  font-size: 0.9rem;
  appearance: none;
  cursor: pointer;
  outline: none;
  transition: border-color 0.2s;
  background-image: url("data:image/svg+xml;charset=UTF-8,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%23cbd5e1' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 8px center;
  background-size: 14px;
  padding-right: 28px;
}

.model-select:focus {
  border-color: #3b82f6;
}

.model-select option {
  background: #0f172a;
  color: #e2e8f0;
}

.model-features {
  margin: 4px 0 0 0;
  color: #94a3b8;
  font-size: 0.85rem;
  line-height: 1.4;
  display: flex;
  align-items: flex-start;
  gap: 6px;
}

.badge {
  background: rgba(59, 130, 246, 0.2);
  color: #60a5fa;
  border: 1px solid rgba(59, 130, 246, 0.3);
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
}

.ai-query-input-area {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

textarea {
  width: 100%;
  box-sizing: border-box;
  min-height: 120px;
  padding: 1rem;
  background: rgba(15, 23, 42, 0.9);
  color: #e2e8f0;
  border: 1px solid rgba(148, 163, 184, 0.5);
  border-radius: 6px;
  resize: vertical;
  font-family: inherit;
  font-size: 0.95rem;
  line-height: 1.6;
  transition: border-color 0.2s;
}

textarea:focus {
  outline: none;
  border-color: #3b82f6;
}

.actions {
  display: flex;
  justify-content: flex-end;
}

.btn-ask {
  padding: 10px 24px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.95rem;
  transition: background-color 0.2s, opacity 0.2s;
}

.btn-ask:hover:not(:disabled) {
  background: #2563eb;
}

.btn-ask:disabled {
  background: rgba(148, 163, 184, 0.5);
  color: rgba(255, 255, 255, 0.5);
  cursor: not-allowed;
  opacity: 0.7;
}

.ai-query-response-area {
  padding-top: 1rem;
  border-top: 1px solid rgba(148, 163, 184, 0.3);
}

.ai-query-response-area h4 {
  margin: 0 0 12px 0;
  color: #f8fafc;
}

.response-content {
  background: rgba(15, 23, 42, 0.9);
  color: #e2e8f0;
  padding: 1.25rem;
  border-radius: 6px;
  white-space: pre-wrap;
  line-height: 1.6;
  border: 1px solid rgba(148, 163, 184, 0.3);
}

.loading-state {
  display: flex;
  align-items: center;
  gap: 12px;
  color: #cbd5e1;
  padding: 1.25rem;
  background: rgba(15, 23, 42, 0.9);
  border-radius: 6px;
  border: 1px solid rgba(148, 163, 184, 0.3);
}

.spinner {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(148, 163, 184, 0.3);
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.api-key-input {
  background: rgba(15, 23, 42, 0.9);
  color: #e2e8f0;
  border: 1px solid rgba(148, 163, 184, 0.5);
  border-radius: 4px;
  padding: 4px 8px;
  font-size: 0.9rem;
  outline: none;
  transition: border-color 0.2s;
  width: 180px;
}
.api-key-input:focus {
  border-color: #3b82f6;
}
.ml-2 { margin-left: 12px; }
</style>
