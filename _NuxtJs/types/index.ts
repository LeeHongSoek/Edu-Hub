export interface QuestionType {
  type_id: string; // 유형 ID (M: 객관식, S: 주관식 등)
  type_name: string; // 유형 이름
  description: string;
}

export interface QuestionOption {
  option_id: string | number; // 보기 고유 ID
  question_id: string | number; // 문제 ID
  option_number: number; // 보기 번호 (1, 2, 3...)
  content: string; // 보기 내용
  is_answer: boolean; // 정답 여부
}

export interface Question {
  question_id: string | number; // 문제 고유 ID
  creator_no: string | number; // 생성자 고유 번호
  group_id: string | number | null; // 소속 그룹 ID
  question_type_id: string; // 문제 유형 ID (M: 객관식, S: 주관식)
  title: string; // 문제 제목
  question: string; // 문제 지문 (마크다운/라텍스 지원)
  content: string | null; // 추가 지문 또는 설명
  answer: string; // 주관식 정답 또는 참고용 정답
  explanation: string | null; // 풀이 및 해설
  hint: string | null; // 힌트
  difficulty: number | null; // 난이도 (1-5)
  is_public: boolean | null; // 공개 여부
  is_deleted: string | null; // 삭제 여부 (Y/N/T)
  time_limit: number | null; // 제한 시간 (초)
  rating: number | null; // 평점 (1-5)
  created_at: string | null; // 생성일시
  type: QuestionType; // 관계: 문제 유형
  group?: Group; // 관계: 소속 그룹
  passage?: { content_md: string }; // 관계: 마크다운 지문 (1:1)
  options?: QuestionOption[]; // 관계: 보기 목록 (객관식용)
  reviews?: QuestionReview[]; // 관계: 리뷰 목록
}

export interface QuestionListResponse {
  items: Question[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface Group {
  group_id: string | number; // 그룹 고유 ID
  name: string; // 그룹 이름
  description: string | null; // 그룹 설명
  parent_group_id: string | number | null; // 상위 그룹 ID
  depth: number | null; // 계층 깊이 (1-3)
  child_groups?: Group[]; // 관계: 하위 그룹 리스트
  parent_group?: Group; // 관계: 상위 그룹 정보
}

export interface QuestionReview {
  review_id: string | number; // 리뷰 고유 ID
  question_id: string | number; // 대상 문제 ID
  user_no: string | number; // 작성자 ID
  content: string; // 리뷰 내용
  rating: number; // 부여한 평점 (1-5)
  created_at: string; // 작성일시
  user?: {
    username: string;
  };
}
