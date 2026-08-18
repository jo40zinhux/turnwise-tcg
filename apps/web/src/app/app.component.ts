import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ToastService } from './core/services/toast.service';

@Component({
  selector: 'tw-root',
  imports: [RouterOutlet],
  template: `
    <router-outlet />
    @if (toast.message(); as message) {
      <div class="tw-toast" role="status">{{ message }}</div>
    }
  `,
  styles: `
    .tw-toast {
      position: fixed;
      z-index: var(--z-toast);
      left: 50%;
      bottom: 24px;
      transform: translateX(-50%);
      background: #262626;
      color: #fff;
      padding: 14px 20px;
      border-radius: 16px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
      max-width: min(92vw, 420px);
    }
  `,
})
export class AppComponent {
  readonly toast = inject(ToastService);
}
