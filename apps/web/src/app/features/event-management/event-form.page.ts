import { Component, effect, inject, input, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { Game } from '../../core/models/domain';
import { PaymentMode } from '../../core/models/enums';
import { EventService } from '../../core/services/app-services';
import { ToastService } from '../../core/services/toast.service';

@Component({
  selector: 'tw-event-form-page',
  imports: [ReactiveFormsModule],
  template: `
    <main class="page-narrow stack-lg">
      <h1>{{ eventId() ? 'Editar evento' : 'Novo evento' }}</h1>
      <form class="stack" [formGroup]="form" (ngSubmit)="save()">
        <label class="field"><span>Nome</span><input formControlName="name" /></label>
        <label class="field">
          <span>Jogo</span>
          <select formControlName="gameId">
            @for (game of games(); track game.id) {
              <option [value]="game.id">{{ game.name }}</option>
            }
          </select>
        </label>
        <label class="field"><span>Descrição</span><textarea formControlName="description"></textarea></label>
        <label class="field"><span>Regras / instruções</span><textarea formControlName="rules"></textarea></label>
        <label class="field"><span>Data e horário</span><input formControlName="startsAt" type="datetime-local" /></label>
        <label class="field"><span>Local</span><input formControlName="locationName" /></label>
        <label class="field"><span>Endereço</span><input formControlName="address" /></label>
        <label class="field"><span>Vagas</span><input formControlName="maxParticipants" type="number" min="1" /></label>
        <label class="field"><span>Valor (R$)</span><input formControlName="price" type="number" min="0" step="0.01" /></label>
        <label class="field">
          <span>Pagamento</span>
          <select formControlName="paymentMode">
            <option [value]="online">Mercado Pago</option>
            <option [value]="onSite">Somente no local</option>
            <option [value]="choice">Jogador escolhe</option>
          </select>
        </label>
        <label class="check"><input formControlName="allowWaitlist" type="checkbox" /><span>Permitir waitlist quando lotar</span></label>
        <label class="check"><input formControlName="refundEnabled" type="checkbox" /><span>Loja oferece reembolso (via WhatsApp)</span></label>
        <label class="field"><span>Taxa de reembolso (%)</span><input formControlName="feePercent" type="number" min="0" max="100" /></label>
        <button class="btn btn-primary" [disabled]="form.invalid || saving()">Salvar</button>
      </form>
    </main>
  `,
})
export class EventFormPageComponent {
  private readonly fb = inject(FormBuilder);
  private readonly events = inject(EventService);
  private readonly router = inject(Router);
  private readonly toast = inject(ToastService);
  readonly eventId = input<string>();
  readonly games = signal<Game[]>([]);
  readonly saving = signal(false);
  readonly online = PaymentMode.ONLINE;
  readonly onSite = PaymentMode.PAY_ON_SITE;
  readonly choice = PaymentMode.PLAYER_CHOICE;
  readonly form = this.fb.nonNullable.group({
    name: ['', Validators.required],
    gameId: ['pokemon', Validators.required],
    description: [''],
    rules: [''],
    startsAt: ['', Validators.required],
    locationName: ['', Validators.required],
    address: [''],
    maxParticipants: [32, [Validators.required, Validators.min(1)]],
    price: [50, [Validators.required, Validators.min(0)]],
    paymentMode: this.fb.nonNullable.control<PaymentMode>(
      PaymentMode.ONLINE,
      Validators.required,
    ),
    allowWaitlist: [true],
    refundEnabled: [true],
    feePercent: [20],
  });

  constructor() {
    void this.events.listGames().then((games) => this.games.set(games));
    effect(() => {
      const id = this.eventId();
      if (id) {
        void this.load(id);
      }
    });
  }

  async save() {
    const value = this.form.getRawValue();
    const payload = {
      name: value.name,
      gameId: value.gameId,
      description: value.description,
      rules: value.rules,
      startsAt: new Date(value.startsAt).toISOString(),
      locationName: value.locationName,
      address: value.address,
      maxParticipants: Number(value.maxParticipants),
      priceCents: Math.round(Number(value.price) * 100),
      paymentMode: value.paymentMode,
      allowWaitlist: value.allowWaitlist,
      refundPolicy: {
        enabled: value.refundEnabled,
        feePercent: Number(value.feePercent),
      },
    };
    this.saving.set(true);
    try {
      const event = this.eventId()
        ? await this.events.update(this.eventId()!, payload)
        : await this.events.create(payload);
      this.toast.show('Evento salvo.');
      await this.router.navigate(['/app/events', event.id]);
    } finally {
      this.saving.set(false);
    }
  }

  private async load(id: string) {
    const view = await this.events.getStoreEvent(id);
    const local = view.event.startsAt.slice(0, 16);
    this.form.patchValue({
      name: view.event.name,
      gameId: view.event.gameId,
      description: view.event.description,
      rules: view.event.rules,
      startsAt: local,
      locationName: view.event.locationName,
      address: view.event.address,
      maxParticipants: view.event.maxParticipants,
      price: view.event.priceCents / 100,
      paymentMode: view.event.paymentMode,
      allowWaitlist: view.event.allowWaitlist,
      refundEnabled: view.event.refundPolicy.enabled,
      feePercent: view.event.refundPolicy.feePercent,
    });
  }
}
