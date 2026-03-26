import { Controller, Post, Get, Body, UseGuards, Request, UnauthorizedException, Param } from '@nestjs/common';
import { SolveResultsService } from './solve-results.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('solve-results')
@UseGuards(JwtAuthGuard)
export class SolveResultsController {
  constructor(private readonly solveResultsService: SolveResultsService) {}

  @Post()
  async create(@Request() req, @Body() body: {
    question_id: string;
    correct_answer: string;
    submitted_answer: string;
    is_correct: number;
    time_taken: number;
  }) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException('User session invalid');
    
    return this.solveResultsService.create(
      BigInt(userNoVal),
      BigInt(body.question_id),
      body.correct_answer,
      body.submitted_answer,
      body.is_correct,
      body.time_taken
    );
  }

  @Get('my')
  async findMyResults(@Request() req) {
    const userNo = BigInt(req.user?.user_no || req.user?.userNo);
    if (!userNo) throw new UnauthorizedException('User session invalid');
    return this.solveResultsService.findByUser(userNo);
  }

  @Get('question/:id')
  async findByQuestion(@Param('id') questionId: string) {
    return this.solveResultsService.findByQuestion(BigInt(questionId));
  }

  @Get('user/:userId')
  async findByUserId(@Param('userId') userId: string) {
    return this.solveResultsService.findByUser(BigInt(userId));
  }
}
