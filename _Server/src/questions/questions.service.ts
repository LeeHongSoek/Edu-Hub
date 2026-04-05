import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

type FindAllParams = {
  creatorNo?: bigint;
  groupId?: bigint;
  bookId?: bigint;
  examId?: bigint;
  excludeBookId?: bigint;
  excludeExamId?: bigint;
  publicOnly?: boolean;
  viewerNo?: bigint;
  searchField?: 'title' | 'content' | 'id';
  searchKeyword?: string;
  page?: number;
  limit?: number;
};

@Injectable()
export class QuestionsService {
  constructor(private prisma: PrismaService) {}

  // 모든 문제 목록 조회 API (필터링 지원)
  async findAll({ 
    creatorNo, groupId, bookId, examId, excludeBookId, excludeExamId,
    publicOnly, viewerNo, searchField, searchKeyword, page = 1, limit = 10 
  }: FindAllParams) {
    const where: any = {};
    // Only fetch parent questions for list view
    where.p_question_id = null;
    where.is_deleted = 'N';
    if (creatorNo !== undefined) {
      where.creator_no = creatorNo;
    } else if (publicOnly) {
      if (viewerNo !== undefined) {
        // '그외 문제'는 공개 문제 중 내 문제를 제외하고 노출
        where.is_public = true;
        where.creator_no = { not: viewerNo };
      } else {
        where.is_public = true;
      }
    }

    if (groupId !== undefined) {
      const gId = BigInt(groupId);
      if (gId === BigInt(-1)) {
        // '전체': 필터 없음 (모두 노출)
        delete where.group_id;
      } else if (gId === BigInt(0)) {
        // '문제분류 없음': 정확히 group_id 0인 것만 노출
        where.group_id = BigInt(0);
      } else {
        const descendantGroupIds = await this.getDescendantGroupIds(groupId);
        where.group_id = {
          in: descendantGroupIds,
        };
      }
    }

    const safePage = Number.isFinite(page) && page > 0 ? Math.floor(page) : 1;
    const safeLimit = Number.isFinite(limit) && limit > 0 ? Math.min(Math.floor(limit), 100) : 10;
    const skip = (safePage - 1) * safeLimit;

    let questionIds: bigint[] | null = null;

    if (examId !== undefined) {
      const examItems = await this.prisma.examQuestion.findMany({
        where: { exam_id: examId },
        select: { question_id: true },
      });
      const ids = examItems.map((item) => item.question_id);
      questionIds = mergeIds(questionIds, ids);
    }

    if (bookId !== undefined) {
      const questionItems = await this.prisma.questionBookItem.findMany({
        where: { book_id: bookId },
        select: { question_id: true },
      });
      const ids = questionItems.map((item) => item.question_id);
      questionIds = mergeIds(questionIds, ids);
    }

    if (questionIds !== null) {
      if (questionIds.length === 0) {
        return {
          items: [],
          total: 0,
          page: safePage,
          limit: safeLimit,
          totalPages: 1,
        };
      }
      where.question_id = { in: questionIds };
    }

    // --- [Exclusion Logic] ---
    let excludedIds: bigint[] = [];
    if (excludeBookId !== undefined) {
      const items = await this.prisma.questionBookItem.findMany({
        where: { book_id: excludeBookId },
        select: { question_id: true }
      });
      excludedIds = [...excludedIds, ...items.map(i => i.question_id)];
    }
    if (excludeExamId !== undefined) {
      const items = await this.prisma.examQuestion.findMany({
        where: { exam_id: excludeExamId },
        select: { question_id: true }
      });
      excludedIds = [...excludedIds, ...items.map(i => i.question_id)];
    }

    if (excludedIds.length > 0) {
      if (where.question_id) {
        // 만약 이미 IN 조건이 있다면
        where.question_id = { ...where.question_id, notIn: excludedIds };
      } else {
        where.question_id = { notIn: excludedIds };
      }
    }
    // -------------------------

    function mergeIds(existing: bigint[] | null, next: bigint[]): bigint[] {
      if (!existing) return next;
      const set = new Set(existing);
      return next.filter((id) => set.has(id));
    }

    if (searchKeyword) {
      where.AND = [
        ...(where.AND ?? []),
        this.buildSearchCondition(searchField ?? 'title', searchKeyword),
      ];
    }

    const [total, items] = await this.prisma.$transaction([
      this.prisma.question.count({ where }),
      this.prisma.question.findMany({
        where,
        skip,
        take: safeLimit,
        orderBy: {
          question_id: 'desc',
        },
        include: {
          type: true,
          creator: {
            select: {
              username: true,
            },
          },
          children: {
            orderBy: {
              question_id: 'asc',
            },
            include: {
              type: true,
              passage: true,
              group: {
                include: {
                  parent_group: {
                    include: {
                      parent_group: true,
                    },
                  },
                },
              },
              options: {
                orderBy: {
                  option_number: 'asc',
                },
              },
            },
          },
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
      }),
    ]);

    return {
      items,
      total,
      page: safePage,
      limit: safeLimit,
      totalPages: Math.max(1, Math.ceil(total / safeLimit)),
    };
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

  private buildSearchCondition(searchField: 'title' | 'content' | 'id', searchKeyword: string) {
    if (searchField === 'id') {
      try {
        const id = BigInt(searchKeyword.trim());
        return {
          question_id: id,
        };
      } catch {
        // 숫자가 아닌 경우 검색 결과가 없도록 처리
        return { question_id: -1 };
      }
    }

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

  // 문제 복사해서 새 문제로 저장
  async copy(id: string | number, targetUserNo: bigint) {
    const questionId = typeof id === 'string' ? BigInt(id) : BigInt(id);
    const source = await this.prisma.question.findUnique({
      where: { question_id: questionId },
      include: {
        passage: true,
        options: {
          orderBy: {
            option_number: 'asc',
          },
        },
        attachments: {
          orderBy: {
            sort_order: 'asc',
          },
        },
        tags: true,
      },
    });

    if (!source) {
      throw new NotFoundException('복사할 문제를 찾을 수 없습니다.');
    }

    const copiedQuestion = await this.prisma.$transaction(async (tx) => {
      const created = await tx.question.create({
        data: {
          creator_no: targetUserNo,
          group_id: source.group_id,
          question_type_id: source.question_type_id,
          title: source.title,
          question: source.question,
          content: source.content,
          answer: source.answer,
          explanation: source.explanation,
          hint: source.hint,
          difficulty: source.difficulty,
          is_public: source.is_public,
          is_deleted: 'N',
          time_limit: source.time_limit,
          rating: source.rating,
          passage: source.passage
            ? {
                create: {
                  content_md: source.passage.content_md,
                },
              }
            : undefined,
          options: source.options.length
            ? {
                create: source.options.map((opt: any) => ({
                  option_number: opt.option_number,
                  content: opt.content,
                  is_answer: opt.is_answer,
                })),
              }
            : undefined,
        },
      });

      if (source.attachments.length > 0) {
        await tx.mediaAttachment.createMany({
          data: source.attachments.map((attachment) => ({
            question_id: created.question_id,
            media_type_id: attachment.media_type_id,
            media_url: attachment.media_url,
            sort_order: attachment.sort_order,
          })),
        });
      }

      if (source.tags.length > 0) {
        await tx.questionTag.createMany({
          data: source.tags.map((tagLink) => ({
            question_id: created.question_id,
            tag_id: tagLink.tag_id,
          })),
        });
      }

      return tx.question.findUnique({
        where: { question_id: created.question_id },
        include: {
          type: true,
          creator: {
            select: {
              username: true,
            },
          },
          passage: true,
          options: {
            orderBy: {
              option_number: 'asc',
            },
          },
          attachments: {
            orderBy: {
              sort_order: 'asc',
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
    });

    return copiedQuestion;
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
    return this.prisma.question.update({
      where: { question_id: questionId },
      data: { is_deleted: 'Y' },
    });
  }

  async removeMany(questionIds: bigint[], userNo: bigint) {
    if (!questionIds.length) {
      return { updatedCount: 0 };
    }

    const result = await this.prisma.question.updateMany({
      where: {
        question_id: { in: questionIds },
        creator_no: userNo,
        is_deleted: 'N',
      },
      data: { is_deleted: 'Y' },
    });

    return { updatedCount: result.count };
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
