import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class ExamsService {
  constructor(private prisma: PrismaService) {}

  private toDbLocalDate(date = new Date()) {
    return new Date(date.getTime() - date.getTimezoneOffset() * 60000);
  }

  private async writeExamLog(
    userNo: bigint,
    examId: bigint,
    userContent: string,
    score = 0,
    totalScore = 0,
    score100 = 0,
  ) {
    await this.prisma.userLog.create({
      data: {
        user_no: userNo,
        logtype: 'E',
        obj_id: examId,
        user_content: userContent,
        score,
        total_score: totalScore,
        score100,
        last_played_at: this.toDbLocalDate(),
      },
    });
  }

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
    const created = await this.prisma.exam.create({
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

    await this.writeExamLog(
      creatorNo,
      created.exam_id,
      `고사 #${created.exam_id.toString()} [${created.exam_name}] 생성`,
    );

    return created;
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

    const updated = await this.prisma.exam.update({
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

    await this.writeExamLog(
      creatorNo,
      updated.exam_id,
      `고사 #${updated.exam_id.toString()} [${updated.exam_name}] 수정`,
    );

    return updated;
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

    const ownedExams = await this.prisma.exam.findMany({
      where: {
        exam_id: { in: examIds },
        creator_no: creatorNo,
        is_deleted: 'N',
      },
      select: {
        exam_id: true,
        exam_name: true,
      },
    });

    const result = await this.prisma.exam.updateMany({
      where: {
        exam_id: { in: examIds },
        creator_no: creatorNo,
        is_deleted: 'N',
      },
      data: { is_deleted: 'Y' },
    });

    await Promise.all(
      ownedExams.map((exam) =>
        this.writeExamLog(
          creatorNo,
          exam.exam_id,
          `고사 #${exam.exam_id.toString()} [${exam.exam_name}] 삭제`,
        ),
      ),
    );

    return { updatedCount: result.count };
  }

  async addItem(examId: bigint, userNo: bigint, questionId: bigint) {
    const [exam, question] = await Promise.all([
      this.prisma.exam.findFirst({
        where: { exam_id: examId, is_deleted: 'N' },
      }),
      this.prisma.question.findUnique({
        where: { question_id: questionId },
        select: { title: true },
      }),
    ]);
    if (!exam) throw new NotFoundException('Exam not found');
    if (exam.creator_no !== userNo) throw new NotFoundException('Not authorized or not found');

    const lastItem = await this.prisma.examQuestion.findFirst({
      where: { exam_id: examId },
      orderBy: { question_order: 'desc' },
      select: { question_order: true }
    });
    const nextOrder = (lastItem?.question_order ?? 0) + 1;

    const result = await this.prisma.examQuestion.upsert({
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

    await this.writeExamLog(
      userNo,
      examId,
      `고사 #${examId.toString()} [${exam.exam_name}]에 문제 #${questionId.toString()} [${question?.title || '제목 없음'}] 등록`,
    );

    return result;
  }

  async removeItem(examId: bigint, userNo: bigint, questionId: bigint) {
    const [exam, question] = await Promise.all([
      this.prisma.exam.findFirst({
        where: { exam_id: examId, is_deleted: 'N' },
      }),
      this.prisma.question.findUnique({
        where: { question_id: questionId },
        select: { title: true },
      }),
    ]);
    if (!exam) throw new NotFoundException('Exam not found');
    if (exam.creator_no !== userNo) throw new NotFoundException('Not authorized or not found');

    const result = await this.prisma.examQuestion.deleteMany({
      where: {
        exam_id: examId,
        question_id: questionId,
      },
    });

    await this.writeExamLog(
      userNo,
      examId,
      `고사 #${examId.toString()} [${exam.exam_name}]에서 문제 #${questionId.toString()} [${question?.title || '제목 없음'}] 제거`,
    );

    return result;
  }
}
