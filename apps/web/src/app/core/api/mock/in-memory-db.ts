import {
  CreateEventInput,
  Event,
  EventCapacity,
  Game,
  GameIdentifier,
  ParticipantQuery,
  ParticipantRow,
  Payment,
  PublicEventView,
  RefundPolicy,
  RegisterInput,
  Registration,
  RegistrationView,
  Store,
  StoreDashboardView,
  StoreMember,
  UpdateEventInput,
  User,
} from '../../models/domain';
import {
  EventStatus,
  ParticipantFilter,
  PaymentMethod,
  PaymentMode,
  PaymentStatus,
  RegistrationStatus,
  UserRole,
} from '../../models/enums';
import {
  canWithdrawDirectly,
  isSeated,
  needsRefundRequest,
} from '../../models/registration-policy';

const FIRST_NAMES = [
  'Ana', 'Bruno', 'Carla', 'Diego', 'Eva', 'Felipe', 'Gabi', 'Hugo',
  'Iris', 'João', 'Kaio', 'Lia', 'Marcos', 'Nina', 'Otávio', 'Paula',
  'Rafa', 'Sofia', 'Tiago', 'Úrsula', 'Vitor', 'Wendy', 'Yasmin', 'Zeca',
];

function id(prefix: string): string {
  return `${prefix}_${crypto.randomUUID().slice(0, 8)}`;
}

function slugify(value: string): string {
  return value
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

export class InMemoryDb {
  readonly games: Game[] = [
    { id: 'pokemon', name: 'Pokémon TCG', accent: '#FBC02D' },
    { id: 'magic', name: 'Magic: The Gathering', accent: '#66BB6A' },
    { id: 'yugioh', name: 'Yu-Gi-Oh!', accent: '#FFD54F' },
    { id: 'one_piece', name: 'One Piece Card Game', accent: '#42A5F5' },
    { id: 'flesh_and_blood', name: 'Flesh and Blood', accent: '#EF5350' },
    { id: 'lorcana', name: 'Disney Lorcana', accent: '#AB47BC' },
  ];

  readonly stores: Store[] = [];
  readonly members: StoreMember[] = [];
  readonly users: User[] = [];
  readonly passwords = new Map<string, string>();
  readonly identifiers: GameIdentifier[] = [];
  readonly events: Event[] = [];
  readonly registrations: Registration[] = [];
  readonly payments: Payment[] = [];

  constructor() {
    this.seed();
  }

  capacity(event: Event): EventCapacity {
    const seatedCount = this.registrations.filter(
      (item) => item.eventId === event.id && isSeated(item.status),
    ).length;
    const waitlistCount = this.registrations.filter(
      (item) =>
        item.eventId === event.id && item.status === RegistrationStatus.WAITLIST,
    ).length;
    return {
      maxParticipants: event.maxParticipants,
      seatedCount,
      available: Math.max(0, event.maxParticipants - seatedCount),
      waitlistCount,
    };
  }

  refreshEventStatus(event: Event): void {
    if (
      event.status === EventStatus.DRAFT ||
      event.status === EventStatus.CLOSED ||
      event.status === EventStatus.CANCELLED ||
      event.status === EventStatus.FINISHED
    ) {
      return;
    }
    const cap = this.capacity(event);
    event.status = cap.available === 0 ? EventStatus.FULL : EventStatus.OPEN;
  }

  toPublic(event: Event): PublicEventView {
    const store = this.requireStore(event.storeId);
    const game = this.requireGame(event.gameId);
    return { event, store, game, capacity: this.capacity(event) };
  }

  toRegistrationView(registration: Registration): RegistrationView {
    const event = this.requireEvent(registration.eventId);
    const payment =
      this.payments.find((item) => item.registrationId === registration.id) ??
      null;
    const player = this.requireUser(registration.userId);
    return {
      registration,
      event,
      store: this.requireStore(event.storeId),
      game: this.requireGame(event.gameId),
      payment,
      player: {
        id: player.id,
        fullName: player.fullName,
        displayName: player.displayName,
        email: player.email,
        phone: player.phone,
      },
      canWithdrawDirectly: canWithdrawDirectly(payment),
      needsRefundRequest: needsRefundRequest(payment),
    };
  }

  requireUser(id: string): User {
    const user = this.users.find((item) => item.id === id);
    if (!user) {
      throw new Error('Usuário não encontrado.');
    }
    return user;
  }

  requireStore(id: string): Store {
    const store = this.stores.find((item) => item.id === id);
    if (!store) {
      throw new Error('Loja não encontrada.');
    }
    return store;
  }

  requireEvent(id: string): Event {
    const event = this.events.find((item) => item.id === id);
    if (!event) {
      throw new Error('Evento não encontrado.');
    }
    return event;
  }

  requireGame(id: string): Game {
    const game = this.games.find((item) => item.id === id);
    if (!game) {
      throw new Error('Jogo não encontrado.');
    }
    return game;
  }

  findEventBySlug(storeSlug: string, eventSlug: string): Event | undefined {
    const store = this.stores.find((item) => item.slug === storeSlug);
    if (!store) {
      return undefined;
    }
    return this.events.find(
      (item) => item.storeId === store.id && item.slug === eventSlug,
    );
  }

  nextWaitlistPosition(eventId: string): number {
    const positions = this.registrations
      .filter(
        (item) =>
          item.eventId === eventId && item.status === RegistrationStatus.WAITLIST,
      )
      .map((item) => item.waitlistPosition ?? 0);
    return (positions.length ? Math.max(...positions) : 0) + 1;
  }

  reindexWaitlist(eventId: string): void {
    this.registrations
      .filter(
        (item) =>
          item.eventId === eventId && item.status === RegistrationStatus.WAITLIST,
      )
      .sort((a, b) => (a.waitlistPosition ?? 0) - (b.waitlistPosition ?? 0))
      .forEach((item, index) => {
        item.waitlistPosition = index + 1;
      });
  }

  promoteNextWaitlist(event: Event): void {
    const cap = this.capacity(event);
    if (cap.available <= 0) {
      return;
    }
    const next = this.registrations
      .filter(
        (item) =>
          item.eventId === event.id && item.status === RegistrationStatus.WAITLIST,
      )
      .sort((a, b) => (a.waitlistPosition ?? 0) - (b.waitlistPosition ?? 0))[0];
    if (!next) {
      return;
    }
    next.status = RegistrationStatus.REGISTERED;
    next.waitlistPosition = undefined;
    this.reindexWaitlist(event.id);
    this.refreshEventStatus(event);
  }

  createPayment(
    registration: Registration,
    method: PaymentMethod,
    amountCents: number,
  ): Payment {
    const now = new Date().toISOString();
    const payment: Payment = {
      id: id('pay'),
      registrationId: registration.id,
      method,
      amountCents,
      status:
        method === PaymentMethod.ON_SITE
          ? PaymentStatus.PAY_ON_SITE
          : PaymentStatus.PENDING,
      updatedAt: now,
    };
    this.payments.push(payment);
    return payment;
  }

  register(input: RegisterInput, actor: User | null): RegistrationView {
    const event = this.findEventBySlug(input.storeSlug, input.eventSlug);
    if (!event) {
      throw new Error('Evento não encontrado.');
    }
    if (event.status !== EventStatus.OPEN && event.status !== EventStatus.FULL) {
      throw new Error('As inscrições deste evento não estão abertas.');
    }

    const email = input.email.trim().toLowerCase();
    let user = actor ?? this.users.find((item) => item.email === email) ?? null;
    if (!user) {
      user = {
        id: id('user'),
        email,
        fullName: input.fullName.trim(),
        displayName: (input.displayName || input.fullName).trim(),
        phone: input.phone?.trim() ?? '',
        role: UserRole.PLAYER,
        hasPassword: Boolean(input.createPassword),
        acceptedTermsAt: new Date().toISOString(),
      };
      this.users.push(user);
      if (input.createPassword) {
        this.passwords.set(user.id, input.createPassword);
      }
    } else if (actor && actor.email !== email) {
      throw new Error('O e-mail precisa ser o da conta conectada.');
    }

    const duplicate = this.registrations.find(
      (item) =>
        item.eventId === event.id &&
        item.userId === user.id &&
        item.status !== RegistrationStatus.CANCELLED,
    );
    if (duplicate) {
      throw new Error('Você já possui uma inscrição neste evento.');
    }

    const cap = this.capacity(event);
    const useWaitlist = cap.available <= 0;
    if (useWaitlist && !event.allowWaitlist) {
      throw new Error('Este evento está lotado.');
    }

    const registration: Registration = {
      id: id('reg'),
      eventId: event.id,
      userId: user.id,
      storeId: event.storeId,
      status: useWaitlist
        ? RegistrationStatus.WAITLIST
        : RegistrationStatus.REGISTERED,
      waitlistPosition: useWaitlist
        ? this.nextWaitlistPosition(event.id)
        : undefined,
      guestAccessToken: id('tok'),
      createdAt: new Date().toISOString(),
    };
    this.registrations.push(registration);

    if (input.gameIdentifierValue?.trim()) {
      this.identifiers.push({
        id: id('gid'),
        userId: user.id,
        gameId: event.gameId,
        type: 'PLAYER_ID',
        value: input.gameIdentifierValue.trim(),
      });
    }

    let method: PaymentMethod = PaymentMethod.ON_SITE;
    if (event.paymentMode === PaymentMode.ONLINE) {
      method = PaymentMethod.MERCADO_PAGO;
    } else if (event.paymentMode === PaymentMode.PLAYER_CHOICE) {
      method = input.paymentChoice ?? PaymentMethod.MERCADO_PAGO;
    }
    this.createPayment(registration, method, event.priceCents);
    this.refreshEventStatus(event);
    return this.toRegistrationView(registration);
  }

  startCheckout(registrationId: string, actorId: string): Payment {
    const registration = this.registrations.find(
      (item) => item.id === registrationId,
    );
    if (!registration || registration.userId !== actorId) {
      throw new Error('Inscrição não encontrada.');
    }
    const payment = this.payments.find(
      (item) => item.registrationId === registrationId,
    );
    if (!payment) {
      throw new Error('Pagamento não encontrado.');
    }
    if (payment.method !== PaymentMethod.MERCADO_PAGO) {
      throw new Error('Este evento não usa Mercado Pago.');
    }
    if (payment.status === PaymentStatus.APPROVED) {
      throw new Error('Pagamento já aprovado.');
    }
    payment.status = PaymentStatus.PENDING;
    payment.preferenceId = `pref_${payment.id}`;
    payment.externalReference = registrationId;
    payment.initPoint = `/payments/checkout/${payment.id}`;
    payment.updatedAt = new Date().toISOString();
    return payment;
  }

  applyPaymentNotification(
    paymentId: string,
    status: Extract<PaymentStatus, 'APPROVED' | 'FAILED' | 'CANCELLED'>,
  ): Payment {
    const payment = this.payments.find((item) => item.id === paymentId);
    if (!payment) {
      throw new Error('Pagamento não encontrado.');
    }
    payment.status = status;
    payment.updatedAt = new Date().toISOString();
    if (status === PaymentStatus.APPROVED) {
      payment.paidAt = payment.updatedAt;
      const registration = this.registrations.find(
        (item) => item.id === payment.registrationId,
      );
      if (
        registration &&
        registration.status === RegistrationStatus.REGISTERED
      ) {
        registration.status = RegistrationStatus.CONFIRMED;
      }
    }
    return payment;
  }

  cancelByPlayer(registrationId: string, actorId: string): RegistrationView {
    const registration = this.registrations.find(
      (item) => item.id === registrationId,
    );
    if (!registration || registration.userId !== actorId) {
      throw new Error('Inscrição não encontrada.');
    }
    const view = this.toRegistrationView(registration);
    if (view.needsRefundRequest) {
      throw new Error(
        'Inscrição paga pelo Mercado Pago. Solicite o reembolso pelo WhatsApp da loja.',
      );
    }
    if (!view.canWithdrawDirectly) {
      throw new Error('Não é possível cancelar esta inscrição.');
    }
    return this.cancelRegistration(registration, view.event);
  }

  cancelByStore(registrationId: string, storeId: string): RegistrationView {
    const registration = this.registrations.find(
      (item) => item.id === registrationId,
    );
    if (!registration || registration.storeId !== storeId) {
      throw new Error('Inscrição não encontrada.');
    }
    const event = this.requireEvent(registration.eventId);
    return this.cancelRegistration(registration, event);
  }

  private cancelRegistration(
    registration: Registration,
    event: Event,
  ): RegistrationView {
    if (registration.status === RegistrationStatus.CANCELLED) {
      return this.toRegistrationView(registration);
    }
    const wasSeated = isSeated(registration.status);
    registration.status = RegistrationStatus.CANCELLED;
    registration.cancelledAt = new Date().toISOString();
    registration.waitlistPosition = undefined;
    const payment = this.payments.find(
      (item) => item.registrationId === registration.id,
    );
    if (payment && payment.status === PaymentStatus.PENDING) {
      payment.status = PaymentStatus.CANCELLED;
      payment.updatedAt = new Date().toISOString();
    }
    this.reindexWaitlist(event.id);
    if (wasSeated) {
      this.promoteNextWaitlist(event);
    }
    this.refreshEventStatus(event);
    return this.toRegistrationView(registration);
  }

  markOnSitePaid(registrationId: string, storeId: string): RegistrationView {
    const registration = this.registrations.find(
      (item) => item.id === registrationId,
    );
    if (!registration || registration.storeId !== storeId) {
      throw new Error('Inscrição não encontrada.');
    }
    const payment = this.payments.find(
      (item) => item.registrationId === registration.id,
    );
    if (!payment || payment.method !== PaymentMethod.ON_SITE) {
      throw new Error('Esta inscrição não é pagamento no local.');
    }
    payment.status = PaymentStatus.APPROVED;
    payment.paidAt = new Date().toISOString();
    payment.updatedAt = payment.paidAt;
    if (registration.status === RegistrationStatus.REGISTERED) {
      registration.status = RegistrationStatus.CONFIRMED;
    }
    return this.toRegistrationView(registration);
  }

  promote(registrationId: string, storeId: string): RegistrationView {
    const registration = this.registrations.find(
      (item) => item.id === registrationId,
    );
    if (!registration || registration.storeId !== storeId) {
      throw new Error('Inscrição não encontrada.');
    }
    const event = this.requireEvent(registration.eventId);
    if (registration.status !== RegistrationStatus.WAITLIST) {
      throw new Error('Jogador não está na waitlist.');
    }
    if (this.capacity(event).available <= 0) {
      throw new Error('Não há vaga disponível.');
    }
    registration.status = RegistrationStatus.REGISTERED;
    registration.waitlistPosition = undefined;
    this.reindexWaitlist(event.id);
    this.refreshEventStatus(event);
    return this.toRegistrationView(registration);
  }

  createEvent(storeId: string, input: CreateEventInput): Event {
    const store = this.requireStore(storeId);
    const event: Event = {
      id: id('evt'),
      storeId,
      gameId: input.gameId,
      slug: this.uniqueSlug(storeId, input.name),
      name: input.name.trim(),
      description: input.description.trim(),
      rules: input.rules.trim(),
      startsAt: input.startsAt,
      locationName: input.locationName.trim() || store.locationName,
      address: input.address.trim() || store.address,
      maxParticipants: input.maxParticipants,
      priceCents: input.priceCents,
      paymentMode: input.paymentMode,
      allowWaitlist: input.allowWaitlist,
      status: EventStatus.DRAFT,
      refundPolicy: { ...input.refundPolicy },
      createdAt: new Date().toISOString(),
    };
    this.events.push(event);
    return event;
  }

  updateEvent(event: Event, input: UpdateEventInput): Event {
    Object.assign(event, {
      ...input,
      name: input.name?.trim() ?? event.name,
      description: input.description?.trim() ?? event.description,
      rules: input.rules?.trim() ?? event.rules,
      locationName: input.locationName?.trim() ?? event.locationName,
      address: input.address?.trim() ?? event.address,
      refundPolicy: input.refundPolicy
        ? { ...input.refundPolicy }
        : event.refundPolicy,
    });
    if (input.name) {
      event.slug = this.uniqueSlug(event.storeId, input.name, event.id);
    }
    return event;
  }

  participants(eventId: string, query: ParticipantQuery): ParticipantRow[] {
    const search = query.search.trim().toLowerCase();
    return this.registrations
      .filter((item) => item.eventId === eventId)
      .map((registration) => {
        const player = this.requireUser(registration.userId);
        const payment =
          this.payments.find((item) => item.registrationId === registration.id) ??
          null;
        return {
          registration,
          player: {
            id: player.id,
            fullName: player.fullName,
            displayName: player.displayName,
            email: player.email,
            phone: player.phone,
          },
          payment,
          gameIdentifiers: this.identifiers.filter(
            (item) => item.userId === player.id,
          ),
        };
      })
      .filter((row) => this.matchesFilter(row, query.filter))
      .filter((row) => {
        if (!search) {
          return true;
        }
        const identifierMatch = row.gameIdentifiers.some((item) =>
          item.value.toLowerCase().includes(search),
        );
        return (
          row.player.fullName.toLowerCase().includes(search) ||
          row.player.email.toLowerCase().includes(search) ||
          identifierMatch
        );
      });
  }

  dashboard(storeId: string): StoreDashboardView {
    const store = this.requireStore(storeId);
    const storeEvents = this.events.filter((item) => item.storeId === storeId);
    const upcomingEvents = storeEvents
      .filter(
        (item) =>
          item.status === EventStatus.OPEN ||
          item.status === EventStatus.FULL ||
          item.status === EventStatus.DRAFT,
      )
      .map((event) => {
        const rows = this.participants(event.id, {
          filter: ParticipantFilter.ALL,
          search: '',
        });
        return {
          event,
          game: this.requireGame(event.gameId),
          capacity: this.capacity(event),
          pendingPayments: rows.filter(
            (row) => row.payment?.status === PaymentStatus.PENDING,
          ).length,
          approvedPayments: rows.filter(
            (row) => row.payment?.status === PaymentStatus.APPROVED,
          ).length,
          onSitePayments: rows.filter(
            (row) => row.payment?.status === PaymentStatus.PAY_ON_SITE,
          ).length,
          cancellations: rows.filter(
            (row) => row.registration.status === RegistrationStatus.CANCELLED,
          ).length,
        };
      });
    return {
      store,
      upcomingEvents,
      totals: {
        activeEvents: upcomingEvents.filter(
          (item) =>
            item.event.status === EventStatus.OPEN ||
            item.event.status === EventStatus.FULL,
        ).length,
        seatedPlayers: upcomingEvents.reduce(
          (sum, item) => sum + item.capacity.seatedCount,
          0,
        ),
        waitlist: upcomingEvents.reduce(
          (sum, item) => sum + item.capacity.waitlistCount,
          0,
        ),
        pendingPayments: upcomingEvents.reduce(
          (sum, item) => sum + item.pendingPayments,
          0,
        ),
      },
    };
  }

  private matchesFilter(row: ParticipantRow, filter: string): boolean {
    const status = row.registration.status;
    const payment = row.payment;
    switch (filter) {
      case ParticipantFilter.CONFIRMED:
        return (
          status === RegistrationStatus.CONFIRMED ||
          status === RegistrationStatus.REGISTERED
        );
      case ParticipantFilter.PENDING:
        return payment?.status === PaymentStatus.PENDING;
      case ParticipantFilter.PAID:
        return payment?.status === PaymentStatus.APPROVED;
      case ParticipantFilter.UNPAID:
        return (
          payment?.status === PaymentStatus.PENDING ||
          payment?.status === PaymentStatus.FAILED ||
          payment?.status === PaymentStatus.PAY_ON_SITE
        );
      case ParticipantFilter.PAY_ON_SITE:
        return payment?.status === PaymentStatus.PAY_ON_SITE;
      case ParticipantFilter.WAITLIST:
        return status === RegistrationStatus.WAITLIST;
      case ParticipantFilter.CANCELLED:
        return status === RegistrationStatus.CANCELLED;
      default:
        return true;
    }
  }

  private uniqueSlug(storeId: string, name: string, exceptId?: string): string {
    const base = slugify(name) || 'evento';
    let slug = base;
    let n = 2;
    while (
      this.events.some(
        (item) =>
          item.storeId === storeId &&
          item.slug === slug &&
          item.id !== exceptId,
      )
    ) {
      slug = `${base}-${n}`;
      n += 1;
    }
    return slug;
  }

  private seed(): void {
    const refundNexus: RefundPolicy = {
      enabled: true,
      feePercent: 20,
      note: 'Reembolso somente via WhatsApp da loja, após pagamento aprovado no Mercado Pago.',
    };
    const nexus: Store = {
      id: 'store_nexus',
      name: 'Arena Nexus',
      slug: 'arena-nexus',
      city: 'São Paulo',
      state: 'SP',
      locationName: 'Arena Nexus',
      address: 'Rua Augusta, 1200 — Consolação, São Paulo',
      whatsapp: '5511999887766',
      defaultRefundPolicy: refundNexus,
    };
    const dragao: Store = {
      id: 'store_dragao',
      name: 'Dragão de Aço',
      slug: 'dragao-de-aco',
      city: 'Curitiba',
      state: 'PR',
      locationName: 'Dragão de Aço',
      address: 'Av. Sete de Setembro, 800 — Centro, Curitiba',
      whatsapp: '5541999776655',
      defaultRefundPolicy: { enabled: false, feePercent: 100 },
    };
    this.stores.push(nexus, dragao);

    const lojaNexus: User = {
      id: 'user_loja_nexus',
      email: 'loja@nexus.demo',
      fullName: 'Marina Costa',
      displayName: 'Marina',
      phone: '11999887766',
      role: UserRole.STORE_ADMIN,
      hasPassword: true,
      acceptedTermsAt: '2026-01-10T12:00:00.000Z',
    };
    const lojaDragao: User = {
      id: 'user_loja_dragao',
      email: 'loja@dragao.demo',
      fullName: 'Paulo Mendes',
      displayName: 'Paulo',
      phone: '41999776655',
      role: UserRole.STORE_ADMIN,
      hasPassword: true,
      acceptedTermsAt: '2026-01-10T12:00:00.000Z',
    };
    const ana: User = {
      id: 'user_ana',
      email: 'ana@player.demo',
      fullName: 'Ana Ribeiro',
      displayName: 'Ana',
      phone: '11987654321',
      city: 'São Paulo',
      state: 'SP',
      role: UserRole.PLAYER,
      hasPassword: true,
      acceptedTermsAt: '2026-02-01T12:00:00.000Z',
    };
    this.users.push(lojaNexus, lojaDragao, ana);
    this.passwords.set(lojaNexus.id, 'demo1234');
    this.passwords.set(lojaDragao.id, 'demo1234');
    this.passwords.set(ana.id, 'demo1234');
    this.members.push(
      { id: 'mem_nexus', storeId: nexus.id, userId: lojaNexus.id, role: 'OWNER' },
      { id: 'mem_dragao', storeId: dragao.id, userId: lojaDragao.id, role: 'OWNER' },
    );
    this.identifiers.push({
      id: 'gid_ana_pkm',
      userId: ana.id,
      gameId: 'pokemon',
      type: 'PLAYER_ID',
      value: 'ANA-PKM-1024',
    });

    const pokemon: Event = {
      id: 'event_pokemon_lc',
      storeId: nexus.id,
      gameId: 'pokemon',
      slug: 'pokemon-league-challenge-nexus',
      name: 'Pokémon League Challenge',
      description:
        'League Challenge da temporada. Traga deck registrado e sleeved.',
      rules:
        'Check-in 13h30. Formato Standard. Lista de participantes fechada 15 min antes.',
      startsAt: '2026-08-23T14:00:00-03:00',
      locationName: 'Arena Nexus',
      address: 'Rua Augusta, 1200 — Consolação, São Paulo',
      maxParticipants: 32,
      priceCents: 5000,
      paymentMode: PaymentMode.ONLINE,
      allowWaitlist: true,
      status: EventStatus.OPEN,
      refundPolicy: refundNexus,
      createdAt: '2026-08-01T12:00:00.000Z',
    };
    const magic: Event = {
      id: 'event_fnm',
      storeId: dragao.id,
      gameId: 'magic',
      slug: 'fnm-dragao-aco',
      name: 'Friday Night Magic',
      description: 'FNM Standard. Evento lotado — waitlist aberta.',
      rules: 'WPN Regular. Chegue com antecedência.',
      startsAt: '2026-08-21T19:30:00-03:00',
      locationName: 'Dragão de Aço',
      address: 'Av. Sete de Setembro, 800 — Centro, Curitiba',
      maxParticipants: 16,
      priceCents: 4000,
      paymentMode: PaymentMode.PLAYER_CHOICE,
      allowWaitlist: true,
      status: EventStatus.OPEN,
      refundPolicy: { enabled: true, feePercent: 10 },
      createdAt: '2026-08-02T12:00:00.000Z',
    };
    const ygo: Event = {
      id: 'event_ygo',
      storeId: nexus.id,
      gameId: 'yugioh',
      slug: 'yugioh-locals-nexus',
      name: 'Yu-Gi-Oh! Locals',
      description: 'Torneio casual da semana. Pagamento no local.',
      rules: 'Advanced format. Pagamento na recepção.',
      startsAt: '2026-08-25T19:00:00-03:00',
      locationName: 'Arena Nexus',
      address: 'Rua Augusta, 1200 — Consolação, São Paulo',
      maxParticipants: 20,
      priceCents: 2500,
      paymentMode: PaymentMode.PAY_ON_SITE,
      allowWaitlist: true,
      status: EventStatus.OPEN,
      refundPolicy: { enabled: false, feePercent: 100 },
      createdAt: '2026-08-05T12:00:00.000Z',
    };
    this.events.push(pokemon, magic, ygo);

    this.seedSeated(pokemon, 24, PaymentMethod.MERCADO_PAGO, PaymentStatus.APPROVED);
    this.seedSeated(magic, 16, PaymentMethod.ON_SITE, PaymentStatus.PAY_ON_SITE);
    this.seedWaitlist(magic, 3);
    this.seedSeated(ygo, 5, PaymentMethod.ON_SITE, PaymentStatus.PAY_ON_SITE);
    this.refreshEventStatus(pokemon);
    this.refreshEventStatus(magic);
    this.refreshEventStatus(ygo);
  }

  private seedSeated(
    event: Event,
    count: number,
    method: PaymentMethod,
    paymentStatus: PaymentStatus,
  ): void {
    for (let i = 0; i < count; i += 1) {
      const first = FIRST_NAMES[i % FIRST_NAMES.length];
      const user: User = {
        id: id('user'),
        email: `${slugify(first)}.${i}@players.demo`,
        fullName: `${first} Silva`,
        displayName: first,
        phone: `1198888${String(1000 + i)}`,
        role: UserRole.PLAYER,
        hasPassword: false,
        acceptedTermsAt: '2026-08-10T12:00:00.000Z',
      };
      this.users.push(user);
      const registration: Registration = {
        id: id('reg'),
        eventId: event.id,
        userId: user.id,
        storeId: event.storeId,
        status:
          paymentStatus === PaymentStatus.APPROVED
            ? RegistrationStatus.CONFIRMED
            : RegistrationStatus.REGISTERED,
        guestAccessToken: id('tok'),
        createdAt: '2026-08-10T12:00:00.000Z',
      };
      this.registrations.push(registration);
      const now = '2026-08-10T12:05:00.000Z';
      this.payments.push({
        id: id('pay'),
        registrationId: registration.id,
        method,
        amountCents: event.priceCents,
        status: paymentStatus,
        paidAt:
          paymentStatus === PaymentStatus.APPROVED ? now : undefined,
        updatedAt: now,
      });
    }
  }

  private seedWaitlist(event: Event, count: number): void {
    const extras = ['Pedro', 'Maria', 'Carlos'];
    for (let i = 0; i < count; i += 1) {
      const name = extras[i] ?? `Wait ${i + 1}`;
      const user: User = {
        id: id('user'),
        email: `wait.${i}@players.demo`,
        fullName: `${name} Costa`,
        displayName: name,
        phone: `1197777${String(2000 + i)}`,
        role: UserRole.PLAYER,
        hasPassword: false,
        acceptedTermsAt: '2026-08-12T12:00:00.000Z',
      };
      this.users.push(user);
      this.registrations.push({
        id: id('reg'),
        eventId: event.id,
        userId: user.id,
        storeId: event.storeId,
        status: RegistrationStatus.WAITLIST,
        waitlistPosition: i + 1,
        guestAccessToken: id('tok'),
        createdAt: '2026-08-12T12:00:00.000Z',
      });
    }
  }
}
