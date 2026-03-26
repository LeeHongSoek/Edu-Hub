<template>
  <div style="padding: 20px; max-width: 600px;">
    <h1>🧪 API Logger 테스트</h1>
    
    <div style="background: #e3f2fd; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
      <h3>📋 테스트 시작</h3>
      <button 
        @click="testApis" 
        :disabled="testing"
        style="padding: 12px 24px; font-size: 16px; background: #2196F3; color: white; border: none; border-radius: 5px; cursor: pointer;"
      >
        {{ testing ? '🔄 실행 중...' : '▶️ 백엔드 API 호출' }}
      </button>
      <p style="margin-top: 10px; color: #666;">
        이 버튼을 클릭하면 실제 백엔드 API를 호출하고 모든 응답을 로깅합니다.
      </p>
    </div>

    <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
      <h3>📊 콘솔 명령어</h3>
      <code style="display: block; background: #fff; padding: 10px; margin: 5px 0; border-left: 3px solid #2196F3;">
        // 모든 로그 보기
        window.__API_LOGS__
      </code>
      <code style="display: block; background: #fff; padding: 10px; margin: 5px 0; border-left: 3px solid #2196F3;">
        // 테이블 형식으로 보기
        console.table(window.__API_LOGS__)
      </code>
      <code style="display: block; background: #fff; padding: 10px; margin: 5px 0; border-left: 3px solid #2196F3;">
        // JSON으로 다운로드
        window.__API_DEBUG__.download()
      </code>
    </div>

    <div v-if="testResults.length > 0" style="background: #fff3e0; padding: 15px; border-radius: 5px;">
      <h3>✅ 테스트 결과</h3>
      <ul>
        <li v-for="(result, idx) in testResults" :key="idx" style="margin: 10px 0; padding: 10px; background: white; border-radius: 3px; border-left: 3px solid #4CAF50;">
          <strong>{{ result.method }} {{ result.url }}</strong><br>
          <small>상태: {{ result.status }} | 데이터: {{ result.dataSize }} bytes</small>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const testing = ref(false);
const testResults = ref<any[]>([]);

const testApis = async () => {
  testing.value = true;
  testResults.value = [];

  try {
    console.log('%c🚀 API 테스트 시작', 'color: #2196F3; font-weight: bold; font-size: 14px;');

    // 테스트 1: GET /api/demo
    console.log('📡 Test 1: GET /api/demo');
    const res1 = await $fetch('/api/demo', { method: 'GET' });
    testResults.value.push({
      method: 'GET',
      url: '/api/demo',
      status: 200,
      dataSize: JSON.stringify(res1).length
    });
    console.log('✅ Result 1:', res1);

    // 테스트 2: GET /api/demo (쿼리 파라미터)
    console.log('📡 Test 2: GET /api/demo?id=123&type=test');
    const res2 = await $fetch('/api/demo?id=123&type=test', { method: 'GET' });
    testResults.value.push({
      method: 'GET',
      url: '/api/demo?id=123&type=test',
      status: 200,
      dataSize: JSON.stringify(res2).length
    });
    console.log('✅ Result 2:', res2);

    // 테스트 3: POST /api/demo (바디 포함)
    console.log('📡 Test 3: POST /api/demo');
    const res3 = await $fetch('/api/demo', {
      method: 'POST',
      body: { userId: 123, action: 'test', timestamp: new Date().toISOString() }
    });
    testResults.value.push({
      method: 'POST',
      url: '/api/demo',
      status: 200,
      dataSize: JSON.stringify(res3).length
    });
    console.log('✅ Result 3:', res3);

    console.log('%c✅ 모든 테스트 완료!', 'color: #4CAF50; font-weight: bold; font-size: 14px;');
    console.log('%c📊 브라우저 콘솔에서 다음 명령어를 실행하세요:', 'color: #FF9800; font-style: italic;');
    console.log('   console.table(window.__API_LOGS__)');
    console.log('   window.__API_DEBUG__.download()');
    
    setTimeout(() => {
      alert('✅ 모든 API 호출이 완료됐습니다!\n\n브라우저 콘솔을 열어서 다음을 실행하세요:\nconsole.table(window.__API_LOGS__)');
    }, 500);

  } catch (error) {
    console.error('❌ 오류 발생:', error);
    alert('❌ 오류: ' + (error as any).message);
  } finally {
    testing.value = false;
  }
};
</script>

<style scoped>
code {
  background: #f0f0f0;
  padding: 4px 8px;
  border-radius: 3px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

button:hover:not(:disabled) {
  background: #1976D2 !important;
}
</style>
