import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../auth/auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.user() ? true : router.createUrlTree(['/login']);
};

export const storeAdminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.isStoreAdmin() ? true : router.createUrlTree(['/login']);
};

export const guestOnlyGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);
  if (!auth.user()) {
    return true;
  }
  return router.createUrlTree([auth.isStoreAdmin() ? '/app' : '/me']);
};
