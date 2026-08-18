# TurnWise Events (Web)

Plataforma web de inscrições e gestão de participantes para eventos TCG. Frontend Angular, mocks no lugar do NestJS.

## Rodar

```bash
cd apps/web
npm start
```

Abre `http://localhost:4200`.

Contas demo:

- Loja: `loja@nexus.demo` / `demo1234`
- Jogador: `ana@player.demo` / `demo1234`

Eventos públicos:

- `/events/pokemon-league-challenge-nexus` — Mercado Pago
- `/events/fnm-dragao-aco` — lotado + waitlist
- `/events/yugioh-locals-nexus` — pagamento no local

## Testes

```bash
npx playwright install chromium
npm run e2e
```

## Arquitetura

UI → services → `API_CLIENT` → `MockApiClient` (hoje) ou `HttpApiClient` (quando o backend existir).

Troca: `environment.useMocks`.
