import { GroupsService } from './groups.service';
export declare class GroupsController {
    private readonly groupsService;
    constructor(groupsService: GroupsService);
    findAll(): Promise<({
        child_groups: ({
            child_groups: {
                description: string | null;
                name: string;
                creator_no: bigint;
                group_id: bigint;
                created_at: Date | null;
                parent_group_id: bigint | null;
                depth: number | null;
            }[];
        } & {
            description: string | null;
            name: string;
            creator_no: bigint;
            group_id: bigint;
            created_at: Date | null;
            parent_group_id: bigint | null;
            depth: number | null;
        })[];
    } & {
        description: string | null;
        name: string;
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        parent_group_id: bigint | null;
        depth: number | null;
    })[]>;
    create(data: any): Promise<{
        description: string | null;
        name: string;
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        parent_group_id: bigint | null;
        depth: number | null;
    }>;
    update(id: string, data: any): Promise<{
        description: string | null;
        name: string;
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        parent_group_id: bigint | null;
        depth: number | null;
    }>;
    remove(id: string): Promise<{
        description: string | null;
        name: string;
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        parent_group_id: bigint | null;
        depth: number | null;
    }>;
}
