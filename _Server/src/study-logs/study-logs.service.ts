import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class StudyLogsService {
  constructor(private prisma: PrismaService) {}

  async create(userNo: bigint, questionId: bigint, userMemo: string) {
    return this.prisma.studyLog.create({
      data: {
        user_no: userNo,
        question_id: questionId,
        user_memo: userMemo,
        is_correct: false, // Default for activity logs
        try_count: 0,
      },
    });
  }

  async findByUser(userNo: bigint) {
    return this.prisma.studyLog.findMany({
      where: { user_no: userNo },
      include: {
        question: {
          select: {
            title: true,
          }
        }
      },
      orderBy: { last_played_at: 'desc' },
      take: 50,
    });
  }

  async findByQuestion(userNo: bigint, questionId: bigint) {
    return this.prisma.studyLog.findMany({
      where: {
        user_no: userNo,
        question_id: questionId,
      },
      orderBy: { last_played_at: 'desc' },
    });
  }
}
