import { Injectable } from '@angular/core';
import * as QRCode from 'qrcode';

@Injectable({ providedIn: 'root' })
export class QrCodeService {
  toDataUrl(value: string): Promise<string> {
    return QRCode.toDataURL(value, {
      margin: 1,
      width: 280,
      color: { dark: '#121212', light: '#ffffff' },
    });
  }

  eventPath(storeSlug: string, eventSlug: string): string {
    return `/events/${storeSlug}/${eventSlug}`;
  }

  eventUrl(storeSlug: string, eventSlug: string): string {
    return `${window.location.origin}${this.eventPath(storeSlug, eventSlug)}`;
  }
}
