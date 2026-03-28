<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue';

const books = ref<any[]>([]);
const loading = ref(true);
const itemsPerPage = 6;
const currentPage = ref(1);
const sliderValue = ref(1);
const searchField = ref<'name' | 'description'>('name');
const searchInput = ref('');
const searchQuery = ref('');
const filteredBooks = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase();
  if (!keyword) return books.value;
  return books.value.filter((book) => {
    const target = searchField.value === 'description'
      ? (book.description || '')
      : book.book_name;
    return target?.toLowerCase().includes(keyword);
  });
});

const totalPages = computed(() => Math.max(1, Math.ceil(filteredBooks.value.length / itemsPerPage)));
const pagedBooks = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredBooks.value.slice(start, start + itemsPerPage);
});
const pageStartItem = computed(() => {
  if (books.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage + 1;
});
const pageEndItem = computed(() => Math.min(currentPage.value * itemsPerPage, books.value.length));
const sliderPercentage = computed(() => {
  if (totalPages.value <= 1) return 0;
  return ((sliderValue.value - 1) / (totalPages.value - 1)) * 100;
});

watch(() => filteredBooks.value.length, () => {
  currentPage.value = 1;
  sliderValue.value = 1;
});

watch(currentPage, (page) => {
  sliderValue.value = page;
});

const applySearch = () => {
  searchQuery.value = searchInput.value.trim();
  currentPage.value = 1;
};

const clearSearch = () => {
  searchInput.value = '';
  searchQuery.value = '';
  currentPage.value = 1;
};
const handleSliderInput = (e: Event) => {
  sliderValue.value = Number((e.target as HTMLInputElement).value);
};

const goToPage = (page: number) => {
  const normalized = Math.min(Math.max(page, 1), totalPages.value);
  if (normalized !== currentPage.value) {
    currentPage.value = normalized;
  }
};

const commitSliderValue = () => {
  goToPage(sliderValue.value);
};

const prevPage = () => goToPage(currentPage.value - 1);
const nextPage = () => goToPage(currentPage.value + 1);
const showCreateModal = ref(false);
const newBook = ref({ book_name: '', description: '' });

const { apiBase, token, getAuthHeader } = useApi();
const router = useRouter();

const viewBookDetails = (bookId: number | string | bigint) => {
  router.push({
    path: '/questions',
    query: { book: String(bookId) },
  });
};

const fetchBooks = async () => {
  try {
    const data = await $fetch(`${apiBase.value}/question-books/my`, {
      headers: getAuthHeader()
    });
    books.value = data as any[];
  } catch (err) {
    console.error('서버 통신 오류(fetch) books:', err);
  } finally {
    loading.value = false;
    currentPage.value = Math.min(currentPage.value, totalPages.value);
    sliderValue.value = currentPage.value;
  }
};

const createBook = async () => {
  try {
    await $fetch(`${apiBase.value}/question-books`, {
      method: 'POST',
      headers: getAuthHeader(),
      body: newBook.value
    });
    showCreateModal.value = false;
    newBook.value = { book_name: '', description: '' };
    fetchBooks();
  } catch (err) {
    alert('문제집 생성 피일');
  }
};

onMounted(fetchBooks);
</script>

<template>
  <div class="book-manager">
    <div class="manager-header">
      <h3>📚 나의 문제집 목록</h3>
      <button class="btn-create" @click="showCreateModal = true">+ 새 문제집</button>
    </div>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="books.length === 0" class="empty">생성된 문제집이 없습니다.</div>
    <div v-else>
      <div class="pagination-panel-border">
        <div class="slider-panel">
          <div class="search-row">
            <select v-model="searchField" class="search-select">
              <option value="name">문제집명</option>
              <option value="description">설명</option>
            </select>
            <input
              v-model="searchInput"
              type="text"
              class="search-input"
              placeholder="문제집명 또는 설명을 입력하세요"
              @keyup.enter="applySearch"
            />
            <button class="btn-search" @click="applySearch">검색</button>
            <button v-if="searchQuery" class="btn-reset-search" @click="clearSearch">초기화</button>
          </div>
          <div class="slider-row">
            <span class="summary-text">총 {{ filteredBooks.length }}개 문제집</span>
            <div class="page-slider-section">
              <div class="slider-wrapper" :class="{ disabled: totalPages <= 1 }">
                <span class="slider-limit">1</span>
                <div class="slider-track-container">
                  <input
                    type="range"
                    :min="1"
                    :max="totalPages"
                    :value="sliderValue"
                    class="page-slider"
                    @input="handleSliderInput"
                    @change="commitSliderValue"
                    :disabled="totalPages <= 1"
                  />
                  <div class="slider-fill" :style="{ width: sliderPercentage + '%' }"></div>
                  <div class="slider-tooltip" :style="{ left: sliderPercentage + '%' }">
                    {{ sliderValue }}
                  </div>
                </div>
                <span class="slider-limit">{{ totalPages }}</span>
              </div>
            </div>
            <span class="range-text">{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시 중</span>
          </div>
        </div>
      </div>
      <div class="book-grid">
        <div v-for="book in pagedBooks" :key="book.book_id" class="book-card">
          <div class="book-card-head">
            <h4><{{ book.book_id }}> {{ book.book_name }}</h4>
            <span class="book-meta">문항 수: {{ book.items?.length || 0 }}개</span>
          </div>
          <div class="book-card-body">
            <p>{{ book.description || '설명 없음' }}</p>
            <button class="btn-view" @click="viewBookDetails(book.book_id)">상세보기</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 생성 모달 -->
    <div v-if="showCreateModal" class="modal-overlay" @click.self="showCreateModal = false">
      <div class="modal-content">
        <h3>새 문제집 만들기</h3>
        <div class="form-group">
          <label>문제집 이름</label>
          <input v-model="newBook.book_name" type="text" placeholder="예: 2024 정보처리기사 핵심문항" />
        </div>
        <div class="form-group">
          <label>설명</label>
          <textarea v-model="newBook.description" placeholder="문제집에 대한 설명을 적어주세요."></textarea>
        </div>
        <div class="modal-actions">
          <button @click="showCreateModal = false">취소</button>
          <button class="btn-primary" @click="createBook">생성하기</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.book-manager { display: flex; flex-direction: column; gap: 1.5rem; }
.manager-header { display: flex; justify-content: space-between; align-items: center; }
.manager-header h3 { color: #f8fafc; margin: 0; }

.btn-create {
  background: #6366f1;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
}

.book-grid {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-top: 1rem;
}

.book-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 10px;
  padding: 1rem 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.45rem;
  transition: border 0.3s, transform 0.3s;
}

.book-card:hover { border-color: #6366f1; transform: translateY(-3px); }

.book-card-head,
.book-card-body {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.book-card-head h4 {
  color: #f8fafc;
  margin: 0;
  font-size: 1.1rem;
}

.book-card-body p {
  color: #94a3b8;
  font-size: 0.9rem;
  margin: 0;
  line-height: 1.4;
  flex: 1;
}

.book-meta {
  font-size: 0.8rem;
  color: #64748b;
  font-weight: 600;
  white-space: nowrap;
}

.btn-view {
  padding: 0.5rem 1.2rem;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.15);
  color: #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: border-color 0.2s, background 0.2s;
  white-space: nowrap;
}

.btn-view:hover {
  border-color: rgba(99, 102, 241, 0.8);
  background: rgba(99, 102, 241, 0.14);
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: #1e293b;
  padding: 2rem;
  border-radius: 10px;
  width: 100%;
  max-width: 450px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.form-group { margin-bottom: 1.5rem; }
.form-group label { display: block; color: #94a3b8; margin-bottom: 0.5rem; font-size: 0.9rem; }
.form-group input, .form-group textarea {
  width: 100%;
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 0.8rem;
  color: white;
}

.modal-actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 1rem; }
.btn-primary { background: #6366f1; border: none; color: white; padding: 0.6rem 1.5rem; border-radius: 10px; cursor: pointer; }

.search-select,
.search-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 12px;
  color: #fff;
  padding: 0 0.95rem;
  font-size: 0.9rem;
  height: 2.3rem;
  display: flex;
  align-items: center;
}

.search-select {
  min-width: 130px;
}

.search-input {
  flex: 1;
  min-width: 200px;
}

.btn-search,
.btn-reset-search {
  border-radius: 10px;
  padding: 0.5rem 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  height: 38px;
}

.btn-search {
  border: none;
  background: #6366f1;
  color: white;
}

.btn-search:hover {
  background: #4f46e5;
  transform: translateY(-1px);
}

.btn-reset-search {
  background: rgba(255, 255, 255, 0.08);
  color: #e2e8f0;
  border: 1px solid rgba(255, 255, 255, 0.15);
}

.summary-text,
.range-text {
  font-size: 0.9rem;
  color: #cbd5f5;
  font-weight: 500;
  white-space: nowrap;
  flex-shrink: 0;
}

.page-slider-section {
  flex: 1;
  min-width: 0;
}

.slider-wrapper {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  width: 100%;
  max-width: none;
}

.slider-wrapper.disabled {
  pointer-events: none;
  opacity: 0.6;
}

.slider-wrapper.disabled .page-slider {
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
  transition: transform 0.2s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.page-slider:hover::-webkit-slider-thumb {
  transform: scale(1.15);
  box-shadow: 0 0 20px rgba(99, 102, 241, 0.6);
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
  top: -24px;
  transform: translateX(-50%);
  background: #6366f1;
  color: white;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 800;
  pointer-events: none;
  white-space: nowrap;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.slider-tooltip::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-top: 4px solid #6366f1;
}

.loading, .empty {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}

.pagination-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 16px;
  padding: 1rem 1.25rem;
  background: rgba(15, 23, 42, 0.65);
  box-shadow: 0 20px 60px -22px rgba(15, 23, 42, 1);
  margin-bottom: 1.5rem;
}

.slider-panel {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.search-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.slider-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  justify-content: space-between;
  flex-wrap: nowrap;
}

</style>
