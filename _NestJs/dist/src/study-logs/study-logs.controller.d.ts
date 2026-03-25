import { StudyLogsService } from './study-logs.service';
export declare class StudyLogsController {
    private readonly studyLogsService;
    constructor(studyLogsService: StudyLogsService);
    create(req: any, body: {
        question_id: string;
        user_memo: string;
    }): Promise<{
        question_id: bigint;
        user_no: bigint;
        is_correct: boolean | null;
        log_id: bigint;
        user_memo: string | null;
        try_count: number | null;
        last_played_at: Date | null;
        next_review_at: Date | null;
    }>;
    findMyLogs(req: any): Promise<({
        question: {
            title: string;
        };
    } & {
        question_id: bigint;
        user_no: bigint;
        is_correct: boolean | null;
        log_id: bigint;
        user_memo: string | null;
        try_count: number | null;
        last_played_at: Date | null;
        next_review_at: Date | null;
    })[]>;
    findByQuestion(req: any, id: string): Promise<{
        question_id: bigint;
        user_no: bigint;
        is_correct: boolean | null;
        log_id: bigint;
        user_memo: string | null;
        try_count: number | null;
        last_played_at: Date | null;
        next_review_at: Date | null;
    }[]>;
}
