export interface QuestionType {
  type_id: string;
  type_name: string;
  description: string;
}

export interface Question {
  question_id: string | number;
  creator_no: string | number;
  group_id: string | number | null;
  question_type_id: string;
  title: string;
  question: string;
  content: string | null;
  answer: string;
  explanation: string | null;
  hint: string | null;
  difficulty: number | null;
  is_public: boolean | null;
  is_deleted: string | null;
  time_limit: number | null;
  created_at: string | null;
  type: QuestionType;
}
