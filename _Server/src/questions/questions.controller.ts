import { Controller, Get, Post, Patch, Delete, Body, Param } from '@nestjs/common';
import { QuestionsService } from './questions.service';

@Controller('questions')
export class QuestionsController {
  constructor(private readonly questionsService: QuestionsService) {}

  // 모든 문제 목록 조회 API
  @Post()
  findAll(
    @Body('creator_no') creatorNo?: string,
    @Body('group_id') groupId?: string,
    @Body('search_field') searchField?: string,
    @Body('search_keyword') searchKeyword?: string,
    @Body('page') page?: number,
    @Body('limit') limit?: number,
    @Body('book_id') bookId?: string,
    @Body('exam_id') examId?: string,
  ) {
    return this.questionsService.findAll({
      creatorNo: (creatorNo && creatorNo !== 'undefined') ? BigInt(creatorNo) : undefined,
      groupId: (groupId && groupId !== 'undefined') ? BigInt(groupId) : undefined,
      bookId: (bookId && bookId !== 'undefined') ? BigInt(bookId) : undefined,
      examId: (examId && examId !== 'undefined') ? BigInt(examId) : undefined,
      searchField: searchField === 'content' ? 'content' : 'title',
      searchKeyword: searchKeyword?.trim() || undefined,
      page: page ? Number(page) : 1,
      limit: limit ? Number(limit) : 10,
    });
  }

  // 문제 생성
  @Post('create')
  create(@Body() createQuestionDto: any) {
    return this.questionsService.create(createQuestionDto);
  }

  // 문제 수정
  @Patch(':id')
  update(@Param('id') id: string, @Body() updateQuestionDto: any) {
    return this.questionsService.update(id, updateQuestionDto);
  }

  // 문제 삭제
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.questionsService.remove(id);
  }

  // 리뷰/의견 조회
  @Get(':id/reviews')
  getReviews(@Param('id') id: string) {
    return this.questionsService.getReviews(id);
  }

  // 리뷰/의견 추가
  @Post(':id/reviews')
  addReview(@Param('id') id: string, @Body() data: any) {
    return this.questionsService.addReview(id, data);
  }
}
