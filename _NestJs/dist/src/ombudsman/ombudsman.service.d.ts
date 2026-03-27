import { PrismaService } from '../common/prisma/prisma.service';
export declare class OmbudsmanService {
    private prisma;
    constructor(prisma: PrismaService);
    create(userNo: bigint, data: any): Promise<{
        title: string;
        content: string;
        created_at: Date | null;
        user_no: bigint;
        report_id: bigint;
        category: import("@prisma/client").$Enums.Ombudsman_category;
        status: import("@prisma/client").$Enums.Ombudsman_status | null;
        updated_at: Date | null;
    }>;
    findByUser(userNo: bigint): Promise<{
        title: string;
        content: string;
        created_at: Date | null;
        user_no: bigint;
        report_id: bigint;
        category: import("@prisma/client").$Enums.Ombudsman_category;
        status: import("@prisma/client").$Enums.Ombudsman_status | null;
        updated_at: Date | null;
    }[]>;
    update(reportId: bigint, userNo: bigint, data: any): Promise<{
        title: string;
        content: string;
        created_at: Date | null;
        user_no: bigint;
        report_id: bigint;
        category: import("@prisma/client").$Enums.Ombudsman_category;
        status: import("@prisma/client").$Enums.Ombudsman_status | null;
        updated_at: Date | null;
    }>;
    remove(reportId: bigint, userNo: bigint): Promise<{
        title: string;
        content: string;
        created_at: Date | null;
        user_no: bigint;
        report_id: bigint;
        category: import("@prisma/client").$Enums.Ombudsman_category;
        status: import("@prisma/client").$Enums.Ombudsman_status | null;
        updated_at: Date | null;
    }>;
}
