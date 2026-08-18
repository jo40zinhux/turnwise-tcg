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
} from '../models/domain';
import { EventStatus, PaymentStatus } from '../models/enums';

export class ApiError extends Error {
  constructor(
    message: string,
    readonly code: string,
    readonly status = 400,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export interface ApiClient {
  login(email: string, password: string): Promise<Session>;
  signup(input: SignupInput): Promise<Session>;
  logout(): Promise<void>;
  currentSession(): Promise<Session | null>;
  updateProfile(input: UpdateProfileInput): Promise<User>;
  addGameIdentifier(input: GameIdentifierInput): Promise<GameIdentifier>;
  listGames(): Promise<Game[]>;

  getPublicEvent(slug: string): Promise<PublicEventView>;
  register(input: RegisterInput): Promise<RegistrationView>;
  claimGuestSession(
    registrationId: string,
    accessToken: string,
  ): Promise<Session>;
  getRegistration(id: string, accessToken?: string): Promise<RegistrationView>;
  listMyRegistrations(): Promise<RegistrationView[]>;
  cancelRegistration(id: string): Promise<RegistrationView>;
  setPassword(password: string): Promise<User>;

  startMercadoPagoCheckout(registrationId: string): Promise<Payment>;
  getPayment(id: string): Promise<Payment>;
  applyPaymentNotification(
    paymentId: string,
    status: Extract<PaymentStatus, 'APPROVED' | 'FAILED' | 'CANCELLED'>,
  ): Promise<Payment>;

  getStore(): Promise<Store>;
  getDashboard(): Promise<StoreDashboardView>;
  listStoreEvents(): Promise<Event[]>;
  getStoreEvent(id: string): Promise<PublicEventView>;
  createEvent(input: CreateEventInput): Promise<Event>;
  updateEvent(id: string, input: UpdateEventInput): Promise<Event>;
  setEventStatus(id: string, status: EventStatus): Promise<Event>;
  listParticipants(eventId: string, query: ParticipantQuery): Promise<ParticipantRow[]>;
  markOnSitePaid(registrationId: string): Promise<RegistrationView>;
  cancelAsStore(registrationId: string): Promise<RegistrationView>;
  promoteFromWaitlist(registrationId: string): Promise<RegistrationView>;
}
