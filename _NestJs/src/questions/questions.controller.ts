import { Controller, Get, Post, Patch, Delete, Body, Param, Query } from '@nestjs/common';
import { QuestionsService } from './questions.service';

@Controller('questions')
export class QuestionsController {
  constructor(private readonly questionsService: QuestionsService) {}

  // 모든 문제 목록 조회 API
  @Get()
  findAll(@Query('creator_no') creatorNo?: string) {
    return this.questionsService.findAll(creatorNo ? BigInt(creatorNo) : undefined);
  }

  // 문제 생성
  @Post()
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
