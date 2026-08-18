import { Component, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { Event } from '../../core/models/domain';
import { EventService } from '../../core/services/app-services';
import { StatusChipComponent } from '../../shared/ui/status-chip/status-chip.component';
import { EmptyStateComponent } from '../../shared/ui/empty-state/empty-state.component';
import { formatEventWhen } from '../../shared/pipes/formatters';

@Component({
  selector: 'tw-event-list-page',
  imports: [RouterLink, StatusChipComponent, EmptyStateComponent],
  template: `
    <main class="page stack-lg">
      <div class="cluster">
        <h1>Eventos</h1>
        <a class="btn btn-primary" routerLink="/app/events/new">Criar evento</a>
      </div>
      @if (!events().length) {
        <tw-empty-state title="Nenhum evento" body="Crie o primeiro evento e compartilhe o QR Code." />
      }
      @for (event of events(); track event.id) {
        <a class="surface cluster" [routerLink]="['/app/events', event.id]">
          <div>
            <h3>{{ event.name }}</h3>
            <p class="muted">{{ formatWhen(event.startsAt) }}</p>
          </div>
          <tw-status-chip kind="event" [status]="event.status" />
        </a>
      }
    </main>
  `,
})
export class EventListPageComponent {
  private readonly eventsApi = inject(EventService);
  readonly events = signal<Event[]>([]);
  readonly formatWhen = formatEventWhen;

  constructor() {
    void this.eventsApi.listStoreEvents().then((rows) => this.events.set(rows));
  }
}
