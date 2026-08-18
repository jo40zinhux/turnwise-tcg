import { Component, inject, input, signal } from '@angular/core';
import { Router } from '@angular/router';
import { PaymentService } from '../../core/services/app-services';
import { PaymentStatus } from '../../core/models/enums';

@Component({
  selector: 'tw-checkout-stub-page',
  template: `
    <main class="page-narrow stack-lg">
      <p class="subtle">Sandbox Mercado Pago</p>
      <h1>Checkout Pro</h1>
      <p class="muted">
        Pague como quiser (PIX, cartão, saldo). O TurnWise não vê o meio —
        só recebe o status depois, via notificação.
      </p>
      <div class="surface stack">
        <p>Preferência de pagamento simulada.</p>
        <button class="btn btn-primary" type="button" [disabled]="busy()" (click)="finish('APPROVED')">Pagar</button>
        <button class="btn btn-surface" type="button" [disabled]="busy()" (click)="finish('FAILED')">Simular falha</button>
        <button class="btn btn-ghost" type="button" [disabled]="busy()" (click)="finish('CANCELLED')">Cancelar</button>
      </div>
    </main>
  `,
})
export class CheckoutStubPageComponent {
  private readonly payments = inject(PaymentService);
  private readonly router = inject(Router);
  readonly paymentId = input.required<string>();
  readonly busy = signal(false);

  async finish(status: Extract<PaymentStatus, 'APPROVED' | 'FAILED' | 'CANCELLED'>) {
    this.busy.set(true);
    await this.payments.notifySandbox(this.paymentId(), status);
    await this.router.navigate(['/payments/return', this.paymentId()]);
  }
}
