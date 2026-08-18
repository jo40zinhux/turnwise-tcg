import { Injectable } from '@nestjs/common';
import { EventStatus, PaymentStatus, RegistrationStatus } from '@prisma/client';
import { DomainError } from '../common/domain-error';
import { AuthUser } from '../common/types';
import {
  refreshEventStatus,
  seatedCount,
  waitlistCount,
} from '../domain/event-ops';
import {
  toEvent,
  toGame,
  toIdentifier,
  toPayment,
  toPlayer,
  toPublicEvent,
  toRegistration,
  toStore,
} from '../domain/mappers';
import { slugify } from '../domain/slug';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEventDto, UpdateEventDto } from './dto';

@Injectable()
export class StoreService {
  constructor(private readonly prisma: PrismaService) {}

  async getStore(actor: AuthUser) {
    return toStore(await this.requireStore(actor.storeId!));
  }

  async dashboard(actor: AuthUser) {
    const storeId = actor.storeId!;
    const store = await this.requireStore(storeId);
    const events = await this.prisma.event.findMany({
      where: {
        storeId,
        status: {
          in: [EventStatus.OPEN, EventStatus.FULL, EventStatus.DRAFT],
        },
      },
      include: { game: true },
      orderBy: { startsAt: 'asc' },
    });

    const mapped = await Promise.all(
      events.map(async (event) => {
        const rows = await this.prisma.registration.findMany({
          where: { eventId: event.id },
          include: { payment: true },
        });
        const seated = await seatedCount(this.prisma, event.id);
        return {
          event: toEvent(event),
          game: toGame(event.game),
          capacity: {
            maxParticipants: event.maxParticipants,
            seatedCount: seated,
            available: Math.max(0, event.maxParticipants - seated),
            waitlistCount: await waitlistCount(this.prisma, event.id),
          },
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
            (row) => row.status === RegistrationStatus.CANCELLED,
          ).length,
        };
      }),
    );

    return {
      store: toStore(store),
      upcomingEvents: mapped,
      totals: {
        activeEvents: mapped.filter(
          (item) =>
            item.event.status === EventStatus.OPEN ||
            item.event.status === EventStatus.FULL,
        ).length,
        seatedPlayers: mapped.reduce(
          (sum, item) => sum + item.capacity.seatedCount,
          0,
        ),
        waitlist: mapped.reduce(
          (sum, item) => sum + item.capacity.waitlistCount,
          0,
        ),
        pendingPayments: mapped.reduce(
          (sum, item) => sum + item.pendingPayments,
          0,
        ),
      },
    };
  }

  async listEvents(actor: AuthUser) {
    const events = await this.prisma.event.findMany({
      where: { storeId: actor.storeId },
      orderBy: { startsAt: 'asc' },
    });
    return events.map(toEvent);
  }

  async getEvent(id: string, actor: AuthUser) {
    const event = await this.requireStoreEvent(id, actor.storeId!);
    return toPublicEvent(
      event,
      await seatedCount(this.prisma, event.id),
      await waitlistCount(this.prisma, event.id),
    );
  }

  async createEvent(actor: AuthUser, dto: CreateEventDto) {
    await this.requireGame(dto.gameId);
    const store = await this.requireStore(actor.storeId!);
    const event = await this.prisma.event.create({
      data: {
        storeId: store.id,
        gameId: dto.gameId,
        slug: await this.uniqueSlug(store.id, dto.name),
        name: dto.name.trim(),
        description: dto.description.trim(),
        rules: dto.rules.trim(),
        startsAt: new Date(dto.startsAt),
        locationName: dto.locationName.trim() || store.locationName,
        address: dto.address.trim() || store.address,
        maxParticipants: dto.maxParticipants,
        priceCents: dto.priceCents,
        paymentMode: dto.paymentMode,
        allowWaitlist: dto.allowWaitlist,
        status: EventStatus.DRAFT,
        refundEnabled: dto.refundPolicy.enabled,
        refundFeePercent: dto.refundPolicy.feePercent,
        refundNote: dto.refundPolicy.note,
      },
    });
    return toEvent(event);
  }

  async updateEvent(id: string, actor: AuthUser, dto: UpdateEventDto) {
    const event = await this.requireStoreEvent(id, actor.storeId!);
    if (dto.gameId) {
      await this.requireGame(dto.gameId);
    }
    const updated = await this.prisma.event.update({
      where: { id: event.id },
      data: {
        name: dto.name?.trim(),
        gameId: dto.gameId,
        description: dto.description?.trim(),
        rules: dto.rules?.trim(),
        startsAt: dto.startsAt ? new Date(dto.startsAt) : undefined,
        locationName: dto.locationName?.trim(),
        address: dto.address?.trim(),
        maxParticipants: dto.maxParticipants,
        priceCents: dto.priceCents,
        paymentMode: dto.paymentMode,
        allowWaitlist: dto.allowWaitlist,
        slug: dto.name ? await this.uniqueSlug(event.storeId, dto.name, event.id) : undefined,
        refundEnabled: dto.refundPolicy?.enabled,
        refundFeePercent: dto.refundPolicy?.feePercent,
        refundNote: dto.refundPolicy?.note,
      },
    });
    return toEvent(updated);
  }

  async setStatus(id: string, actor: AuthUser, status: EventStatus) {
    const event = await this.requireStoreEvent(id, actor.storeId!);
    await this.prisma.event.update({
      where: { id: event.id },
      data: { status },
    });
    if (status === EventStatus.OPEN) {
      await refreshEventStatus(this.prisma, event.id);
    }
    const fresh = await this.prisma.event.findUniqueOrThrow({
      where: { id: event.id },
    });
    return toEvent(fresh);
  }

  async participants(eventId: string, actor: AuthUser, filter: string, search: string) {
    const event = await this.requireStoreEvent(eventId, actor.storeId!);
    const rows = await this.prisma.registration.findMany({
      where: { eventId: event.id },
      include: {
        user: { include: { identifiers: true } },
        payment: true,
      },
      orderBy: { createdAt: 'asc' },
    });
    const needle = search.trim().toLowerCase();
    return rows
      .map((row) => ({
        registration: toRegistration(row),
        player: toPlayer(row.user),
        payment: toPayment(row.payment),
        gameIdentifiers: row.user.identifiers.map(toIdentifier),
      }))
      .filter((row) => this.matchesFilter(row, filter))
      .filter((row) => {
        if (!needle) {
          return true;
        }
        const identifierMatch = row.gameIdentifiers.some((item) =>
          item.value.toLowerCase().includes(needle),
        );
        return (
          row.player.fullName.toLowerCase().includes(needle) ||
          row.player.email.toLowerCase().includes(needle) ||
          identifierMatch
        );
      });
  }

  private matchesFilter(
    row: {
      registration: { status: RegistrationStatus };
      payment: { status: PaymentStatus } | null;
    },
    filter: string,
  ): boolean {
    const status = row.registration.status;
    const payment = row.payment;
    switch (filter) {
      case 'CONFIRMED':
        return (
          status === RegistrationStatus.CONFIRMED ||
          status === RegistrationStatus.REGISTERED
        );
      case 'PENDING':
        return payment?.status === PaymentStatus.PENDING;
      case 'PAID':
        return payment?.status === PaymentStatus.APPROVED;
      case 'UNPAID':
        return (
          payment?.status === PaymentStatus.PENDING ||
          payment?.status === PaymentStatus.FAILED ||
          payment?.status === PaymentStatus.PAY_ON_SITE
        );
      case 'PAY_ON_SITE':
        return payment?.status === PaymentStatus.PAY_ON_SITE;
      case 'WAITLIST':
        return status === RegistrationStatus.WAITLIST;
      case 'CANCELLED':
        return status === RegistrationStatus.CANCELLED;
      default:
        return true;
    }
  }

  private async uniqueSlug(
    storeId: string,
    name: string,
    exceptId?: string,
  ): Promise<string> {
    const base = slugify(name) || 'evento';
    let slug = base;
    let n = 2;
    while (true) {
      const existing = await this.prisma.event.findUnique({
        where: { storeId_slug: { storeId, slug } },
      });
      if (!existing || existing.id === exceptId) {
        return slug;
      }
      slug = `${base}-${n}`;
      n += 1;
    }
  }

  private async requireGame(id: string) {
    const game = await this.prisma.game.findUnique({ where: { id } });
    if (!game) {
      throw new DomainError('Jogo não encontrado.', 'NOT_FOUND', 404);
    }
    return game;
  }

  private async requireStore(id: string) {
    const store = await this.prisma.store.findUnique({ where: { id } });
    if (!store) {
      throw new DomainError('Loja não encontrada.', 'NOT_FOUND', 404);
    }
    return store;
  }

  private async requireStoreEvent(id: string, storeId: string) {
    const event = await this.prisma.event.findUnique({
      where: { id },
      include: { store: true, game: true },
    });
    if (!event) {
      throw new DomainError('Evento não encontrado.', 'NOT_FOUND', 404);
    }
    if (event.storeId !== storeId) {
      throw new DomainError('Evento de outra loja.', 'FORBIDDEN', 403);
    }
    return event;
  }
}
