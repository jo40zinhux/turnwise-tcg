import { Component, effect, inject, input, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { ApiError } from '../../core/api/api-client';
import { AuthService } from '../../core/auth/auth.service';
import { PublicEventView } from '../../core/models/domain';
import { PaymentMethod, PaymentMode } from '../../core/models/enums';
import { EventService, RegistrationService } from '../../core/services/app-services';
import { ToastService } from '../../core/services/toast.service';

@Component({
  selector: 'tw-register-page',
  imports: [ReactiveFormsModule, RouterLink],
  template: `
    <main class="page-narrow stack-lg">
      <a routerLink="../">← Voltar ao evento</a>
      @if (view(); as data) {
        <h1>Inscrição</h1>
        <p class="muted">{{ data.event.name }} · {{ data.game.name }}</p>
        @if (data.capacity.available === 0) {
          <p class="banner-warning">Evento lotado. Você entra na waitlist.</p>
        }
        <form class="stack" [formGroup]="form" (ngSubmit)="submit()">
          <label class="field">
            <span>Nome completo</span>
            <input formControlName="fullName" autocomplete="name" />
          </label>
          <label class="field">
            <span>E-mail</span>
            <input formControlName="email" type="email" autocomplete="email" />
          </label>
          <label class="field">
            <span>Telefone (opcional)</span>
            <input formControlName="phone" autocomplete="tel" />
          </label>
          <label class="field">
            <span>ID do jogo (opcional)</span>
            <input formControlName="gameIdentifierValue" />
          </label>
          @if (data.event.paymentMode === playerChoice) {
            <label class="field">
              <span>Pagamento</span>
              <select formControlName="paymentChoice">
                <option [value]="mp">Mercado Pago</option>
                <option [value]="onSite">Pagar no local</option>
              </select>
            </label>
          }
          @if (!auth.user()?.hasPassword) {
            <label class="field">
              <span>Criar senha (opcional)</span>
              <input formControlName="createPassword" type="password" autocomplete="new-password" />
            </label>
            <p class="subtle">Sem senha você ainda acompanha a inscrição por este dispositivo.</p>
          }
          <label class="check">
            <input formControlName="acceptedTerms" type="checkbox" />
            <span>Aceito os <a routerLink="/legal/terms">termos</a> e a <a routerLink="/legal/privacy">privacidade</a>.</span>
          </label>
          @if (error()) {
            <p class="field error">{{ error() }}</p>
          }
          <button class="btn btn-primary btn-block" [disabled]="form.invalid || loading()">
            {{ loading() ? 'Enviando…' : 'Confirmar inscrição' }}
          </button>
        </form>
      }
    </main>
  `,
})
export class RegisterPageComponent {
  private readonly fb = inject(FormBuilder);
  private readonly events = inject(EventService);
  private readonly registrations = inject(RegistrationService);
  private readonly router = inject(Router);
  private readonly toast = inject(ToastService);
  readonly auth = inject(AuthService);
  readonly slug = input.required<string>();
  readonly view = signal<PublicEventView | null>(null);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly playerChoice = PaymentMode.PLAYER_CHOICE;
  readonly mp = PaymentMethod.MERCADO_PAGO;
  readonly onSite = PaymentMethod.ON_SITE;
  readonly form = this.fb.nonNullable.group({
    fullName: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    phone: [''],
    gameIdentifierValue: [''],
    paymentChoice: [PaymentMethod.MERCADO_PAGO],
    createPassword: [''],
    acceptedTerms: [false, Validators.requiredTrue],
  });

  constructor() {
    const user = this.auth.user();
    if (user) {
      this.form.patchValue({
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
      });
    }
    effect(() => {
      void this.events.getPublic(this.slug()).then((data) => this.view.set(data));
    });
  }

  async submit() {
    if (this.form.invalid) {
      return;
    }
    this.loading.set(true);
    this.error.set(null);
    const value = this.form.getRawValue();
    try {
      const result = await this.registrations.register({
        eventSlug: this.slug(),
        fullName: value.fullName,
        email: value.email,
        phone: value.phone || undefined,
        gameIdentifierValue: value.gameIdentifierValue || undefined,
        paymentChoice: value.paymentChoice,
        acceptedTerms: value.acceptedTerms,
        createPassword: value.createPassword || undefined,
      });
      await this.auth.claimGuest(
        result.registration.id,
        result.registration.guestAccessToken,
      );
      this.toast.show('Inscrição criada.');
      await this.router.navigate(['/r', result.registration.id]);
    } catch (err) {
      this.error.set(err instanceof ApiError ? err.message : 'Não foi possível inscrever.');
    } finally {
      this.loading.set(false);
    }
  }
}
