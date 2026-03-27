import { OmbudsmanService } from './ombudsman.service';
export declare class OmbudsmanController {
    private readonly ombudsmanService;
    constructor(ombudsmanService: OmbudsmanService);
    create(req: any, body: any): Promise<{
        title: string;
        content: string;
        created_at: Date | null;
        user_no: bigint;
        report_id: bigint;
        category: import("@prisma/client").$Enums.Ombudsman_category;
        status: import("@prisma/client").$Enums.Ombudsman_status | null;
        updated_at: Date | null;
    }>;
    findMyReports(req: any): Promise<{
        title: string;
        content: string;
        created_at: Date | null;
        user_no: bigint;
        report_id: bigint;
        category: import("@prisma/client").$Enums.Ombudsman_category;
        status: import("@prisma/client").$Enums.Ombudsman_status | null;
        updated_at: Date | null;
    }[]>;
    update(req: any, id: string, body: any): Promise<{
        title: string;
        content: string;
        created_at: Date | null;
        user_no: bigint;
        report_id: bigint;
        category: import("@prisma/client").$Enums.Ombudsman_category;
        status: import("@prisma/client").$Enums.Ombudsman_status | null;
        updated_at: Date | null;
    }>;
    remove(req: any, id: string): Promise<{
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
