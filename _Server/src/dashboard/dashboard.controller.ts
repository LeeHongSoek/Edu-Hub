import { Body, Controller, Delete, Get, Param, Post, Query, UseGuards, Request, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('dashboard')
@UseGuards(JwtAuthGuard)
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) { }

  @Get('stats')
  async getDashboardStats(@Request() req) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    const userNo = BigInt(userNoVal);
    const roleId = req.user.role;
    console.log('[백엔드:dashboard.controller.ts  // ', '사용자번호=', userNoVal, '역활부호=', roleId);

    return this.dashboardService.getStats(userNo, roleId);
  }

  @Get('classes')
  async getDashboardClasses(@Request() req) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    const roleId = String(req.user?.role_id || req.user?.role || '').toUpperCase();
    return this.dashboardService.getClassList(BigInt(userNoVal), roleId);
  }

  @Get('relations')
  async getRelations(
    @Request() req,
    @Query('q') q = '',
    @Query('target') target = '',
    @Query('page') page = '1',
    @Query('limit') limit = '8',
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    const userRoleId = String(req.user?.role_id || req.user?.role || '').toUpperCase();
    return this.dashboardService.getRelations(
      BigInt(userNoVal),
      userRoleId,
      q,
      target,
      Number(page),
      Number(limit),
    );
  }

  @Get('relations/candidates')
  async getRelationCandidates(
    @Request() req,
    @Query('role') role: string,
    @Query('q') q = '',
    @Query('page') page = '1',
    @Query('limit') limit = '6',
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    const normalizedRole = String(role || '').toUpperCase();
    if (!['S', 'T', 'P'].includes(normalizedRole)) {
      throw new BadRequestException('검색 대상 역할이 올바르지 않습니다.');
    }

    return this.dashboardService.getRelationCandidates(
      BigInt(userNoVal),
      normalizedRole,
      q,
      Number(page),
      Number(limit),
    );
  }

  @Post('relations')
  async createRelation(@Request() req, @Body() body: { targetUserNo?: string | number; targetRoleId?: string }) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    return this.dashboardService.createRelation(
      BigInt(userNoVal),
      body?.targetUserNo,
      body?.targetRoleId,
    );
  }

  @Delete('relations/:targetUserNo')
  async deleteRelation(@Request() req, @Param('targetUserNo') targetUserNo: string) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    return this.dashboardService.deleteRelation(BigInt(userNoVal), targetUserNo);
  }

  @Get('messages')
  async getMessages(
    @Request() req,
    @Query('view') view = 'received',
    @Query('q') q = '',
    @Query('page') page = '1',
    @Query('limit') limit = '8',
    @Query('peerUserNo') peerUserNo = '',
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.dashboardService.getMessages(
      BigInt(userNoVal),
      String(view || 'received'),
      q,
      Number(page),
      Number(limit),
      peerUserNo,
    );
  }

  @Get('messages/recipients')
  async getMessageRecipients(
    @Request() req,
    @Query('q') q = '',
    @Query('page') page = '1',
    @Query('limit') limit = '6',
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();
    return this.dashboardService.getMessageRecipients(BigInt(userNoVal), q, Number(page), Number(limit));
  }

  @Post('messages')
  async sendMessage(
    @Request() req,
    @Body() body: { receiverUserNo?: string | number; content?: string },
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    return this.dashboardService.sendMessage(
      BigInt(userNoVal),
      body?.receiverUserNo,
      body?.content,
    );
  }
}
