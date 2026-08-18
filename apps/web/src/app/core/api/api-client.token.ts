import { InjectionToken, Provider } from '@angular/core';
import { environment } from '../../../environments/environment';
import { ApiClient } from './api-client';
import { HttpApiClient } from './http/http-api.client';
import { MockApiClient } from './mock/mock-api.client';

export const API_CLIENT = new InjectionToken<ApiClient>('API_CLIENT');

export function provideApiClient(): Provider {
  return {
    provide: API_CLIENT,
    useClass: environment.useMocks ? MockApiClient : HttpApiClient,
  };
}
