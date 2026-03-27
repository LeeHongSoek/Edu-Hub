import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

type FindAllParams = {
  creatorNo?: bigint;
  groupId?: bigint;
  searchField?: 'title' | 'content';
  searchKeyword?: string;
};

@Injectable()
export class QuestionsService {
  constructor(private prisma: PrismaService) {}

  // 모든 문제 목록 조회 API (필터링 지원)
  async findAll({ creatorNo, groupId, searchField, searchKeyword }: FindAllParams) {
    const where: any = {};
    if (creatorNo !== undefined) where.creator_no = creatorNo;

    if (groupId !== undefined) {
      const descendantGroupIds = await this.getDescendantGroupIds(groupId);
      where.group_id = {
        in: descendantGroupIds,
      };
    }

    if (searchKeyword) {
      where.AND = [
        ...(where.AND ?? []),
        this.buildSearchCondition(searchField ?? 'title', searchKeyword),
      ];
    }

    return this.prisma.question.findMany({
      where,
      orderBy: {
        question_id: 'desc',
      },
      include: {
        type: true,
        passage: true,
        options: {
          orderBy: {
            option_number: 'asc',
          },
        },
        group: {
          include: {
            parent_group: {
              include: {
                parent_group: true,
              },
            },
          },
        },
        tags: {
          include: {
            tag: true,
          },
        },
      },
    });
  }

  private async getDescendantGroupIds(groupId: bigint) {
    const groups = await this.prisma.group.findMany({
      select: {
        group_id: true,
        parent_group_id: true,
      },
    });

    const descendantIds: bigint[] = [];
    const queue: bigint[] = [groupId];

    while (queue.length > 0) {
      const currentGroupId = queue.shift();
      if (currentGroupId === undefined) continue;

      descendantIds.push(currentGroupId);

      const childGroups = groups.filter((group) => group.parent_group_id === currentGroupId);
      for (const childGroup of childGroups) {
        queue.push(childGroup.group_id);
      }
    }

    return descendantIds;
  }

  private buildSearchCondition(searchField: 'title' | 'content', searchKeyword: string) {
    if (searchField === 'content') {
      return {
        OR: [
          { question: { contains: searchKeyword } },
          { content: { contains: searchKeyword } },
          { passage: { is: { content_md: { contains: searchKeyword } } } },
        ],
      };
    }

    return {
      title: {
        contains: searchKeyword,
      },
    };
  }

  // 문제 생성
  async create(data: any) {
    const { options, ...questionData } = data;
    return this.prisma.$transaction(async (tx) => {
      const question = await tx.question.create({
        data: {
          ...questionData,
          passage: questionData.passage ? {
            create: {
              content_md: questionData.passage
            }
          } : undefined,
          options: options ? {
            create: options.map((opt: any) => ({
              option_number: opt.option_number,
              content: opt.content,
              is_answer: opt.is_answer,
            })),
          } : undefined,
        },
        include: { options: true, passage: true },
      });
      return question;
    });
  }

  // 문제 수정
  async update(id: string | number, data: any) {
    const { options, passage, ...questionData } = data;
    const questionId = typeof id === 'string' ? BigInt(id) : BigInt(id);

    return this.prisma.$transaction(async (tx) => {
      // 기존 옵션 삭제 후 재생성 (가장 단순한 동기화 전략)
      if (options) {
        await tx.questionOption.deleteMany({
          where: { question_id: questionId },
        });
      }

      // 지문 처리: 만약 passage 속성이 있으면 upsert
      if (passage !== undefined) {
        if (passage) {
          // 값이 있으면 upsert
          await tx.questionPassage.upsert({
            where: { question_id: questionId },
            update: { content_md: passage },
            create: { question_id: questionId, content_md: passage }
          });
        } else {
          // 값이 빈 문자열이거나 null이면 삭제
          await tx.questionPassage.deleteMany({
            where: { question_id: questionId }
          });
        }
      }

      return tx.question.update({
        where: { question_id: questionId },
        data: {
          ...questionData,
          options: options ? {
            create: options.map((opt: any) => ({
              option_number: opt.option_number,
              content: opt.content,
              is_answer: opt.is_answer,
            })),
          } : undefined,
        },
        include: { options: true, passage: true },
      });
    });
  }

  // 문제 삭제
  async remove(id: string | number) {
    const questionId = typeof id === 'string' ? BigInt(id) : BigInt(id);
    return this.prisma.question.delete({
      where: { question_id: questionId },
    });
  }

  // 리뷰 목록 조회
  async getReviews(questionId: string | number) {
    const qid = typeof questionId === 'string' ? BigInt(questionId) : BigInt(questionId);
    return this.prisma.questionReview.findMany({
      where: { question_id: qid },
      include: {
        user: { select: { username: true } },
      },
      orderBy: { review_id: 'desc' },
    });
  }

  // 리뷰 추가 및 평균 별점 갱신
  async addReview(questionId: string | number, data: any) {
    const qid = typeof questionId === 'string' ? BigInt(questionId) : BigInt(questionId);
    return this.prisma.$transaction(async (tx) => {
      const review = await tx.questionReview.create({
        data: {
          question_id: qid,
          user_no: data.user_no || 2, // 기본적으로 김철수(2)로 추가 (샘플용)
          content: data.content,
          rating: data.rating,
        },
      });

      // 전체 리뷰 평점 계산
      const aggregations = await tx.questionReview.aggregate({
        where: { question_id: qid },
        _avg: { rating: true },
      });

      const avgRating = Math.round(aggregations._avg.rating || 0);

      // 질문 메인의 rating 업데이트
      await tx.question.update({
        where: { question_id: qid },
        data: { rating: avgRating },
      });

      return review;
    });
  }
}
