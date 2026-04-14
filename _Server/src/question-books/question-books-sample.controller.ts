import { Controller, Get } from '@nestjs/common';
import { QuestionBooksService } from './question-books.service';

@Controller('question-books_sample')
export class QuestionBooksSampleController {
  constructor(private readonly questionBooksService: QuestionBooksService) {}

  // 랜딩 페이지 오늘의 공개문제 샘플 조회 API
  @Get('daily/refresh')
  async refreshDaily() {
    return this.questionBooksService.refreshDailyQuestions();
  }
}
