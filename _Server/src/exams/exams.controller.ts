import { Controller, Get, Post, Body, UseGuards, Request, UnauthorizedException, Param, Query, Patch } from '@nestjs/common';
import { ExamsService } from './exams.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('exams')
@UseGuards(JwtAuthGuard)
export class ExamsController {
  constructor(private readonly examsService: ExamsService) {}

  @Get()
  async findAll(
    @Request() req: any,
    @Query('scope') scope?: 'mine' | 'all',
    @Query('classId') classId?: string,
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    const classIdValue = classId ? BigInt(classId) : undefined;
    return scope === 'all'
      ? this.examsService.findAll(undefined, classIdValue)
      : this.examsService.findAll(BigInt(userNoVal), classIdValue);
  }

  @Post()
  async create(
    @Request() req: any,
    @Body() body: {
      exam_name: string;
      description?: string;
      start_time: string;
      end_time: string;
      location?: string;
      is_auto_score?: boolean;
      class_id?: string;
    },
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.examsService.create(BigInt(userNoVal), body);
  }

  @Patch(':id')
  async update(
    @Request() req: any,
    @Param('id') id: string,
    @Body() body: {
      exam_name: string;
      description?: string;
      start_time: string;
      end_time: string;
      location?: string;
      is_auto_score?: boolean;
      class_id?: string | number | null;
    },
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.examsService.update(BigInt(id), BigInt(userNoVal), body);
  }

  @Patch('soft-delete')
  async softDeleteMany(
    @Request() req: any,
    @Body('examIds') examIds: Array<string | number | bigint>,
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    const normalizedExamIds = Array.isArray(examIds)
      ? examIds.map((examId) => BigInt(examId))
      : [];

    return this.examsService.removeMany(normalizedExamIds, BigInt(userNoVal));
  }

  @Get(':id')
  async findOne(@Request() req: any, @Param('id') id: string) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.examsService.findById(BigInt(id), BigInt(userNoVal));
  }
}
