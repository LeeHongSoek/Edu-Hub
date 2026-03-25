import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { StudyLogsService } from './study-logs.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('study-logs')
@UseGuards(JwtAuthGuard)
export class StudyLogsController {
  constructor(private readonly studyLogsService: StudyLogsService) {}

  @Post()
  async create(@Request() req, @Body() body: { question_id: string; user_memo: string }) {
    const userNo = BigInt(req.user.user_no);
    return this.studyLogsService.create(userNo, BigInt(body.question_id), body.user_memo);
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
