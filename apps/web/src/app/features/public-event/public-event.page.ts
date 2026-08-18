import { Component, effect, inject, input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { PublicEventView } from '../../core/models/domain';
import { EventStatus, PaymentMode } from '../../core/models/enums';
import { EventService } from '../../core/services/app-services';
import { CapacityMeterComponent } from '../../shared/ui/capacity-meter/capacity-meter.component';
import { SkeletonBlockComponent } from '../../shared/ui/skeleton-block/skeleton-block.component';
import { StatusChipComponent } from '../../shared/ui/status-chip/status-chip.component';
import { formatBrl, formatEventWhen, refundCopy } from '../../shared/pipes/formatters';

@Component({
  selector: 'tw-public-event-page',
  imports: [RouterLink, CapacityMeterComponent, StatusChipComponent, SkeletonBlockComponent],
  template: `
    <main class="page-narrow stack-lg">
      @if (loading()) {
        <tw-skeleton height="220px" />
      } @else if (error()) {
        <p class="field error">Evento não encontrado.</p>
      } @else {
        @if (view(); as data) {
        <p class="muted">{{ data.store.name }} · {{ data.store.city }}/{{ data.store.state }}</p>
        <h1>{{ data.event.name }}</h1>
        <div class="row">
          <span class="chip chip-neutral">{{ data.game.name }}</span>
          <tw-status-chip kind="event" [status]="data.event.status" />
        </div>
        <p>{{ formatWhen(data.event.startsAt) }}</p>
        <p class="muted">{{ data.event.locationName }}<br />{{ data.event.address }}</p>
        <p><strong>{{ formatPrice(data.event.priceCents) }}</strong> · {{ payLabel(data.event.paymentMode) }}</p>
        <tw-capacity-meter [capacity]="data.capacity" />
        <p>{{ data.event.description }}</p>
        @if (data.event.rules) {
          <section class="surface">
            <h3>Instruções</h3>
            <p class="muted">{{ data.event.rules }}</p>
          </section>
        }
        <section class="banner-info">
          <strong>Reembolso</strong>
          <p>{{ refundText(data.event.refundPolicy.enabled, data.event.refundPolicy.feePercent) }}</p>
        </section>
        <div class="sticky-cta">
          @if (canRegister(data.event.status, data.event.allowWaitlist, data.capacity.available)) {
            <a class="btn btn-primary btn-block" [routerLink]="['/events', data.store.slug, data.event.slug, 'register']">
              {{ data.capacity.available === 0 ? 'Entrar na waitlist' : 'Inscrever-se' }}
            </a>
          } @else {
            <button class="btn btn-primary btn-block" disabled>Inscrições encerradas</button>
          }
        </div>
        }
      }
    </main>
  `,
})
export class PublicEventPageComponent {
  private readonly events = inject(EventService);
  readonly storeSlug = input.required<string>();
  readonly eventSlug = input.required<string>();
  readonly view = signal<PublicEventView | null>(null);
  readonly loading = signal(true);
  readonly error = signal(false);
  readonly formatWhen = formatEventWhen;
  readonly formatPrice = formatBrl;
  readonly refundText = refundCopy;

  constructor() {
    effect(() => {
      const storeSlug = this.storeSlug();
      const eventSlug = this.eventSlug();
      void this.load(storeSlug, eventSlug);
    });
  }

  payLabel(mode: string) {
    if (mode === PaymentMode.ONLINE) {
      return 'Pagamento online (Mercado Pago)';
    }
    if (mode === PaymentMode.PAY_ON_SITE) {
      return 'Pagamento no local';
    }
    return 'Online ou no local';
  }

  canRegister(status: string, waitlist: boolean, available: number) {
    if (status === EventStatus.OPEN) {
      return true;
    }
    return status === EventStatus.FULL && waitlist;
  }

  private async load(storeSlug: string, eventSlug: string) {
    this.loading.set(true);
    this.error.set(false);
    try {
      this.view.set(await this.events.getPublic(storeSlug, eventSlug));
    } catch {
      this.error.set(true);
    } finally {
      this.loading.set(false);
    }
  }
}
