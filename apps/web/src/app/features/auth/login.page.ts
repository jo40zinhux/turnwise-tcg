import { Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { AuthService } from '../../core/auth/auth.service';
import { ApiError } from '../../core/api/api-client';
import { UserRole } from '../../core/models/enums';

@Component({
  selector: 'tw-login-page',
  imports: [ReactiveFormsModule, RouterLink],
  template: `
    <main class="page-narrow stack-lg">
      <h1>Bem-vindo ao<br />TurnWise Events</h1>
      <p class="muted">Entre para gerenciar a loja ou acompanhar suas inscrições.</p>
      <form class="stack" [formGroup]="form" (ngSubmit)="submit()">
        <label class="field">
          <span>E-mail</span>
          <input formControlName="email" type="email" autocomplete="username" />
        </label>
        <label class="field">
          <span>Senha</span>
          <input formControlName="password" type="password" autocomplete="current-password" />
        </label>
        @if (error()) {
          <p class="field error">{{ error() }}</p>
        }
        <button class="btn btn-primary btn-block" [disabled]="form.invalid || loading()">
          {{ loading() ? 'Entrando…' : 'Entrar' }}
        </button>
      </form>
      <p class="muted">Jogador novo? <a routerLink="/signup">Criar conta</a></p>
    </main>
  `,
})
export class LoginPageComponent {
  private readonly fb = inject(FormBuilder);
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  readonly loading = signal(false);
  readonly error = signal<string | null>(null);
  readonly form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', Validators.required],
  });

  async submit() {
    if (this.form.invalid) {
      return;
    }
    this.loading.set(true);
    this.error.set(null);
    try {
      const session = await this.auth.login(
        this.form.getRawValue().email,
        this.form.getRawValue().password,
      );
      await this.router.navigateByUrl(
        session.user.role === UserRole.STORE_ADMIN ? '/app' : '/me',
      );
    } catch (err) {
      this.error.set(err instanceof ApiError ? err.message : 'Não foi possível entrar.');
    } finally {
      this.loading.set(false);
    }
  }
}
