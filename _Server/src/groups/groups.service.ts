import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class GroupsService {
  constructor(private prisma: PrismaService) {}

  /**
   * 그룹 계층 구조 및 문항 수를 조회합니다.
   */
  async findAll(scope?: string, userNo?: string | number, viewerNo?: string | number, bookId?: string | number, examId?: string | number) {
    const selector = this.countSelector(scope, userNo, viewerNo, bookId, examId);
    
    // 메인 쿼리 필터: 최상위 그룹부터 조회
    const mainWhere: any = { parent_group_id: null, is_deleted: { not: 'Y' } };
    const normalizedScope = String(scope || '').toLowerCase();
    
    // A 환경의 '나의 문제' 탭에서만 그룹 목록을 내 것으로 한정함
    // B, C 환경이나 A의 '전체' 탭에서는 모든 사용자의 그룹을 탐색할 수 있어야 함
    if (normalizedScope === 'mine' && userNo !== undefined && userNo !== null && !bookId && !examId) {
      mainWhere.creator_no = BigInt(userNo);
    }

    const groups = await this.prisma.group.findMany({
      where: mainWhere,
      include: {
        _count: { select: selector },
        child_groups: {
          include: {
            _count: { select: selector },
            child_groups: {
              include: {
                _count: { select: selector },
                child_groups: {
                  include: {
                    _count: { select: selector },
                  },
                },
              },
            },
          },
        },
      },
    });

    let hierarchy = this.attachCounts(groups);
    
    // 문항이 0개인 그룹(접근 권한이 없는 타인의 그룹 등)은 숨겨서 목록을 깔끔하게 유지
    const filterEmpty = (nodes: any[]): any[] => {
      return nodes
        .filter(node => node.question_total > 0)
        .map(node => {
          const newNode = { ...node };
          if (newNode.child_groups) {
            newNode.child_groups = filterEmpty(newNode.child_groups);
          }
          return newNode;
        });
    };
    hierarchy = filterEmpty(hierarchy);

    const unassignedCount = await this.getUnassignedCount(scope, userNo, viewerNo, bookId, examId);

    return {
      groups: hierarchy,
      unassigned_count: unassignedCount
    };
  }

  async getHierarchy(scope?: string, userNo?: string | number, viewerNo?: string | number, bookId?: string | number, examId?: string | number) {
    return this.findAll(scope, userNo, viewerNo, bookId, examId);
  }

  private async getUnassignedCount(scope?: string, userNo?: string | number, viewerNo?: string | number, bookId?: string | number, examId?: string | number) {
    const selector = this.countSelector(scope, userNo, viewerNo, bookId, examId);
    const where = { ...selector.questions.where, group_id: null, p_question_id: null };
    return this.prisma.question.count({ where });
  }

  /**
   * 재귀적으로 하위 그룹의 문항 수를 합산하여 처리합니다.
   */
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

  /**
   * 상황별 문항 집계 필터를 생성합니다.
   */
  private countSelector(scope?: string, userNo?: string | number, viewerNo?: string | number, bookId?: string | number, examId?: string | number) {
    const where: any = { is_deleted: { not: 'Y' } };
    const normalizedScope = String(scope || '').toLowerCase();

    // 1. 컨텍스트별 우선순위 결정
    if (bookId !== undefined && bookId !== null || examId !== undefined && examId !== null) {
      // [B, C 환경: 문제집/고사 관리]
      // 사용자의 요청에 따라 사이드바는 항상 '전체 사용자 라이브러리(내 문제 + 모든 공개 문제)'를 집계함
      const orConditions: any[] = [{ is_public: true }];
      if (viewerNo !== undefined && viewerNo !== null) {
        orConditions.push({ creator_no: BigInt(viewerNo) });
      }
      where.OR = orConditions;
    } else {
      // [A 환경: 메인 관리]
      if (normalizedScope === 'mine' && userNo !== undefined && userNo !== null) {
        where.creator_no = BigInt(userNo);
      } else if (normalizedScope === 'all') {
        where.is_public = true;
        if (viewerNo !== undefined && viewerNo !== null) {
          // 타인의 공개 문항 중심(Discover)
          where.creator_no = { not: BigInt(viewerNo) };
        }
      }
    }

    return { questions: { where } };
  }

  async create(data: any) {
    return this.prisma.group.create({
      data: {
        ...data,
        depth: data.depth || 1,
      },
    });
  }

  async update(id: string | number, data: any) {
    const groupId = typeof id === 'string' ? BigInt(id) : BigInt(id);
    return this.prisma.group.update({
      where: { group_id: groupId },
      data,
    });
  }

  async remove(id: string | number) {
    const groupId = typeof id === 'string' ? BigInt(id) : BigInt(id);
    return this.prisma.group.delete({
      where: { group_id: groupId },
    });
  }
}
