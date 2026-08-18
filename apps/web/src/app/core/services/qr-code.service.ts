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

  eventUrl(slug: string): string {
    return `${window.location.origin}/events/${slug}`;
  }
}
