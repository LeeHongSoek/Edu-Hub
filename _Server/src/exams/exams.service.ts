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
      class_id?: string;
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
        class_id: data.class_id ? BigInt(data.class_id) : null,
      },
      include: {
        creator: { select: { user_no: true, username: true } },
        class: true,
        _count: { select: { questions: true } },
      },
    });
  }

  async findAll(userNo?: bigint, classId?: bigint) {
    const where: any = {};

    if (userNo) {
      where.creator_no = userNo;
    }

    if (classId) {
      where.class_id = classId;
    }

    return this.prisma.exam.findMany({
      where,
      include: {
        creator: { select: { user_no: true, username: true } },
        class: true,
        _count: { select: { questions: true } }
      },
      orderBy: { created_at: 'desc' },
    });
  }

  async findById(examId: bigint, userNo?: bigint) {
    const exam = await this.prisma.exam.findUnique({
      where: { exam_id: examId },
      include: {
        creator: { select: { user_no: true, username: true } },
        class: true,
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
}
