import { Controller, Post, Body } from '@nestjs/common';
import { QuestionsService } from './questions.service';

@Controller('questions_sample')
export class QuestionsSampleController {
  constructor(private readonly questionsService: QuestionsService) {}

  // 랜딩 페이지 샘플/공개 문제 조회 API
  @Post()
  findSampleList(
    @Body('group_id') groupId?: string,
    @Body('search_field') searchField?: string,
    @Body('search_keyword') searchKeyword?: string,
    @Body('page') page?: number,
    @Body('limit') limit?: number,
  ) {
    return this.questionsService.findAll({
      groupId: groupId && groupId !== 'undefined' ? BigInt(groupId) : undefined,
      publicOnly: true,
      searchField: (searchField === 'content' || searchField === 'id') ? searchField : 'title',
      searchKeyword: searchKeyword?.trim() || undefined,
      page: page ? Number(page) : 1,
      limit: limit ? Number(limit) : 10,
    });
  }
}
