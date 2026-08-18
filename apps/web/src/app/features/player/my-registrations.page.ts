import { Component, inject, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { RegistrationView } from '../../core/models/domain';
import { RegistrationService } from '../../core/services/app-services';
import { EmptyStateComponent } from '../../shared/ui/empty-state/empty-state.component';
import { StatusChipComponent } from '../../shared/ui/status-chip/status-chip.component';
import { formatEventWhen } from '../../shared/pipes/formatters';

@Component({
  selector: 'tw-my-registrations-page',
  imports: [RouterLink, StatusChipComponent, EmptyStateComponent],
  template: `
    <main class="page stack-lg">
      <div class="cluster">
        <h1>Minhas inscrições</h1>
        <a routerLink="/me/profile">Perfil</a>
      </div>
      @if (!items().length) {
        <tw-empty-state
          title="Nenhuma inscrição ainda"
          body="Escaneie o QR Code da loja ou abra o link do evento para se inscrever."
        />
      } @else {
        <div class="stack">
          @for (item of items(); track item.registration.id) {
            <a class="surface cluster" [routerLink]="['/r', item.registration.id]">
              <div>
                <h3>{{ item.event.name }}</h3>
                <p class="muted">{{ formatWhen(item.event.startsAt) }}</p>
              </div>
              <div class="row">
                <tw-status-chip kind="registration" [status]="item.registration.status" />
                @if (item.payment) {
                  <tw-status-chip kind="payment" [status]="item.payment.status" />
                }
              </div>
            </a>
          }
        </div>
      }
    </main>
  `,
})
export class MyRegistrationsPageComponent {
  private readonly registrations = inject(RegistrationService);
  readonly items = signal<RegistrationView[]>([]);
  readonly formatWhen = formatEventWhen;

  constructor() {
    void this.registrations.mine().then((rows) => this.items.set(rows));
  }
}
