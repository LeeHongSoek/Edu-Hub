import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class UserLogsService {
  constructor(private prisma: PrismaService) {}

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
        let title = 'Unknown Item';
        
        if (log.logtype === 'Q') {
          const q = await this.prisma.question.findUnique({ where: { question_id: log.obj_id }, select: { title: true } });
          title = q?.title || 'Unknown Question';
        } else if (log.logtype === 'B') {
          const b = await this.prisma.questionBook.findUnique({ where: { book_id: log.obj_id }, select: { book_name: true } });
          title = b?.book_name || 'Unknown Book';
        } else if (log.logtype === 'E') {
          const e = await this.prisma.exam.findUnique({ where: { exam_id: log.obj_id }, select: { exam_name: true } });
          title = e?.exam_name || 'Unknown Exam';
        }

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
