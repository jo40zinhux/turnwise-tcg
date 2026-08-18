import { Component, effect, inject, input, signal, viewChild } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ParticipantFilter, PaymentStatus, RegistrationStatus } from '../../core/models/enums';
import { ParticipantRow } from '../../core/models/domain';
import { StoreService } from '../../core/services/app-services';
import { ToastService } from '../../core/services/toast.service';
import { ConfirmDialogComponent } from '../../shared/ui/confirm-dialog/confirm-dialog.component';
import { StatusChipComponent } from '../../shared/ui/status-chip/status-chip.component';

@Component({
  selector: 'tw-participants-page',
  imports: [FormsModule, StatusChipComponent, ConfirmDialogComponent],
  template: `
    <main class="page stack-lg">
      <h1>Participantes</h1>
      <input
        class="field"
        style="width:100%;background:var(--table-surface);border:0;border-radius:16px;padding:16px 20px"
        type="search"
        aria-label="Buscar participantes"
        placeholder="Buscar nome, e-mail ou ID do jogo"
        [ngModel]="search()"
        (ngModelChange)="search.set($event); reload()"
      />
      <div class="filters">
        @for (item of filters; track item.id) {
          <button type="button" [class.active]="filter() === item.id" (click)="setFilter(item.id)">{{ item.label }}</button>
        }
      </div>
      <div style="overflow:auto">
        <table class="data-table">
          <thead>
            <tr>
              <th>Jogador</th>
              <th>Status</th>
              <th>Pagamento</th>
              <th>Inscrição</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            @for (row of rows(); track row.registration.id) {
              <tr>
                <td>
                  <strong>{{ row.player.displayName }}</strong>
                  <div class="subtle">{{ row.player.email }}</div>
                </td>
                <td><tw-status-chip kind="registration" [status]="row.registration.status" /></td>
                <td>
                  @if (row.payment) {
                    <tw-status-chip kind="payment" [status]="row.payment.status" />
                  }
                </td>
                <td>{{ row.registration.status }}</td>
                <td>
                  <div class="row">
                    @if (row.payment?.status === onSite) {
                      <button class="btn btn-surface" type="button" (click)="markPaid(row)">Marcar pago</button>
                    }
                    @if (row.registration.status === waitlist) {
                      <button class="btn btn-surface" type="button" (click)="promote(row)">Promover</button>
                    }
                    @if (row.registration.status !== cancelled) {
                      <button class="btn btn-ghost" type="button" (click)="cancel(row)">Cancelar</button>
                    }
                  </div>
                </td>
              </tr>
            }
          </tbody>
        </table>
      </div>
      <tw-confirm-dialog />
    </main>
  `,
})
export class ParticipantsPageComponent {
  private readonly store = inject(StoreService);
  private readonly toast = inject(ToastService);
  readonly eventId = input.required<string>();
  readonly rows = signal<ParticipantRow[]>([]);
  readonly search = signal('');
  readonly filter = signal<string>(ParticipantFilter.ALL);
  readonly confirm = viewChild.required(ConfirmDialogComponent);
  readonly onSite = PaymentStatus.PAY_ON_SITE;
  readonly waitlist = RegistrationStatus.WAITLIST;
  readonly cancelled = RegistrationStatus.CANCELLED;
  readonly filters = [
    { id: ParticipantFilter.ALL, label: 'Todos' },
    { id: ParticipantFilter.CONFIRMED, label: 'Confirmados' },
    { id: ParticipantFilter.PENDING, label: 'Pendentes' },
    { id: ParticipantFilter.PAID, label: 'Pagos' },
    { id: ParticipantFilter.UNPAID, label: 'Não pagos' },
    { id: ParticipantFilter.PAY_ON_SITE, label: 'No local' },
    { id: ParticipantFilter.WAITLIST, label: 'Waitlist' },
    { id: ParticipantFilter.CANCELLED, label: 'Cancelados' },
  ];

  constructor() {
    effect(() => {
      this.eventId();
      void this.reload();
    });
  }

  setFilter(id: string) {
    this.filter.set(id);
    void this.reload();
  }

  async markPaid(row: ParticipantRow) {
    await this.store.markPaid(row.registration.id);
    this.toast.show('Pagamento no local marcado como pago.');
    await this.reload();
  }

  async promote(row: ParticipantRow) {
    await this.store.promote(row.registration.id);
    this.toast.show('Jogador promovido da waitlist.');
    await this.reload();
  }

  async cancel(row: ParticipantRow) {
    const ok = await this.confirm().open({
      title: 'Cancelar inscrição?',
      body: `Remover ${row.player.displayName} da lista. A vaga pode ir para a waitlist.`,
      confirmLabel: 'Cancelar inscrição',
    });
    if (!ok) {
      return;
    }
    await this.store.cancel(row.registration.id);
    this.toast.show('Inscrição cancelada.');
    await this.reload();
  }

  async reload() {
    this.rows.set(
      await this.store.participants(this.eventId(), {
        filter: this.filter(),
        search: this.search(),
      }),
    );
  }

}
