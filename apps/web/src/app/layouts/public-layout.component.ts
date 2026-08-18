import { Component, inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../core/auth/auth.service';

@Component({
  selector: 'tw-public-layout',
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <header class="site-header">
      <a routerLink="/" class="brand">
        <img src="/logo.svg" width="32" height="32" alt="" />
        TurnWise Events
      </a>
      <nav class="nav-links">
        @if (auth.user(); as user) {
          @if (auth.isStoreAdmin()) {
            <a routerLink="/app" routerLinkActive="active">Loja</a>
          } @else {
            <a routerLink="/me" routerLinkActive="active">Minhas inscrições</a>
          }
          <button class="btn btn-ghost" type="button" (click)="logout()">Sair</button>
        } @else {
          <a routerLink="/login" routerLinkActive="active">Entrar</a>
        }
      </nav>
    </header>
    <router-outlet />
  `,
})
export class PublicLayoutComponent {
  readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  async logout() {
    await this.auth.logout();
    await this.router.navigateByUrl('/');
  }
}
