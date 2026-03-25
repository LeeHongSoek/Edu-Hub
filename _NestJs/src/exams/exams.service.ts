import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class ExamsService {
  constructor(private prisma: PrismaService) {}

  async findAll(userNo?: bigint) {
    return this.prisma.exam.findMany({
      where: userNo ? { creator_no: userNo } : {},
      include: {
        creator: { select: { username: true } },
        class: true,
        _count: { select: { questions: true } }
      },
      orderBy: { created_at: 'desc' },
    });
  }
}
