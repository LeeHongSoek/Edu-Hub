<!--
파일 개요:
- 역할: 백엔드 동작 확인과 테스트 목적의 보조 페이지입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<template>
  <div style="padding: 20px; max-width: 800px">
    <h1>
      <IconRocket
        style="width: 1.2rem; height: 1.2rem; vertical-align: -0.15rem"
      />
      실제 백엔드 API 테스트
    </h1>

    <div
      style="
        background: #e3f2fd;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 20px;
      ">
      <button
        @click="testBackendApis"
        :disabled="testing"
        style="
          padding: 12px 24px;
          font-size: 16px;
          background: #2196f3;
          color: white;
          border: none;
          border-radius: 5px;
          cursor: pointer;
        ">
        <span style="display: inline-flex; align-items: center; gap: 0.35rem">
          <IconRefresh v-if="testing" style="width: 1rem; height: 1rem" />
          <IconRocket v-else style="width: 1rem; height: 1rem" />
          {{ testing ? "실행 중..." : "백엔드 API 호출" }}
        </span>
      </button>
      <p style="color: #666; margin-top: 10px">
        이 버튼을 클릭하면 {{ config.public.backendOriginLabel }} 의 실제 백엔드
        API를 호출합니다.
      </p>
    </div>

    <div
      style="
        background: #f5f5f5;
        padding: 15px;
        border-radius: 5px;
        margin-bottom: 20px;
        max-height: 400px;
        overflow-y: auto;
      ">
      <h3>
        <IconChart
          style="width: 1rem; height: 1rem; vertical-align: -0.15rem"
        />
        API 응답 로그
      </h3>
      <div v-if="testResults.length === 0" style="color: #999">
        위의 버튼을 클릭하여 API를 호출하세요.
      </div>
      <ul v-else style="list-style: none; padding: 0">
        <li
          v-for="(result, idx) in testResults"
          :key="idx"
          style="
            margin: 10px 0;
            padding: 10px;
            background: white;
            border-left: 4px solid #2196f3;
            border-radius: 3px;
          ">
          <strong>{{ result.method }} {{ result.url }}</strong
          ><br />
          <small style="color: #666"
            >상태: {{ result.status }} | 크기: {{ result.size }} bytes</small>
          <details style="margin-top: 5px">
            <summary style="cursor: pointer; color: #2196f3">
              <IconFileText
                style="
                  width: 0.95rem;
                  height: 0.95rem;
                  vertical-align: -0.15rem;
                "
              />
              응답 데이터
            </summary>
            <pre
              style="
                background: #f0f0f0;
                padding: 10px;
                border-radius: 3px;
                overflow-x: auto;
                font-size: 12px;
              "
              >{{ JSON.stringify(result.data, null, 2) }}</pre>
          </details>
        </li>
      </ul>
    </div>

    <div style="background: #fff3e0; padding: 15px; border-radius: 5px">
      <h3>
        <IconTarget
          style="width: 1rem; height: 1rem; vertical-align: -0.15rem"
        />
        브라우저 콘솔 명령어
      </h3>
      <code
        style="
          display: block;
          background: white;
          padding: 10px;
          margin: 5px 0;
          border-left: 3px solid #ff9800;
        ">
        // 프론트 요청 로그는 logs/api-front.log 에 저장됩니다.
      </code>
      <code
        style="
          display: block;
          background: white;
          padding: 10px;
          margin: 5px 0;
          border-left: 3px solid #ff9800;
        ">
        // 백엔드 요청 로그는 logs/api-back.log 에 저장됩니다.
      </code>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import IconRocket from "~/assets/icons/IconRocket.svg?component";
import IconRefresh from "~/assets/icons/IconRefresh.svg?component";
import IconChart from "~/assets/icons/IconChart.svg?component";
import IconFileText from "~/assets/icons/IconFileText.svg?component";
import IconTarget from "~/assets/icons/IconTarget.svg?component";

const config = useRuntimeConfig();
const testing = ref(false);
const testResults = ref<any[]>([]);

const testBackendApis = async () => {
  testing.value = true;
  testResults.value = [];

  try {
    console.log(
      "%c백엔드 API 테스트 시작",
      "color: #FF5722; font-weight: bold; font-size: 14px;",
    );

    // 테스트 1: 대시보드 통계
    try {
      console.log("Test 1: GET /api/dashboard/stats");
      const res1 = await $fetch("/api/dashboard/stats");

      testResults.value.push({
        method: "GET",
        url: "/api/dashboard/stats",

        status: 200,
        size: JSON.stringify(res1).length,
        data: res1,
      });
      console.log("Stats:", res1);
    } catch (e) {
      console.warn("Stats 엔드포인트 없음, 다른 API 시도");
    }

    // 테스트 2: 사용자 정보
    try {
      console.log("Test 2: GET /api/users");
      const res2 = await $fetch("/api/users");

      testResults.value.push({
        method: "GET",
        url: "/api/users",

        status: 200,
        size: JSON.stringify(res2).length,
        data: res2,
      });
      console.log("Users:", res2);
    } catch (e) {
      console.warn("Users 엔드포인트 없음");
    }

    // 테스트 3: 질문 목록
    try {
      console.log("Test 3: POST /api/questions");
      const res3 = await $fetch("/api/questions", {
        method: "POST",
        body: {
          page: 1,
          limit: 10,
        },
      });

      testResults.value.push({
        method: "POST",
        url: "/api/questions",

        status: 200,
        size: JSON.stringify(res3).length,
        data: res3,
      });
      console.log("Questions:", res3);
    } catch (e) {
      console.warn("Questions 엔드포인트 없음");
    }

    console.log(
      "%cAPI 테스트 완료!",
      "color: #4CAF50; font-weight: bold; font-size: 14px;",
    );
    console.log(
      "%c요청 로그는 프론트 logs/api-front.log, 백엔드 logs/api-back.log 에 저장됩니다.",
      "font-style: italic; color: #FF9800;",
    );
  } catch (error) {
    console.error("오류:", error);
  } finally {
    testing.value = false;
  }
};
</script>

<style scoped>
code {
  font-family: "Courier New", monospace;
  font-size: 12px;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
