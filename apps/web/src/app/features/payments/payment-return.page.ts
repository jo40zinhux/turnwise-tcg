import { Component, DestroyRef, inject, input, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { RouterLink } from '@angular/router';
import { Payment } from '../../core/models/domain';
import { PaymentStatus } from '../../core/models/enums';
import { PaymentService } from '../../core/services/app-services';
import { PaymentStatusObserver } from '../../core/services/payment-status.observer';
import { StatusChipComponent } from '../../shared/ui/status-chip/status-chip.component';

@Component({
  selector: 'tw-payment-return-page',
  imports: [RouterLink, StatusChipComponent],
  template: `
    <main class="page-narrow stack-lg">
      <h1>Pagamento</h1>
      @if (payment(); as item) {
        <tw-status-chip kind="payment" [status]="item.status" />
        @if (item.status === pending) {
          <p class="muted">Aguardando confirmação do Mercado Pago…</p>
        }
        @if (item.status === approved) {
          <p>Pagamento aprovado. Sua inscrição está confirmada.</p>
        }
        @if (item.status === failed) {
          <p>O pagamento não foi aprovado. Você pode tentar de novo na inscrição.</p>
        }
        @if (item.status === cancelled) {
          <p>Pagamento cancelado.</p>
        }
        @if (item.registrationId) {
          <a class="btn btn-primary" [routerLink]="['/r', item.registrationId]">Ver inscrição</a>
        }
      }
    </main>
  `,
})
export class PaymentReturnPageComponent {
  private readonly observer = inject(PaymentStatusObserver);
  private readonly payments = inject(PaymentService);
  private readonly destroyRef = inject(DestroyRef);
  readonly paymentId = input.required<string>();
  readonly payment = signal<Payment | null>(null);
  readonly pending = PaymentStatus.PENDING;
  readonly approved = PaymentStatus.APPROVED;
  readonly failed = PaymentStatus.FAILED;
  readonly cancelled = PaymentStatus.CANCELLED;

  async ngOnInit() {
    this.payment.set(await this.payments.get(this.paymentId()));
    this.observer
      .observe(this.paymentId())
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((payment) => this.payment.set(payment));
  }
}
