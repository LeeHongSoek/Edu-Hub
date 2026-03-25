<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
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
  ArcElement
} from 'chart.js';
import { Line, Bar, Pie } from 'vue-chartjs';

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  ArcElement
);

const stats = ref<any>(null);
const loading = ref(true);

const fetchStats = async () => {
  const config = useRuntimeConfig();
  const token = useCookie('auth_token');
  try {
    const data = await $fetch(`${config.public.apiBase}/dashboard/stats`, {
      headers: { Authorization: `Bearer ${token.value}` }
    });
    stats.value = data;
  } catch (err) {
    console.error('Failed to fetch stats:', err);
  } finally {
    loading.value = false;
  }
};

onMounted(fetchStats);

const chartData = computed(() => {
  if (!stats.value || !stats.value.dailyStats) return null;
  return {
    labels: stats.value.dailyStats.map((d: any) => d.date.split('-').slice(1).join('/')),
    datasets: [
      {
        label: '푼 문제 수',
        backgroundColor: '#818cf8',
        borderColor: '#818cf8',
        data: stats.value.dailyStats.map((d: any) => d.count),
        tension: 0.4,
        fill: true,
      }
    ]
  };
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { display: false },
  },
  scales: {
    y: { beginAtZero: true, grid: { color: 'rgba(255,255,255,0.05)' } },
    x: { grid: { display: false } }
  }
};
</script>

<template>
  <div v-if="loading" class="loading">통계를 불러오는 중...</div>
  <div v-else-if="stats" class="stats-grid">
    <div class="stat-card main-chart">
      <h3>📅 최근 7일 학습 현황</h3>
      <div class="chart-container">
        <Line v-if="chartData" :data="chartData" :options="chartOptions" />
      </div>
    </div>
    
    <div class="stat-card">
      <div class="stat-icon">🎯</div>
      <div class="stat-info">
        <span class="label">평균 정답률</span>
        <span class="value">{{ stats.accuracy }}%</span>
      </div>
    </div>

    <div class="stat-card">
      <div class="stat-icon">📝</div>
      <div class="stat-info">
        <span class="label">총 푼 문제</span>
        <span class="value">{{ stats.totalSolved }}개</span>
      </div>
    </div>

    <div class="stat-card">
      <div class="stat-icon">📚</div>
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
