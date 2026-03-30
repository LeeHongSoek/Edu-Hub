import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  // 헬스 체크용 또는 기본 API
  @Get()
  getHello(): string {
    return this.appService.getHello();
  }
}
