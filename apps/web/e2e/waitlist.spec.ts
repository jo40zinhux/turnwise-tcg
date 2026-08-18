import { expect, test } from '@playwright/test';
import {
  EVENTS,
  STORE_DRAGAO,
  confirmDialog,
  login,
  statusChip,
  uniqueEmail,
} from './helpers';

test.describe('Waitlist', () => {
  test('evento lotado impede vaga e mostra posição na espera', async ({
    page,
  }) => {
    await page.goto(`/events/${EVENTS.magic}`);
    await expect(statusChip(page, 'Lotado')).toBeVisible();
    await expect(page.getByText('0 disponíveis')).toBeVisible();
    await expect(page.getByText('3 na waitlist')).toBeVisible();
    await expect(page.getByRole('link', { name: 'Inscrever-se' })).toHaveCount(0);
    await page.getByRole('link', { name: 'Entrar na waitlist' }).click();
    await expect(page.getByText('Você entra na waitlist')).toBeVisible();
    await page.getByLabel('Nome completo').fill('Wait Playwright');
    await page.getByLabel('E-mail').fill(uniqueEmail('wait'));
    await page.getByRole('checkbox', { name: /aceito/i }).check();
    await page.getByRole('button', { name: 'Confirmar inscrição' }).click();
    await expect(statusChip(page, 'Waitlist')).toBeVisible();
    await expect(page.getByText(/posição 4/i)).toBeVisible();
  });

  test('loja vê waitlist e a vaga liberada promove o próximo', async ({
    page,
  }) => {
    await login(page, STORE_DRAGAO.email, STORE_DRAGAO.password);
    await page.getByRole('link', { name: /Friday Night Magic/ }).click();
    await page.getByRole('link', { name: 'Participantes' }).click();
    await page.getByRole('button', { name: 'Waitlist', exact: true }).click();
    await expect(page.getByRole('row', { name: /Pedro/ })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Promover' }).first()).toBeVisible();

    await page.getByRole('button', { name: 'Confirmados' }).click();
    await page.getByRole('button', { name: 'Cancelar' }).first().click();
    await confirmDialog(page);

    await page.getByRole('button', { name: 'Waitlist', exact: true }).click();
    await expect(page.getByRole('row', { name: /Pedro/ })).toHaveCount(0);
  });
});
