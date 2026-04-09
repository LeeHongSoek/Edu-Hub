import { Controller, Get } from '@nestjs/common';
import { StatsService } from './stats.service';

@Controller('stats_sample')
export class StatsSampleController {
  constructor(private readonly statsService: StatsService) {}

  @Get()
  async getStatsSample() {
    return this.statsService.getStats();
  }
}
