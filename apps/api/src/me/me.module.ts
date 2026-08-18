import { Module } from '@nestjs/common';
import { RegistrationsModule } from '../registrations/registrations.module';
import { MeController } from './me.controller';

@Module({
  imports: [RegistrationsModule],
  controllers: [MeController],
})
export class MeModule {}
