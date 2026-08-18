import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { OptionalJwtGuard } from '../common/guards/optional-jwt.guard';
import { AuthUser } from '../common/types';
import { RegistrationsService } from '../registrations/registrations.service';
import { RegisterDto } from './dto';

@Controller('events')
export class EventsController {
  constructor(private readonly registrations: RegistrationsService) {}

  @Get(':storeSlug/:eventSlug')
  getPublic(
    @Param('storeSlug') storeSlug: string,
    @Param('eventSlug') eventSlug: string,
  ) {
    return this.registrations.getPublicEvent(storeSlug, eventSlug);
  }

  @Post(':storeSlug/:eventSlug/registrations')
  @UseGuards(OptionalJwtGuard)
  register(
    @Param('storeSlug') storeSlug: string,
    @Param('eventSlug') eventSlug: string,
    @Body() dto: RegisterDto,
    @CurrentUser() actor?: AuthUser,
  ) {
    return this.registrations.register(
      { ...dto, storeSlug, eventSlug },
      actor,
    );
  }
}
