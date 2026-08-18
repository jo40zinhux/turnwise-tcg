import { Injectable, computed, inject, signal } from '@angular/core';
import { API_CLIENT } from '../api/api-client.token';
import { Session, SignupInput, User } from '../models/domain';
import { UserRole } from '../models/enums';
import { GUEST_ACCESS_KEY, SESSION_STORAGE_KEY } from './session';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(API_CLIENT);
  private readonly session = signal<Session | null>(this.readSession());

  readonly current = this.session.asReadonly();
  readonly user = computed(() => this.session()?.user ?? null);
  readonly isStoreAdmin = computed(() => {
    const current = this.session();
    return Boolean(
      current?.storeId && current.user.role === UserRole.STORE_ADMIN,
    );
  });

  async login(email: string, password: string): Promise<Session> {
    const session = await this.api.login(email, password);
    this.persist(session);
    return session;
  }

  async signup(input: SignupInput): Promise<Session> {
    const session = await this.api.signup(input);
    this.persist(session);
    return session;
  }

  async logout(): Promise<void> {
    await this.api.logout();
    sessionStorage.removeItem(SESSION_STORAGE_KEY);
    this.session.set(null);
  }

  async claimGuest(
    registrationId: string,
    accessToken: string,
  ): Promise<Session> {
    this.saveGuestAccess(registrationId, accessToken);
    const session = await this.api.claimGuestSession(
      registrationId,
      accessToken,
    );
    this.persist(session);
    return session;
  }

  guestAccess(registrationId: string): string | undefined {
    return this.readGuestMap()[registrationId];
  }

  restoreUser(user: User): void {
    const current = this.session();
    if (!current) {
      return;
    }
    this.persist({ ...current, user });
  }

  private persist(session: Session): void {
    sessionStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(session));
    this.session.set(session);
  }

  private readSession(): Session | null {
    const raw = sessionStorage.getItem(SESSION_STORAGE_KEY);
    return raw ? (JSON.parse(raw) as Session) : null;
  }

  private saveGuestAccess(registrationId: string, token: string): void {
    const map = this.readGuestMap();
    map[registrationId] = token;
    sessionStorage.setItem(GUEST_ACCESS_KEY, JSON.stringify(map));
  }

  private readGuestMap(): Record<string, string> {
    const raw = sessionStorage.getItem(GUEST_ACCESS_KEY);
    return raw ? (JSON.parse(raw) as Record<string, string>) : {};
  }
}
