import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { StoreGuard } from '../common/guards/store.guard';
import { AuthUser } from '../common/types';
import { RegistrationsService } from '../registrations/registrations.service';
import { CreateEventDto, SetEventStatusDto, UpdateEventDto } from './dto';
import { StoreService } from './store.service';

@Controller('store')
@UseGuards(JwtAuthGuard, StoreGuard)
export class StoreController {
  constructor(
    private readonly stores: StoreService,
    private readonly registrations: RegistrationsService,
  ) {}

  @Get()
  getStore(@CurrentUser() actor: AuthUser) {
    return this.stores.getStore(actor);
  }

  @Get('dashboard')
  dashboard(@CurrentUser() actor: AuthUser) {
    return this.stores.dashboard(actor);
  }

  @Get('events')
  listEvents(@CurrentUser() actor: AuthUser) {
    return this.stores.listEvents(actor);
  }

  @Get('events/:id')
  getEvent(@Param('id') id: string, @CurrentUser() actor: AuthUser) {
    return this.stores.getEvent(id, actor);
  }

  @Post('events')
  createEvent(@CurrentUser() actor: AuthUser, @Body() dto: CreateEventDto) {
    return this.stores.createEvent(actor, dto);
  }

  @Patch('events/:id')
  updateEvent(
    @Param('id') id: string,
    @CurrentUser() actor: AuthUser,
    @Body() dto: UpdateEventDto,
  ) {
    return this.stores.updateEvent(id, actor, dto);
  }

  @Post('events/:id/status')
  setStatus(
    @Param('id') id: string,
    @CurrentUser() actor: AuthUser,
    @Body() dto: SetEventStatusDto,
  ) {
    return this.stores.setStatus(id, actor, dto.status);
  }

  @Get('events/:id/participants')
  listParticipants(
    @Param('id') id: string,
    @CurrentUser() actor: AuthUser,
    @Query('filter') filter = 'ALL',
    @Query('search') search = '',
  ) {
    return this.stores.participants(id, actor, filter, search);
  }

  @Post('registrations/:id/pay-on-site')
  markPaid(@Param('id') id: string, @CurrentUser() actor: AuthUser) {
    return this.registrations.markOnSitePaid(id, actor.storeId!);
  }

  @Post('registrations/:id/cancel')
  cancel(@Param('id') id: string, @CurrentUser() actor: AuthUser) {
    return this.registrations.cancelByStore(id, actor.storeId!);
  }

  @Post('registrations/:id/promote')
  promote(@Param('id') id: string, @CurrentUser() actor: AuthUser) {
    return this.registrations.promote(id, actor.storeId!);
  }
}
