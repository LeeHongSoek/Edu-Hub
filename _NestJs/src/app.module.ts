import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './common/prisma/prisma.module';
import { QuestionsModule } from './questions/questions.module';
import { GroupsModule } from './groups/groups.module';

@Module({
  imports: [ConfigModule.forRoot({ isGlobal: true }), PrismaModule, QuestionsModule, GroupsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
