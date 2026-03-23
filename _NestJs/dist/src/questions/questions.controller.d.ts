import { QuestionsService } from './questions.service';
export declare class QuestionsController {
    private readonly questionsService;
    constructor(questionsService: QuestionsService);
    findAll(): Promise<({
        options: {
            question_id: bigint;
            content: string;
            option_number: number;
            option_id: bigint;
            is_answer: boolean | null;
        }[];
        tags: ({
            tag: {
                created_at: Date | null;
                tag_id: bigint;
                tag_name: string;
            };
        } & {
            question_id: bigint;
            tag_id: bigint;
        })[];
        group: ({
            parent_group: ({
                parent_group: {
                    creator_no: bigint;
                    group_id: bigint;
                    created_at: Date | null;
                    name: string;
                    parent_group_id: bigint | null;
                    depth: number | null;
                    description: string | null;
                } | null;
            } & {
                creator_no: bigint;
                group_id: bigint;
                created_at: Date | null;
                name: string;
                parent_group_id: bigint | null;
                depth: number | null;
                description: string | null;
            }) | null;
        } & {
            creator_no: bigint;
            group_id: bigint;
            created_at: Date | null;
            name: string;
            parent_group_id: bigint | null;
            depth: number | null;
            description: string | null;
        }) | null;
        type: {
            description: string;
            type_id: string;
            type_name: string;
        };
    } & {
        question: string;
        question_id: bigint;
        creator_no: bigint;
        group_id: bigint | null;
        question_type_id: string;
        title: string;
        content: string | null;
        answer: string;
        explanation: string | null;
        hint: string | null;
        difficulty: number | null;
        is_public: boolean | null;
        is_deleted: import("@prisma/client").$Enums.IsDeleted | null;
        time_limit: number | null;
        created_at: Date | null;
    })[]>;
    create(createQuestionDto: any): Promise<{
        options: {
            question_id: bigint;
            content: string;
            option_number: number;
            option_id: bigint;
            is_answer: boolean | null;
        }[];
    } & {
        question: string;
        question_id: bigint;
        creator_no: bigint;
        group_id: bigint | null;
        question_type_id: string;
        title: string;
        content: string | null;
        answer: string;
        explanation: string | null;
        hint: string | null;
        difficulty: number | null;
        is_public: boolean | null;
        is_deleted: import("@prisma/client").$Enums.IsDeleted | null;
        time_limit: number | null;
        created_at: Date | null;
    }>;
    update(id: string, updateQuestionDto: any): Promise<{
        options: {
            question_id: bigint;
            content: string;
            option_number: number;
            option_id: bigint;
            is_answer: boolean | null;
        }[];
    } & {
        question: string;
        question_id: bigint;
        creator_no: bigint;
        group_id: bigint | null;
        question_type_id: string;
        title: string;
        content: string | null;
        answer: string;
        explanation: string | null;
        hint: string | null;
        difficulty: number | null;
        is_public: boolean | null;
        is_deleted: import("@prisma/client").$Enums.IsDeleted | null;
        time_limit: number | null;
        created_at: Date | null;
    }>;
    remove(id: string): Promise<{
        question: string;
        question_id: bigint;
        creator_no: bigint;
        group_id: bigint | null;
        question_type_id: string;
        title: string;
        content: string | null;
        answer: string;
        explanation: string | null;
        hint: string | null;
        difficulty: number | null;
        is_public: boolean | null;
        is_deleted: import("@prisma/client").$Enums.IsDeleted | null;
        time_limit: number | null;
        created_at: Date | null;
    }>;
}
