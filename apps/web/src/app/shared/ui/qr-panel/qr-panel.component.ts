import { Component, effect, inject, input, signal } from '@angular/core';
import { QrCodeService } from '../../../core/services/qr-code.service';
import { ToastService } from '../../../core/services/toast.service';

@Component({
  selector: 'tw-qr-panel',
  template: `
    <div class="stack">
      @if (src()) {
        <img [src]="src()" width="220" height="220" alt="QR Code do evento" />
      }
      <p class="muted">{{ url() }}</p>
      <div class="row">
        <button class="btn btn-surface" type="button" (click)="copy()">Copiar link</button>
        <button class="btn btn-surface" type="button" (click)="share()">Compartilhar</button>
      </div>
    </div>
  `,
})
export class QrPanelComponent {
  private readonly qr = inject(QrCodeService);
  private readonly toast = inject(ToastService);
  readonly slug = input.required<string>();
  readonly src = signal('');
  readonly url = signal('');

  constructor() {
    effect(() => {
      const slug = this.slug();
      if (!slug) {
        return;
      }
      this.url.set(this.qr.eventUrl(slug));
      void this.qr.toDataUrl(this.url()).then((value) => this.src.set(value));
    });
  }

  async copy() {
    await navigator.clipboard.writeText(this.url());
    this.toast.show('Link copiado.');
  }

  async share() {
    if (navigator.share) {
      await navigator.share({ title: 'TurnWise Events', url: this.url() });
      return;
    }
    await this.copy();
  }
}
