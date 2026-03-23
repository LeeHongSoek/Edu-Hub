import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaMariaDb } from '@prisma/adapter-mariadb';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor() {
    // MariaDB 어댑터를 사용하여 Prisma 클라이언트 초기화
    const adapter = new PrismaMariaDb(process.env.DATABASE_URL!);
    super({ adapter });
  }

  // 모듈 초기화 시 DB 연결
  async onModuleInit() {
    await this.$connect();
  }
}
