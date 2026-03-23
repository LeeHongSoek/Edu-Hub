import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common/prisma/prisma.service';

@Injectable()
export class QuestionsService {
  constructor(private prisma: PrismaService) {}

  // DB에서 모든 문제 정보를 조회 (유형 및 그룹 정보 포함)
  async findAll() {
    return this.prisma.question.findMany({
      include: {
        type: true, // 문제 유형 (객관식/주관식)
        options: {
          orderBy: {
            option_number: 'asc', // 보기 번호 순서대로 정렬
          },
        },
        group: {
          include: {
            parent_group: {
              include: {
                parent_group: true, // 최대 3단계 계층 구조 포함
              },
            },
          },
        },
        tags: {
          include: {
            tag: true,
          },
        },
      },
    });
  }
}
