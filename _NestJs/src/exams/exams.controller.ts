import { Controller, Get, UseGuards, Request, UnauthorizedException, Param } from '@nestjs/common';
import { ExamsService } from './exams.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('exams')
@UseGuards(JwtAuthGuard)
export class ExamsController {
  constructor(private readonly examsService: ExamsService) {}

  @Get()
  async findAll(@Request() req: any) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.examsService.findAll(BigInt(userNoVal));
  }

  @Get(':id')
  async findOne(@Request() req: any, @Param('id') id: string) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.examsService.findById(BigInt(id), BigInt(userNoVal));
  }
}
