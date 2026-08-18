import { Body, Controller, Get, Patch, Post, UseGuards } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { DomainError } from '../common/domain-error';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { AuthUser } from '../common/types';
import { toIdentifier, toUser } from '../domain/mappers';
import { PrismaService } from '../prisma/prisma.service';
import { RegistrationsService } from '../registrations/registrations.service';
import { GameIdentifierDto, SetPasswordDto, UpdateProfileDto } from './dto';

@Controller('me')
@UseGuards(JwtAuthGuard)
export class MeController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly registrations: RegistrationsService,
  ) {}

  @Patch()
  async updateProfile(
    @CurrentUser() actor: AuthUser,
    @Body() dto: UpdateProfileDto,
  ) {
    const user = await this.prisma.user.update({
      where: { id: actor.id },
      data: {
        fullName: dto.fullName?.trim(),
        displayName: dto.displayName?.trim(),
        phone: dto.phone?.trim(),
        city: dto.city?.trim(),
        state: dto.state?.trim(),
      },
    });
    return toUser(user);
  }

  @Post('game-identifiers')
  async addIdentifier(
    @CurrentUser() actor: AuthUser,
    @Body() dto: GameIdentifierDto,
  ) {
    const game = await this.prisma.game.findUnique({
      where: { id: dto.gameId },
    });
    if (!game) {
      throw new DomainError('Jogo não encontrado.', 'NOT_FOUND', 404);
    }
    const identifier = await this.prisma.gameIdentifier.create({
      data: {
        userId: actor.id,
        gameId: dto.gameId,
        type: dto.type.trim() || 'PLAYER_ID',
        value: dto.value.trim(),
      },
    });
    return toIdentifier(identifier);
  }

  @Get('registrations')
  listRegistrations(@CurrentUser() actor: AuthUser) {
    return this.registrations.listMine(actor);
  }

  @Post('password')
  async setPassword(
    @CurrentUser() actor: AuthUser,
    @Body() dto: SetPasswordDto,
  ) {
    const user = await this.prisma.user.update({
      where: { id: actor.id },
      data: { passwordHash: await bcrypt.hash(dto.password, 10) },
    });
    return toUser(user);
  }
}
