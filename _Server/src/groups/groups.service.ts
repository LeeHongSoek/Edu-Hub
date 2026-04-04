import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class GroupsService {
  constructor(private prisma: PrismaService) {}

  // 최상위 그룹(depth 1)을 기준으로 하위 그룹들을 포함하여 조회
  // 최상위 그룹(depth 1)을 기준으로 하위 그룹들을 포함하여 조회
  async findAll(scope?: string, userNo?: string | number, viewerNo?: string | number, bookId?: string | number, examId?: string | number) {
    const selector = this.countSelector(scope, userNo, viewerNo, bookId, examId);
    
    // 메인 쿼리 필터 구성
    const mainWhere: any = { parent_group_id: null };
    const normalizedScope = String(scope || '').toLowerCase();
    
    // scope=mine일 경우 그룹 목록 자체도 로그인 사용자의 것만 필터링
    // 단, B, C 환경(문제집/고사 관리)에서는 다른 사람의 그룹에 속한 문항이 포함될 수 있으므로 필터를 해제함
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
    
    // B, C 환경에서 빈 그룹 필터링 로직 제거 (항상 전체를 보여달라는 요청 반영)
    /*
    if (bookId || examId) {
      const filterEmpty = (nodes: any[]): any[] => {
        return nodes
          .filter(node => node.question_total > 0)
          .map(node => {
            if (node.child_groups) {
              node.child_groups = filterEmpty(node.child_groups);
            }
            return node;
          });
      };
      hierarchy = filterEmpty(hierarchy);
    }
    */

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

  private countSelector(scope?: string, userNo?: string | number, viewerNo?: string | number, bookId?: string | number, examId?: string | number) {
    const where: any = { is_deleted: { not: 'Y' } };
    const normalizedScope = String(scope || '').toLowerCase();

    // 문제집/고사 컨텍스트 필터링이 있을 경우
    if (bookId !== undefined && bookId !== null || examId !== undefined && examId !== null) {
      // 사용자의 요청에 따라 B, C 환경의 사이드바는 항상 시스템 전체(내 문제 + 공개 문제)를 보여줌
      const orConditions: any[] = [{ is_public: true }];
      if (viewerNo !== undefined && viewerNo !== null) {
        orConditions.push({ creator_no: BigInt(viewerNo) });
      }
      where.OR = orConditions;
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
