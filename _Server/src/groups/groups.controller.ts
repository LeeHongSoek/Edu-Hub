import { Controller, Get, Post, Patch, Delete, Body, Param, Query, Request, UnauthorizedException, UseGuards } from '@nestjs/common';
import { GroupsService } from './groups.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('groups')
@UseGuards(JwtAuthGuard)
export class GroupsController {
  constructor(private readonly groupsService: GroupsService) {}

  @Get()
  findAll(
    @Request() req: any,
    @Query('scope') scope?: string,
    @Query('bookId') bookId?: string | number,
    @Query('examId') examId?: string | number,
  ) {
    const userNoVal = req.user?.user_no || req.user?.userNo;
    if (!userNoVal) throw new UnauthorizedException();

    return this.groupsService.getHierarchy(scope, userNoVal, userNoVal, bookId, examId);
  }

  @Post()
  create(@Body() data: any) {
    return this.groupsService.create(data);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() data: any) {
    return this.groupsService.update(id, data);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.groupsService.remove(id);
  }
}
