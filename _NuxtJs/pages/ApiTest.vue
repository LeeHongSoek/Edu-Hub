<template>
  <div class="api-test">
    <section class="header-card">
      <div>
        <p class="eyebrow">API Health Check</p>
        <h1>백엔드 /api/demo 연결 상태</h1>
        <p class="lede">
          버튼을 누르면 GET, 쿼리付き GET, POST 요청을 순차적으로 보내고 결과를 하단 카드에 정리합니다.
        </p>
      </div>
      <button
        class="run-btn"
        :disabled="testing"
        @click="testApis"
      >
        <span v-if="testing">🔄 호출 중...</span>
        <span v-else>▶️ 테스트 실행</span>
      </button>
    </section>

    <section class="results-card" v-if="testResults.length">
      <header>
        <h2>응답 로그</h2>
        <p>{{ testResults.length }}건 기록됨</p>
      </header>
      <ul>
        <li v-for="(item, idx) in testResults" :key="idx">
          <div>
            <strong>{{ item.method }} {{ item.url }}</strong>
            <p class="meta">상태 {{ item.status }} · {{ item.dataSize }} bytes · {{ item.duration }}ms</p>
          </div>
          <pre>{{ item.payload }}</pre>
        </li>
      </ul>
    </section>

    <section class="hint-card">
      <p>콘솔에서 다음을 실행하면 로그가 탐색 가능합니다:</p>
      <code>console.table(window.__API_LOGS__)</code>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import type { NitroFetchOptions } from 'nitropack/types';

type TestCaseMethod = 'GET' | 'POST';

type TestCase = {
  label: string;
  method: TestCaseMethod;
  url: string;
  options?: NitroFetchOptions<string & {}, TestCaseMethod>;
};

const testing = ref(false);
const testResults = ref<
  Array<{
    method: string;
    url: string;
    status: number;
    dataSize: number;
    duration: number;
    payload: string;
  }>
>([]);

const testCases: TestCase[] = [
  {
    label: '기본 GET',
    method: 'GET',
    url: '/api/demo',
    options: { method: 'GET' }
  },
  {
    label: '쿼리付き GET',
    method: 'GET',
    url: '/api/demo?id=123&type=test',
    options: { method: 'GET' }
  },
  {
    label: 'POST (데이터 포함)',
    method: 'POST',
    url: '/api/demo',
    options: {
      method: 'POST',
      body: { userId: 123, action: 'test', timestamp: new Date().toISOString() }
    }
  }
];

const testApis = async () => {
  if (testing.value) return;
  testing.value = true;
  testResults.value = [];

  try {
    for (const test of testCases) {
      const start = performance.now();
      const res = await $fetch(test.url, test.options);
      const duration = Math.round(performance.now() - start);

      testResults.value.push({
        method: test.method,
        url: test.url,
        status: 200,
        dataSize: JSON.stringify(res).length,
        duration,
        payload: JSON.stringify(res, null, 2)
      });
    }

    console.log('✅ 모든 API 테스트 완료', testResults.value);
  } catch (error) {
    console.error('❌ API 테스트 실패', error);
    alert(`API 요청 중 오류가 발생했습니다: ${(error as Error).message}`);
  } finally {
    testing.value = false;
  }
};
</script>

<style scoped>
.api-test {
  max-width: 900px;
  margin: 2rem auto;
  padding: 0 1rem 3rem;
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.header-card {
  background: linear-gradient(135deg, #25265c, #1d213c);
  border-radius: 10px;
  padding: 2rem;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
  box-shadow: 0 20px 45px rgba(9, 8, 30, 0.5);
}

.header-card h1 {
  margin: 0.25rem 0 0.5rem;
  font-size: 2rem;
}

.header-card .lede {
  max-width: 480px;
  margin: 0;
  color: rgba(255, 255, 255, 0.85);
}

.eyebrow {
  letter-spacing: 0.2em;
  text-transform: uppercase;
  font-size: 0.75rem;
  color: #a3a6ff;
}

.run-btn {
  background: #9b65ff;
  border: none;
  padding: 0.85rem 1.85rem;
  border-radius: 10px;
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.run-btn:disabled {
  opacity: 0.6;
  cursor: progress;
}

.run-btn:not(:disabled):hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 40px rgba(155, 101, 255, 0.3);
}

.results-card {
  background: #0f1324;
  border-radius: 10px;
  padding: 1.5rem;
  color: #f3f4ff;
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.results-card header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}

.results-card h2 {
  margin: 0;
}

.results-card ul {
  list-style: none;
  padding: 0;
  margin: 1rem 0 0;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.results-card li {
  background: rgba(255, 255, 255, 0.04);
  padding: 1rem;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.results-card .meta {
  margin: 0.2rem 0 0;
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.6);
}

.results-card pre {
  margin: 0.75rem 0 0;
  background: rgba(16, 30, 70, 0.5);
  border-radius: 10px;
  padding: 0.75rem;
  font-size: 0.85rem;
  overflow-x: auto;
}

.hint-card {
  background: #fff7e2;
  padding: 1.25rem 1.5rem;
  border-radius: 10px;
  border: 1px solid #ffeecc;
  font-size: 0.95rem;
}

.hint-card code {
  display: block;
  margin-top: 0.5rem;
  background: #fff;
  padding: 0.5rem;
  border-radius: 8px;
}
</style>
