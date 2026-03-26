import { Controller, Get } from '@nestjs/common';
import { StatsService } from './stats.service';

@Controller('stats')
export class StatsController {
  constructor(private readonly statsService: StatsService) { }

  @Get()
  async getStats() {
    const stats = await this.statsService.getStats();
    console.log('[여기:stats.controller.ts] returning stats:', stats); //  returning stats: { questions: 7, teachers: 1, students: 2, parents: 1, totalUsers: 4 }
    return stats;
  }
}
