import { Module } from '@nestjs/common';
import { StatsService } from './stats.service';
import { StatsController } from './stats.controller';
import { StatsSampleController } from './stats-sample.controller';
import { PrismaModule } from '../common/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [StatsController, StatsSampleController],
  providers: [StatsService],
})
export class StatsModule {}
