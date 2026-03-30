import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class StatsService {
  constructor(private prisma: PrismaService) {}

  async getStats() {
    const [questions, teachers, students, parents] = await Promise.all([
      this.prisma.question.count(),
      this.prisma.user.count({ where: { role_id: 'T' } }),
      this.prisma.user.count({ where: { role_id: 'S' } }),
      this.prisma.user.count({ where: { role_id: 'P' } }),
    ]);

    return {
      questions,
      teachers,
      students,
      parents,
      totalUsers: teachers + students + parents,
    };
  }
}
