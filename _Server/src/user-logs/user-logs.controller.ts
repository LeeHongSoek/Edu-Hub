import { Controller, Get, Post, Body, Param, UseGuards, Req } from '@nestjs/common';
import { UserLogsService } from './user-logs.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('user-logs')
@UseGuards(JwtAuthGuard)
export class UserLogsController {
  constructor(private readonly userLogsService: UserLogsService) {}

  @Get('my')
  async findMyLogs(@Req() req) {
    const userNo = BigInt(req.user.user_no);
    return this.userLogsService.findByUser(userNo);
  }

  @Post(':logtype/:obj_id')
  async createLog(
    @Req() req,
    @Param('logtype') logtype: string,
    @Param('obj_id') obj_id: string,
    @Body() body: { user_content?: string, score?: number, total_score?: number, score100?: number }
  ) {
    const userNo = BigInt(req.user.user_no);
    return this.userLogsService.create(userNo, logtype, BigInt(obj_id), body);
  }

  @Get(':logtype/:obj_id')
  async findByObject(
    @Req() req,
    @Param('logtype') logtype: string,
    @Param('obj_id') obj_id: string
  ) {
    const userNo = BigInt(req.user.user_no);
    return this.userLogsService.findByObject(userNo, logtype, BigInt(obj_id));
  }
}
