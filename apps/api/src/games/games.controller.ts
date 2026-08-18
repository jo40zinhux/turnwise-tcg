import { Controller, Get } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { toGame } from '../domain/mappers';

@Controller('games')
export class GamesController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async list() {
    const games = await this.prisma.game.findMany({ orderBy: { name: 'asc' } });
    return games.map(toGame);
  }
}
