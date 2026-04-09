<!--
파일 개요:
- 역할: 문제집 목록과 생성/수정 흐름을 관리하는 컴포넌트입니다.
- 책임: 이 파일은 화면 렌더링과 사용자 상호작용을 담당하며, 상위 페이지 또는 부모 컴포넌트와의 데이터 연동을 수행합니다.
- 유지보수: props, emits, import 경로, 템플릿 구조를 변경할 때는 이 파일을 사용하는 모든 화면을 함께 확인해야 합니다.
-->
<script setup lang="ts">
import { ref, computed, watch, onMounted } from "vue";
import IconBook from "~/assets/icons/IconBook.svg?component";
import CmmManagerNav from "~/components/CmmManagerNav.vue";
import IconCreateAction from "~/assets/icons/IconCreateAction.svg?component";
import IconDeleteAction from "~/assets/icons/IconDeleteAction.svg?component";
import CmmPageSlider from "~/components/CmmPageSlider.vue";
import CmmPlayQuestions from "~/components/CmmPlayQuestions.vue";
import QuestionBookUpsertModal from "~/components/dashboard/QuestionBookUpsertModal.vue";
import type { Question } from "~/types";
import { useUserLog } from "~/composables/useUserLog";

const props = withDefaults(
  defineProps<{
    showScopeToggle?: boolean;
  }>(),
  {
    showScopeToggle: false,
  },
);

const books = ref<any[]>([]);
const loading = ref(true);
const itemsPerPage = 6;
const currentPage = ref(1);
const sliderValue = ref(1);
const listScope = ref<"mine" | "all">("mine");
const searchField = ref<"name" | "description">("name");
const searchInput = ref("");
const searchQuery = ref("");
const selectedBookIds = ref<string[]>([]);
const userCookie = useCookie("user_info");
const userInfo = computed(() => {
  if (!userCookie.value) return null;
  try {
    return typeof userCookie.value === "string"
      ? JSON.parse(userCookie.value)
      : userCookie.value;
  } catch {
    return null;
  }
});

const listTitle = computed(() =>
  listScope.value === "all" ? "전체 문제집 목록" : "나의 문제집 목록",
);
const emptyText = computed(() => {
  if (searchQuery.value) return "검색 조건에 맞는 문제집이 없습니다.";
  return listScope.value === "all"
    ? "등록된 문제집이 없습니다."
    : "생성된 문제집이 없습니다.";
});

const isCurrentUserOwner = (
  ownerUserNo: string | number | bigint | null | undefined,
) => {
  if (!userInfo.value || ownerUserNo === null || ownerUserNo === undefined)
    return false;
  return String(userInfo.value.user_no) === String(ownerUserNo);
};
const filteredBooks = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase();
  if (!keyword) return books.value;
  return books.value.filter((book) => {
    const target =
      searchField.value === "description"
        ? book.description || ""
        : book.book_name;
    return target?.toLowerCase().includes(keyword);
  });
});

const totalPages = computed(() =>
  Math.max(1, Math.ceil(filteredBooks.value.length / itemsPerPage)),
);
const pagedBooks = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage;
  return filteredBooks.value.slice(start, start + itemsPerPage);
});
const pageStartItem = computed(() => {
  if (filteredBooks.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage + 1;
});
const pageEndItem = computed(() =>
  Math.min(currentPage.value * itemsPerPage, filteredBooks.value.length),
);
const selectedBookCount = computed(() => selectedBookIds.value.length);
const canDeleteBooks = computed(() => selectedBookCount.value > 0);

watch(
  () => filteredBooks.value.length,
  () => {
    currentPage.value = 1;
    sliderValue.value = 1;
  },
);

watch(currentPage, (page) => {
  sliderValue.value = page;
});

const applySearch = () => {
  searchQuery.value = searchInput.value.trim();
  currentPage.value = 1;
  if (searchQuery.value) {
    void logBookAction(
      0,
      `문제집 검색 실행(${searchField.value === "description" ? "설명" : "문제집명"}): "${searchQuery.value}"`,
    );
  }
};

const clearSearch = () => {
  searchInput.value = "";
  searchQuery.value = "";
  currentPage.value = 1;
  void logBookAction(0, "문제집 검색어 초기화");
};
const goToPage = (page: number) => {
  const normalized = Math.min(Math.max(page, 1), totalPages.value);
  if (normalized !== currentPage.value) {
    currentPage.value = normalized;
  }
};

const commitSliderValue = (page?: number) => {
  goToPage(page ?? sliderValue.value);
};

const prevPage = () => goToPage(currentPage.value - 1);
const nextPage = () => goToPage(currentPage.value + 1);
const showCreateModal = ref(false);
const newBook = ref({ book_name: "", description: "" });
const editingBookId = ref<string>("");

const { apiBase, getAuthHeader } = useApi();
const { writeUserLog, writeUserLogOncePerSession } = useUserLog();
const router = useRouter();

const logBookAction = async (
  bookId: number | string | bigint,
  userContent: string,
  score = 0,
  totalScore = 0,
  score100 = 0,
) => {
  await writeUserLog("B", bookId, {
    user_content: userContent,
    score,
    total_score: totalScore,
    score100,
  });
};

const showDailyQuizModal = ref(false);
const dailyQuizQuestions = ref<Question[]>([]);
const dailyQuizTitle = ref("");
const dailyQuizLogContent = ref("");
const dailyQuizLogBookId = ref<string | number | bigint | null>(null);

const closeDailyQuizModal = () => {
  showDailyQuizModal.value = false;
  dailyQuizQuestions.value = [];
};

interface QuestionBookPayload {
  items?: Array<{ question?: Question }>;
}

const startQuiz = async (bookId: number | string | bigint) => {
  const book = books.value.find((item) => String(item.book_id) === String(bookId));
  void logBookAction(
    bookId,
    book
      ? `${getBookLogLabel(book)} 문제풀이 시작`
      : `문제집 #${String(bookId)} 문제풀이 시작`,
  );

  try {
    const payload = await $fetch<QuestionBookPayload>(`${apiBase.value}/question-books/${bookId}`, {
      headers: getAuthHeader(),
    });
    const items: any[] = payload?.items ?? [];
    const fetchedQuestions = items
      .map((item) => item.question)
      .filter((question): question is Question => Boolean(question));

    if (fetchedQuestions.length === 0) {
      alert("문제집에 담긴 문제가 없습니다.");
      return;
    }

    dailyQuizQuestions.value = fetchedQuestions;
    dailyQuizTitle.value = book
      ? `${book.book_name || "문제집"} 일괄 풀기`
      : "문제집 일괄 풀기";
    dailyQuizLogContent.value = book
      ? `${getBookLogLabel(book)} 일괄 풀이`
      : `문제집 #${String(bookId)} 일괄 풀이`;
    dailyQuizLogBookId.value = bookId;
    showDailyQuizModal.value = true;
  } catch (error) {
    console.error("문제집 문제 조회 실패:", error);
    alert("문제집 문제를 불러오는 중 오류가 발생했습니다.");
  }
};

const getBookLogLabel = (book: any) =>
  `문제집 #${String(book.book_id)} [${book.book_name || "제목 없음"}]`;

const isEditingBook = computed(() => editingBookId.value !== "");
const modalTitle = computed(() =>
  isEditingBook.value ? "문제집 수정" : "새 문제집 만들기",
);
const submitButtonLabel = computed(() =>
  isEditingBook.value ? "수정하기" : "생성하기",
);

const openCreateModal = () => {
  editingBookId.value = "";
  newBook.value = { book_name: "", description: "" };
  showCreateModal.value = true;
  void logBookAction(0, "문제집 생성 모달 열기");
};

const openEditModal = (book: any) => {
  editingBookId.value = String(book.book_id);
  newBook.value = {
    book_name: book.book_name || "",
    description: book.description || "",
  };
  showCreateModal.value = true;
  void logBookAction(book.book_id, `${getBookLogLabel(book)} 수정 모달 열기`);
};

const closeCreateModal = () => {
  editingBookId.value = "";
  showCreateModal.value = false;
};

const viewBookDetails = async (bookId: number | string | bigint) => {
  const book = books.value.find((item) => String(item.book_id) === String(bookId));
  await logBookAction(
    bookId,
    book ? `${getBookLogLabel(book)} 문제등록 화면 이동` : `문제집 #${String(bookId)} 문제등록 화면 이동`,
  );
  router.push({
    path: "/questions",
    query: { book: String(bookId) },
  });
};

const fetchBooks = async () => {
  loading.value = true;
  try {
    const data = await $fetch(`${apiBase.value}/question-books`, {
      headers: getAuthHeader(),
      query: { scope: listScope.value },
    });
    books.value = data as any[];
    selectedBookIds.value = [];
  } catch (err) {
    console.error("서버 통신 오류(fetch) books:", err);
  } finally {
    loading.value = false;
    currentPage.value = Math.min(currentPage.value, totalPages.value);
    sliderValue.value = currentPage.value;
  }
};

const submitBookForm = async (payload?: {
  form: { book_name: string; description: string };
}) => {
  const formData = payload?.form ?? newBook.value;
  try {
    if (isEditingBook.value) {
      await $fetch(`${apiBase.value}/question-books/${editingBookId.value}`, {
        method: "PATCH",
        headers: getAuthHeader(),
        body: formData,
      });
      await logBookAction(
        editingBookId.value,
        `문제집 #${String(editingBookId.value)} [${formData.book_name.trim()}] 수정 저장 완료`,
      );
    } else {
      const createdBook = (await $fetch(`${apiBase.value}/question-books`, {
        method: "POST",
        headers: getAuthHeader(),
        body: formData,
      })) as { book_id?: string | number };
      await logBookAction(
        createdBook?.book_id ?? 0,
        `문제집 #${String(createdBook?.book_id ?? 0)} [${formData.book_name.trim()}] 생성 저장 완료`,
      );
    }
    closeCreateModal();
    newBook.value = { book_name: "", description: "" };
    await fetchBooks();
  } catch (err) {
    alert(isEditingBook.value ? "문제집 수정 실패" : "문제집 생성 실패");
  }
};

const getBookIdKey = (bookId: number | string | bigint) => String(bookId);

const isBookSelected = (bookId: number | string | bigint) =>
  selectedBookIds.value.includes(getBookIdKey(bookId));

const toggleBookSelected = (
  bookId: number | string | bigint,
  checked: boolean,
) => {
  const idKey = getBookIdKey(bookId);
  if (checked) {
    if (!selectedBookIds.value.includes(idKey)) {
      selectedBookIds.value = [...selectedBookIds.value, idKey];
    }
    return;
  }
  selectedBookIds.value = selectedBookIds.value.filter((id) => id !== idKey);
};

const toggleBookSelectedByTitle = (book: any) => {
  if (!isCurrentUserOwner(book.creator?.user_no)) return;
  const nextChecked = !isBookSelected(book.book_id);
  toggleBookSelected(book.book_id, nextChecked);
  void logBookAction(
    book.book_id,
    `${getBookLogLabel(book)} 선택 ${nextChecked ? "추가" : "해제"}`,
  );
};

const deleteSelectedBooks = async () => {
  if (!canDeleteBooks.value) return;
  const ok = window.confirm(
    `선택한 문제집 ${selectedBookCount.value}개를 삭제하시겠습니까?`,
  );
  if (!ok) return;

  try {
    const result = (await $fetch(
      `${apiBase.value}/question-books/soft-delete`,
      {
        method: "PATCH",
        headers: getAuthHeader(),
        body: {
          bookIds: selectedBookIds.value,
        },
      },
    )) as { updatedCount?: number };

    const deletedCount = Number(result?.updatedCount ?? 0);
    if (deletedCount === 0) {
      alert("삭제할 수 있는 문제집이 없습니다.");
    }
    await logBookAction(
      0,
      `문제집 일괄 삭제 요청 완료: ${selectedBookCount.value}개 선택`,
      deletedCount,
      selectedBookCount.value,
      selectedBookCount.value > 0
        ? Math.round((deletedCount / selectedBookCount.value) * 100)
        : 0,
    );
    selectedBookIds.value = [];
    await fetchBooks();
  } catch (err) {
    console.error("문제집 삭제 오류:", err);
    alert("문제집 삭제 중 오류가 발생했습니다.");
  }
};

watch(
  listScope,
  async () => {
    currentPage.value = 1;
    sliderValue.value = 1;
    await fetchBooks();
  },
  { immediate: true },
);

const setScope = (scope: "mine" | "all") => {
  if (listScope.value === scope) return;
  void logBookAction(
    0,
    `문제집 목록 범위 전환: ${scope === "all" ? "전체 문제집" : "나의 문제집"}`,
  );
  listScope.value = scope;
};

onMounted(() => {
  void writeUserLogOncePerSession("dashboard-books-visit", "B", 0, {
    user_content: "문제집 관리 화면 진입",
    score: 1,
    total_score: 1,
    score100: 100,
  });
});
</script>

<template>
  <div class="book-manager">
    <div class="manager-header">
      <div class="header-copy">
        <div class="title-row">
          <h3><IconBook class="section-icon" /> {{ listTitle }}</h3>

          <div class="action-button-group">
            <button class="btn-create" @click="openCreateModal">
              <IconCreateAction class="btn-action-icon" />
              새 문제집
            </button>
            <button
              class="btn-delete"
              :disabled="!canDeleteBooks"
              @click="deleteSelectedBooks">
              <IconDeleteAction class="btn-action-icon" />
              삭제
            </button>
          </div>
        </div>
      </div>

      <CmmManagerNav active-page="books" />
    </div>

    <div v-if="loading" class="loading">불러오는 중...</div>
    <div v-else-if="filteredBooks.length === 0" class="empty">
      {{ emptyText }}
    </div>
    <div v-else>
      <div class="pagination-panel-border">
        <div class="slider-panel">
          <div class="search-row">
            <div
              v-if="showScopeToggle"
              class="scope-toggle"
              role="tablist"
              aria-label="문제집 범위 선택">
              <button
                type="button"
                class="scope-btn"
                :class="{ active: listScope === 'mine' }"
                :aria-pressed="listScope === 'mine'"
                @click="setScope('mine')">
                나의 문제집
              </button>
              <button
                type="button"
                class="scope-btn"
                :class="{ active: listScope === 'all' }"
                :aria-pressed="listScope === 'all'"
                @click="setScope('all')">
                전체 문제집
              </button>
            </div>
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
            <button
              v-if="searchQuery"
              class="btn-reset-search"
              @click="clearSearch">
              초기화
            </button>
          </div>
          <div class="slider-row">
            <span class="summary-text"
              >총 {{ filteredBooks.length }}개 문제집</span>
            <div class="page-slider-section">
              <CmmPageSlider
                v-model="sliderValue"
                :max="totalPages"
                :disabled="totalPages <= 1"
                postfix="페이지"
                @commit="commitSliderValue"
              />
            </div>
            <span class="range-text"
              >{{ pageStartItem }}-{{ pageEndItem }}번째 항목 표시 중</span>
          </div>
        </div>
      </div>
      <div class="book-grid">
        <div v-for="book in pagedBooks" :key="book.book_id" class="book-card">
          <div class="book-card-head">
            <div class="book-headline-left">
              <span class="book-id">{{ book.book_id }}</span>
              <p class="book-description">
                {{ book.description || "설명 없음" }}
              </p>
              <span
                v-if="
                  book.creator?.username &&
                  !isCurrentUserOwner(book.creator.user_no)
                "
                class="book-owner-badge"
                >{{ book.creator.username }}</span>
            </div>
            <div class="book-headline-right">
              <span class="book-count-badge">
                {{ book.items?.length || 0 }} 문제
              </span>
            </div>
          </div>
          <div class="book-card-body">
            <div class="book-main">
              <h4>
                <input
                  type="checkbox"
                  class="copy-checkbox"
                  aria-label="문제집 선택"
                  :checked="isBookSelected(book.book_id)"
                  :disabled="!isCurrentUserOwner(book.creator?.user_no)"
                  @change="
                    toggleBookSelected(
                      book.book_id,
                      ($event.target as HTMLInputElement).checked,
                    )
                  "
                />
                <span
                  class="book-title"
                  :class="{
                    selectable: isCurrentUserOwner(book.creator?.user_no),
                  }"
                  @click="toggleBookSelectedByTitle(book)">
                  {{ book.book_name }}
                </span>
              </h4>
            </div>
            <div
              v-if="isCurrentUserOwner(book.creator?.user_no)"
              class="book-card-actions">
              <button
                class="btn-view btn-card-action"
                @click="openEditModal(book)">
                수정
              </button>
              <button
                class="btn-start btn-card-action"
                @click="viewBookDetails(book.book_id)">
                문제등록
              </button>
              <button
                class="btn-start btn-card-action"
                @click="startQuiz(book.book_id)">
                문제풀기
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <QuestionBookUpsertModal
      :show="showCreateModal"
      :title="modalTitle"
      :submit-label="submitButtonLabel"
      :initial-form="newBook"
      @close="closeCreateModal"
      @submit="submitBookForm"
    />
    <CmmPlayQuestions
      v-if="showDailyQuizModal"
      :questions="dailyQuizQuestions"
      :title="dailyQuizTitle"
      log-type="B"
      :log-object-id="dailyQuizLogBookId"
      :log-content="dailyQuizLogContent"
      @close="closeDailyQuizModal"
    />
  </div>
</template>

<style scoped>
.book-manager {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}
.manager-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  width: 100%;
}
.header-copy {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
  flex: 1;
}
.title-row {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  flex-wrap: wrap;
}
.manager-header h3 {
  color: #f8fafc;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.35rem;
  font-size: 1.35rem;
  line-height: 1.2;
  font-weight: 800;
}

.section-icon {
  width: 1.4rem;
  height: 1.4rem;
  flex-shrink: 0;
}

.scope-toggle {
  display: inline-flex;
  gap: 2px;
  padding: 2px;
  border-radius: 6px;
  background: rgba(15, 23, 42, 0.55);
  border: 1px solid rgba(148, 163, 184, 0.14);
}

.scope-btn {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 0.9rem;
  font-weight: 700;
  border-radius: 10px;
  padding: 0 0.85rem;
  height: 32px;
  line-height: 32px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  transition: all 0.2s ease;
}

.scope-btn {
  border: none;
  background: transparent;
  color: #94a3b8;
  font-size: 0.75rem;
  font-weight: 700;
  border-radius: 4px;
  padding: 0.45rem 0.9rem;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.scope-btn.active {
  background: linear-gradient(135deg, #6366f1, #818cf8);
  color: #ffffff;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.35);
}

.scope-icon {
  width: 0.95rem;
  height: 0.95rem;
  flex-shrink: 0;
}

.action-button-group {
  display: flex !important;
  align-items: center !important;
  background: rgba(15, 23, 42, 0.4);
  padding: 4px;
  border-radius: 10px;
  border: 1px solid rgba(129, 140, 248, 0.2);
  backdrop-filter: blur(8px);
}

.btn-create,
.btn-delete {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  height: 32px;
  padding: 0 0.95rem;
  border: none;
  font-size: 0.9rem;
  font-weight: 700;
  line-height: 1;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.btn-create {
  background: linear-gradient(135deg, #6366f1, #818cf8);
  color: white;
  border-radius: 8px;
}

.btn-create:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4);
}

.btn-delete {
  background: transparent;
  color: #94a3b8;
  border-radius: 8px;
  margin-left: 2px;
}

.btn-delete:hover:not(:disabled) {
  background: rgba(239, 68, 68, 0.15);
  color: #f87171;
}

.btn-delete:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.btn-action-icon {
  width: 0.92rem;
  height: 0.92rem;
  flex-shrink: 0;
}

.book-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.625rem;
  margin-top: 1rem;
}

.book-card {
  background: rgba(30, 41, 59, 0.4);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 1.25rem 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
}

.book-card:hover {
  background: rgba(30, 41, 59, 0.4);
  transform: none;
  border-color: rgba(255, 255, 255, 0.05);
  box-shadow: none;
}

.book-card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.book-card-body {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.book-headline-left {
  display: flex;
  align-items: center;
  gap: 0.45rem;
}

.book-headline-right {
  display: inline-flex;
  align-items: center;
  justify-content: flex-end;
  margin-left: auto;
  flex-shrink: 0;
}

.book-card-body h4 {
  color: #f8fafc;
  margin: 0;
  font-size: 1.1rem;
  display: flex;
  align-items: center;
  gap: 0.15rem;
  width: 100%;
}

.book-id {
  font-size: 1.5rem !important;
  font-weight: 900 !important;
  color: #0055ff !important;
  margin: 0;
}

.book-title {
  color: #f8fafc;
}

.book-title.selectable {
  cursor: pointer;
}

.book-main {
  display: flex;
  flex-direction: column;
  gap: 0.22rem;
  min-width: 0;
  flex: 1;
}

.book-card-actions {
  margin-left: auto;
  display: inline-flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0;
  flex-shrink: 0;
  border-radius: 9px;
  overflow: hidden;
  border: 1px solid rgba(129, 140, 248, 0.24);
  background: rgba(15, 23, 42, 0.55);
}

.book-card-actions .btn-card-action + .btn-card-action {
  margin-left: -1px;
}

.book-card-actions .btn-card-action:first-child {
  border-top-right-radius: 0;
  border-bottom-right-radius: 0;
}

.book-card-actions .btn-card-action:not(:first-child):not(:last-child) {
  border-radius: 0;
}

.book-card-actions .btn-card-action:last-child {
  border-top-left-radius: 0;
  border-bottom-left-radius: 0;
}

.btn-card-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 72px;
  height: 34px;
  padding: 0 0.95rem;
  border-radius: 0;
  border: 1px solid rgba(129, 140, 248, 0.24);
  background: rgba(99, 102, 241, 0.1);
  color: #c7d2fe;
  font-size: 0.84rem;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
  transition:
    background 0.2s ease,
    border-color 0.2s ease,
    transform 0.2s ease;
}

.btn-card-action:hover {
  background: rgba(129, 140, 248, 0.18);
  border-color: rgba(129, 140, 248, 0.42);
  transform: translateY(-1px);
}


.copy-checkbox {
  width: 1.4rem;
  height: 1.4rem;
  -webkit-appearance: none;
  appearance: none;
  border: 1.9px solid rgba(148, 163, 184, 0.7);
  border-radius: 0.19rem;
  background: rgba(15, 23, 42, 0.55);
  box-shadow: inset 0 0 0 1px rgba(15, 23, 42, 0.35);
  cursor: pointer;
  position: relative;
  display: inline-flex;
  flex-shrink: 0;
  align-self: center;
  margin-right: 0.22rem;
}

.copy-checkbox:checked {
  border-color: #818cf8;
  background: rgba(99, 102, 241, 0.28);
}

.copy-checkbox:checked::after {
  content: "";
  position: absolute;
  left: 35%;
  top: 18%;
  width: 20%;
  height: 42%;
  border: solid #dbeafe;
  border-width: 0 0.18rem 0.18rem 0;
  transform: rotate(45deg);
}

.copy-checkbox:disabled {
  opacity: 0.42;
  cursor: not-allowed;
}

.book-description {
  color: #94a3b8;
  font-size: 0.85rem;
  margin: 0;
  line-height: 1.4;
  font-weight: 500;
}

.book-owner-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.16rem 0.55rem;
  border-radius: 10px;
  background: rgba(56, 189, 248, 0.12);
  border: 1px solid rgba(56, 189, 248, 0.2);
  color: #7dd3fc;
  font-size: 0.72rem;
  font-weight: 700;
  line-height: 1;
  white-space: nowrap;
}

.book-count-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 74px;
  min-width: 74px;
  max-width: 74px;
  flex: 0 0 74px;
  box-sizing: border-box;
  padding: 0.08rem 0.3rem;
  border-radius: 6px;
  background: rgba(129, 140, 248, 0.1);
  color: #818cf8;
  font-size: 0.72rem;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
  letter-spacing: -0.01em;
  cursor: pointer;
  transition: all 0.2s ease;
}

.book-count-badge:hover {
  background: rgba(129, 140, 248, 0.22);
  color: #ffffff;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
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
  box-sizing: border-box;
  overflow: hidden;
  position: relative;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 800;
  color: #fff;
}

.modal-close {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  width: 32px;
  height: 32px;
  border-radius: 8px;
  color: #94a3b8;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.9rem;
}

.modal-close:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  transform: scale(1.05);
}

.form-group {
  margin-bottom: 1.5rem;
  min-width: 0;
}
.form-group label {
  display: block;
  color: #94a3b8;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}
.form-group input,
.form-group textarea {
  width: 100%;
  background: rgba(0, 0, 0, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 0.8rem;
  color: white;
  box-sizing: border-box;
  max-width: 100%;
  outline: none;
  transition:
    border-color 0.2s,
    box-shadow 0.2s;
}

.form-group textarea {
  min-height: 96px;
  resize: vertical;
}

.form-group input:focus,
.form-group textarea:focus {
  border-color: rgba(99, 102, 241, 0.55);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.12);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  margin-top: 1rem;
}

.btn-secondary,
.btn-primary {
  padding: 0.6rem 1.5rem;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 700;
  transition:
    transform 0.2s,
    background 0.2s,
    border-color 0.2s,
    color 0.2s;
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.14);
  color: #cbd5e1;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.12);
  border-color: rgba(255, 255, 255, 0.22);
  color: #f8fafc;
}

.btn-primary {
  background: #6366f1;
  border: none;
  color: white;
}

.btn-primary:hover,
.btn-secondary:hover {
  transform: translateY(-1px);
}

.search-select,
.search-input {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 5px;
  color: #fff;
  padding: 0 0.7rem;
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

@media (max-width: 1024px) {
  .book-grid {
    grid-template-columns: 1fr;
  }
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
  top: 32px;
  transform: translateX(-50%);
  background: #6366f1;
  color: white;
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 800;
  pointer-events: none;
  white-space: nowrap;
  box-shadow:
    0 4px 6px -1px rgba(0, 0, 0, 0.1),
    0 2px 4px -1px rgba(0, 0, 0, 0.06);
  z-index: 10;
}

.slider-tooltip::after {
  content: "";
  position: absolute;
  top: -4px;
  left: 50%;
  transform: translateX(-50%);
  border-left: 4px solid transparent;
  border-right: 4px solid transparent;
  border-bottom: 4px solid #6366f1;
}

.loading,
.empty {
  text-align: center;
  padding: 3rem;
  color: #64748b;
}

.pagination-panel-border {
  border: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 10px;
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
