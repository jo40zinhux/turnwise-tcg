import { Injectable } from '@nestjs/common';
import {
  PaymentMethod,
  PaymentMode,
  PaymentStatus,
  Prisma,
  RegistrationStatus,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';
import { DomainError } from '../common/domain-error';
import { AuthUser } from '../common/types';
import {
  nextWaitlistPosition,
  promoteNextWaitlist,
  refreshEventStatus,
  reindexWaitlist,
  seatedCount,
  waitlistCount,
} from '../domain/event-ops';
import {
  canWithdrawDirectly,
  isSeated,
  needsRefundRequest,
  registrationInclude,
  toPublicEvent,
  toRegistrationView,
} from '../domain/mappers';
import { PrismaService } from '../prisma/prisma.service';

export type RegisterInput = {
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
};

@Injectable()
export class RegistrationsService {
  constructor(private readonly prisma: PrismaService) {}

  async getPublicEvent(storeSlug: string, eventSlug: string) {
    const event = await this.findByPublicSlugs(storeSlug, eventSlug);
    if (!event || event.status === 'DRAFT') {
      throw new DomainError('Evento não encontrado.', 'NOT_FOUND', 404);
    }
    return toPublicEvent(
      event,
      await seatedCount(this.prisma, event.id),
      await waitlistCount(this.prisma, event.id),
    );
  }

  async register(input: RegisterInput, actor?: AuthUser) {
    if (!input.acceptedTerms) {
      throw new DomainError(
        'Aceite os termos para se inscrever.',
        'TERMS_REQUIRED',
      );
    }

    return this.prisma.$transaction(async (tx) => {
      const event = await this.findByPublicSlugs(
        input.storeSlug,
        input.eventSlug,
        tx,
      );
      if (!event) {
        throw new DomainError('Evento não encontrado.', 'NOT_FOUND', 404);
      }
      if (event.status !== 'OPEN' && event.status !== 'FULL') {
        throw new DomainError(
          'As inscrições deste evento não estão abertas.',
          'REGISTER_FAILED',
        );
      }

      const email = input.email.trim().toLowerCase();
      let user = actor
        ? await tx.user.findUnique({ where: { id: actor.id } })
        : await tx.user.findUnique({ where: { email } });

      if (actor && user && user.email !== email) {
        throw new DomainError(
          'O e-mail precisa ser o da conta conectada.',
          'REGISTER_FAILED',
        );
      }

      if (!user) {
        user = await tx.user.create({
          data: {
            email,
            fullName: input.fullName.trim(),
            displayName: (input.displayName || input.fullName).trim(),
            phone: input.phone?.trim() ?? '',
            role: 'PLAYER',
            acceptedTermsAt: new Date(),
            passwordHash: input.createPassword
              ? await bcrypt.hash(input.createPassword, 10)
              : null,
          },
        });
      } else if (input.createPassword && !user.passwordHash) {
        user = await tx.user.update({
          where: { id: user.id },
          data: { passwordHash: await bcrypt.hash(input.createPassword, 10) },
        });
      }

      const duplicate = await tx.registration.findFirst({
        where: {
          eventId: event.id,
          userId: user.id,
          status: { not: RegistrationStatus.CANCELLED },
        },
      });
      if (duplicate) {
        throw new DomainError(
          'Você já possui uma inscrição neste evento.',
          'REGISTER_FAILED',
        );
      }

      const seated = await seatedCount(tx, event.id);
      const useWaitlist = seated >= event.maxParticipants;
      if (useWaitlist && !event.allowWaitlist) {
        throw new DomainError('Este evento está lotado.', 'REGISTER_FAILED');
      }

      const registration = await tx.registration.create({
        data: {
          eventId: event.id,
          userId: user.id,
          storeId: event.storeId,
          status: useWaitlist
            ? RegistrationStatus.WAITLIST
            : RegistrationStatus.REGISTERED,
          waitlistPosition: useWaitlist
            ? await nextWaitlistPosition(tx, event.id)
            : null,
          guestAccessToken: `tok_${randomUUID()}`,
        },
      });

      if (input.gameIdentifierValue?.trim()) {
        await tx.gameIdentifier.create({
          data: {
            userId: user.id,
            gameId: event.gameId,
            type: 'PLAYER_ID',
            value: input.gameIdentifierValue.trim(),
          },
        });
      }

      let method: PaymentMethod = PaymentMethod.ON_SITE;
      if (event.paymentMode === PaymentMode.ONLINE) {
        method = PaymentMethod.MERCADO_PAGO;
      } else if (event.paymentMode === PaymentMode.PLAYER_CHOICE) {
        method = input.paymentChoice ?? PaymentMethod.MERCADO_PAGO;
      }

      await tx.payment.create({
        data: {
          registrationId: registration.id,
          method,
          amountCents: event.priceCents,
          status:
            method === PaymentMethod.ON_SITE
              ? PaymentStatus.PAY_ON_SITE
              : PaymentStatus.PENDING,
        },
      });

      await refreshEventStatus(tx, event.id);

      return this.loadView(tx, registration.id);
    });
  }

  async getOne(id: string, actor?: AuthUser, accessToken?: string) {
    const row = await this.prisma.registration.findUnique({
      where: { id },
      include: registrationInclude,
    });
    if (!row) {
      throw new DomainError('Inscrição não encontrada.', 'NOT_FOUND', 404);
    }
    const allowed =
      actor?.id === row.userId ||
      actor?.storeId === row.storeId ||
      (accessToken && accessToken === row.guestAccessToken);
    if (!allowed) {
      throw new DomainError(
        'Você não pode ver esta inscrição.',
        'FORBIDDEN',
        403,
      );
    }
    return toRegistrationView(row);
  }

  async listMine(actor: AuthUser) {
    const rows = await this.prisma.registration.findMany({
      where: { userId: actor.id },
      include: registrationInclude,
      orderBy: { createdAt: 'desc' },
    });
    return rows.map(toRegistrationView);
  }

  async cancelByPlayer(id: string, actor: AuthUser) {
    const row = await this.prisma.registration.findUnique({
      where: { id },
      include: { payment: true },
    });
    if (!row || row.userId !== actor.id) {
      throw new DomainError('Inscrição não encontrada.', 'NOT_FOUND', 404);
    }
    if (needsRefundRequest(row.payment)) {
      throw new DomainError(
        'Inscrição paga pelo Mercado Pago. Solicite o reembolso pelo WhatsApp da loja.',
        'CANCEL_FAILED',
      );
    }
    if (!canWithdrawDirectly(row.payment)) {
      throw new DomainError(
        'Não é possível cancelar esta inscrição.',
        'CANCEL_FAILED',
      );
    }
    return this.cancel(row.id);
  }

  async cancelByStore(id: string, storeId: string) {
    const row = await this.prisma.registration.findUnique({ where: { id } });
    if (!row || row.storeId !== storeId) {
      throw new DomainError('Inscrição não encontrada.', 'NOT_FOUND', 404);
    }
    return this.cancel(row.id);
  }

  async markOnSitePaid(id: string, storeId: string) {
    return this.prisma.$transaction(async (tx) => {
      const row = await tx.registration.findUnique({
        where: { id },
        include: { payment: true },
      });
      if (!row || row.storeId !== storeId) {
        throw new DomainError('Inscrição não encontrada.', 'NOT_FOUND', 404);
      }
      if (!row.payment || row.payment.method !== PaymentMethod.ON_SITE) {
        throw new DomainError(
          'Esta inscrição não é pagamento no local.',
          'PAY_FAILED',
        );
      }
      const now = new Date();
      await tx.payment.update({
        where: { id: row.payment.id },
        data: {
          status: PaymentStatus.APPROVED,
          paidAt: now,
        },
      });
      if (row.status === RegistrationStatus.REGISTERED) {
        await tx.registration.update({
          where: { id: row.id },
          data: { status: RegistrationStatus.CONFIRMED },
        });
      }
      return this.loadView(tx, row.id);
    });
  }

  async promote(id: string, storeId: string) {
    return this.prisma.$transaction(async (tx) => {
      const row = await tx.registration.findUnique({ where: { id } });
      if (!row || row.storeId !== storeId) {
        throw new DomainError('Inscrição não encontrada.', 'NOT_FOUND', 404);
      }
      if (row.status !== RegistrationStatus.WAITLIST) {
        throw new DomainError(
          'Jogador não está na waitlist.',
          'PROMOTE_FAILED',
        );
      }
      const event = await tx.event.findUniqueOrThrow({
        where: { id: row.eventId },
      });
      const seated = await seatedCount(tx, event.id);
      if (seated >= event.maxParticipants) {
        throw new DomainError('Não há vaga disponível.', 'PROMOTE_FAILED');
      }
      await tx.registration.update({
        where: { id: row.id },
        data: { status: RegistrationStatus.REGISTERED, waitlistPosition: null },
      });
      await reindexWaitlist(tx, event.id);
      await refreshEventStatus(tx, event.id);
      return this.loadView(tx, row.id);
    });
  }

  async startCheckout(registrationId: string, actor: AuthUser) {
    const row = await this.prisma.registration.findUnique({
      where: { id: registrationId },
      include: { payment: true },
    });
    if (!row || row.userId !== actor.id) {
      throw new DomainError('Inscrição não encontrada.', 'NOT_FOUND', 404);
    }
    if (!row.payment) {
      throw new DomainError('Pagamento não encontrado.', 'NOT_FOUND', 404);
    }
    if (row.payment.method !== PaymentMethod.MERCADO_PAGO) {
      throw new DomainError(
        'Este evento não usa Mercado Pago.',
        'CHECKOUT_FAILED',
      );
    }
    if (row.payment.status === PaymentStatus.APPROVED) {
      throw new DomainError('Pagamento já aprovado.', 'CHECKOUT_FAILED');
    }
    return this.prisma.payment.update({
      where: { id: row.payment.id },
      data: {
        status: PaymentStatus.PENDING,
        preferenceId: `pref_${row.payment.id}`,
        externalReference: registrationId,
        initPoint: `/payments/checkout/${row.payment.id}`,
      },
    });
  }

  async getPayment(id: string) {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment) {
      throw new DomainError('Pagamento não encontrado.', 'NOT_FOUND', 404);
    }
    return payment;
  }

  async applyNotification(
    paymentId: string,
    status: Extract<PaymentStatus, 'APPROVED' | 'FAILED' | 'CANCELLED'>,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const payment = await tx.payment.findUnique({ where: { id: paymentId } });
      if (!payment) {
        throw new DomainError('Pagamento não encontrado.', 'NOT_FOUND', 404);
      }
      const updated = await tx.payment.update({
        where: { id: payment.id },
        data: {
          status,
          paidAt: status === PaymentStatus.APPROVED ? new Date() : payment.paidAt,
        },
      });
      if (status === PaymentStatus.APPROVED) {
        const registration = await tx.registration.findUnique({
          where: { id: payment.registrationId },
        });
        if (registration?.status === RegistrationStatus.REGISTERED) {
          await tx.registration.update({
            where: { id: registration.id },
            data: { status: RegistrationStatus.CONFIRMED },
          });
        }
      }
      return updated;
    });
  }

  private async cancel(id: string) {
    return this.prisma.$transaction(async (tx) => {
      const row = await tx.registration.findUniqueOrThrow({
        where: { id },
        include: { payment: true },
      });
      if (row.status === RegistrationStatus.CANCELLED) {
        return this.loadView(tx, row.id);
      }
      const wasSeated = isSeated(row.status);
      await tx.registration.update({
        where: { id: row.id },
        data: {
          status: RegistrationStatus.CANCELLED,
          cancelledAt: new Date(),
          waitlistPosition: null,
        },
      });
      if (row.payment?.status === PaymentStatus.PENDING) {
        await tx.payment.update({
          where: { id: row.payment.id },
          data: { status: PaymentStatus.CANCELLED },
        });
      }
      await reindexWaitlist(tx, row.eventId);
      if (wasSeated) {
        await promoteNextWaitlist(tx, row.eventId);
      }
      await refreshEventStatus(tx, row.eventId);
      return this.loadView(tx, row.id);
    });
  }

  private async findByPublicSlugs(
    storeSlug: string,
    eventSlug: string,
    db: Prisma.TransactionClient | PrismaService = this.prisma,
  ) {
    return db.event.findFirst({
      where: {
        slug: eventSlug,
        store: { slug: storeSlug },
      },
      include: { store: true, game: true },
    });
  }

  private async loadView(db: Prisma.TransactionClient | PrismaService, id: string) {
    const row = await db.registration.findUniqueOrThrow({
      where: { id },
      include: registrationInclude,
    });
    return toRegistrationView(row);
  }

}
