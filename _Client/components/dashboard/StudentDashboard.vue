<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import IconCalendar from "~/assets/icons/IconCalendar.svg?component";
import IconTarget from "~/assets/icons/IconTarget.svg?component";
import IconPencil from "~/assets/icons/IconPencil.svg?component";
import IconBook from "~/assets/icons/IconBook.svg?component";
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  ArcElement,
} from "chart.js";
import { Line, Bar, Pie } from "vue-chartjs";

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  ArcElement,
);

const stats = ref<any>(null);
const loading = ref(true);

const { apiBase, token, getAuthHeader } = useApi();

const getDefaultDailyStats = () => {
  const dates = [];
  for (let i = 6; i >= 0; i--) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    dates.push({
      date: d.toISOString().split("T")[0],
      count: 0,
    });
  }
  return dates;
};

const fetchStats = async () => {
  try {
    console.log("토큰값=", token.value);
    const data: any = await $fetch(`${apiBase.value}/dashboard/stats`, {
      headers: getAuthHeader(),
    });
    console.log("[프런트엔드:StudentDashboard.vue] 패치된 정보:", data);

    // 만약 data가 없거나 속성들이 비어있다면 0을 기본값으로 사용
    stats.value = {
      accuracy: data?.accuracy || 0,
      totalSolved: data?.totalSolved || 0,
      totalViewed: data?.totalViewed || 0,
      studyLogs: data?.studyLogs || 0,
      totalQuestions: data?.totalQuestions || 0,
      // 데이터가 없으면 7일치 0개 배열을 추가
      dailyStats:
        data?.dailyStats && data.dailyStats.length > 0
          ? data.dailyStats
          : getDefaultDailyStats(),
    };
  } catch (err) {
    console.error("서버 통신 오류(fetch) stats:", err);
    // 에러 시에도 기본값을 넣어서 그래프와 숫자가 0으로 보이게 처리
    stats.value = {
      accuracy: 0,
      totalSolved: 0,
      totalViewed: 0,
      totalQuestions: 0,
      studyLogs: 0,
      dailyStats: getDefaultDailyStats(),
    };
  } finally {
    loading.value = false;
  }
};

onMounted(fetchStats);

const chartData = computed(() => {
  if (!stats.value || !stats.value.dailyStats) return null;
  return {
    labels: stats.value.dailyStats.map((d: any) =>
      d.date.split("-").slice(1).join("/"),
    ),
    datasets: [
      {
        label: "푼 문제 수",
        backgroundColor: "#818cf8",
        borderColor: "#818cf8",
        data: stats.value.dailyStats.map((d: any) => d.count),
        tension: 0.4,
        fill: true,
      },
    ],
  };
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
  },
  scales: {
    y: { beginAtZero: true, grid: { color: "rgba(255,255,255,0.05)" } },
    x: { grid: { display: false } },
  },
};
</script>

<template>
  <div v-if="loading" class="loading">통계를 불러오는 중...</div>
  <div v-else-if="stats" class="stats-grid">
    <div class="stat-card main-chart">
      <h3><IconCalendar class="section-icon" /> 최근 7일 학습 현황</h3>
      <div class="chart-container">
        <Line v-if="chartData" :data="chartData" :options="chartOptions" />
      </div>
    </div>

    <div class="stat-card">
      <div class="stat-icon"><IconTarget class="stat-icon-svg" /></div>
      <div class="stat-info">
        <span class="label">평균 정답률 (정답 / 푼 문제)</span>
        <span class="value">{{ stats.accuracy }}%</span>
      </div>
    </div>

    <div class="stat-card">
      <div class="stat-icon"><IconPencil class="stat-icon-svg" /></div>
      <div class="stat-info">
        <span class="label">총 푼 문제</span>
        <span class="value"
          >{{ stats.totalSolved }} / {{ stats.totalViewed }}개</span
        >
      </div>
    </div>

    <div class="stat-card">
      <div class="stat-icon"><IconBook class="stat-icon-svg" /></div>
      <div class="stat-info">
        <span class="label">오답 노트 수</span>
        <span class="value">{{ stats.studyLogs }}개</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.stats-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
}

.stat-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1.2rem;
}

.main-chart {
  grid-column: span 3;
  display: block;
}

.main-chart h3 {
  margin-bottom: 1.5rem;
  color: #94a3b8;
  font-size: 1rem;
  display: flex;
  align-items: center;
  gap: 0.35rem;
}

.section-icon {
  width: 1rem;
  height: 1rem;
  flex-shrink: 0;
}

.chart-container {
  height: 250px;
}

.stat-icon {
  font-size: 2rem;
  background: rgba(255, 255, 255, 0.05);
  width: 60px;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
}

.stat-icon-svg {
  width: 1.4rem;
  height: 1.4rem;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-info .label {
  color: #94a3b8;
  font-size: 0.9rem;
  margin-bottom: 0.2rem;
}

.stat-info .value {
  font-size: 1.8rem;
  font-weight: 800;
  color: #f8fafc;
}

.loading {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}
</style>
