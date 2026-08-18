import {
  EventStatus,
  PaymentMethod,
  PaymentMode,
  PaymentStatus,
  RegistrationStatus,
  UserRole,
} from './enums';

export interface Game {
  id: string;
  name: string;
  accent: string;
}

export interface GameIdentifier {
  id: string;
  userId: string;
  gameId: string;
  type: string;
  value: string;
}

export interface User {
  id: string;
  email: string;
  fullName: string;
  displayName: string;
  phone: string;
  city?: string;
  state?: string;
  role: UserRole;
  hasPassword: boolean;
  acceptedTermsAt: string;
}

export interface RefundPolicy {
  enabled: boolean;
  feePercent: number;
  note?: string;
}

export interface Store {
  id: string;
  name: string;
  slug: string;
  city: string;
  state: string;
  locationName: string;
  address: string;
  whatsapp: string;
  defaultRefundPolicy: RefundPolicy;
}

export interface StoreMember {
  id: string;
  storeId: string;
  userId: string;
  role: 'OWNER' | 'ADMIN';
}

export interface EventCapacity {
  maxParticipants: number;
  seatedCount: number;
  available: number;
  waitlistCount: number;
}

export interface Event {
  id: string;
  storeId: string;
  gameId: string;
  slug: string;
  name: string;
  description: string;
  rules: string;
  startsAt: string;
  locationName: string;
  address: string;
  maxParticipants: number;
  priceCents: number;
  paymentMode: PaymentMode;
  allowWaitlist: boolean;
  status: EventStatus;
  imageUrl?: string;
  refundPolicy: RefundPolicy;
  createdAt: string;
}

export interface Payment {
  id: string;
  registrationId: string;
  status: PaymentStatus;
  method: PaymentMethod;
  amountCents: number;
  preferenceId?: string;
  initPoint?: string;
  externalReference?: string;
  paidAt?: string;
  updatedAt: string;
}

export interface Registration {
  id: string;
  eventId: string;
  userId: string;
  storeId: string;
  status: RegistrationStatus;
  waitlistPosition?: number;
  guestAccessToken: string;
  createdAt: string;
  cancelledAt?: string;
}

export interface Session {
  token: string;
  user: User;
  storeId?: string;
}

export interface PublicEventView {
  event: Event;
  store: Store;
  game: Game;
  capacity: EventCapacity;
}

export interface RegistrationView {
  registration: Registration;
  event: Event;
  store: Store;
  game: Game;
  payment: Payment | null;
  player: Pick<User, 'id' | 'fullName' | 'displayName' | 'email' | 'phone'>;
  canWithdrawDirectly: boolean;
  needsRefundRequest: boolean;
}

export interface ParticipantRow {
  registration: Registration;
  player: Pick<User, 'id' | 'fullName' | 'displayName' | 'email' | 'phone'>;
  payment: Payment | null;
  gameIdentifiers: GameIdentifier[];
}

export interface StoreDashboardView {
  store: Store;
  upcomingEvents: Array<{
    event: Event;
    game: Game;
    capacity: EventCapacity;
    pendingPayments: number;
    approvedPayments: number;
    onSitePayments: number;
    cancellations: number;
  }>;
  totals: {
    activeEvents: number;
    seatedPlayers: number;
    waitlist: number;
    pendingPayments: number;
  };
}

export interface SignupInput {
  fullName: string;
  email: string;
  password: string;
  phone?: string;
  acceptedTerms: boolean;
}

export interface RegisterInput {
  storeSlug: string;
  eventSlug: string;
  fullName: string;
  email: string;
  phone?: string;
  displayName?: string;
  gameIdentifierValue?: string;
  paymentChoice?: PaymentMethod;
  acceptedTerms: boolean;
  createPassword?: string;
}

export interface CreateEventInput {
  name: string;
  gameId: string;
  description: string;
  rules: string;
  startsAt: string;
  locationName: string;
  address: string;
  maxParticipants: number;
  priceCents: number;
  paymentMode: PaymentMode;
  allowWaitlist: boolean;
  refundPolicy: RefundPolicy;
}

export type UpdateEventInput = Partial<CreateEventInput>;

export interface UpdateProfileInput {
  fullName?: string;
  displayName?: string;
  phone?: string;
  city?: string;
  state?: string;
}

export interface GameIdentifierInput {
  gameId: string;
  type: string;
  value: string;
}

export interface ParticipantQuery {
  filter: string;
  search: string;
}
