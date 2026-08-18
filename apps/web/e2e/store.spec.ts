import { expect, test } from '@playwright/test';
import { STORE_NEXUS, confirmDialog, login, statusChip } from './helpers';

test.describe('Loja', () => {
  test('login leva ao dashboard operacional', async ({ page }) => {
    await login(page, STORE_NEXUS.email, STORE_NEXUS.password);
    await expect(page).toHaveURL('/app');
    await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
    await expect(page.getByText('Arena Nexus')).toBeVisible();
    await expect(page.getByText('pagamentos pendentes')).toBeVisible();
    await expect(
      page.getByRole('link', { name: /Pokémon League Challenge/ }),
    ).toBeVisible();
  });

  test('cria evento, abre inscrições e edita', async ({ page }) => {
    const name = `Challenge E2E ${Date.now()}`;
    await login(page, STORE_NEXUS.email, STORE_NEXUS.password);
    await page.getByRole('link', { name: 'Criar evento' }).click();
    await expect(page.getByRole('heading', { name: 'Novo evento' })).toBeVisible();
    await page.getByLabel('Nome', { exact: true }).fill(name);
    await page.getByLabel('Data e horário').fill('2026-09-15T19:00');
    await expect(page.getByLabel('Local', { exact: true })).toHaveValue(
      'Arena Nexus',
    );
    await expect(page.getByLabel('Endereço')).toHaveValue(/Augusta/);
    await page.getByLabel('Vagas').fill('8');
    await page.getByLabel('Valor (R$)').fill('35');
    await page.getByRole('button', { name: 'Salvar' }).click();
    await expect(page.getByRole('heading', { name })).toBeVisible();
    await expect(statusChip(page, 'Rascunho')).toBeVisible();

    await page.getByRole('button', { name: 'Abrir inscrições' }).click();
    await expect(statusChip(page, 'Inscrições abertas')).toBeVisible();

    await page.getByRole('link', { name: 'Editar' }).click();
    await expect(page.getByRole('heading', { name: 'Editar evento' })).toBeVisible();
    await page.getByLabel('Descrição').fill('Evento de teste E2E.');
    await page.getByRole('button', { name: 'Salvar' }).click();
    await expect(page.getByRole('heading', { name })).toBeVisible();
  });

  test('lista participantes, filtra pagamentos e cancela inscrição', async ({
    page,
  }) => {
    await login(page, STORE_NEXUS.email, STORE_NEXUS.password);
    await page.getByRole('link', { name: /Pokémon League Challenge/ }).click();
    await page.getByRole('link', { name: 'Participantes' }).click();
    await expect(page.getByRole('heading', { name: 'Participantes' })).toBeVisible();
    await expect(statusChip(page, 'Confirmado').first()).toBeVisible();
    await expect(statusChip(page, 'Pago').first()).toBeVisible();

    await page.getByRole('searchbox', { name: 'Buscar participantes' }).fill('Ana');
    await expect(page.getByRole('cell', { name: /Ana/ }).first()).toBeVisible();

    await page.getByRole('searchbox', { name: 'Buscar participantes' }).fill('');
    await page.getByRole('button', { name: 'Pagos', exact: true }).click();
    await expect(statusChip(page, 'Pago').first()).toBeVisible();

    await page.getByRole('button', { name: 'Todos' }).click();
    await page.getByRole('button', { name: 'Cancelar' }).first().click();
    await confirmDialog(page);
    await expect(statusChip(page, 'Cancelada').first()).toBeVisible();
  });

  test('marca pagamento no local como pago', async ({ page }) => {
    await login(page, STORE_NEXUS.email, STORE_NEXUS.password);
    await page.getByRole('link', { name: /Yu-Gi-Oh! Locals/ }).click();
    await page.getByRole('link', { name: 'Participantes' }).click();
    await page.getByRole('button', { name: 'No local' }).click();
    await page.getByRole('button', { name: 'Marcar pago' }).first().click();
    await page.getByRole('button', { name: 'Pagos', exact: true }).click();
    await expect(statusChip(page, 'Pago').first()).toBeVisible();
  });
});
