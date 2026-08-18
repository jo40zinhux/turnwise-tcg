import { Component, effect, inject, input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { PublicEventView } from '../../core/models/domain';
import { EventStatus } from '../../core/models/enums';
import { EventService } from '../../core/services/app-services';
import { ToastService } from '../../core/services/toast.service';
import { CapacityMeterComponent } from '../../shared/ui/capacity-meter/capacity-meter.component';
import { StatusChipComponent } from '../../shared/ui/status-chip/status-chip.component';
import { formatBrl, formatEventWhen } from '../../shared/pipes/formatters';

@Component({
  selector: 'tw-event-detail-page',
  imports: [RouterLink, CapacityMeterComponent, StatusChipComponent],
  template: `
    <main class="page stack-lg">
      @if (view(); as data) {
        <div class="cluster">
          <div>
            <h1>{{ data.event.name }}</h1>
            <p class="muted">{{ data.game.name }} · {{ formatWhen(data.event.startsAt) }}</p>
          </div>
          <tw-status-chip kind="event" [status]="data.event.status" />
        </div>
        <tw-capacity-meter [capacity]="data.capacity" />
        <p><strong>{{ formatPrice(data.event.priceCents) }}</strong></p>
        @if (data.event.status !== draft) {
          <p class="muted">/events/{{ data.store.slug }}/{{ data.event.slug }}</p>
        }
        <div class="row">
          <a class="btn btn-primary" [routerLink]="['/app/events', data.event.id, 'participants']">Participantes</a>
          <a class="btn btn-surface" [routerLink]="['/app/events', data.event.id, 'share']">QR Code / link</a>
          <a class="btn btn-surface" [routerLink]="['/app/events', data.event.id, 'edit']">Editar</a>
          @if (data.event.status === draft) {
            <button class="btn btn-surface" type="button" (click)="openRegistrations()">Abrir inscrições</button>
          }
          @if (data.event.status === openStatus || data.event.status === full) {
            <button class="btn btn-ghost" type="button" (click)="closeRegistrations()">Fechar inscrições</button>
          }
        </div>
      }
    </main>
  `,
})
export class EventDetailPageComponent {
  private readonly events = inject(EventService);
  private readonly toast = inject(ToastService);
  readonly eventId = input.required<string>();
  readonly view = signal<PublicEventView | null>(null);
  readonly formatWhen = formatEventWhen;
  readonly formatPrice = formatBrl;
  readonly draft = EventStatus.DRAFT;
  readonly openStatus = EventStatus.OPEN;
  readonly full = EventStatus.FULL;

  constructor() {
    effect(() => {
      void this.load(this.eventId());
    });
  }

  async openRegistrations() {
    await this.events.setStatus(this.eventId(), EventStatus.OPEN);
    this.toast.show('Inscrições abertas.');
    await this.load(this.eventId());
  }

  async closeRegistrations() {
    await this.events.setStatus(this.eventId(), EventStatus.CLOSED);
    this.toast.show('Inscrições fechadas.');
    await this.load(this.eventId());
  }

  private async load(id: string) {
    this.view.set(await this.events.getStoreEvent(id));
  }
}
