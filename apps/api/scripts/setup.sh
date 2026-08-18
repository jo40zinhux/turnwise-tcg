#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker nao encontrado."
  echo "macOS:  brew install --cask docker"
  echo "Depois abra o Docker Desktop uma vez e rode este script de novo."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker esta instalado, mas o daemon nao esta no ar. Abra o Docker Desktop e tente de novo."
  exit 1
fi

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Criado .env a partir de .env.example"
fi

docker compose up -d postgres

echo "Aguardando Postgres..."
for i in $(seq 1 30); do
  if docker compose exec -T postgres pg_isready -U turnwise -d turnwise_events >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

npm install
npx prisma migrate deploy
npx prisma db seed

echo
echo "Pronto. API local:"
echo "  npm run start:dev"
echo
echo "Ou API em container:"
echo "  npm run start:docker"
echo
echo "Frontend (outro terminal):"
echo "  cd ../web && npm install && npm start"
echo "  (useMocks: false em src/environments/environment.ts)"
