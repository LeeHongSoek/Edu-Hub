import { Controller, Get, Query, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SysLogsService } from './sys-logs.service';

@Controller('sys-logs')
@UseGuards(JwtAuthGuard)
export class SysLogsController {
  constructor(private readonly sysLogsService: SysLogsService) {}

  @Get()
  async list(
    @Req() req,
    @Query('q') q?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const userRole = req.user?.role_id || req.user?.role;
    if (userRole !== 'A') {
      return { items: [], total: 0 };
    }

    return this.sysLogsService.findAll({
      search: q || undefined,
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }
}
