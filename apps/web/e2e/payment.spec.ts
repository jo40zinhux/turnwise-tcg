import { expect, test } from '@playwright/test';
import { EVENTS, registerGuest, statusChip, uniqueEmail } from './helpers';

test.describe('Pagamentos Mercado Pago', () => {
  test('aprova no Checkout Pro e a inscrição observa status pago', async ({
    page,
  }) => {
    await registerGuest(page, {
      event: EVENTS.pokemon,
      name: 'Pago Playwright',
      email: uniqueEmail('pay'),
    });
    await page.getByRole('button', { name: 'Pagar com Mercado Pago' }).click();
    await expect(page.getByRole('heading', { name: 'Checkout Pro' })).toBeVisible();
    await page.getByRole('button', { name: 'Pagar' }).click();
    await expect(page.getByText('Pagamento aprovado')).toBeVisible();
    await expect(statusChip(page, 'Pago')).toBeVisible();
    await page.getByRole('link', { name: 'Ver inscrição' }).click();
    await expect(statusChip(page, 'Confirmado')).toBeVisible();
    await expect(statusChip(page, 'Pago')).toBeVisible();
    await expect(
      page.getByRole('link', { name: 'Pedir reembolso no WhatsApp' }),
    ).toBeVisible();
    await expect(
      page.getByRole('link', { name: 'Pedir reembolso no WhatsApp' }),
    ).toHaveAttribute('href', /wa\.me\/5511999887766/);
    await expect(
      page.getByRole('button', { name: 'Desistir da vaga' }),
    ).toHaveCount(0);
  });

  test('falha no checkout e permite tentar de novo', async ({ page }) => {
    await registerGuest(page, {
      event: EVENTS.pokemon,
      name: 'Falha Playwright',
      email: uniqueEmail('fail'),
    });
    await page.getByRole('button', { name: 'Pagar com Mercado Pago' }).click();
    await page.getByRole('button', { name: 'Simular falha' }).click();
    await expect(page.getByText('não foi aprovado')).toBeVisible();
    await page.getByRole('link', { name: 'Ver inscrição' }).click();
    await expect(statusChip(page, 'Falhou')).toBeVisible();
    await expect(
      page.getByRole('button', { name: 'Pagar com Mercado Pago' }),
    ).toBeVisible();
  });
});
