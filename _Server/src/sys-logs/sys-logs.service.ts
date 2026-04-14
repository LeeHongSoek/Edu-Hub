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
    truncateCache?: boolean;
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

    const logIds = items.map((item) => item.log_id);
    let cacheRows: { log_id: bigint; cache_id: bigint }[] = [];
    if (logIds.length > 0) {
      cacheRows = await this.prisma.$queryRaw<
        { log_id: bigint; cache_id: bigint }[]
      >`SELECT log_id, cache_id FROM sys_logs_cache WHERE log_id IN (${Prisma.join(
        logIds.map((id) => Prisma.sql`${id}`),
      )})`;
    }

    const cacheMap = new Map<string, number>();
    cacheRows.forEach((row) => {
      cacheMap.set(row.log_id.toString(), Number(row.cache_id));
    });

    const itemsWithCache = items.map((item) => ({
      ...item,
      cache_id: cacheMap.get(item.log_id.toString()) ?? null,
    }));

    if (options.truncateCache) {
      await this.prisma.$executeRawUnsafe('TRUNCATE TABLE sys_logs_cache');
    }

    return { items: itemsWithCache, total: Math.min(total, 100) }; // 100개 이상은 안보여줌
  }

  async clearCache() {
    await this.prisma.$executeRawUnsafe('TRUNCATE TABLE sys_logs_cache');
  }
}
