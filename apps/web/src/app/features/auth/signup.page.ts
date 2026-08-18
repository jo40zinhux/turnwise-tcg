import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { ApiError } from '../../core/api/api-client';

@Component({
  selector: 'tw-signup-page',
  imports: [ReactiveFormsModule, RouterLink],
  template: `
    <main class="page-narrow stack-lg">
      <h1>Criar conta</h1>
      <p class="muted">Cadastro de jogador. Lojas entram por convite.</p>
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
          <span>Senha</span>
          <input formControlName="password" type="password" autocomplete="new-password" />
        </label>
        <label class="check">
          <input formControlName="acceptedTerms" type="checkbox" />
          <span>Li e aceito os <a routerLink="/legal/terms">termos</a> e a <a routerLink="/legal/privacy">política de privacidade</a>.</span>
        </label>
        @if (error()) {
          <p class="field error">{{ error() }}</p>
        }
        <button class="btn btn-primary btn-block" [disabled]="form.invalid || loading()">
          {{ loading() ? 'Criando…' : 'Criar conta' }}
        </button>
      </form>
      <a routerLink="/login">Já tenho conta</a>
    </main>
  `,
})
export class SignupPageComponent {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly form = this.fb.nonNullable.group({
    fullName: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
    acceptedTerms: [false, Validators.requiredTrue],
  });

  async submit() {
    if (this.form.invalid) {
      return;
    }
    this.loading.set(true);
    this.error.set(null);
    try {
      await this.auth.signup(this.form.getRawValue());
      await this.router.navigateByUrl('/me');
    } catch (err) {
      this.error.set(err instanceof ApiError ? err.message : 'Não foi possível criar a conta.');
    } finally {
      this.loading.set(false);
    }
  }
}
