import { Component, effect, inject, input, signal, viewChild } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { ApiError } from '../../core/api/api-client';
import { AuthService } from '../../core/auth/auth.service';
import { RegistrationView } from '../../core/models/domain';
import { PaymentMethod, PaymentStatus, RegistrationStatus } from '../../core/models/enums';
import { PaymentService, RegistrationService } from '../../core/services/app-services';
import { ToastService } from '../../core/services/toast.service';
import { WhatsAppService } from '../../core/services/whatsapp.service';
import { ConfirmDialogComponent } from '../../shared/ui/confirm-dialog/confirm-dialog.component';
import { StatusChipComponent } from '../../shared/ui/status-chip/status-chip.component';
import { formatBrl, formatEventWhen, refundCopy } from '../../shared/pipes/formatters';

@Component({
  selector: 'tw-registration-detail-page',
  imports: [RouterLink, StatusChipComponent, ConfirmDialogComponent],
  template: `
    <main class="page-narrow stack-lg">
      <a routerLink="/me">← Minhas inscrições</a>
      @if (view(); as data) {
        <h1>{{ data.event.name }}</h1>
        <p class="muted">{{ formatWhen(data.event.startsAt) }} · {{ data.event.locationName }}</p>
        <div class="row">
          <tw-status-chip kind="registration" [status]="data.registration.status" />
          @if (data.payment) {
            <tw-status-chip kind="payment" [status]="data.payment.status" />
          }
        </div>
        @if (data.registration.status === waitlist && data.registration.waitlistPosition) {
          <p class="banner-warning">Você está na waitlist · posição {{ data.registration.waitlistPosition }}</p>
        }
        @if (data.payment) {
          <p><strong>{{ formatPrice(data.payment.amountCents) }}</strong></p>
        }
        <section class="banner-info">
          {{ refundText(data.event.refundPolicy.enabled, data.event.refundPolicy.feePercent) }}
        </section>
        @if (data.payment?.method === mp && (data.payment?.status === pending || data.payment?.status === failed) && data.registration.status !== cancelled) {
          <button class="btn btn-primary btn-block" type="button" (click)="pay()">Pagar com Mercado Pago</button>
        }
        @if (data.canWithdrawDirectly && data.registration.status !== cancelled) {
          <button class="btn btn-danger btn-block" type="button" (click)="cancel()">Desistir da vaga</button>
        }
        @if (data.needsRefundRequest && data.registration.status !== cancelled) {
          <a class="btn btn-surface btn-block" [href]="whatsapp.refundUrl(data)" target="_blank" rel="noopener">
            Pedir reembolso no WhatsApp
          </a>
        }
        @if (error()) {
          <p class="field error">{{ error() }}</p>
        }
      }
      <tw-confirm-dialog />
    </main>
  `,
})
export class RegistrationDetailPageComponent {
  private readonly registrations = inject(RegistrationService);
  private readonly payments = inject(PaymentService);
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly toast = inject(ToastService);
  readonly whatsapp = inject(WhatsAppService);
  readonly id = input.required<string>();
  readonly view = signal<RegistrationView | null>(null);
  readonly error = signal<string | null>(null);
  readonly confirm = viewChild.required(ConfirmDialogComponent);
  readonly formatWhen = formatEventWhen;
  readonly formatPrice = formatBrl;
  readonly refundText = refundCopy;
  readonly waitlist = RegistrationStatus.WAITLIST;
  readonly cancelled = RegistrationStatus.CANCELLED;
  readonly mp = PaymentMethod.MERCADO_PAGO;
  readonly pending = PaymentStatus.PENDING;
  readonly failed = PaymentStatus.FAILED;

  constructor() {
    effect(() => {
      void this.load(this.id());
    });
  }

  async pay() {
    const data = this.view();
    if (!data) {
      return;
    }
    try {
      const payment = await this.payments.startCheckout(data.registration.id);
      if (payment.initPoint) {
        await this.router.navigateByUrl(payment.initPoint);
      }
    } catch (err) {
      this.error.set(err instanceof ApiError ? err.message : 'Não foi possível iniciar o pagamento.');
    }
  }

  async cancel() {
    const data = this.view();
    if (!data) {
      return;
    }
    const ok = await this.confirm().open({
      title: 'Desistir da inscrição?',
      body: 'Sua vaga será liberada. Se houver waitlist, o próximo jogador pode ser promovido.',
      confirmLabel: 'Desistir',
    });
    if (!ok) {
      return;
    }
    try {
      this.view.set(await this.registrations.cancel(data.registration.id));
      this.toast.show('Inscrição cancelada.');
    } catch (err) {
      this.error.set(err instanceof ApiError ? err.message : 'Não foi possível cancelar.');
    }
  }

  private async load(id: string) {
    const token = this.auth.guestAccess(id);
    this.view.set(await this.registrations.get(id, token));
  }
}
