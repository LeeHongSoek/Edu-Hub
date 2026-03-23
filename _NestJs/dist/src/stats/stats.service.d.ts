import { PrismaService } from '../common/prisma/prisma.service';
export declare class StatsService {
    private prisma;
    constructor(prisma: PrismaService);
    getStats(): Promise<{
        questions: number;
        teachers: number;
        students: number;
        parents: number;
        totalUsers: number;
    }>;
}
