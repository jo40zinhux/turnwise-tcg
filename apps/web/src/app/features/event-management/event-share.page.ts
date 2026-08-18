import { Component, effect, inject, input, signal } from '@angular/core';
import { EventStatus } from '../../core/models/enums';
import { EventService } from '../../core/services/app-services';
import { QrPanelComponent } from '../../shared/ui/qr-panel/qr-panel.component';

@Component({
  selector: 'tw-event-share-page',
  imports: [QrPanelComponent],
  template: `
    <main class="page-narrow stack-lg">
      <h1>Compartilhar evento</h1>
      <p class="muted">Mostre o QR Code na loja ou copie o link para o WhatsApp.</p>
      @if (draft()) {
        <p class="banner-warning">
          O link só abre para o público depois de <strong>Abrir inscrições</strong>.
        </p>
      }
      @if (storeSlug() && eventSlug()) {
        <div class="surface">
          <tw-qr-panel [storeSlug]="storeSlug()" [eventSlug]="eventSlug()" />
        </div>
      }
    </main>
  `,
})
export class EventSharePageComponent {
  private readonly events = inject(EventService);
  readonly eventId = input.required<string>();
  readonly storeSlug = signal('');
  readonly eventSlug = signal('');
  readonly draft = signal(false);

  constructor() {
    effect(() => {
      void this.events.getStoreEvent(this.eventId()).then((view) => {
        this.storeSlug.set(view.store.slug);
        this.eventSlug.set(view.event.slug);
        this.draft.set(view.event.status === EventStatus.DRAFT);
      });
    });
  }
}
