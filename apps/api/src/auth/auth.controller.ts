import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { OptionalJwtGuard } from '../common/guards/optional-jwt.guard';
import { AuthUser } from '../common/types';
import { AuthService } from './auth.service';
import { GuestSessionDto, LoginDto, SignupDto } from './dto';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @Post('signup')
  signup(@Body() dto: SignupDto) {
    return this.auth.signup(dto);
  }

  @Post('logout')
  logout() {
    return;
  }

  @Get('session')
  @UseGuards(OptionalJwtGuard)
  session(@CurrentUser() actor?: AuthUser) {
    return this.auth.currentSession(actor);
  }

  @Post('guest-session')
  @UseGuards(OptionalJwtGuard)
  guestSession(@Body() dto: GuestSessionDto, @CurrentUser() actor?: AuthUser) {
    return this.auth.claimGuest(dto, actor);
  }
}
