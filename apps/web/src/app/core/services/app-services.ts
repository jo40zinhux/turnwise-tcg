import { Injectable, inject } from '@angular/core';
import { API_CLIENT } from '../api/api-client.token';
import { RegisterInput } from '../models/domain';

@Injectable({ providedIn: 'root' })
export class EventService {
  private readonly api = inject(API_CLIENT);

  getPublic(storeSlug: string, eventSlug: string) {
    return this.api.getPublicEvent(storeSlug, eventSlug);
  }

  listGames() {
    return this.api.listGames();
  }

  listStoreEvents() {
    return this.api.listStoreEvents();
  }

  getStoreEvent(id: string) {
    return this.api.getStoreEvent(id);
  }

  create(input: Parameters<typeof this.api.createEvent>[0]) {
    return this.api.createEvent(input);
  }

  update(...args: Parameters<typeof this.api.updateEvent>) {
    return this.api.updateEvent(...args);
  }

  setStatus(...args: Parameters<typeof this.api.setEventStatus>) {
    return this.api.setEventStatus(...args);
  }
}

@Injectable({ providedIn: 'root' })
export class RegistrationService {
  private readonly api = inject(API_CLIENT);

  register(input: RegisterInput) {
    return this.api.register(input);
  }

  get(id: string, accessToken?: string) {
    return this.api.getRegistration(id, accessToken);
  }

  mine() {
    return this.api.listMyRegistrations();
  }

  cancel(id: string) {
    return this.api.cancelRegistration(id);
  }
}

@Injectable({ providedIn: 'root' })
export class PaymentService {
  private readonly api = inject(API_CLIENT);

  startCheckout(registrationId: string) {
    return this.api.startMercadoPagoCheckout(registrationId);
  }

  get(id: string) {
    return this.api.getPayment(id);
  }

  notifySandbox(
    paymentId: string,
    status: 'APPROVED' | 'FAILED' | 'CANCELLED',
  ) {
    return this.api.applyPaymentNotification(paymentId, status);
  }
}

@Injectable({ providedIn: 'root' })
export class StoreService {
  private readonly api = inject(API_CLIENT);

  dashboard() {
    return this.api.getDashboard();
  }

  current() {
    return this.api.getStore();
  }

  participants(...args: Parameters<typeof this.api.listParticipants>) {
    return this.api.listParticipants(...args);
  }

  markPaid(registrationId: string) {
    return this.api.markOnSitePaid(registrationId);
  }

  cancel(registrationId: string) {
    return this.api.cancelAsStore(registrationId);
  }

  promote(registrationId: string) {
    return this.api.promoteFromWaitlist(registrationId);
  }
}
