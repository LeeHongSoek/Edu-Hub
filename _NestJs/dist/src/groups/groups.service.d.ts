import { PrismaService } from '../common/prisma/prisma.service';
export declare class GroupsService {
    private prisma;
    constructor(prisma: PrismaService);
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
    getHierarchy(): Promise<({
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
    update(id: string | number, data: any): Promise<{
        group_id: bigint;
        creator_no: bigint;
        parent_group_id: bigint | null;
        depth: number | null;
        name: string;
        description: string | null;
        created_at: Date | null;
    }>;
    remove(id: string | number): Promise<{
        group_id: bigint;
        creator_no: bigint;
        parent_group_id: bigint | null;
        depth: number | null;
        name: string;
        description: string | null;
        created_at: Date | null;
    }>;
}
