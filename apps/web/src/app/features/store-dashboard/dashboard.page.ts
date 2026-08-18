import { Component, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { StoreDashboardView } from '../../core/models/domain';
import { StoreService } from '../../core/services/app-services';
import { CapacityMeterComponent } from '../../shared/ui/capacity-meter/capacity-meter.component';
import { StatusChipComponent } from '../../shared/ui/status-chip/status-chip.component';
import { SkeletonBlockComponent } from '../../shared/ui/skeleton-block/skeleton-block.component';
import { formatEventWhen } from '../../shared/pipes/formatters';

@Component({
  selector: 'tw-dashboard-page',
  imports: [RouterLink, CapacityMeterComponent, StatusChipComponent, SkeletonBlockComponent],
  template: `
    <main class="page stack-lg">
      <div class="cluster">
        <div>
          <p class="muted">{{ data()?.store?.name }}</p>
          <h1>Dashboard</h1>
        </div>
        <a class="btn btn-primary" routerLink="/app/events/new">Criar evento</a>
      </div>
      @if (!data()) {
        <tw-skeleton />
      } @else {
        @if (data(); as dash) {
        <section class="row">
          <div class="surface"><strong>{{ dash.totals.activeEvents }}</strong><p class="muted">eventos ativos</p></div>
          <div class="surface"><strong>{{ dash.totals.seatedPlayers }}</strong><p class="muted">inscritos</p></div>
          <div class="surface"><strong>{{ dash.totals.waitlist }}</strong><p class="muted">waitlist</p></div>
          <div class="surface"><strong>{{ dash.totals.pendingPayments }}</strong><p class="muted">pagamentos pendentes</p></div>
        </section>
        <h2>Próximos eventos</h2>
        @for (item of dash.upcomingEvents; track item.event.id) {
          <a class="surface stack" [routerLink]="['/app/events', item.event.id]">
            <div class="cluster">
              <h3>{{ item.event.name }}</h3>
              <tw-status-chip kind="event" [status]="item.event.status" />
            </div>
            <p class="muted">{{ item.game.name }} · {{ formatWhen(item.event.startsAt) }}</p>
            <tw-capacity-meter [capacity]="item.capacity" />
            <p class="subtle">
              {{ item.approvedPayments }} pagos ·
              {{ item.pendingPayments }} pendentes ·
              {{ item.onSitePayments }} no local ·
              {{ item.cancellations }} desistências
            </p>
          </a>
        }
        }
      }
    </main>
  `,
})
export class DashboardPageComponent {
  private readonly store = inject(StoreService);
  readonly data = signal<StoreDashboardView | null>(null);
  readonly formatWhen = formatEventWhen;

  constructor() {
    void this.store.dashboard().then((value) => this.data.set(value));
  }
}
