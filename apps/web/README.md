# TurnWise Events (Web)

Plataforma web de inscrições e gestão de participantes para eventos TCG.

Frontend Angular em `apps/web`. Backend NestJS em `apps/api`.

Requisito: Node.js 22 (`apps/web/.nvmrc`).

## Rodar (mocks)

```bash
cd apps/web
npm install
npm start
```

Abre `http://localhost:4200`. Com `environment.useMocks: true` não precisa da API.

## Rodar com API real (Windows e macOS)

1. Suba o backend com Docker + Postgres — `apps/api/README.md` (`setup.ps1` no Windows, `setup.sh` no macOS).
2. Em `src/environments/environment.ts`, `useMocks: false`.
3. `npm start` — o proxy envia `/api` para `http://localhost:3000`.

Contas demo (mock e seed da API):

- Loja: `loja@nexus.demo` / `demo1234`
- Jogador: `ana@player.demo` / `demo1234`

Eventos públicos:

- `/events/arena-nexus/pokemon-league-challenge-nexus` — Mercado Pago
- `/events/dragao-de-aco/fnm-dragao-aco` — lotado + waitlist
- `/events/arena-nexus/yugioh-locals-nexus` — pagamento no local

## Testes

```bash
npx playwright install chromium
npm run e2e
```

Os e2e atuais usam o mock. Contra a API, rode o seed e ligue `useMocks: false`.

## Arquitetura

UI → services → `API_CLIENT` → `MockApiClient` ou `HttpApiClient`.

Troca: `environment.useMocks`.
