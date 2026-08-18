import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { EventsModule } from './events/events.module';
import { GamesModule } from './games/games.module';
import { HealthController } from './health.controller';
import { MeModule } from './me/me.module';
import { PaymentsModule } from './payments/payments.module';
import { PrismaModule } from './prisma/prisma.module';
import { RegistrationsModule } from './registrations/registrations.module';
import { StoreModule } from './store/store.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    GamesModule,
    EventsModule,
    RegistrationsModule,
    MeModule,
    StoreModule,
    PaymentsModule,
  ],
  controllers: [HealthController],
})
export class AppModule {}
