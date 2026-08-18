import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { User } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { DomainError } from '../common/domain-error';
import { AuthUser } from '../common/types';
import { toUser } from '../domain/mappers';
import { PrismaService } from '../prisma/prisma.service';
import { GuestSessionDto, LoginDto, SignupDto } from './dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async login(dto: LoginDto) {
    const email = dto.email.trim().toLowerCase();
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { memberships: true },
    });
    if (!user?.passwordHash) {
      throw new DomainError('E-mail ou senha inválidos.', 'INVALID_CREDENTIALS', 401);
    }
    const ok = await bcrypt.compare(dto.password, user.passwordHash);
    if (!ok) {
      throw new DomainError('E-mail ou senha inválidos.', 'INVALID_CREDENTIALS', 401);
    }
    return this.issue(user, user.memberships[0]?.storeId);
  }

  async signup(dto: SignupDto) {
    if (!dto.acceptedTerms) {
      throw new DomainError('Aceite os termos para continuar.', 'TERMS_REQUIRED');
    }
    const email = dto.email.trim().toLowerCase();
    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing?.passwordHash) {
      throw new DomainError('Já existe uma conta com este e-mail.', 'EMAIL_TAKEN');
    }
    const passwordHash = await bcrypt.hash(dto.password, 10);
    const user = existing
      ? await this.prisma.user.update({
          where: { id: existing.id },
          data: {
            fullName: dto.fullName.trim(),
            displayName: dto.fullName.trim(),
            phone: dto.phone?.trim() ?? existing.phone,
            passwordHash,
            acceptedTermsAt: new Date(),
            role: existing.role,
          },
          include: { memberships: true },
        })
      : await this.prisma.user.create({
          data: {
            email,
            fullName: dto.fullName.trim(),
            displayName: dto.fullName.trim(),
            phone: dto.phone?.trim() ?? '',
            passwordHash,
            role: 'PLAYER',
            acceptedTermsAt: new Date(),
          },
          include: { memberships: true },
        });
    return this.issue(user, user.memberships[0]?.storeId);
  }

  async currentSession(actor?: AuthUser) {
    if (!actor) {
      return null;
    }
    const user = await this.prisma.user.findUnique({
      where: { id: actor.id },
      include: { memberships: true },
    });
    if (!user) {
      return null;
    }
    return {
      token: actor.token,
      user: toUser(user),
      storeId: user.memberships[0]?.storeId,
    };
  }

  async claimGuest(dto: GuestSessionDto, actor?: AuthUser) {
    if (actor) {
      return this.currentSession(actor);
    }
    const registration = await this.prisma.registration.findUnique({
      where: { id: dto.registrationId },
      include: { user: { include: { memberships: true } } },
    });
    if (!registration || registration.guestAccessToken !== dto.accessToken) {
      throw new DomainError('Link de inscrição inválido.', 'FORBIDDEN', 403);
    }
    return this.issue(
      registration.user,
      registration.user.memberships[0]?.storeId,
    );
  }

  private issue(
    user: User & { memberships?: { storeId: string }[] },
    storeId?: string,
  ) {
    const token = this.jwt.sign({ sub: user.id, storeId });
    return {
      token,
      user: toUser(user),
      storeId,
    };
  }
}
