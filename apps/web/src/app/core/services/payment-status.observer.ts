import { Injectable, inject } from '@angular/core';
import { interval, map, startWith, switchMap, takeWhile } from 'rxjs';
import { Payment } from '../models/domain';
import { PaymentStatus } from '../models/enums';
import { PaymentService } from './app-services';

/**
 * Observes backend payment state. The UI never marks a payment as approved
 * on its own — it only reacts to status returned by the API (webhook later).
 */
@Injectable({ providedIn: 'root' })
export class PaymentStatusObserver {
  private readonly payments = inject(PaymentService);

  observe(paymentId: string) {
    return interval(2000).pipe(
      startWith(0),
      switchMap(() => this.payments.get(paymentId)),
      takeWhile(
        (payment: Payment) => payment.status === PaymentStatus.PENDING,
        true,
      ),
      map((payment) => payment),
    );
  }
}
