import { Component, inject } from '@angular/core';
import { Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AuthService } from '../core/auth/auth.service';

@Component({
  selector: 'tw-store-layout',
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <div class="store-shell">
      <aside class="store-side">
        <a routerLink="/app" class="brand">
          <img src="/logo.svg" width="32" height="32" alt="" />
          TurnWise Events
        </a>
        <nav>
          <a routerLink="/app" routerLinkActive="active" [routerLinkActiveOptions]="{ exact: true }">Dashboard</a>
          <a routerLink="/app/events" routerLinkActive="active">Eventos</a>
          <a routerLink="/app/settings" routerLinkActive="active">Loja</a>
        </nav>
        <button class="btn btn-ghost" type="button" (click)="logout()">Sair</button>
      </aside>
      <div>
        <router-outlet />
      </div>
    </div>
  `,
})
export class StoreLayoutComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  async logout() {
    await this.auth.logout();
    await this.router.navigateByUrl('/');
  }
}
