import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '../../core/auth/auth.service';
import { API_CLIENT } from '../../core/api/api-client.token';
import { Game } from '../../core/models/domain';
import { ToastService } from '../../core/services/toast.service';

@Component({
  selector: 'tw-profile-page',
  imports: [ReactiveFormsModule],
  template: `
    <main class="page-narrow stack-lg">
      <h1>Perfil</h1>
      <form class="stack" [formGroup]="form" (ngSubmit)="save()">
        <label class="field"><span>Nome completo</span><input formControlName="fullName" /></label>
        <label class="field"><span>Nome de exibição</span><input formControlName="displayName" /></label>
        <label class="field"><span>Telefone</span><input formControlName="phone" /></label>
        <button class="btn btn-primary" [disabled]="form.invalid">Salvar</button>
      </form>
      <section class="surface stack">
        <h3>Identificadores por jogo</h3>
        <form class="stack" [formGroup]="idForm" (ngSubmit)="addId()">
          <label class="field">
            <span>Jogo</span>
            <select formControlName="gameId">
              @for (game of games(); track game.id) {
                <option [value]="game.id">{{ game.name }}</option>
              }
            </select>
          </label>
          <label class="field"><span>Player ID</span><input formControlName="value" /></label>
          <button class="btn btn-surface" type="submit">Adicionar</button>
        </form>
      </section>
    </main>
  `,
})
export class ProfilePageComponent {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly api = inject(API_CLIENT);
  private readonly toast = inject(ToastService);
  readonly games = signal<Game[]>([]);
  readonly form = this.fb.nonNullable.group({
    fullName: [this.auth.user()?.fullName ?? '', Validators.required],
    displayName: [this.auth.user()?.displayName ?? '', Validators.required],
    phone: [this.auth.user()?.phone ?? ''],
  });
  readonly idForm = this.fb.nonNullable.group({
    gameId: ['pokemon', Validators.required],
    value: ['', Validators.required],
  });

  constructor() {
    void this.api.listGames().then((games) => this.games.set(games));
  }

  async save() {
    const user = await this.api.updateProfile(this.form.getRawValue());
    this.auth.restoreUser(user);
    this.toast.show('Perfil atualizado.');
  }

  async addId() {
    const value = this.idForm.getRawValue();
    await this.api.addGameIdentifier({
      gameId: value.gameId,
      type: 'PLAYER_ID',
      value: value.value,
    });
    this.idForm.patchValue({ value: '' });
    this.toast.show('Identificador salvo.');
  }
}
