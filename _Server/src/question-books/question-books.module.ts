import { Module } from '@nestjs/common';
import { QuestionBooksController } from './question-books.controller';
import { QuestionBooksService } from './question-books.service';
import { QuestionBooksSampleController } from './question-books-sample.controller';

@Module({
  controllers: [QuestionBooksController, QuestionBooksSampleController],
  providers: [QuestionBooksService],
})
export class QuestionBooksModule {}
