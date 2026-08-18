import {
  Event,
  EventStatus,
  Game,
  GameIdentifier,
  Payment,
  PaymentMethod,
  PaymentStatus,
  Prisma,
  Registration,
  RegistrationStatus,
  Store,
  User,
} from '@prisma/client';

export type EventWithRelations = Event & { store: Store; game: Game };
export type RegistrationWithRelations = Registration & {
  event: EventWithRelations;
  user: User;
  payment: Payment | null;
};

export function toUser(user: User) {
  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    displayName: user.displayName,
    phone: user.phone,
    city: user.city ?? undefined,
    state: user.state ?? undefined,
    role: user.role,
    hasPassword: Boolean(user.passwordHash),
    acceptedTermsAt: (user.acceptedTermsAt ?? user.createdAt).toISOString(),
  };
}

export function toStore(store: Store) {
  return {
    id: store.id,
    name: store.name,
    slug: store.slug,
    city: store.city,
    state: store.state,
    locationName: store.locationName,
    address: store.address,
    whatsapp: store.whatsapp,
    defaultRefundPolicy: {
      enabled: store.refundEnabled,
      feePercent: store.refundFeePercent,
      note: store.refundNote ?? undefined,
    },
  };
}

export function toEvent(event: Event) {
  return {
    id: event.id,
    storeId: event.storeId,
    gameId: event.gameId,
    slug: event.slug,
    name: event.name,
    description: event.description,
    rules: event.rules,
    startsAt: event.startsAt.toISOString(),
    locationName: event.locationName,
    address: event.address,
    maxParticipants: event.maxParticipants,
    priceCents: event.priceCents,
    paymentMode: event.paymentMode,
    allowWaitlist: event.allowWaitlist,
    status: event.status,
    imageUrl: event.imageUrl ?? undefined,
    refundPolicy: {
      enabled: event.refundEnabled,
      feePercent: event.refundFeePercent,
      note: event.refundNote ?? undefined,
    },
    createdAt: event.createdAt.toISOString(),
  };
}

export function toGame(game: Game) {
  return {
    id: game.id,
    name: game.name,
    accent: game.accent,
  };
}

export function toPayment(payment: Payment | null) {
  if (!payment) {
    return null;
  }
  return {
    id: payment.id,
    registrationId: payment.registrationId,
    status: payment.status,
    method: payment.method,
    amountCents: payment.amountCents,
    preferenceId: payment.preferenceId ?? undefined,
    initPoint: payment.initPoint ?? undefined,
    externalReference: payment.externalReference ?? undefined,
    paidAt: payment.paidAt?.toISOString(),
    updatedAt: payment.updatedAt.toISOString(),
  };
}

export function toRegistration(registration: Registration) {
  return {
    id: registration.id,
    eventId: registration.eventId,
    userId: registration.userId,
    storeId: registration.storeId,
    status: registration.status,
    waitlistPosition: registration.waitlistPosition ?? undefined,
    guestAccessToken: registration.guestAccessToken,
    createdAt: registration.createdAt.toISOString(),
    cancelledAt: registration.cancelledAt?.toISOString(),
  };
}

export function toIdentifier(identifier: GameIdentifier) {
  return {
    id: identifier.id,
    userId: identifier.userId,
    gameId: identifier.gameId,
    type: identifier.type,
    value: identifier.value,
  };
}

export function toPlayer(user: User) {
  return {
    id: user.id,
    fullName: user.fullName,
    displayName: user.displayName,
    email: user.email,
    phone: user.phone,
  };
}

export function canWithdrawDirectly(payment: Payment | null): boolean {
  if (!payment) {
    return true;
  }
  if (payment.method === PaymentMethod.ON_SITE) {
    return true;
  }
  return payment.status !== PaymentStatus.APPROVED;
}

export function needsRefundRequest(payment: Payment | null): boolean {
  return (
    payment?.method === PaymentMethod.MERCADO_PAGO &&
    payment.status === PaymentStatus.APPROVED
  );
}

export function isSeated(status: RegistrationStatus): boolean {
  return (
    status === RegistrationStatus.REGISTERED ||
    status === RegistrationStatus.CONFIRMED
  );
}

export function toRegistrationView(row: RegistrationWithRelations) {
  return {
    registration: toRegistration(row),
    event: toEvent(row.event),
    store: toStore(row.event.store),
    game: toGame(row.event.game),
    payment: toPayment(row.payment),
    player: toPlayer(row.user),
    canWithdrawDirectly: canWithdrawDirectly(row.payment),
    needsRefundRequest: needsRefundRequest(row.payment),
  };
}

export function toPublicEvent(
  event: EventWithRelations,
  seatedCount: number,
  waitlistCount: number,
) {
  return {
    event: toEvent(event),
    store: toStore(event.store),
    game: toGame(event.game),
    capacity: {
      maxParticipants: event.maxParticipants,
      seatedCount,
      available: Math.max(0, event.maxParticipants - seatedCount),
      waitlistCount,
    },
  };
}

export const registrationInclude = {
  event: { include: { store: true, game: true } },
  user: true,
  payment: true,
} satisfies Prisma.RegistrationInclude;

export const lockedEventStatuses: EventStatus[] = [
  EventStatus.DRAFT,
  EventStatus.CLOSED,
  EventStatus.CANCELLED,
  EventStatus.FINISHED,
];
