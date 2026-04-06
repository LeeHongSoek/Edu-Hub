import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class UserLogsService {
  constructor(private prisma: PrismaService) { }

  private toDbLocalDate(date = new Date()) {
    return new Date(date.getTime() - date.getTimezoneOffset() * 60000);
  }

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

    if (log.logtype === 'V') {
      return '화면 / 버튼 활동';
    }

    return 'Unknown Item';
  }

  async create(userNo: bigint, logtype: string, objId: bigint, data: { user_content?: string, score?: number, total_score?: number, score100?: number, time_taken?: number }) {
    const timestamp = this.toDbLocalDate();

    return this.prisma.userLog.create({
      data: {
        user_no: userNo,
        logtype: logtype,
        obj_id: objId,
        user_content: data.user_content || '',
        score: data.score || 0,
        total_score: data.total_score || 0,
        score100: data.score100 || 0,
        time_taken: data.time_taken || 0,
        created_at: timestamp,
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

    const filters = [
      Prisma.sql`user_no = ${userNo}`,
      ...(logtype && logtype !== 'all'
        ? [Prisma.sql`logtype_id = ${logtype}`]
        : []),
      ...(search
        ? [Prisma.sql`user_content LIKE ${`%${search}%`}`]
        : []),
    ];

    const whereSql =
      filters.length > 0
        ? Prisma.sql`WHERE ${Prisma.join(filters, ' AND ')}`
        : Prisma.empty;

    const [logs, totalResult] = await Promise.all([
      this.prisma.$queryRaw<any[]>(Prisma.sql`
        SELECT
          log_id,
          user_no,
          logtype_id AS logtype,
          obj_id,
          user_content,
          score,
          total_score,
          score100,
          time_taken,
          DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s') AS created_at
        FROM users_logs
        ${whereSql}
        ORDER BY created_at DESC, log_id DESC
        LIMIT ${limit}
        OFFSET ${(page - 1) * limit}
      `),
      this.prisma.$queryRaw<Array<{ total: bigint }>>(Prisma.sql`
        SELECT COUNT(*) AS total
        FROM users_logs
        ${whereSql}
      `),
    ]);

    const total = Number(totalResult[0]?.total ?? 0);

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
    return this.prisma.$queryRaw(Prisma.sql`
      SELECT
        log_id,
        user_no,
        logtype_id AS logtype,
        obj_id,
        user_content,
        score,
        total_score,
        score100,
        time_taken,
        DATE_FORMAT(created_at, '%Y-%m-%dT%H:%i:%s') AS created_at
      FROM users_logs
      WHERE user_no = ${userNo}
        AND logtype_id = ${logtype}
        AND obj_id = ${objId}
      ORDER BY created_at DESC, log_id DESC
    `);
  }
}
