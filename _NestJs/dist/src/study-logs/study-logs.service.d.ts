import { PrismaService } from '../common/prisma/prisma.service';
export declare class StudyLogsService {
    private prisma;
    constructor(prisma: PrismaService);
    create(userNo: bigint, questionId: bigint, userMemo: string): Promise<{
        question_id: bigint;
        user_no: bigint;
        user_memo: string | null;
        is_correct: boolean | null;
        log_id: bigint;
        try_count: number | null;
        last_played_at: Date | null;
        next_review_at: Date | null;
    }>;
    findByUser(userNo: bigint): Promise<({
        question: {
            title: string;
        };
    } & {
        question_id: bigint;
        user_no: bigint;
        user_memo: string | null;
        is_correct: boolean | null;
        log_id: bigint;
        try_count: number | null;
        last_played_at: Date | null;
        next_review_at: Date | null;
    })[]>;
    findByQuestion(userNo: bigint, questionId: bigint): Promise<{
        question_id: bigint;
        user_no: bigint;
        user_memo: string | null;
        is_correct: boolean | null;
        log_id: bigint;
        try_count: number | null;
        last_played_at: Date | null;
        next_review_at: Date | null;
    }[]>;
}
