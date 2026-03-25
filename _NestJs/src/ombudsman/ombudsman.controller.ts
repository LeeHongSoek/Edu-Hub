import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { OmbudsmanService } from './ombudsman.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('ombudsman')
@UseGuards(JwtAuthGuard)
export class OmbudsmanController {
  constructor(private readonly ombudsmanService: OmbudsmanService) {}

  @Post()
  async create(@Request() req, @Body() body: any) {
    const userNo = BigInt(req.user.userNo);
    return this.ombudsmanService.create(userNo, body);
  }

  @Get('my')
  async findMyReports(@Request() req) {
    const userNo = BigInt(req.user.userNo);
    return this.ombudsmanService.findByUser(userNo);
  }

  @Patch(':id')
  async update(@Request() req, @Param('id') id: string, @Body() body: any) {
    const userNo = BigInt(req.user.userNo);
    return this.ombudsmanService.update(BigInt(id), userNo, body);
  }

  @Delete(':id')
  async remove(@Request() req, @Param('id') id: string) {
    const userNo = BigInt(req.user.userNo);
    return this.ombudsmanService.remove(BigInt(id), userNo);
  }
}
