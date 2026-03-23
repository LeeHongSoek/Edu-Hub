import { PrismaService } from '../common/prisma/prisma.service';
export declare class GroupsService {
    private prisma;
    constructor(prisma: PrismaService);
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
    getHierarchy(): Promise<({
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
}
