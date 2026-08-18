import {
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { OptionalJwtGuard } from '../common/guards/optional-jwt.guard';
import { AuthUser } from '../common/types';
import { RegistrationsService } from './registrations.service';

@Controller()
export class RegistrationsController {
  constructor(private readonly registrations: RegistrationsService) {}

  @Get('registrations/:id')
  @UseGuards(OptionalJwtGuard)
  getOne(
    @Param('id') id: string,
    @Query('access') access: string | undefined,
    @CurrentUser() actor?: AuthUser,
  ) {
    return this.registrations.getOne(id, actor, access);
  }

  @Post('registrations/:id/cancel')
  @UseGuards(JwtAuthGuard)
  cancel(@Param('id') id: string, @CurrentUser() actor: AuthUser) {
    return this.registrations.cancelByPlayer(id, actor);
  }
}
