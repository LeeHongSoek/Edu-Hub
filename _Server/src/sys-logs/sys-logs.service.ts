import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class SysLogsService {
  constructor(private prisma: PrismaService) { }

  async findAll(options: {
    search?: string;
    page?: number;
    limit?: number;
  }) {
    const page = options.page && options.page > 0 ? options.page : 1;
    const requestedLimit = options.limit && options.limit > 0 ? options.limit : 1;
    const limit = Math.min(requestedLimit, 20);
    const where: Prisma.SysLogWhereInput = options.search
      ? {
        content: {
          contains: options.search,
        },
      }
      : {};

    const [items, total] = await Promise.all([
      this.prisma.sysLog.findMany({
        where,
        orderBy: { created_at: 'desc' },
        take: limit,
        skip: (page - 1) * limit,
      }),
      this.prisma.sysLog.count({ where }),
    ]);

    return { items, total: Math.min(total, 100) }; // 100개 이상은 안보여줌
  }
}
