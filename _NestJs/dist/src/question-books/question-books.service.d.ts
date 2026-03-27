import { PrismaService } from '../common/prisma/prisma.service';
export declare class QuestionBooksService {
    private prisma;
    constructor(prisma: PrismaService);
    create(userNo: bigint, data: any): Promise<{
        description: string | null;
        created_at: Date | null;
        user_no: bigint;
        book_id: bigint;
        book_name: string;
    }>;
    findByUser(userNo: bigint): Promise<({
        items: ({
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
            question_id: bigint;
            book_id: bigint;
        })[];
    } & {
        description: string | null;
        created_at: Date | null;
        user_no: bigint;
        book_id: bigint;
        book_name: string;
    })[]>;
    update(bookId: bigint, userNo: bigint, data: any): Promise<{
        description: string | null;
        created_at: Date | null;
        user_no: bigint;
        book_id: bigint;
        book_name: string;
    }>;
    remove(bookId: bigint, userNo: bigint): Promise<{
        description: string | null;
        created_at: Date | null;
        user_no: bigint;
        book_id: bigint;
        book_name: string;
    }>;
    addItem(bookId: bigint, userNo: bigint, questionId: bigint): Promise<{
        question_id: bigint;
        book_id: bigint;
    }>;
    removeItem(bookId: bigint, userNo: bigint, questionId: bigint): Promise<{
        question_id: bigint;
        book_id: bigint;
    }>;
}
