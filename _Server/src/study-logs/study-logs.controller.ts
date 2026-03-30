import { Controller, Get, Post, Body, Param, UseGuards, Request, UnauthorizedException } from '@nestjs/common';
import { StudyLogsService } from './study-logs.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('study-logs')
@UseGuards(JwtAuthGuard)
export class StudyLogsController {
  constructor(private readonly studyLogsService: StudyLogsService) {}

  @Post()
  async create(@Request() req, @Body() body: { question_id: string; user_memo: string }) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException('User session invalid');
    
    const userNo = BigInt(userNoVal);
    const questionId = body.question_id ? BigInt(body.question_id) : undefined;
    if (!questionId) throw new Error('Question ID missing');
    
    return this.studyLogsService.create(userNo, questionId, body.user_memo);
  }

  @Get('my')
  async findMyLogs(@Request() req) {
    const userNo = BigInt(req.user.user_no);
    return this.studyLogsService.findByUser(userNo);
  }

  @Get('question/:id')
  async findByQuestion(@Request() req, @Param('id') id: string) {
    const userNo = BigInt(req.user.user_no);
    return this.studyLogsService.findByQuestion(userNo, BigInt(id));
  }
}
