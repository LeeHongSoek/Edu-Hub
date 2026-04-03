import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { resolve } from 'path';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './common/prisma/prisma.module';
import { QuestionsModule } from './questions/questions.module';
import { GroupsModule } from './groups/groups.module';
import { AuthModule } from './auth/auth.module';
import { StatsModule } from './stats/stats.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { OmbudsmanModule } from './ombudsman/ombudsman.module';
import { UserLogsModule } from './user-logs/user-logs.module';
import { QuestionBooksModule } from './question-books/question-books.module';
import { ExamsModule } from './exams/exams.module';
import { SolveResultsModule } from './solve-results/solve-results.module';
import { DemoModule } from './demo/demo.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [
        process.env.ENV_FILE || resolve(process.cwd(), '..', 'config', 'runtime', 'primary.env'),
        resolve(process.cwd(), '.env'),
      ],
    }),
    PrismaModule,
    QuestionsModule,
    GroupsModule,
    AuthModule,
    StatsModule,
    DashboardModule,
    OmbudsmanModule,
    UserLogsModule,
    QuestionBooksModule,
    ExamsModule,
    SolveResultsModule,
    DemoModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
