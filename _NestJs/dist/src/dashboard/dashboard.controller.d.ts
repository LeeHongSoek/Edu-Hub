import { DashboardService } from './dashboard.service';
export declare class DashboardController {
    private readonly dashboardService;
    constructor(dashboardService: DashboardService);
    getDashboardStats(req: any): Promise<{}>;
    getRelations(req: any): Promise<({
        relation_type: {
            description: string;
            relation_type_id: string;
        };
        user2: {
            role_id: string;
            user_no: bigint;
            user_id: string;
            username: string;
        };
    } & {
        created_at: Date | null;
        relation_id: bigint;
        user_no_1: bigint;
        user_no_2: bigint;
        relation_type_id: string;
    })[]>;
    getMessages(req: any): Promise<({
        sender: {
            username: string;
        };
        receiver: {
            username: string;
        };
    } & {
        content: string;
        created_at: Date | null;
        message_id: bigint;
        sender_no: bigint;
        receiver_no: bigint;
        is_read: import("@prisma/client").$Enums.UserMessage_is_read | null;
    })[]>;
}
