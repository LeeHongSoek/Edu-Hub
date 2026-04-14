import { Module } from '@nestjs/common';
import { QuestionsService } from './questions.service';
import { QuestionsController } from './questions.controller';
import { QuestionsSampleController } from './questions-sample.controller';

@Module({
  providers: [QuestionsService],
  controllers: [QuestionsController, QuestionsSampleController],
})
export class QuestionsModule {}
