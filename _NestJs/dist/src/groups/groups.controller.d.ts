import { GroupsService } from './groups.service';
export declare class GroupsController {
    private readonly groupsService;
    constructor(groupsService: GroupsService);
    findAll(): Promise<({
        child_groups: ({
            child_groups: {
                creator_no: bigint;
                group_id: bigint;
                created_at: Date | null;
                name: string;
                parent_group_id: bigint | null;
                depth: number | null;
                description: string | null;
            }[];
        } & {
            creator_no: bigint;
            group_id: bigint;
            created_at: Date | null;
            name: string;
            parent_group_id: bigint | null;
            depth: number | null;
            description: string | null;
        })[];
    } & {
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        name: string;
        parent_group_id: bigint | null;
        depth: number | null;
        description: string | null;
    })[]>;
    create(data: any): Promise<{
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        name: string;
        parent_group_id: bigint | null;
        depth: number | null;
        description: string | null;
    }>;
    update(id: string, data: any): Promise<{
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        name: string;
        parent_group_id: bigint | null;
        depth: number | null;
        description: string | null;
    }>;
    remove(id: string): Promise<{
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        name: string;
        parent_group_id: bigint | null;
        depth: number | null;
        description: string | null;
    }>;
}
