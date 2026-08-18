import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../../../environments/environment';
import { ApiClient } from '../api-client';
import {
  CreateEventInput,
  Event,
  Game,
  GameIdentifier,
  GameIdentifierInput,
  ParticipantQuery,
  ParticipantRow,
  Payment,
  PublicEventView,
  RegisterInput,
  RegistrationView,
  Session,
  SignupInput,
  Store,
  StoreDashboardView,
  UpdateEventInput,
  UpdateProfileInput,
  User,
} from '../../models/domain';
import { EventStatus, PaymentStatus } from '../../models/enums';

@Injectable()
export class HttpApiClient implements ApiClient {
  private readonly base = environment.apiBaseUrl;

  constructor(private readonly http: HttpClient) {}

  login(email: string, password: string): Promise<Session> {
    return this.post('/auth/login', { email, password });
  }
  signup(input: SignupInput): Promise<Session> {
    return this.post('/auth/signup', input);
  }
  logout(): Promise<void> {
    return this.post('/auth/logout', {});
  }
  currentSession(): Promise<Session | null> {
    return this.get('/auth/session');
  }
  updateProfile(input: UpdateProfileInput): Promise<User> {
    return this.patch('/me', input);
  }
  addGameIdentifier(input: GameIdentifierInput): Promise<GameIdentifier> {
    return this.post('/me/game-identifiers', input);
  }
  listGames(): Promise<Game[]> {
    return this.get('/games');
  }
  getPublicEvent(storeSlug: string, eventSlug: string): Promise<PublicEventView> {
    return this.get(`/events/${storeSlug}/${eventSlug}`);
  }
  register(input: RegisterInput): Promise<RegistrationView> {
    return this.post(
      `/events/${input.storeSlug}/${input.eventSlug}/registrations`,
      input,
    );
  }
  claimGuestSession(
    registrationId: string,
    accessToken: string,
  ): Promise<Session> {
    return this.post('/auth/guest-session', { registrationId, accessToken });
  }
  getRegistration(id: string, accessToken?: string): Promise<RegistrationView> {
    const query = accessToken ? `?access=${encodeURIComponent(accessToken)}` : '';
    return this.get(`/registrations/${id}${query}`);
  }
  listMyRegistrations(): Promise<RegistrationView[]> {
    return this.get('/me/registrations');
  }
  cancelRegistration(id: string): Promise<RegistrationView> {
    return this.post(`/registrations/${id}/cancel`, {});
  }
  setPassword(password: string): Promise<User> {
    return this.post('/me/password', { password });
  }
  startMercadoPagoCheckout(registrationId: string): Promise<Payment> {
    return this.post(`/registrations/${registrationId}/payments/mercadopago`, {});
  }
  getPayment(id: string): Promise<Payment> {
    return this.get(`/payments/${id}`);
  }
  applyPaymentNotification(
    paymentId: string,
    status: Extract<PaymentStatus, 'APPROVED' | 'FAILED' | 'CANCELLED'>,
  ): Promise<Payment> {
    return this.post(`/payments/${paymentId}/notifications`, { status });
  }
  getStore(): Promise<Store> {
    return this.get('/store');
  }
  getDashboard(): Promise<StoreDashboardView> {
    return this.get('/store/dashboard');
  }
  listStoreEvents(): Promise<Event[]> {
    return this.get('/store/events');
  }
  getStoreEvent(id: string): Promise<PublicEventView> {
    return this.get(`/store/events/${id}`);
  }
  createEvent(input: CreateEventInput): Promise<Event> {
    return this.post('/store/events', input);
  }
  updateEvent(id: string, input: UpdateEventInput): Promise<Event> {
    return this.patch(`/store/events/${id}`, input);
  }
  setEventStatus(id: string, status: EventStatus): Promise<Event> {
    return this.post(`/store/events/${id}/status`, { status });
  }
  listParticipants(
    eventId: string,
    query: ParticipantQuery,
  ): Promise<ParticipantRow[]> {
    const params = new URLSearchParams({
      filter: query.filter,
      search: query.search,
    });
    return this.get(`/store/events/${eventId}/participants?${params.toString()}`);
  }
  markOnSitePaid(registrationId: string): Promise<RegistrationView> {
    return this.post(`/store/registrations/${registrationId}/pay-on-site`, {});
  }
  cancelAsStore(registrationId: string): Promise<RegistrationView> {
    return this.post(`/store/registrations/${registrationId}/cancel`, {});
  }
  promoteFromWaitlist(registrationId: string): Promise<RegistrationView> {
    return this.post(`/store/registrations/${registrationId}/promote`, {});
  }

  private get<T>(path: string): Promise<T> {
    return firstValueFrom(this.http.get<T>(`${this.base}${path}`));
  }
  private post<T>(path: string, body: unknown): Promise<T> {
    return firstValueFrom(this.http.post<T>(`${this.base}${path}`, body));
  }
  private patch<T>(path: string, body: unknown): Promise<T> {
    return firstValueFrom(this.http.patch<T>(`${this.base}${path}`, body));
  }
}
