import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('dashboard')
@UseGuards(JwtAuthGuard)
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('stats')
  async getDashboardStats(@Request() req) {
    const userNo = BigInt(req.user.userNo);
    const roleId = req.user.roleId;
    return this.dashboardService.getStats(userNo, roleId);
  }

  @Get('relations')
  async getRelations(@Request() req) {
    const userNo = BigInt(req.user.userNo);
    return this.dashboardService.getRelations(userNo);
  }

  @Get('messages')
  async getMessages(@Request() req) {
    const userNo = BigInt(req.user.userNo);
    return this.dashboardService.getMessages(userNo);
  }
}
