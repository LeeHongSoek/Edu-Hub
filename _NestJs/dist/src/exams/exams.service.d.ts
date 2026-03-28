import { PrismaService } from '../common/prisma/prisma.service';
export declare class ExamsService {
    private prisma;
    constructor(prisma: PrismaService);
    findAll(userNo?: bigint): Promise<({
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
        exam_id: bigint;
        creator_no: bigint;
        created_at: Date | null;
        class_id: bigint | null;
        exam_name: string;
        start_time: Date;
        end_time: Date;
        location: string | null;
        is_auto_score: boolean | null;
    })[]>;
    findById(examId: bigint, userNo?: bigint): Promise<{
        class: {
            created_at: Date | null;
            class_id: bigint;
            teacher_no: bigint;
            class_name: string;
        } | null;
        creator: {
            username: string;
        };
        questions: ({
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
            exam_id: bigint;
            question_id: bigint;
            question_order: number;
            score: number | null;
        })[];
    } & {
        exam_id: bigint;
        creator_no: bigint;
        created_at: Date | null;
        class_id: bigint | null;
        exam_name: string;
        start_time: Date;
        end_time: Date;
        location: string | null;
        is_auto_score: boolean | null;
    }>;
}
