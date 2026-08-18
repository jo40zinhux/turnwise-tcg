import { Component, input } from '@angular/core';
import {
  EventStatus,
  PaymentStatus,
  RegistrationStatus,
} from '../../../core/models/enums';

type Kind = 'event' | 'registration' | 'payment';

const EVENT_LABEL: Record<EventStatus, { label: string; cls: string }> = {
  DRAFT: { label: 'Rascunho', cls: 'chip-neutral' },
  OPEN: { label: 'Inscrições abertas', cls: 'chip-success' },
  FULL: { label: 'Lotado', cls: 'chip-warning' },
  CLOSED: { label: 'Fechado', cls: 'chip-neutral' },
  CANCELLED: { label: 'Cancelado', cls: 'chip-danger' },
  FINISHED: { label: 'Encerrado', cls: 'chip-neutral' },
};

const REG_LABEL: Record<RegistrationStatus, { label: string; cls: string }> = {
  REGISTERED: { label: 'Inscrito', cls: 'chip-info' },
  CONFIRMED: { label: 'Confirmado', cls: 'chip-success' },
  WAITLIST: { label: 'Waitlist', cls: 'chip-warning' },
  CANCELLED: { label: 'Cancelada', cls: 'chip-danger' },
  NO_SHOW: { label: 'Não compareceu', cls: 'chip-neutral' },
};

const PAY_LABEL: Record<PaymentStatus, { label: string; cls: string }> = {
  PENDING: { label: 'Pendente', cls: 'chip-warning' },
  APPROVED: { label: 'Pago', cls: 'chip-success' },
  FAILED: { label: 'Falhou', cls: 'chip-danger' },
  CANCELLED: { label: 'Cancelado', cls: 'chip-neutral' },
  PAY_ON_SITE: { label: 'Pagamento no local', cls: 'chip-violet' },
};

@Component({
  selector: 'tw-status-chip',
  template: `@if (meta(); as item) {
    <span class="chip {{ item.cls }}" role="status">{{ item.label }}</span>
  }`,
})
export class StatusChipComponent {
  readonly kind = input.required<Kind>();
  readonly status = input.required<string>();

  meta() {
    const status = this.status();
    if (this.kind() === 'event') {
      return EVENT_LABEL[status as EventStatus];
    }
    if (this.kind() === 'registration') {
      return REG_LABEL[status as RegistrationStatus];
    }
    return PAY_LABEL[status as PaymentStatus];
  }
}
