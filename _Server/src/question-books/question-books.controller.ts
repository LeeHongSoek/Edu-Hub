import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards, Request, Query } from '@nestjs/common';
import { QuestionBooksService } from './question-books.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('question-books')
export class QuestionBooksController {
  constructor(private readonly questionBooksService: QuestionBooksService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async create(@Request() req, @Body() body: any) {
    const userNo = BigInt(req.user.user_no);
    return this.questionBooksService.create(userNo, body);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  async findAll(@Request() req, @Query('scope') scope?: 'mine' | 'all') {
    const userNo = BigInt(req.user.user_no);
    return scope === 'all'
      ? this.questionBooksService.findAll()
      : this.questionBooksService.findByUser(userNo);
  }

  @Get('my')
  @UseGuards(JwtAuthGuard)
  async findMyBooks(@Request() req) {
    const userNo = BigInt(req.user.user_no);
    return this.questionBooksService.findByUser(userNo);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.questionBooksService.findById(BigInt(id));
  }

  @Patch('soft-delete')
  @UseGuards(JwtAuthGuard)
  async softDeleteMany(
    @Request() req,
    @Body('bookIds') bookIds: Array<string | number | bigint>,
  ) {
    const userNo = BigInt(req.user.user_no);
    const normalizedBookIds = Array.isArray(bookIds)
      ? bookIds.map((bookId) => BigInt(bookId))
      : [];
    return this.questionBooksService.removeMany(normalizedBookIds, userNo);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async update(@Request() req, @Param('id') id: string, @Body() body: any) {
    const userNo = BigInt(req.user.user_no);
    return this.questionBooksService.update(BigInt(id), userNo, body);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async remove(@Request() req, @Param('id') id: string) {
    const userNo = BigInt(req.user.user_no);
    return this.questionBooksService.remove(BigInt(id), userNo);
  }

  @Post(':id/items')
  @UseGuards(JwtAuthGuard)
  async addItem(@Request() req, @Param('id') id: string, @Body('question_id') questionId: string) {
    const userNo = BigInt(req.user.user_no);
    return this.questionBooksService.addItem(BigInt(id), userNo, BigInt(questionId));
  }

  @Delete(':id/items/:qId')
  @UseGuards(JwtAuthGuard)
  async removeItem(@Request() req, @Param('id') id: string, @Param('qId') qId: string) {
    const userNo = BigInt(req.user.user_no);
    return this.questionBooksService.removeItem(BigInt(id), userNo, BigInt(qId));
  }

  // 오늘의 공개문제 갱신 및 가져오기 (인증 없음)
  @Get('daily/refresh')
  async refreshDaily() {
    return this.questionBooksService.refreshDailyQuestions();
  }
}
