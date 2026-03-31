import { Controller, Get, UseGuards, Request, UnauthorizedException, Param, Query } from '@nestjs/common';
import { ExamsService } from './exams.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('exams')
@UseGuards(JwtAuthGuard)
export class ExamsController {
  constructor(private readonly examsService: ExamsService) {}

  @Get()
  async findAll(@Request() req: any, @Query('scope') scope?: 'mine' | 'all') {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return scope === 'all'
      ? this.examsService.findAll()
      : this.examsService.findAll(BigInt(userNoVal));
  }

  @Get(':id')
  async findOne(@Request() req: any, @Param('id') id: string) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.examsService.findById(BigInt(id), BigInt(userNoVal));
  }
}
