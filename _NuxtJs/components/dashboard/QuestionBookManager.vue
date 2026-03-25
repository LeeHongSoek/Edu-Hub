<script setup lang="ts">
import { ref, onMounted } from 'vue';

const books = ref<any[]>([]);
const loading = ref(true);
const showCreateModal = ref(false);
const newBook = ref({ book_name: '', description: '' });

const fetchBooks = async () => {
  const config = useRuntimeConfig();
  const token = useCookie('auth_token');
  try {
    const data = await $fetch(`${config.public.apiBase}/question-books/my`, {
      headers: { Authorization: `Bearer ${token.value}` }
    });
    books.value = data as any[];
  } catch (err) {
    console.error('Failed to fetch books:', err);
  } finally {
    loading.value = false;
  }
};

const createBook = async () => {
  const config = useRuntimeConfig();
  const token = useCookie('auth_token');
  try {
    await $fetch(`${config.public.apiBase}/question-books`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token.value}` },
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
    <div v-else class="book-grid">
      <div v-for="book in books" :key="book.book_id" class="book-card">
        <div class="book-info">
          <h4>{{ book.book_name }}</h4>
          <p>{{ book.description || '설명 없음' }}</p>
          <div class="book-meta">문항 수: {{ book.items?.length || 0 }}개</div>
        </div>
        <div class="book-actions">
          <button class="btn-view">상세보기</button>
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
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
}

.book-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  transition: all 0.3s;
}

.book-card:hover { border-color: #6366f1; transform: translateY(-4px); }

.book-info h4 { color: #f8fafc; margin: 0 0 0.5rem 0; font-size: 1.1rem; }
.book-info p { color: #94a3b8; font-size: 0.9rem; margin-bottom: 1rem; line-height: 1.4; }
.book-meta { font-size: 0.8rem; color: #64748b; font-weight: 600; }

.btn-view {
  width: 100%;
  margin-top: 1rem;
  padding: 0.6rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
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

.loading, .empty { text-align: center; padding: 3rem; color: #64748b; }
</style>
