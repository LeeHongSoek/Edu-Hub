import { Module } from '@nestjs/common';
import { QuestionBooksController } from './question-books.controller';
import { QuestionBooksService } from './question-books.service';

@Module({
  controllers: [QuestionBooksController],
  providers: [QuestionBooksService],
})
export class QuestionBooksModule {}
