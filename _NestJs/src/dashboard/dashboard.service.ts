import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) { }

  async getStats(userNo: bigint, roleId: string) {
    if (roleId === 'S') {
      return this.getStudentStats(userNo);
    } else if (roleId === 'T') {
      return this.getTeacherStats(userNo);
    } else if (roleId === 'P') {
      return this.getParentStats(userNo);
    }
    return {};
  }

  private async getStudentStats(userNo: bigint) {
    // 학생 통계: 최근 7일간 푼 문제 수, 정답률 등
    const now = new Date();
    const ago7d = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    const solveResults = await this.prisma.solveResult.findMany({
      where: {
        user_no: userNo,
        solved_at: { gte: ago7d },
      },
    });

    const recentSolvedCount = solveResults.length;
    const correctOnes = solveResults.filter((r) => r.is_correct).length;
    const accuracy = recentSolvedCount > 0 ? Math.round((correctOnes / recentSolvedCount) * 100) : 0;

    // 일별 푼 문제 수 (최근 7일)
    const dailyStats: { date: string; count: number }[] = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now);
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      const count = solveResults.filter((r) => r.solved_at?.toISOString().split('T')[0] === dateStr).length;
      dailyStats.push({ date: dateStr, count });
    }

    return {
      totalViewed: await this.prisma.studyLog.count({
        where: {
          user_no: userNo,
          user_memo: '문제보기',
        },
      }),
      totalSolved: await this.prisma.studyLog.count({
        where: {
          user_no: userNo,
          user_memo: '문제풀기',
        },
      }),
      accuracy,
      dailyStats,
      studyLogs: await this.prisma.studyLog.count({
        where: {
          user_no: userNo,
          is_correct: false,
        },
      }),
    };
  }

  private async getTeacherStats(userNo: bigint) {
    // 선생님 통계: 담당 학급 수, 학생 수, 본인이 만든 문제 수
    const [classes, studentCount, myQuestions] = await Promise.all([
      this.prisma.class.findMany({ where: { teacher_no: userNo } }),
      this.prisma.classStudent.count({
        where: { class: { teacher_no: userNo } },
      }),
      this.prisma.question.count({ where: { creator_no: userNo } }),
    ]);

    return {
      classCount: classes.length,
      studentCount,
      myQuestions,
    };
  }

  private async getParentStats(userNo: bigint) {
    // 학부모 통계: 연결된 자녀 리스트 및 자녀의 최근 학습 요약
    const childrenRelations = await this.prisma.userRelation.findMany({
      where: {
        user_no_1: userNo,
        relation_type_id: 'PARENT_CHILD',
      },
      include: {
        user2: {
          select: {
            user_no: true,
            username: true,
            solve_results: {
              take: 5,
              orderBy: { solved_at: 'desc' },
            },
          },
        },
      },
    });

    return childrenRelations.map((rel) => ({
      studentNo: rel.user2.user_no.toString(),
      studentName: rel.user2.username,
      recentSolveCount: rel.user2.solve_results.length,
    }));
  }

  async getRelations(userNo: bigint) {
    return this.prisma.userRelation.findMany({
      where: { user_no_1: userNo },
      include: {
        user2: {
          select: {
            user_no: true,
            user_id: true,
            username: true,
            role_id: true,
          },
        },
        relation_type: true,
      },
    });
  }

  async getMessages(userNo: bigint) {
    return this.prisma.userMessage.findMany({
      where: {
        OR: [{ sender_no: userNo }, { receiver_no: userNo }],
      },
      include: {
        sender: { select: { username: true } },
        receiver: { select: { username: true } },
      },
      orderBy: { created_at: 'desc' },
    });
  }
}
