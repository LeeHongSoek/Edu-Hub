import { GroupsService } from './groups.service';
export declare class GroupsController {
    private readonly groupsService;
    constructor(groupsService: GroupsService);
    findAll(): Promise<({
        child_groups: ({
            child_groups: {
                group_id: bigint;
                creator_no: bigint;
                parent_group_id: bigint | null;
                depth: number | null;
                name: string;
                description: string | null;
                created_at: Date | null;
            }[];
        } & {
            group_id: bigint;
            creator_no: bigint;
            parent_group_id: bigint | null;
            depth: number | null;
            name: string;
            description: string | null;
            created_at: Date | null;
        })[];
    } & {
        group_id: bigint;
        creator_no: bigint;
        parent_group_id: bigint | null;
        depth: number | null;
        name: string;
        description: string | null;
        created_at: Date | null;
    })[]>;
    create(data: any): Promise<{
        group_id: bigint;
        creator_no: bigint;
        parent_group_id: bigint | null;
        depth: number | null;
        name: string;
        description: string | null;
        created_at: Date | null;
    }>;
    update(id: string, data: any): Promise<{
        group_id: bigint;
        creator_no: bigint;
        parent_group_id: bigint | null;
        depth: number | null;
        name: string;
        description: string | null;
        created_at: Date | null;
    }>;
    remove(id: string): Promise<{
        group_id: bigint;
        creator_no: bigint;
        parent_group_id: bigint | null;
        depth: number | null;
        name: string;
        description: string | null;
        created_at: Date | null;
    }>;
}
