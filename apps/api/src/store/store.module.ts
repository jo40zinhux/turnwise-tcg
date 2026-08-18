import { Module } from '@nestjs/common';
import { RegistrationsModule } from '../registrations/registrations.module';
import { StoreController } from './store.controller';
import { StoreService } from './store.service';

@Module({
  imports: [RegistrationsModule],
  controllers: [StoreController],
  providers: [StoreService],
})
export class StoreModule {}
