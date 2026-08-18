import { expect, type Page } from '@playwright/test';

export const STORE_NEXUS = { email: 'loja@nexus.demo', password: 'demo1234' };
export const STORE_DRAGAO = { email: 'loja@dragao.demo', password: 'demo1234' };
export const PLAYER_ANA = {
  email: 'ana@player.demo',
  password: 'demo1234',
  name: 'Ana Ribeiro',
};

export const EVENTS = {
  pokemon: { store: 'arena-nexus', slug: 'pokemon-league-challenge-nexus' },
  magic: { store: 'dragao-de-aco', slug: 'fnm-dragao-aco' },
  yugioh: { store: 'arena-nexus', slug: 'yugioh-locals-nexus' },
};

export function eventPath(event: { store: string; slug: string }): string {
  return `/events/${event.store}/${event.slug}`;
}

export function uniqueEmail(prefix: string): string {
  return `${prefix}.${Date.now()}.${Math.random().toString(36).slice(2, 6)}@play.demo`;
}

export function statusChip(page: Page, label: string) {
  return page.getByRole('status').filter({ hasText: new RegExp(`^${label}$`) });
}

export async function login(page: Page, email: string, password: string) {
  await page.goto('/login');
  await page.getByLabel('E-mail').fill(email);
  await page.getByLabel('Senha').fill(password);
  await page.getByRole('button', { name: 'Entrar' }).click();
}

export async function acceptTerms(page: Page) {
  await page.getByRole('checkbox', { name: /aceito/i }).check();
}

export async function registerGuest(
  page: Page,
  options: { event: { store: string; slug: string }; name: string; email: string },
) {
  await page.goto(`${eventPath(options.event)}/register`);
  await expect(page.getByRole('heading', { name: 'Inscrição' })).toBeVisible();
  await page.getByLabel('Nome completo').fill(options.name);
  await page.getByLabel('E-mail').fill(options.email);
  await acceptTerms(page);
  await page.getByRole('button', { name: 'Confirmar inscrição' }).click();
  await expect(page).toHaveURL(/\/r\//);
}

export async function confirmDialog(page: Page) {
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await dialog.getByTestId('confirm-dialog-yes').click();
}
