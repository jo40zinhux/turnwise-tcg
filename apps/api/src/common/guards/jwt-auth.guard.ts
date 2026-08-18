import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { DomainError } from '../domain-error';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  handleRequest<TUser>(err: Error | null, user: TUser): TUser {
    if (err || !user) {
      throw new DomainError('Faça login para continuar.', 'UNAUTHENTICATED', 401);
    }
    return user;
  }
}
