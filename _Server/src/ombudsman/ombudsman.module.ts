import { Module } from '@nestjs/common';
import { OmbudsmanController } from './ombudsman.controller';
import { OmbudsmanService } from './ombudsman.service';

@Module({
  controllers: [OmbudsmanController],
  providers: [OmbudsmanService],
})
export class OmbudsmanModule {}
