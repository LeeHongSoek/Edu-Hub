import { Module } from '@nestjs/common';
import { SolveResultsService } from './solve-results.service';
import { SolveResultsController } from './solve-results.controller';
import { PrismaService } from '../common/prisma/prisma.service';

@Module({
  controllers: [SolveResultsController],
  providers: [SolveResultsService, PrismaService],
})
export class SolveResultsModule {}
