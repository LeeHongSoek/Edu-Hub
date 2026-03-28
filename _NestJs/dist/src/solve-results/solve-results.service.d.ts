import { PrismaService } from '../common/prisma/prisma.service';
export declare class SolveResultsService {
    private prisma;
    constructor(prisma: PrismaService);
    create(userNo: bigint, questionId: bigint, correctAnswer: string, submittedAnswer: string, isCorrect: number, timeTaken: number): Promise<{
        exam_id: bigint | null;
        question_id: bigint;
        user_no: bigint;
        result_id: bigint;
        correct_answer: string;
        submitted_answer: string | null;
        is_correct: number;
        time_taken: number;
        solved_at: Date | null;
    }>;
    findByUser(userNo: bigint): Promise<({
        question: {
            question: string;
            title: string;
            content: string | null;
            question_id: bigint;
            creator_no: bigint;
            group_id: bigint | null;
            question_type_id: string;
            answer: string;
            explanation: string | null;
            hint: string | null;
            difficulty: number | null;
            is_public: boolean | null;
            is_deleted: import("@prisma/client").$Enums.IsDeleted | null;
            time_limit: number | null;
            rating: number | null;
            created_at: Date | null;
        };
    } & {
        exam_id: bigint | null;
        question_id: bigint;
        user_no: bigint;
        result_id: bigint;
        correct_answer: string;
        submitted_answer: string | null;
        is_correct: number;
        time_taken: number;
        solved_at: Date | null;
    })[]>;
    findByQuestion(questionId: bigint): Promise<({
        user: {
            role_id: string;
            created_at: Date | null;
            user_no: bigint;
            user_id: string;
            user_pw: string;
            username: string;
            email: string;
            is_withdrawn: import("@prisma/client").$Enums.IsWithdrawn | null;
        };
    } & {
        exam_id: bigint | null;
        question_id: bigint;
        user_no: bigint;
        result_id: bigint;
        correct_answer: string;
        submitted_answer: string | null;
        is_correct: number;
        time_taken: number;
        solved_at: Date | null;
    })[]>;
    findOne(resultId: bigint): Promise<({
        user: {
            role_id: string;
            created_at: Date | null;
            user_no: bigint;
            user_id: string;
            user_pw: string;
            username: string;
            email: string;
            is_withdrawn: import("@prisma/client").$Enums.IsWithdrawn | null;
        };
        question: {
            question: string;
            title: string;
            content: string | null;
            question_id: bigint;
            creator_no: bigint;
            group_id: bigint | null;
            question_type_id: string;
            answer: string;
            explanation: string | null;
            hint: string | null;
            difficulty: number | null;
            is_public: boolean | null;
            is_deleted: import("@prisma/client").$Enums.IsDeleted | null;
            time_limit: number | null;
            rating: number | null;
            created_at: Date | null;
        };
    } & {
        exam_id: bigint | null;
        question_id: bigint;
        user_no: bigint;
        result_id: bigint;
        correct_answer: string;
        submitted_answer: string | null;
        is_correct: number;
        time_taken: number;
        solved_at: Date | null;
    }) | null>;
    getStatsByUser(userNo: bigint): Promise<{
        totalCount: number;
        correctCount: number;
        wrongCount: number;
        timeoutCount: number;
        accuracyRate: number;
        totalTime: number;
        averageTime: number;
    }>;
}
