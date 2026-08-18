import { Module } from '@nestjs/common';
import { RegistrationsModule } from '../registrations/registrations.module';
import { EventsController } from './events.controller';

@Module({
  imports: [RegistrationsModule],
  controllers: [EventsController],
})
export class EventsModule {}
