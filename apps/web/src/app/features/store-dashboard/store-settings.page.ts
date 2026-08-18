import { Component, inject, signal } from '@angular/core';
import { Store } from '../../core/models/domain';
import { StoreService } from '../../core/services/app-services';

@Component({
  selector: 'tw-store-settings-page',
  template: `
    <main class="page-narrow stack-lg">
      <h1>Loja</h1>
      @if (store(); as item) {
        <section class="surface stack">
          <h3>{{ item.name }}</h3>
          <p class="muted">{{ item.locationName }}</p>
          <p class="muted">{{ item.address }}</p>
          <p class="muted">{{ item.city }}/{{ item.state }}</p>
          <p>WhatsApp: {{ item.whatsapp }}</p>
          <p class="muted">
            Reembolso padrão:
            @if (item.defaultRefundPolicy.enabled) {
              taxa de {{ item.defaultRefundPolicy.feePercent }}%
            } @else {
              não garante reembolso automático
            }
          </p>
          <p class="subtle">Cadastro de novas lojas é feito por convite neste MVP.</p>
        </section>
      }
    </main>
  `,
})
export class StoreSettingsPageComponent {
  private readonly stores = inject(StoreService);
  readonly store = signal<Store | null>(null);

  constructor() {
    void this.stores.current().then((value) => this.store.set(value));
  }
}
