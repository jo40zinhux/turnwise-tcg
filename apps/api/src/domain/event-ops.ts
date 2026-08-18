import { EventStatus, Prisma, RegistrationStatus } from '@prisma/client';
import { lockedEventStatuses } from './mappers';

type Db = Prisma.TransactionClient;

export async function seatedCount(db: Db, eventId: string): Promise<number> {
  return db.registration.count({
    where: {
      eventId,
      status: {
        in: [RegistrationStatus.REGISTERED, RegistrationStatus.CONFIRMED],
      },
    },
  });
}

export async function waitlistCount(db: Db, eventId: string): Promise<number> {
  return db.registration.count({
    where: { eventId, status: RegistrationStatus.WAITLIST },
  });
}

export async function nextWaitlistPosition(
  db: Db,
  eventId: string,
): Promise<number> {
  const last = await db.registration.aggregate({
    where: { eventId, status: RegistrationStatus.WAITLIST },
    _max: { waitlistPosition: true },
  });
  return (last._max.waitlistPosition ?? 0) + 1;
}

export async function reindexWaitlist(db: Db, eventId: string): Promise<void> {
  const rows = await db.registration.findMany({
    where: { eventId, status: RegistrationStatus.WAITLIST },
    orderBy: { waitlistPosition: 'asc' },
  });
  for (let i = 0; i < rows.length; i += 1) {
    const position = i + 1;
    if (rows[i].waitlistPosition !== position) {
      await db.registration.update({
        where: { id: rows[i].id },
        data: { waitlistPosition: position },
      });
    }
  }
}

export async function refreshEventStatus(db: Db, eventId: string) {
  const event = await db.event.findUniqueOrThrow({ where: { id: eventId } });
  if (lockedEventStatuses.includes(event.status)) {
    return event;
  }
  const seated = await seatedCount(db, eventId);
  const status =
    seated >= event.maxParticipants ? EventStatus.FULL : EventStatus.OPEN;
  if (status === event.status) {
    return event;
  }
  return db.event.update({ where: { id: eventId }, data: { status } });
}

export async function promoteNextWaitlist(db: Db, eventId: string) {
  const event = await db.event.findUniqueOrThrow({ where: { id: eventId } });
  const seated = await seatedCount(db, eventId);
  if (seated >= event.maxParticipants) {
    return;
  }
  const next = await db.registration.findFirst({
    where: { eventId, status: RegistrationStatus.WAITLIST },
    orderBy: { waitlistPosition: 'asc' },
  });
  if (!next) {
    return;
  }
  await db.registration.update({
    where: { id: next.id },
    data: { status: RegistrationStatus.REGISTERED, waitlistPosition: null },
  });
  await reindexWaitlist(db, eventId);
  await refreshEventStatus(db, eventId);
}
