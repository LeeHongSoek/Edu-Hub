import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class UserLogsService {
  constructor(private prisma: PrismaService) {}

  private async resolveLogTitle(log: {
    logtype: string;
    obj_id: bigint;
    user_no: bigint;
  }) {
    if (log.logtype === 'Q') {
      if (log.obj_id === BigInt(0)) return '문제 활동';
      const q = await this.prisma.question.findUnique({
        where: { question_id: log.obj_id },
        select: { title: true },
      });
      return q?.title || 'Unknown Question';
    }

    if (log.logtype === 'B') {
      if (log.obj_id === BigInt(0)) return '임시 문제집';
      const b = await this.prisma.questionBook.findUnique({
        where: { book_id: log.obj_id },
        select: { book_name: true },
      });
      return b?.book_name || 'Unknown Book';
    }

    if (log.logtype === 'E') {
      if (log.obj_id === BigInt(0)) return '고사 영역';
      const e = await this.prisma.exam.findUnique({
        where: { exam_id: log.obj_id },
        select: { exam_name: true },
      });
      return e?.exam_name || 'Unknown Exam';
    }

    if (log.logtype === 'C') {
      if (log.obj_id === BigInt(0)) return '클래스 영역';
      const classroom = await this.prisma.class.findUnique({
        where: { class_id: log.obj_id },
        select: { class_name: true },
      });
      return classroom?.class_name || 'Unknown Class';
    }

    if (log.logtype === 'R') {
      if (log.obj_id === BigInt(0)) return '관계 활동';
      const otherUser = await this.prisma.user.findUnique({
        where: { user_no: log.obj_id },
        select: { username: true, user_id: true },
      });
      return otherUser
        ? `${otherUser.username} (${otherUser.user_id})`
        : 'Unknown Relation';
    }

    if (log.logtype === 'L') {
      return '로그인 / 접속';
    }

    return 'Unknown Item';
  }

  async create(userNo: bigint, logtype: string, objId: bigint, data: { user_content?: string, score?: number, total_score?: number, score100?: number }) {
    return this.prisma.userLog.create({
      data: {
        user_no: userNo,
        logtype: logtype,
        obj_id: objId,
        user_content: data.user_content || '',
        score: data.score || 0,
        total_score: data.total_score || 0,
        score100: data.score100 || 0,
        last_played_at: new Date(),
      },
    });
  }

  async findByUser(
    userNo: bigint, 
    logtype?: string, 
    search?: string, 
    page: number = 1, 
    limit: number = 10
  ) {
    const where: any = { user_no: userNo };
    
    if (logtype && logtype !== 'all') {
      where.logtype = logtype;
    }
    
    if (search) {
      where.user_content = { contains: search };
    }

    const [logs, total] = await Promise.all([
      this.prisma.userLog.findMany({
        where,
        include: {
          type: true,
        },
        orderBy: { last_played_at: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.userLog.count({ where }),
    ]);

    // Resolve titles for polymorphic obj_id (only for paginated items)
    const resolvedLogs = await Promise.all(
      logs.map(async (log) => {
        const title = await this.resolveLogTitle(log);
        return {
          ...log,
          title,
        };
      })
    );

    return {
      items: resolvedLogs,
      total,
    };
  }

  async findByObject(userNo: bigint, logtype: string, objId: bigint) {
    return this.prisma.userLog.findMany({
      where: {
        user_no: userNo,
        logtype: logtype,
        obj_id: objId,
      },
      orderBy: { last_played_at: 'desc' },
    });
  }
}
