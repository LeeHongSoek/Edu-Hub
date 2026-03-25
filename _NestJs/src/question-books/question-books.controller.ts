import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { QuestionBooksService } from './question-books.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('question-books')
@UseGuards(JwtAuthGuard)
export class QuestionBooksController {
  constructor(private readonly questionBooksService: QuestionBooksService) {}

  @Post()
  async create(@Request() req, @Body() body: any) {
    const userNo = BigInt(req.user.userNo);
    return this.questionBooksService.create(userNo, body);
  }

  @Get('my')
  async findMyBooks(@Request() req) {
    const userNo = BigInt(req.user.userNo);
    return this.questionBooksService.findByUser(userNo);
  }

  @Patch(':id')
  async update(@Request() req, @Param('id') id: string, @Body() body: any) {
    const userNo = BigInt(req.user.userNo);
    return this.questionBooksService.update(BigInt(id), userNo, body);
  }

  @Delete(':id')
  async remove(@Request() req, @Param('id') id: string) {
    const userNo = BigInt(req.user.userNo);
    return this.questionBooksService.remove(BigInt(id), userNo);
  }

  @Post(':id/items')
  async addItem(@Request() req, @Param('id') id: string, @Body('question_id') questionId: string) {
    const userNo = BigInt(req.user.userNo);
    return this.questionBooksService.addItem(BigInt(id), userNo, BigInt(questionId));
  }

  @Delete(':id/items/:qId')
  async removeItem(@Request() req, @Param('id') id: string, @Param('qId') qId: string) {
    const userNo = BigInt(req.user.userNo);
    return this.questionBooksService.removeItem(BigInt(id), userNo, BigInt(qId));
  }
}
