<script setup lang="ts">
import { ref, onMounted } from 'vue';

const emit = defineEmits(['close']);

const reports = ref<any[]>([]);
const loading = ref(true);
const showForm = ref(false);
const editingReport = ref<any>(null);

const { apiBase, token, getAuthHeader } = useApi();

const form = ref({
  category: 'OPINION',
  title: '',
  content: ''
});

const categories = [
  { value: 'OPINION', label: '단순 의견' },
  { value: 'IMPROVEMENT', label: '개선 제안' },
  { value: 'COMPLAINT', label: '불만/오류 제보' }
];


const fetchMyReports = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/ombudsman/my`, {
      headers: getAuthHeader()
    });
    reports.value = data as any[];
  } catch (err) {
    console.error('서버 통신 오류(fetch) reports:', err);
  } finally {
    loading.value = false;
  }
};

const submitReport = async () => {
  try {
    if (editingReport.value) {
      await $fetch(`${apiBase.value}/ombudsman/${editingReport.value.report_id}`, {
        method: 'PATCH',
        headers: getAuthHeader(),
        body: form.value
      });
    } else {
      await $fetch(`${apiBase.value}/ombudsman`, {
        method: 'POST',
        headers: getAuthHeader(),
        body: form.value
      });
    }
    resetForm();
    await fetchMyReports();
  } catch (err) {
    alert('제출에 실패했습니다.');
  }
};

const editReport = (report: any) => {
  editingReport.value = report;
  form.value = {
    category: report.category,
    title: report.title,
    content: report.content
  };
  showForm.value = true;
};

const deleteReport = async (id: string) => {
  if (!confirm('정말 삭제하시겠습니까?')) return;
  try {
    await $fetch(`${apiBase.value}/ombudsman/${id}`, {
      method: 'DELETE',
      headers: getAuthHeader()
    });
    await fetchMyReports();
  } catch (err) {
    alert('삭제에 실패했습니다.');
  }
};

const resetForm = () => {
  showForm.value = false;
  editingReport.value = null;
  form.value = { category: 'OPINION', title: '', content: '' };
};

onMounted(fetchMyReports);
</script>

<template>
  <div class="modal-overlay" @click.self="emit('close')">
    <div class="modal-card">
      <div class="modal-header">
        <h2>📢 옴브즈먼 (사이트 피드백)</h2>
        <button class="btn-close" @click="emit('close')">&times;</button>
      </div>

      <div class="modal-body">
        <div v-if="!showForm" class="list-section">
          <div class="list-header">
            <h3>나의 제보 내역</h3>
            <button class="btn-primary" @click="showForm = true">새 제보하기</button>
          </div>
          
          <div v-if="loading" class="loading">불러오는 중...</div>
          <div v-else-if="reports.length === 0" class="empty">
            아직 등록된 제보가 없습니다.
          </div>
          <div v-else class="report-list">
            <div v-for="report in reports" :key="report.report_id" class="report-item">
              <div class="report-main">
                <span class="category-badge" :class="report.category.toLowerCase()">
                  {{ categories.find(c => c.value === report.category)?.label }}
                </span>
                <h4 class="report-title">{{ report.title }}</h4>
                <p class="report-date">{{ new Date(report.created_at).toLocaleDateString() }}</p>
              </div>
              <div class="report-actions">
                <button class="btn-icon" @click="editReport(report)">✏️</button>
                <button class="btn-icon" @click="deleteReport(report.report_id)">🗑️</button>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="form-section">
          <h3>{{ editingReport ? '제보 수정' : '새 제보 등록' }}</h3>
          <div class="form-group">
            <label>분류</label>
            <select v-model="form.category">
              <option v-for="cat in categories" :key="cat.value" :value="cat.value">
                {{ cat.label }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label>제목</label>
            <input v-model="form.title" type="text" placeholder="제목을 입력하세요" />
          </div>
          <div class="form-group">
            <label>내용</label>
            <textarea v-model="form.content" rows="6" placeholder="상세 내용을 입력하세요"></textarea>
          </div>
          <div class="form-actions">
            <button class="btn-secondary" @click="resetForm">취소</button>
            <button class="btn-primary" @click="submitReport">
              {{ editingReport ? '수정 완료' : '제출하기' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-card {
  background: #1e293b;
  width: 90%;
  max-width: 600px;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  max-height: 85vh;
}

.modal-header {
  padding: 1.5rem 2rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h2 {
  font-size: 1.25rem;
  color: #f8fafc;
  font-weight: 800;
}

.btn-close {
  background: none; border: none;
  color: #94a3b8; font-size: 2rem;
  cursor: pointer;
}

.modal-body {
  padding: 2rem;
  overflow-y: auto;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.list-header h3 { color: #94a3b8; font-size: 1rem; }

.report-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.report-item {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.category-badge {
  font-size: 0.7rem;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-weight: 700;
  margin-bottom: 0.3rem;
  display: inline-block;
}

.category-badge.opinion { background: rgba(56, 189, 248, 0.1); color: #38bdf8; }
.category-badge.improvement { background: rgba(34, 197, 94, 0.1); color: #4ade80; }
.category-badge.complaint { background: rgba(244, 63, 94, 0.1); color: #fb7185; }

.report-title { color: #f8fafc; font-weight: 600; margin-bottom: 0.2rem; }
.report-date { color: #64748b; font-size: 0.8rem; }

.report-actions { display: flex; gap: 0.5rem; }
.btn-icon {
  background: none; border: none; font-size: 1.1rem; cursor: pointer;
  opacity: 0.6; transition: opacity 0.2s;
}
.btn-icon:hover { opacity: 1; }

.form-section h3 { color: #f8fafc; margin-bottom: 1.5rem; }

.form-group { margin-bottom: 1.2rem; display: flex; flex-direction: column; gap: 0.5rem; }
.form-group label { color: #94a3b8; font-size: 0.9rem; font-weight: 600; }

.form-group input, .form-group textarea, .form-group select {
  background: rgba(15, 23, 42, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 0.8rem;
  color: #f8fafc;
  outline: none;
}

.form-group input:focus, .form-group textarea:focus {
  border-color: #818cf8;
}

.form-actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 2rem; }

.btn-primary {
  background: #818cf8; color: white; border: none;
  padding: 0.6rem 1.2rem; border-radius: 10px; font-weight: 700; cursor: pointer;
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.05); color: #94a3b8; border: none;
  padding: 0.6rem 1.2rem; border-radius: 10px; font-weight: 700; cursor: pointer;
}

.loading, .empty { text-align: center; padding: 2rem; color: #64748b; }
</style>
