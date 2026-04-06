import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class ExamsService {
  constructor(private prisma: PrismaService) {}

  async create(
    creatorNo: bigint,
    data: {
      exam_name: string;
      description?: string;
      start_time: string;
      end_time: string;
      location?: string;
      is_auto_score?: boolean;
    },
  ) {
    return this.prisma.exam.create({
      data: {
        creator_no: creatorNo,
        exam_name: data.exam_name,
        description: data.description || null,
        start_time: new Date(data.start_time),
        end_time: new Date(data.end_time),
        location: data.location || null,
        is_auto_score: data.is_auto_score ?? true,
      },
      include: {
        creator: { select: { user_no: true, username: true } },
        class_exam_links: {
          include: {
            class: true,
          },
        },
        _count: { select: { questions: true } },
      },
    });
  }

  async update(
    examId: bigint,
    creatorNo: bigint,
    data: {
      exam_name: string;
      description?: string;
      start_time: string;
      end_time: string;
      location?: string;
      is_auto_score?: boolean;
    },
  ) {
    const existing = await this.prisma.exam.findFirst({
      where: {
        exam_id: examId,
        creator_no: creatorNo,
        is_deleted: 'N',
      },
      select: { exam_id: true },
    });

    if (!existing) {
      throw new NotFoundException('Exam not found');
    }

    return this.prisma.exam.update({
      where: { exam_id: examId },
      data: {
        exam_name: data.exam_name,
        description: data.description || null,
        start_time: new Date(data.start_time),
        end_time: new Date(data.end_time),
        location: data.location || null,
        is_auto_score: data.is_auto_score ?? true,
      },
      include: {
        creator: { select: { user_no: true, username: true } },
        class_exam_links: {
          include: {
            class: true,
          },
        },
        _count: { select: { questions: true } },
      },
    });
  }

  async findAll(userNo?: bigint, classId?: bigint) {
    const where: any = {
      is_deleted: 'N',
    };

    if (userNo) {
      where.creator_no = userNo;
    }

    if (classId) {
      where.class_exam_links = {
        some: {
          class_id: classId,
        },
      };
    }

    return this.prisma.exam.findMany({
      where,
      include: {
        creator: { select: { user_no: true, username: true } },
        class_exam_links: {
          include: {
            class: true,
          },
        },
        _count: { select: { questions: true } }
      },
      orderBy: { created_at: 'desc' },
    });
  }

  async findById(examId: bigint, userNo?: bigint) {
    const exam = await this.prisma.exam.findFirst({
      where: { exam_id: examId, is_deleted: 'N' },
      include: {
        creator: { select: { user_no: true, username: true } },
        class_exam_links: {
          include: {
            class: true,
          },
        },
        questions: {
          include: {
            question: true,
          },
          orderBy: {
            question_order: 'asc',
          },
        },
      },
    });

    if (!exam) throw new NotFoundException('Exam not found');

    return exam;
  }

  async removeMany(examIds: bigint[], creatorNo: bigint) {
    if (!examIds.length) {
      return { updatedCount: 0 };
    }

    const result = await this.prisma.exam.updateMany({
      where: {
        exam_id: { in: examIds },
        creator_no: creatorNo,
        is_deleted: 'N',
      },
      data: { is_deleted: 'Y' },
    });

    return { updatedCount: result.count };
  }

  async addItem(examId: bigint, userNo: bigint, questionId: bigint) {
    const exam = await this.prisma.exam.findFirst({
      where: { exam_id: examId, is_deleted: 'N' },
    });
    if (!exam) throw new NotFoundException('Exam not found');
    if (exam.creator_no !== userNo) throw new NotFoundException('Not authorized or not found');

    const lastItem = await this.prisma.examQuestion.findFirst({
      where: { exam_id: examId },
      orderBy: { question_order: 'desc' },
      select: { question_order: true }
    });
    const nextOrder = (lastItem?.question_order ?? 0) + 1;

    return this.prisma.examQuestion.upsert({
      where: {
        exam_id_question_id: {
          exam_id: examId,
          question_id: questionId,
        }
      },
      update: {}, // 이미 존재하면 아무것도 하지 않음
      create: {
        exam_id: examId,
        question_id: questionId,
        question_order: nextOrder,
      },
    });
  }

  async removeItem(examId: bigint, userNo: bigint, questionId: bigint) {
    const exam = await this.prisma.exam.findFirst({
      where: { exam_id: examId, is_deleted: 'N' },
    });
    if (!exam) throw new NotFoundException('Exam not found');
    if (exam.creator_no !== userNo) throw new NotFoundException('Not authorized or not found');

    return this.prisma.examQuestion.deleteMany({
      where: {
        exam_id: examId,
        question_id: questionId,
      },
    });
  }
}
