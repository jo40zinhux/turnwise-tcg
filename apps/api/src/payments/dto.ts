import { IsEnum } from 'class-validator';
import { PaymentStatus } from '@prisma/client';

export class PaymentNotificationDto {
  @IsEnum(PaymentStatus)
  status!: Extract<PaymentStatus, 'APPROVED' | 'FAILED' | 'CANCELLED'>;
}
