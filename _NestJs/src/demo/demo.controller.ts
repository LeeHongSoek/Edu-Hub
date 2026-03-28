import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { DemoService } from './demo.service';

@Controller('api/demo')
export class DemoController {
  constructor(private readonly demoService: DemoService) {}

  @Get()
  getDemo(@Query('id') id?: string, @Query('type') type?: string) {
    return this.demoService.getStatus({ id, type });
  }

  @Post()
  postDemo(
    @Body('userId') userId?: number,
    @Body('action') action?: string,
    @Body('timestamp') timestamp?: string
  ) {
    return this.demoService.createAction({ userId, action, timestamp });
  }
}
