import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { AuthUser } from '../types';
import { DomainError } from '../domain-error';

@Injectable()
export class StoreGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const user = context.switchToHttp().getRequest<{ user?: AuthUser }>().user;
    if (!user?.storeId) {
      throw new DomainError('Conta de loja necessária.', 'FORBIDDEN', 403);
    }
    return true;
  }
}
