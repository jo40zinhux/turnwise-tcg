import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { catchError, throwError } from 'rxjs';
import { ApiError } from '../api/api-client';
import { SESSION_STORAGE_KEY } from '../auth/session';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const raw = sessionStorage.getItem(SESSION_STORAGE_KEY);
  let headers = req.headers;
  if (raw) {
    try {
      const session = JSON.parse(raw) as { token?: string };
      if (session.token) {
        headers = headers.set('Authorization', `Bearer ${session.token}`);
      }
    } catch {
      /* ignore malformed session */
    }
  }

  return next(req.clone({ headers })).pipe(
    catchError((error: unknown) => {
      if (error instanceof HttpErrorResponse) {
        const body = error.error as { message?: string; code?: string } | null;
        return throwError(
          () =>
            new ApiError(
              body?.message ?? error.message,
              body?.code ?? 'HTTP_ERROR',
              error.status || 500,
            ),
        );
      }
      return throwError(() => error);
    }),
  );
};
