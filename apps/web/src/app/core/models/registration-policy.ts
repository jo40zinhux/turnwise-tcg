import { PaymentMethod, PaymentStatus, RegistrationStatus } from '../models/enums';
import { Payment, Registration } from '../models/domain';

/** UI helper only. The backend remains the source of truth. */
export function canWithdrawDirectly(payment: Payment | null): boolean {
  if (!payment) {
    return true;
  }
  if (payment.method === PaymentMethod.ON_SITE) {
    return true;
  }
  return payment.status !== PaymentStatus.APPROVED;
}

export function needsRefundRequest(payment: Payment | null): boolean {
  return (
    payment?.method === PaymentMethod.MERCADO_PAGO &&
    payment.status === PaymentStatus.APPROVED
  );
}

export function isSeated(status: RegistrationStatus): boolean {
  return (
    status === RegistrationStatus.REGISTERED ||
    status === RegistrationStatus.CONFIRMED
  );
}

export function isActiveRegistration(registration: Registration): boolean {
  return registration.status !== RegistrationStatus.CANCELLED;
}
