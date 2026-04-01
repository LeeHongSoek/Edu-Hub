import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class GroupsService {
  constructor(private prisma: PrismaService) {}

  // 최상위 그룹(depth 1)을 기준으로 하위 그룹들을 포함하여 조회
  async findAll(scope?: string, userNo?: string | number, viewerNo?: string | number) {
    const groups = await this.prisma.group.findMany({
      where: {
        parent_group_id: null,
      },
      include: {
        _count: { select: this.countSelector(scope, userNo, viewerNo) },
        child_groups: {
          include: {
            _count: { select: this.countSelector(scope, userNo, viewerNo) },
            child_groups: {
              include: {
                _count: { select: this.countSelector(scope, userNo, viewerNo) },
                child_groups: {
                  include: {
                    _count: { select: this.countSelector(scope, userNo, viewerNo) },
                  },
                },
              },
            },
          },
        },
      },
    });

    return this.attachCounts(groups);
  }

  async getHierarchy(scope?: string, userNo?: string | number, viewerNo?: string | number) {
    const groups = await this.prisma.group.findMany({
      where: {
        parent_group_id: null,
      },
      include: {
        _count: { select: this.countSelector(scope, userNo, viewerNo) },
        child_groups: {
          include: {
            _count: { select: this.countSelector(scope, userNo, viewerNo) },
            child_groups: {
              include: {
                _count: { select: this.countSelector(scope, userNo, viewerNo) },
                child_groups: {
                  include: {
                    _count: { select: this.countSelector(scope, userNo, viewerNo) },
                  },
                },
              },
            },
          },
        },
      },
    });

    return this.attachCounts(groups);
  }

  private attachCounts(groups: any[]): any[] {
    const compute = (node: any): number => {
      const own = node?._count?.questions ?? 0;
      const children = Array.isArray(node?.child_groups)
        ? node.child_groups.reduce((sum: number, child: any) => sum + compute(child), 0)
        : 0;
      node.question_count = own;
      node.question_total = own + children;
      return node.question_total;
    };

    groups.forEach((g) => compute(g));
    return groups;
  }

  private countSelector(scope?: string, userNo?: string | number, viewerNo?: string | number) {
    const where: any = { is_deleted: { not: 'Y' } };
    const normalizedScope = String(scope || '').toLowerCase();

    if (normalizedScope === 'mine' && userNo !== undefined && userNo !== null) {
      where.creator_no = BigInt(userNo);
    } else if (normalizedScope === 'all') {
      where.is_public = true;
      if (viewerNo !== undefined && viewerNo !== null) {
        where.creator_no = { not: BigInt(viewerNo) };
      }
    }

    return { questions: { where } };
  }

  // 그룹 생성
  async create(data: any) {
    return this.prisma.group.create({
      data: {
        ...data,
        depth: data.depth || 1,
      },
    });
  }

  // 그룹 수정
  async update(id: string | number, data: any) {
    const groupId = typeof id === 'string' ? BigInt(id) : BigInt(id);
    return this.prisma.group.update({
      where: { group_id: groupId },
      data,
    });
  }

  // 그룹 삭제
  async remove(id: string | number) {
    const groupId = typeof id === 'string' ? BigInt(id) : BigInt(id);
    return this.prisma.group.delete({
      where: { group_id: groupId },
    });
  }
}
