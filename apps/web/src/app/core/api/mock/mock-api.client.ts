import { Injectable } from '@angular/core';
import { SESSION_STORAGE_KEY } from '../../auth/session';
import { ApiClient, ApiError } from '../api-client';
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
import { EventStatus, PaymentStatus, UserRole } from '../../models/enums';
import { InMemoryDb } from './in-memory-db';

function wait(ms = 180): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

@Injectable()
export class MockApiClient implements ApiClient {
  private readonly db = new InMemoryDb();
  private readonly tokens = new Map<string, { userId: string; storeId?: string }>();

  async login(email: string, password: string): Promise<Session> {
    await wait();
    const user = this.db.users.find(
      (item) => item.email === email.trim().toLowerCase(),
    );
    if (!user || this.db.passwords.get(user.id) !== password) {
      throw new ApiError('E-mail ou senha inválidos.', 'INVALID_CREDENTIALS', 401);
    }
    return this.issue(user);
  }

  async signup(input: SignupInput): Promise<Session> {
    await wait();
    if (!input.acceptedTerms) {
      throw new ApiError('Aceite os termos para continuar.', 'TERMS_REQUIRED');
    }
    const email = input.email.trim().toLowerCase();
    const existing = this.db.users.find((item) => item.email === email);
    if (existing?.hasPassword) {
      throw new ApiError('Já existe uma conta com este e-mail.', 'EMAIL_TAKEN');
    }
    const user =
      existing ??
      ({
        id: `user_${crypto.randomUUID().slice(0, 8)}`,
        email,
        fullName: input.fullName.trim(),
        displayName: input.fullName.trim(),
        phone: input.phone?.trim() ?? '',
        role: UserRole.PLAYER,
        hasPassword: true,
        acceptedTermsAt: new Date().toISOString(),
      } satisfies User);
    if (!existing) {
      this.db.users.push(user);
    }
    user.hasPassword = true;
    user.fullName = input.fullName.trim();
    this.db.passwords.set(user.id, input.password);
    return this.issue(user);
  }

  async logout(): Promise<void> {
    await wait(60);
    const session = this.readStoredSession();
    if (session) {
      this.tokens.delete(session.token);
    }
  }

  async currentSession(): Promise<Session | null> {
    await wait(40);
    return this.readStoredSession();
  }

  async updateProfile(input: UpdateProfileInput): Promise<User> {
    await wait();
    const user = this.requireActor();
    Object.assign(user, {
      fullName: input.fullName?.trim() ?? user.fullName,
      displayName: input.displayName?.trim() ?? user.displayName,
      phone: input.phone?.trim() ?? user.phone,
      city: input.city?.trim() ?? user.city,
      state: input.state?.trim() ?? user.state,
    });
    return { ...user };
  }

  async addGameIdentifier(input: GameIdentifierInput): Promise<GameIdentifier> {
    await wait();
    const user = this.requireActor();
    this.db.requireGame(input.gameId);
    const identifier: GameIdentifier = {
      id: `gid_${crypto.randomUUID().slice(0, 8)}`,
      userId: user.id,
      gameId: input.gameId,
      type: input.type.trim() || 'PLAYER_ID',
      value: input.value.trim(),
    };
    this.db.identifiers.push(identifier);
    return identifier;
  }

  async listGames(): Promise<Game[]> {
    await wait(80);
    return [...this.db.games];
  }

  async getPublicEvent(storeSlug: string, eventSlug: string): Promise<PublicEventView> {
    await wait();
    const event = this.db.findEventBySlug(storeSlug, eventSlug);
    if (!event || event.status === EventStatus.DRAFT) {
      throw new ApiError('Evento não encontrado.', 'NOT_FOUND', 404);
    }
    return this.db.toPublic(event);
  }

  async register(input: RegisterInput): Promise<RegistrationView> {
    await wait(240);
    if (!input.acceptedTerms) {
      throw new ApiError('Aceite os termos para se inscrever.', 'TERMS_REQUIRED');
    }
    try {
      return this.db.register(input, this.optionalActor());
    } catch (error) {
      throw new ApiError((error as Error).message, 'REGISTER_FAILED');
    }
  }

  async claimGuestSession(
    registrationId: string,
    accessToken: string,
  ): Promise<Session> {
    await wait(80);
    const existing = this.optionalActor();
    if (existing) {
      return this.issue(existing);
    }
    const registration = this.db.registrations.find(
      (item) => item.id === registrationId,
    );
    if (
      !registration ||
      registration.guestAccessToken !== accessToken
    ) {
      throw new ApiError('Link de inscrição inválido.', 'FORBIDDEN', 403);
    }
    return this.issue(this.db.requireUser(registration.userId));
  }

  async getRegistration(
    id: string,
    accessToken?: string,
  ): Promise<RegistrationView> {
    await wait();
    const registration = this.db.registrations.find((item) => item.id === id);
    if (!registration) {
      throw new ApiError('Inscrição não encontrada.', 'NOT_FOUND', 404);
    }
    const actor = this.optionalActor();
    const storeId = this.currentStoreId();
    const allowed =
      actor?.id === registration.userId ||
      storeId === registration.storeId ||
      (accessToken && accessToken === registration.guestAccessToken);
    if (!allowed) {
      throw new ApiError('Você não pode ver esta inscrição.', 'FORBIDDEN', 403);
    }
    return this.db.toRegistrationView(registration);
  }

  async listMyRegistrations(): Promise<RegistrationView[]> {
    await wait();
    const actor = this.requireActor();
    return this.db.registrations
      .filter((item) => item.userId === actor.id)
      .map((item) => this.db.toRegistrationView(item));
  }

  async cancelRegistration(id: string): Promise<RegistrationView> {
    await wait();
    const actor = this.requireActor();
    try {
      return this.db.cancelByPlayer(id, actor.id);
    } catch (error) {
      throw new ApiError((error as Error).message, 'CANCEL_FAILED');
    }
  }

  async setPassword(password: string): Promise<User> {
    await wait();
    const user = this.requireActor();
    this.db.passwords.set(user.id, password);
    user.hasPassword = true;
    return { ...user };
  }

  async startMercadoPagoCheckout(registrationId: string): Promise<Payment> {
    await wait();
    const actor = this.requireActor();
    try {
      return this.db.startCheckout(registrationId, actor.id);
    } catch (error) {
      throw new ApiError((error as Error).message, 'CHECKOUT_FAILED');
    }
  }

  async getPayment(id: string): Promise<Payment> {
    await wait(80);
    const payment = this.db.payments.find((item) => item.id === id);
    if (!payment) {
      throw new ApiError('Pagamento não encontrado.', 'NOT_FOUND', 404);
    }
    return { ...payment };
  }

  async applyPaymentNotification(
    paymentId: string,
    status: Extract<PaymentStatus, 'APPROVED' | 'FAILED' | 'CANCELLED'>,
  ): Promise<Payment> {
    await wait(120);
    try {
      return { ...this.db.applyPaymentNotification(paymentId, status) };
    } catch (error) {
      throw new ApiError((error as Error).message, 'WEBHOOK_FAILED');
    }
  }

  async getStore(): Promise<Store> {
    await wait();
    return { ...this.db.requireStore(this.requireStoreId()) };
  }

  async getDashboard(): Promise<StoreDashboardView> {
    await wait();
    return this.db.dashboard(this.requireStoreId());
  }

  async listStoreEvents(): Promise<Event[]> {
    await wait();
    const storeId = this.requireStoreId();
    return this.db.events.filter((item) => item.storeId === storeId);
  }

  async getStoreEvent(id: string): Promise<PublicEventView> {
    await wait();
    const event = this.db.requireEvent(id);
    if (event.storeId !== this.requireStoreId()) {
      throw new ApiError('Evento de outra loja.', 'FORBIDDEN', 403);
    }
    return this.db.toPublic(event);
  }

  async createEvent(input: CreateEventInput): Promise<Event> {
    await wait();
    return this.db.createEvent(this.requireStoreId(), input);
  }

  async updateEvent(id: string, input: UpdateEventInput): Promise<Event> {
    await wait();
    const event = this.db.requireEvent(id);
    if (event.storeId !== this.requireStoreId()) {
      throw new ApiError('Evento de outra loja.', 'FORBIDDEN', 403);
    }
    return this.db.updateEvent(event, input);
  }

  async setEventStatus(id: string, status: EventStatus): Promise<Event> {
    await wait();
    const event = this.db.requireEvent(id);
    if (event.storeId !== this.requireStoreId()) {
      throw new ApiError('Evento de outra loja.', 'FORBIDDEN', 403);
    }
    event.status = status;
    if (status === EventStatus.OPEN) {
      this.db.refreshEventStatus(event);
    }
    return event;
  }

  async listParticipants(
    eventId: string,
    query: ParticipantQuery,
  ): Promise<ParticipantRow[]> {
    await wait();
    const event = this.db.requireEvent(eventId);
    if (event.storeId !== this.requireStoreId()) {
      throw new ApiError('Evento de outra loja.', 'FORBIDDEN', 403);
    }
    return this.db.participants(eventId, query);
  }

  async markOnSitePaid(registrationId: string): Promise<RegistrationView> {
    await wait();
    try {
      return this.db.markOnSitePaid(registrationId, this.requireStoreId());
    } catch (error) {
      throw new ApiError((error as Error).message, 'PAY_FAILED');
    }
  }

  async cancelAsStore(registrationId: string): Promise<RegistrationView> {
    await wait();
    try {
      return this.db.cancelByStore(registrationId, this.requireStoreId());
    } catch (error) {
      throw new ApiError((error as Error).message, 'CANCEL_FAILED');
    }
  }

  async promoteFromWaitlist(registrationId: string): Promise<RegistrationView> {
    await wait();
    try {
      return this.db.promote(registrationId, this.requireStoreId());
    } catch (error) {
      throw new ApiError((error as Error).message, 'PROMOTE_FAILED');
    }
  }

  private issue(user: User): Session {
    const member = this.db.members.find((item) => item.userId === user.id);
    const token = `tok_${crypto.randomUUID()}`;
    this.tokens.set(token, { userId: user.id, storeId: member?.storeId });
    return {
      token,
      user: { ...user },
      storeId: member?.storeId,
    };
  }

  private readStoredSession(): Session | null {
    const raw = sessionStorage.getItem(SESSION_STORAGE_KEY);
    if (!raw) {
      return null;
    }
    const parsed = JSON.parse(raw) as Session;
    this.tokens.set(parsed.token, {
      userId: parsed.user.id,
      storeId: parsed.storeId,
    });
    const user = this.db.users.find((item) => item.id === parsed.user.id);
    if (!user) {
      return null;
    }
    return { ...parsed, user: { ...user } };
  }

  private optionalActor(): User | null {
    const session = this.readStoredSession();
    return session ? this.db.requireUser(session.user.id) : null;
  }

  private requireActor(): User {
    const user = this.optionalActor();
    if (!user) {
      throw new ApiError('Faça login para continuar.', 'UNAUTHENTICATED', 401);
    }
    return user;
  }

  private currentStoreId(): string | undefined {
    return this.readStoredSession()?.storeId;
  }

  private requireStoreId(): string {
    const storeId = this.currentStoreId();
    if (!storeId) {
      throw new ApiError('Conta de loja necessária.', 'FORBIDDEN', 403);
    }
    return storeId;
  }
}
