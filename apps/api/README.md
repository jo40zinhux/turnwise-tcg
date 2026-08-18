# TurnWise Events API

Backend NestJS + PostgreSQL + Prisma. Implementa o contrato do `HttpApiClient` em `apps/web`.

Mercado Pago **ainda não é live**: o checkout devolve um `initPoint` para o stub do Angular (`/payments/checkout/:id`).

O caminho padrão em **Windows, macOS e Linux** é o mesmo: **Docker Desktop + Postgres 16 no Compose**. A API pode rodar no host (`npm run start:dev`) ou no container (`npm run start:docker`).

## Requisitos

- Node.js 22 (`apps/api/.nvmrc`)
- Docker Desktop (inclui `docker compose`)
- npm

Não instale Postgres nativo se for usar o Compose — os dois brigam na porta `5432`.

## 1. Instalar Docker

**Windows**

```powershell
winget install -e --id Docker.DockerDesktop
```

Abra o **Docker Desktop** uma vez (WSL 2) e espere ficar verde.

**macOS**

```bash
brew install --cask docker
```

Abra o Docker Desktop (Applications) uma vez. No Apple Silicon o image `postgres:16-alpine` já é multi-arch.

## 2. Subir o ambiente

**Windows**

```powershell
cd apps/api
.\scripts\setup.ps1
npm run start:dev
```

**macOS / Linux**

```bash
cd apps/api
chmod +x scripts/setup.sh
./scripts/setup.sh
npm run start:dev
```

O setup copia `.env`, sobe o Postgres, instala deps, aplica migrations e roda o seed.

Comandos equivalentes, manualmente:

```bash
cp .env.example .env          # Windows: copy .env.example .env
docker compose up -d postgres
npm install
npx prisma migrate deploy
npx prisma db seed
npm run start:dev
```

API em `http://localhost:3000/api`. Health: `GET /api/health`.

## 3. Frontend

Em `apps/web/src/environments/environment.ts`: `useMocks: false`.

```bash
cd apps/web
npm install
npm start
```

Abre `http://localhost:4200`. O proxy envia `/api` para a API.

## API só em Docker (outro ambiente / homolog)

Com o Postgres já no Compose:

```bash
cd apps/api
docker compose --profile app up --build
```

No container a API usa `DATABASE_URL` com host `postgres` (nome do serviço), não `localhost`. Seed (só quando quiser resetar dados demo):

```bash
npx prisma db seed
```

Rode o seed **no host** (com `.env` apontando para `localhost:5432`) ou:

```bash
docker compose exec api npx prisma db seed
```

(o seed apaga e recria os dados demo.)

## Fallback sem Docker

Só se o Docker não puder rodar:

```bash
npm run db:embedded
```

Sobe um Postgres embutido na porta 5432. Não use junto com `docker compose`.

## Contas seed (invite-only)

- `loja@nexus.demo` / `demo1234` — Arena Nexus
- `loja@dragao.demo` / `demo1234` — Dragão de Aço
- `ana@player.demo` / `demo1234` — jogadora

Eventos públicos:

- `/events/arena-nexus/pokemon-league-challenge-nexus`
- `/events/dragao-de-aco/fnm-dragao-aco`
- `/events/arena-nexus/yugioh-locals-nexus`
