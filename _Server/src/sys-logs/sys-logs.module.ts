import { Module } from '@nestjs/common';
import { SysLogsService } from './sys-logs.service';
import { SysLogsController } from './sys-logs.controller';

@Module({
  controllers: [SysLogsController],
  providers: [SysLogsService],
})
export class SysLogsModule {}
