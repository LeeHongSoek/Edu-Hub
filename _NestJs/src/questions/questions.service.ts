import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class QuestionsService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.question.findMany({
      include: {
        type: true,
        options: true,
        attachments: true,
        tags: {
          include: {
            tag: true,
          },
        },
      },
    });
  }
}
