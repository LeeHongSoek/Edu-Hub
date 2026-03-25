import { QuestionBooksService } from './question-books.service';
export declare class QuestionBooksController {
    private readonly questionBooksService;
    constructor(questionBooksService: QuestionBooksService);
    create(req: any, body: any): Promise<{
        description: string | null;
        created_at: Date | null;
        user_no: bigint;
        book_id: bigint;
        book_name: string;
    }>;
    findMyBooks(req: any): Promise<({
        items: ({
            question: {
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
    update(req: any, id: string, body: any): Promise<{
        description: string | null;
        created_at: Date | null;
        user_no: bigint;
        book_id: bigint;
        book_name: string;
    }>;
    remove(req: any, id: string): Promise<{
        description: string | null;
        created_at: Date | null;
        user_no: bigint;
        book_id: bigint;
        book_name: string;
    }>;
    addItem(req: any, id: string, questionId: string): Promise<{
        question_id: bigint;
        book_id: bigint;
    }>;
    removeItem(req: any, id: string, qId: string): Promise<{
        question_id: bigint;
        book_id: bigint;
    }>;
}
