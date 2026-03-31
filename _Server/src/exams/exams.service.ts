import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class ExamsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userNo?: bigint) {
    return this.prisma.exam.findMany({
      where: userNo ? { creator_no: userNo } : {},
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
