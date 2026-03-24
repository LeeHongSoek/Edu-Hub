import { QuestionsService } from './questions.service';
export declare class QuestionsController {
    private readonly questionsService;
    constructor(questionsService: QuestionsService);
    findAll(): Promise<({
        group: ({
            parent_group: ({
                parent_group: {
                    description: string | null;
                    name: string;
                    creator_no: bigint;
                    group_id: bigint;
                    created_at: Date | null;
                    parent_group_id: bigint | null;
                    depth: number | null;
                } | null;
            } & {
                description: string | null;
                name: string;
                creator_no: bigint;
                group_id: bigint;
                created_at: Date | null;
                parent_group_id: bigint | null;
                depth: number | null;
            }) | null;
        } & {
            description: string | null;
            name: string;
            creator_no: bigint;
            group_id: bigint;
            created_at: Date | null;
            parent_group_id: bigint | null;
            depth: number | null;
        }) | null;
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
        type: {
            description: string;
            type_id: string;
            type_name: string;
        };
        passage: {
            question_id: bigint;
            passage_id: bigint;
            content_md: string;
        } | null;
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
        rating: number | null;
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
        passage: {
            question_id: bigint;
            passage_id: bigint;
            content_md: string;
        } | null;
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
        rating: number | null;
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
        passage: {
            question_id: bigint;
            passage_id: bigint;
            content_md: string;
        } | null;
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
        rating: number | null;
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
        rating: number | null;
        created_at: Date | null;
    }>;
    getReviews(id: string): Promise<({
        user: {
            username: string;
        };
    } & {
        question_id: bigint;
        content: string;
        rating: number;
        created_at: Date | null;
        review_id: bigint;
        user_no: bigint;
    })[]>;
    addReview(id: string, data: any): Promise<{
        question_id: bigint;
        content: string;
        rating: number;
        created_at: Date | null;
        review_id: bigint;
        user_no: bigint;
    }>;
}
