import { PrismaService } from '../common/prisma/prisma.service';
export declare class QuestionsService {
    private prisma;
    constructor(prisma: PrismaService);
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
    create(data: any): Promise<{
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
        rating: number | null;
        created_at: Date | null;
    }>;
    update(id: string | number, data: any): Promise<{
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
        rating: number | null;
        created_at: Date | null;
    }>;
    remove(id: string | number): Promise<{
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
    getReviews(questionId: string | number): Promise<({
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
    addReview(questionId: string | number, data: any): Promise<{
        question_id: bigint;
        content: string;
        rating: number;
        created_at: Date | null;
        review_id: bigint;
        user_no: bigint;
    }>;
}
