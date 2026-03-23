import { StatsService } from './stats.service';
export declare class StatsController {
    private readonly statsService;
    constructor(statsService: StatsService);
    getStats(): Promise<{
        questions: number;
        teachers: number;
        students: number;
        parents: number;
        totalUsers: number;
    }>;
}
