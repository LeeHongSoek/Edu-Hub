import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './common/prisma/prisma.module';
import { QuestionsModule } from './questions/questions.module';
import { GroupsModule } from './groups/groups.module';
import { AuthModule } from './auth/auth.module';
import { StatsModule } from './stats/stats.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { OmbudsmanModule } from './ombudsman/ombudsman.module';
import { StudyLogsModule } from './study-logs/study-logs.module';
import { QuestionBooksModule } from './question-books/question-books.module';

@Module({
  imports: [ConfigModule.forRoot({ isGlobal: true }), PrismaModule, QuestionsModule, GroupsModule, AuthModule, StatsModule, DashboardModule, OmbudsmanModule, StudyLogsModule, QuestionBooksModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
