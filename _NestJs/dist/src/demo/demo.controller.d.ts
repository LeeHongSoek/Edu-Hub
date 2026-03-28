import { DemoService } from './demo.service';
export declare class DemoController {
    private readonly demoService;
    constructor(demoService: DemoService);
    getDemo(id?: string, type?: string): {
        status: string;
        message: string;
        query: {
            id?: string;
            type?: string;
        };
        serverTime: string;
        totalSamples: number;
        samples: {
            id: number;
            title: string;
            description: string;
        }[];
    };
    postDemo(userId?: number, action?: string, timestamp?: string): {
        status: string;
        message: string;
        received: {
            userId?: number;
            action?: string;
            timestamp?: string;
        };
        processedAt: string;
    };
}
