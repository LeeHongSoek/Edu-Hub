import { BadRequestException, Controller, Get, Post, Patch, Delete, Body, Param, Request, UnauthorizedException, UseGuards } from '@nestjs/common';
import { QuestionsService } from './questions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('questions')
export class QuestionsController {
  constructor(private readonly questionsService: QuestionsService) {}

  // 모든 문제 목록 조회 API
  @Post()
  @UseGuards(JwtAuthGuard)
  findAll(
    @Request() req: any,
    @Body('creator_no') creatorNo?: string,
    @Body('group_id') groupId?: string,
    @Body('search_field') searchField?: string,
    @Body('search_keyword') searchKeyword?: string,
    @Body('page') page?: number,
    @Body('limit') limit?: number,
    @Body('book_id') bookId?: string,
    @Body('exam_id') examId?: string,
    @Body('exclude_book_id') excludeBookId?: string,
    @Body('exclude_exam_id') excludeExamId?: string,
    @Body('public_only') publicOnly?: boolean | string,
    @Body('viewer_no') viewerNo?: string,
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    const effectiveCreatorNo = (creatorNo && creatorNo !== 'undefined') ? creatorNo : String(userNoVal);
    const effectiveViewerNo = (viewerNo && viewerNo !== 'undefined') ? viewerNo : String(userNoVal);

    return this.questionsService.findAll({
      creatorNo: effectiveCreatorNo ? BigInt(effectiveCreatorNo) : undefined,
      groupId: (groupId && groupId !== 'undefined') ? BigInt(groupId) : undefined,
      bookId: (bookId && bookId !== 'undefined') ? BigInt(bookId) : undefined,
      examId: (examId && examId !== 'undefined') ? BigInt(examId) : undefined,
      excludeBookId: (excludeBookId && excludeBookId !== 'undefined') ? BigInt(excludeBookId) : undefined,
      excludeExamId: (excludeExamId && excludeExamId !== 'undefined') ? BigInt(excludeExamId) : undefined,
      publicOnly: publicOnly === true || publicOnly === 'true',
      viewerNo: effectiveViewerNo ? BigInt(effectiveViewerNo) : undefined,
      searchField: (searchField === 'content' || searchField === 'id') ? searchField : 'title',
      searchKeyword: searchKeyword?.trim() || undefined,
      page: page ? Number(page) : 1,
      limit: limit ? Number(limit) : 10,
    });
  }

  // 문제 생성
  @UseGuards(JwtAuthGuard)
  @Post('create')
  create(@Request() req: any, @Body() createQuestionDto: any) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    return this.questionsService.create({
      ...createQuestionDto,
      creator_no: userNoVal,
    });
  }

  // 문제 수정
  @Patch('soft-delete')
  softDeleteMany(
    @Body('questionIds') questionIds: Array<string | number | bigint>,
    @Body('user_no') userNo?: string | number | bigint,
  ) {
    const normalizedUserNo = userNo !== undefined && userNo !== null
      ? BigInt(userNo)
      : undefined;
    if (!normalizedUserNo) {
      throw new BadRequestException('삭제할 사용자 정보가 필요합니다.');
    }

    const normalizedQuestionIds = Array.isArray(questionIds)
      ? questionIds.map((questionId) => BigInt(questionId))
      : [];

    return this.questionsService.removeMany(normalizedQuestionIds, normalizedUserNo);
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

  // 문제 복사해서 내 문제로 가져오기
  @Post(':id/copy')
  copy(@Param('id') id: string, @Body('user_no') userNo?: string) {
    if (!userNo || userNo === 'undefined') {
      throw new BadRequestException('문제를 가져올 사용자 정보가 필요합니다.');
    }
    return this.questionsService.copy(id, BigInt(userNo));
  }
}
