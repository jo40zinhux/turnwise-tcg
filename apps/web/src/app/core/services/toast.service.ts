import { Injectable, signal } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class ToastService {
  readonly message = signal<string | null>(null);

  show(message: string): void {
    this.message.set(message);
    window.setTimeout(() => {
      if (this.message() === message) {
        this.message.set(null);
      }
    }, 3400);
  }
}
