import { ExamsService } from './exams.service';
export declare class ExamsController {
    private readonly examsService;
    constructor(examsService: ExamsService);
    findAll(req: any): Promise<({
        _count: {
            questions: number;
        };
        class: {
            created_at: Date | null;
            class_id: bigint;
            teacher_no: bigint;
            class_name: string;
        } | null;
        creator: {
            username: string;
        };
    } & {
        creator_no: bigint;
        created_at: Date | null;
        exam_id: bigint;
        class_id: bigint | null;
        exam_name: string;
        start_time: Date;
        end_time: Date;
        location: string | null;
        is_auto_score: boolean | null;
    })[]>;
}
