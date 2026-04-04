import { Controller, Get, Post, Patch, Delete, Body, Param, Query } from '@nestjs/common';
import { GroupsService } from './groups.service';

@Controller('groups')
export class GroupsController {
  constructor(private readonly groupsService: GroupsService) {}

  @Get()
  findAll(
    @Query('scope') scope?: string,
    @Query('userNo') userNo?: string | number,
    @Query('viewerNo') viewerNo?: string | number,
    @Query('bookId') bookId?: string | number,
    @Query('examId') examId?: string | number,
  ) {
    return this.groupsService.getHierarchy(scope, userNo, viewerNo, bookId, examId);
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
