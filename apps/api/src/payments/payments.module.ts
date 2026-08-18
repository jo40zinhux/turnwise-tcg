import { Module } from '@nestjs/common';
import { RegistrationsModule } from '../registrations/registrations.module';
import { PaymentsController } from './payments.controller';

@Module({
  imports: [RegistrationsModule],
  controllers: [PaymentsController],
})
export class PaymentsModule {}
