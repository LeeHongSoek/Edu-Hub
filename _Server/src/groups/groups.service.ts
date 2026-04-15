import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class GroupsService {
  constructor(private prisma: PrismaService) { }

  async findAll(scope?: string, userNo?: string | number, viewerNo?: string | number, bookId?: string | number, examId?: string | number) {
    const normalizedScope = String(scope || '').toLowerCase();
    const groupWhere: any = {};
    const contextQuestionIds = await this.loadContextQuestionIds(bookId, examId);
    const selector = this.countSelector(
      scope,
      userNo,
      viewerNo,
      bookId,
      examId,
      contextQuestionIds,
    );

    if (normalizedScope === 'mine' && userNo !== undefined && userNo !== null && !bookId && !examId) {
      groupWhere.OR = [
        { creator_no: BigInt(userNo) },
        { creator_no: BigInt(0) },
      ];
    }

    const flatGroups = await this.prisma.group.findMany({
      where: groupWhere,
      include: {
        _count: { select: selector },
      },
      orderBy: [
        { depth: 'asc' },
        { group_id: 'asc' },
      ],
    });

    let hierarchy = this.attachCounts(this.buildHierarchy(flatGroups));

    if (normalizedScope === 'mine' && userNo !== undefined && userNo !== null && !bookId && !examId) {
      const ownerNo = BigInt(userNo);
      const [ownedTotal, unassignedTotal] = await Promise.all([
        this.prisma.question.count({
          where: {
            creator_no: ownerNo,
            p_question_id: null,
            is_deleted: { not: 'Y' },
          },
        }),
        this.prisma.question.count({
          where: {
            creator_no: ownerNo,
            group_id: { in: [BigInt(0)] },
            p_question_id: null,
            is_deleted: { not: 'Y' },
          },
        }),
      ]);

      const overrideSystemCounts = (group: any): any => {
        const groupId = Number(group.group_id);
        const nextChildren = (group.child_groups ?? []).map((child: any) => overrideSystemCounts(child));

        if (groupId === -1) {
          return {
            ...group,
            child_groups: nextChildren,
            question_count: ownedTotal,
            question_total: ownedTotal,
          };
        }
        if (groupId === 0) {
          return {
            ...group,
            child_groups: nextChildren,
            question_count: unassignedTotal,
            question_total: unassignedTotal,
          };
        }
        return {
          ...group,
          child_groups: nextChildren,
        };
      };

      hierarchy = hierarchy.map((group) => overrideSystemCounts(group));
    }

    return {
      groups: hierarchy,
    };
  }

  async getHierarchy(scope?: string, userNo?: string | number, viewerNo?: string | number, bookId?: string | number, examId?: string | number) {
    return this.findAll(scope, userNo, viewerNo, bookId, examId);
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

  private buildHierarchy(groups: any[]): any[] {
    const keptGroups = groups
      .filter((group) => {
        if (BigInt(group.creator_no) !== BigInt(0)) return true;
        return Number(group.group_id) === -1 || Number(group.group_id) === 0;
      })
      .map((group) => ({
        ...group,
        child_groups: [],
      }));

    const byId = new Map<string, any>();
    keptGroups.forEach((group) => {
      byId.set(String(group.group_id), group);
    });

    const roots: any[] = [];

    for (const group of keptGroups) {
      const parentId = group.parent_group_id;
      if (parentId === null || parentId === undefined) {
        roots.push(group);
        continue;
      }

      const parent = byId.get(String(parentId));
      if (!parent) {
        roots.push(group);
        continue;
      }

      parent.child_groups.push(group);
    }

    const sortNodes = (nodes: any[]) => {
      nodes.sort((a, b) => this.compareGroups(a, b));
      nodes.forEach((node) => sortNodes(node.child_groups ?? []));
    };

    sortNodes(roots);

    const wholeRoot = byId.get('-1');
    if (!wholeRoot) return roots;

    return [wholeRoot];
  }

  private compareGroups(a: any, b: any) {
    const gidA = Number(a.group_id);
    const gidB = Number(b.group_id);

    if (gidA === -1) return -1;
    if (gidB === -1) return 1;

    if (gidA === 0) return -1;
    if (gidB === 0) return 1;

    return gidA - gidB;
  }

  private async loadContextQuestionIds(bookId?: string | number, examId?: string | number) {
    if (bookId !== undefined && bookId !== null) {
      const items = await this.prisma.questionBookItem.findMany({
        where: { book_id: BigInt(bookId) },
        select: { question_id: true },
      });
      return items.map((item) => item.question_id);
    }

    if (examId !== undefined && examId !== null) {
      const items = await this.prisma.examQuestion.findMany({
        where: { exam_id: BigInt(examId) },
        select: { question_id: true },
      });
      return items.map((item) => item.question_id);
    }

    return [];
  }

  private countSelector(
    scope?: string,
    userNo?: string | number,
    viewerNo?: string | number,
    bookId?: string | number,
    examId?: string | number,
    contextQuestionIds: bigint[] = [],
  ) {
    const where: any = {
      is_deleted: { not: 'Y' },
      p_question_id: null,
    };
    const normalizedScope = String(scope || '').toLowerCase();

    // 문제집/고사 컨텍스트 필터링이 있을 경우
    if (bookId !== undefined && bookId !== null || examId !== undefined && examId !== null) {
      if (normalizedScope === 'mine') {
        where.question_id = { in: contextQuestionIds };
      } else {
        const orConditions: any[] = [{ is_public: true }];
        if (viewerNo !== undefined && viewerNo !== null) {
          orConditions.push({ creator_no: BigInt(viewerNo) });
        }
        where.OR = orConditions;
        if (contextQuestionIds.length > 0) {
          where.question_id = { notIn: contextQuestionIds };
        }
      }
    } else {
      // 컬렉션 환경이 아닐 때만 기존 scope 필터 적용
      if (normalizedScope === 'mine' && userNo !== undefined && userNo !== null) {
        where.creator_no = BigInt(userNo);
      } else if (normalizedScope === 'all') {
        where.is_public = true;
        if (viewerNo !== undefined && viewerNo !== null) {
          where.creator_no = { not: BigInt(viewerNo) };
        }
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
