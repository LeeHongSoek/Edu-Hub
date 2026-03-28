type DemoQuery = {
    id?: string;
    type?: string;
};
type DemoPostBody = {
    userId?: number;
    action?: string;
    timestamp?: string;
};
export declare class DemoService {
    getStatus(query: DemoQuery): {
        status: string;
        message: string;
        query: DemoQuery;
        serverTime: string;
        totalSamples: number;
        samples: {
            id: number;
            title: string;
            description: string;
        }[];
    };
    createAction(payload: DemoPostBody): {
        status: string;
        message: string;
        received: DemoPostBody;
        processedAt: string;
    };
}
export {};
