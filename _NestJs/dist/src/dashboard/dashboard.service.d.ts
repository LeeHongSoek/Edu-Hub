import { PrismaService } from '../common/prisma/prisma.service';
export declare class DashboardService {
    private prisma;
    constructor(prisma: PrismaService);
    getStats(userNo: bigint, roleId: string): Promise<{}>;
    private getStudentStats;
    private getTeacherStats;
    private getParentStats;
    getRelations(userNo: bigint): Promise<({
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
    getMessages(userNo: bigint): Promise<({
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
