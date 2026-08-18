import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PaymentStatus } from '@prisma/client';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { DomainError } from '../common/domain-error';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { AuthUser } from '../common/types';
import { toPayment } from '../domain/mappers';
import { RegistrationsService } from '../registrations/registrations.service';
import { PaymentNotificationDto } from './dto';

@Controller()
export class PaymentsController {
  constructor(
    private readonly registrations: RegistrationsService,
    private readonly config: ConfigService,
  ) {}

  @Post('registrations/:id/payments/mercadopago')
  @UseGuards(JwtAuthGuard)
  async startCheckout(
    @Param('id') id: string,
    @CurrentUser() actor: AuthUser,
  ) {
    const payment = await this.registrations.startCheckout(id, actor);
    return toPayment(payment);
  }

  @Get('payments/:id')
  async getPayment(@Param('id') id: string) {
    return toPayment(await this.registrations.getPayment(id));
  }

  @Post('payments/:id/notifications')
  async notify(
    @Param('id') id: string,
    @Body() dto: PaymentNotificationDto,
  ) {
    if (this.config.get('ALLOW_SANDBOX_NOTIFICATIONS') !== 'true') {
      throw new DomainError('Notificações sandbox desabilitadas.', 'FORBIDDEN', 403);
    }
    const allowed: Array<'APPROVED' | 'FAILED' | 'CANCELLED'> = [
      'APPROVED',
      'FAILED',
      'CANCELLED',
    ];
    if (!allowed.includes(dto.status as 'APPROVED' | 'FAILED' | 'CANCELLED')) {
      throw new DomainError('Status de pagamento inválido.', 'WEBHOOK_FAILED');
    }
    const payment = await this.registrations.applyNotification(
      id,
      dto.status as Extract<PaymentStatus, 'APPROVED' | 'FAILED' | 'CANCELLED'>,
    );
    return toPayment(payment);
  }
}
