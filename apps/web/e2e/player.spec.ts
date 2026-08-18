import { expect, test } from '@playwright/test';
import {
  EVENTS,
  eventPath,
  PLAYER_ANA,
  acceptTerms,
  confirmDialog,
  login,
  registerGuest,
  statusChip,
  uniqueEmail,
} from './helpers';

test.describe('Jogador — evento público', () => {
  test('acessa o evento, vê vagas e não vê nomes de participantes', async ({
    page,
  }) => {
    await page.goto(eventPath(EVENTS.pokemon));
    await expect(
      page.getByRole('heading', { name: 'Pokémon League Challenge' }),
    ).toBeVisible();
    await expect(page.getByText('32 vagas')).toBeVisible();
    await expect(page.getByText('24 inscritos')).toBeVisible();
    await expect(page.getByText('8 disponíveis')).toBeVisible();
    await expect(page.getByText('Reembolso', { exact: true })).toBeVisible();
    await expect(page.getByText(/taxa de 20%/i)).toBeVisible();
    await expect(page.getByText('Ana Silva')).toHaveCount(0);
    await expect(page.getByText(/@players\.demo/)).toHaveCount(0);
    await expect(page.getByRole('link', { name: 'Inscrever-se' })).toBeVisible();
  });
});

test.describe('Jogador — inscrição guest', () => {
  test('inscreve, consulta confirmação e desiste sem ter pago', async ({
    page,
  }) => {
    await registerGuest(page, {
      event: EVENTS.pokemon,
      name: 'Guest Playwright',
      email: uniqueEmail('guest'),
    });
    await expect(
      page.getByRole('heading', { name: 'Pokémon League Challenge' }),
    ).toBeVisible();
    await expect(statusChip(page, 'Inscrito')).toBeVisible();
    await expect(statusChip(page, 'Pendente')).toBeVisible();
    await page.getByRole('button', { name: 'Desistir da vaga' }).click();
    await confirmDialog(page);
    await expect(statusChip(page, 'Cancelada')).toBeVisible();
  });

  test('pagamento no local permite desistência direta', async ({ page }) => {
    await registerGuest(page, {
      event: EVENTS.yugioh,
      name: 'Locals Guest',
      email: uniqueEmail('locals'),
    });
    await expect(statusChip(page, 'Pagamento no local')).toBeVisible();
    await expect(
      page.getByRole('button', { name: 'Desistir da vaga' }),
    ).toBeVisible();
    await expect(
      page.getByRole('link', { name: 'Pedir reembolso no WhatsApp' }),
    ).toHaveCount(0);
  });
});

test.describe('Jogador — conta', () => {
  test('cria conta e vê lista vazia de inscrições', async ({ page }) => {
    const email = uniqueEmail('signup');
    await page.goto('/signup');
    await page.getByLabel('Nome completo').fill('Nova Jogadora');
    await page.getByLabel('E-mail').fill(email);
    await page.getByLabel('Senha').fill('demo1234');
    await acceptTerms(page);
    await page.getByRole('button', { name: 'Criar conta' }).click();
    await expect(page).toHaveURL('/me');
    await expect(
      page.getByRole('heading', { name: 'Nenhuma inscrição ainda' }),
    ).toBeVisible();
  });

  test('jogador existente entra com dados pré-preenchidos e se inscreve', async ({
    page,
  }) => {
    await login(page, PLAYER_ANA.email, PLAYER_ANA.password);
    await expect(page).toHaveURL('/me');
    await page.getByRole('link', { name: 'TurnWise Events' }).click();
    await page.getByRole('link', { name: /Pokémon League Challenge/ }).click();
    await page.getByRole('link', { name: 'Inscrever-se' }).click();
    await expect(page.getByLabel('Nome completo')).toHaveValue(PLAYER_ANA.name);
    await expect(page.getByLabel('E-mail')).toHaveValue(PLAYER_ANA.email);
    await acceptTerms(page);
    await page.getByRole('button', { name: 'Confirmar inscrição' }).click();
    await expect(page).toHaveURL(/\/r\//);
    await expect(
      page.getByRole('heading', { name: 'Pokémon League Challenge' }),
    ).toBeVisible();
    await page.getByRole('link', { name: 'Minhas inscrições' }).first().click();
    await expect(
      page.getByRole('heading', { name: 'Pokémon League Challenge' }),
    ).toBeVisible();
  });
});
