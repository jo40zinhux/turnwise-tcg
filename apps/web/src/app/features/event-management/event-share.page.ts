import { Component, effect, inject, input, signal } from '@angular/core';
import { EventService } from '../../core/services/app-services';
import { QrPanelComponent } from '../../shared/ui/qr-panel/qr-panel.component';

@Component({
  selector: 'tw-event-share-page',
  imports: [QrPanelComponent],
  template: `
    <main class="page-narrow stack-lg">
      <h1>Compartilhar evento</h1>
      <p class="muted">Mostre o QR Code na loja ou copie o link para o WhatsApp.</p>
      @if (slug()) {
        <div class="surface">
          <tw-qr-panel [slug]="slug()" />
        </div>
      }
    </main>
  `,
})
export class EventSharePageComponent {
  private readonly events = inject(EventService);
  readonly eventId = input.required<string>();
  readonly slug = signal('');

  constructor() {
    effect(() => {
      void this.events
        .getStoreEvent(this.eventId())
        .then((view) => this.slug.set(view.event.slug));
    });
  }
}
