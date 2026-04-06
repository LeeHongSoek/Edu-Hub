import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaMariaDb } from '@prisma/adapter-mariadb';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor() {
    const databaseUrl = process.env.DATABASE_URL;

    if (!databaseUrl) {
      throw new Error(
        'DATABASE_URL is not defined. Check _Server/.env or set ENV_FILE to a runtime env file that includes DATABASE_URL.',
      );
    }

    // MariaDB 어댑터를 사용하여 Prisma 클라이언트 초기화
    const adapter = new PrismaMariaDb(databaseUrl);
    super({ adapter });
  }

  // 모듈 초기화 시 DB 연결
  async onModuleInit() {
    await this.$connect();
    await this.$executeRawUnsafe(`SET time_zone = '+09:00'`);
  }
}
