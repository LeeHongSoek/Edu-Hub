import { PrismaService } from '../common/prisma/prisma.service';
export declare class GroupsService {
    private prisma;
    constructor(prisma: PrismaService);
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
    getHierarchy(): Promise<({
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
    update(id: string | number, data: any): Promise<{
        description: string | null;
        name: string;
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        parent_group_id: bigint | null;
        depth: number | null;
    }>;
    remove(id: string | number): Promise<{
        description: string | null;
        name: string;
        creator_no: bigint;
        group_id: bigint;
        created_at: Date | null;
        parent_group_id: bigint | null;
        depth: number | null;
    }>;
}
