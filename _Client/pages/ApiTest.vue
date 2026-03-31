<template>
  <div class="api-test">
    <section class="header-card">
      <div>
        <p class="eyebrow">API Health Check</p>
        <h1>백엔드 /api/demo 연결 상태</h1>
        <p class="lede">
          버튼을 누르면 GET, 쿼리付き GET, POST 요청을 순차적으로 보내고 결과를
          하단 카드에 정리합니다.
        </p>
      </div>
      <button class="run-btn" :disabled="testing" @click="testApis">
        <span v-if="testing" class="button-label">
          <IconRefresh class="button-icon spinning" />
          호출 중...
        </span>
        <span v-else class="button-label">
          <IconPlay class="button-icon" />
          테스트 실행
        </span>
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
            <strong>{{ item.method.toUpperCase() }} {{ item.url }}</strong>
            <p class="meta">
              상태 {{ item.status }} · {{ item.dataSize }} bytes ·
              {{ item.duration }}ms
            </p>
          </div>
          <pre>{{ item.payload }}</pre>
        </li>
      </ul>
    </section>

    <section class="hint-card">
      <p>요청 로그는 서버의 <code>logs/api-front.log</code> 에 쌓입니다.</p>
      <p>브라우저 콘솔에서는 이 페이지의 API 호출 결과만 확인하면 됩니다.</p>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import type { NitroFetchOptions } from "nitropack/types";
import IconRefresh from "~/assets/icons/IconRefresh.svg?component";
import IconPlay from "~/assets/icons/IconPlay.svg?component";

type TestCaseMethod = "get" | "post";

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
    requestBody: unknown;
    responseBody: unknown;
  }>
>([]);

const testCases: TestCase[] = [
  {
    label: "기본 GET",
    method: "get",
    url: "/api/demo",
    options: { method: "get" },
  },
  {
    label: "쿼리付き GET",
    method: "get",
    url: "/api/demo?id=123&type=test",
    options: { method: "get" },
  },
  {
    label: "POST (데이터 포함)",
    method: "post",
    url: "/api/demo",
    options: {
      method: "post",
      body: {
        userId: 123,
        action: "test",
        timestamp: new Date().toISOString(),
      },
    },
  },
];

const testApis = async () => {
  if (testing.value) return;
  testing.value = true;
  testResults.value = [];

  const printTable = () => {
    // 테스트 결과를 콘솔에서 빠르게 훑어볼 수 있게 요약 테이블로 출력
    console.table(
      testResults.value.map((item) => ({
        method: item.method.toUpperCase(),
        url: item.url,
        status: item.status,
        duration: `${item.duration}ms`,
        bytes: item.dataSize,
        resBody: item.payload,
      })),
    );
  };

  const printBodyTable = (label: string, body: unknown) => {
    console.log(label);

    if (body && typeof body === "object" && !Array.isArray(body)) {
      console.table([body]);
      return;
    }

    if (Array.isArray(body)) {
      console.table(body);
      return;
    }

    console.table([{ value: body }]);
  };

  try {
    for (const test of testCases) {
      const start = performance.now();
      const res = await $fetch(test.url, test.options);
      const duration = Math.round(performance.now() - start);
      const requestBody = test.options?.body ?? null;

      // 화면 표시용 + 콘솔 표 출력용으로 응답 요약을 저장
      testResults.value.push({
        method: test.method,
        url: test.url,
        status: 200,
        dataSize: JSON.stringify(res).length,
        duration,
        payload: JSON.stringify(res, null, 2),
        requestBody,
        responseBody: res,
      });

      console.log(
        `[API통신_헤더] <${test.method.toUpperCase()}> ${test.url} (200) - ${duration}ms`,
      );
      if (requestBody) {
        printBodyTable("[API통신_데이터_요청]", requestBody);
      }
      printBodyTable("[API통신_데이터_응답]", res);
    }

    printTable();
    console.log("API 테스트 완료", testResults.value);
  } catch (error) {
    printTable();
    console.error("API 테스트 실패", error);
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
  transition:
    transform 0.2s ease,
    box-shadow 0.2s ease;
}

.button-label {
  display: inline-flex;
  align-items: center;
  gap: 0.45rem;
}

.button-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.spinning {
  animation: spin 1s linear infinite;
}

.run-btn:disabled {
  opacity: 0.6;
  cursor: progress;
}

.run-btn:not(:disabled):hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 40px rgba(155, 101, 255, 0.3);
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
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
