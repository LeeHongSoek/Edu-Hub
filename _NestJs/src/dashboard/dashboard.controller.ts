import { Controller, Get, Query, UseGuards, Request, UnauthorizedException } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('dashboard')
@UseGuards(JwtAuthGuard)
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('stats')
  async getDashboardStats(@Request() req) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    
    const userNo = BigInt(userNoVal);
    const roleId = req.user.role;
    return this.dashboardService.getStats(userNo, roleId);
  }

  @Get('relations')
  async getRelations(@Request() req) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.dashboardService.getRelations(BigInt(userNoVal));
  }

  @Get('messages')
  async getMessages(@Request() req) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.dashboardService.getMessages(BigInt(userNoVal));
  }
}
