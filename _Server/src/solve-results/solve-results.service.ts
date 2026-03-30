import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class SolveResultsService {
  constructor(private prisma: PrismaService) {}

  async create(
    userNo: bigint,
    questionId: bigint,
    correctAnswer: string,
    submittedAnswer: string,
    isCorrect: number,
    timeTaken: number,
  ) {
    return this.prisma.solveResult.create({
      data: {
        user_no: userNo,
        question_id: questionId,
        correct_answer: correctAnswer,
        submitted_answer: submittedAnswer,
        is_correct: isCorrect,
        time_taken: timeTaken,
        solved_at: new Date(),
      },
    });
  }

  async findByUser(userNo: bigint) {
    return this.prisma.solveResult.findMany({
      where: {
        user_no: userNo,
      },
      include: {
        question: true,
      },
      orderBy: {
        solved_at: 'desc',
      },
    });
  }

  async findByQuestion(questionId: bigint) {
    return this.prisma.solveResult.findMany({
      where: {
        question_id: questionId,
      },
      include: {
        user: true,
      },
      orderBy: {
        solved_at: 'desc',
      },
    });
  }

  async findOne(resultId: bigint) {
    return this.prisma.solveResult.findUnique({
      where: {
        result_id: resultId,
      },
      include: {
        question: true,
        user: true,
      },
    });
  }

  async getStatsByUser(userNo: bigint) {
    const results = await this.prisma.solveResult.findMany({
      where: {
        user_no: userNo,
      },
    });

    const totalCount = results.length;
    const correctCount = results.filter((r) => r.is_correct === 1).length;
    const wrongCount = results.filter((r) => r.is_correct === 0).length;
    const timeoutCount = results.filter((r) => r.is_correct === -1).length;
    const accuracyRate = totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
    const totalTime = results.reduce((sum, r) => sum + r.time_taken, 0);

    return {
      totalCount,
      correctCount,
      wrongCount,
      timeoutCount,
      accuracyRate: Math.round(accuracyRate * 100) / 100,
      totalTime,
      averageTime: totalCount > 0 ? Math.round(totalTime / totalCount) : 0,
    };
  }
}
