$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host "Docker nao encontrado. Instale o Docker Desktop e abra o app uma vez."
  Write-Host "  winget install -e --id Docker.DockerDesktop"
  exit 1
}

try {
  docker info | Out-Null
} catch {
  Write-Host "Docker esta instalado, mas o daemon nao esta no ar. Abra o Docker Desktop e tente de novo."
  exit 1
}

if (-not (Test-Path .env)) {
  Copy-Item .env.example .env
  Write-Host "Criado .env a partir de .env.example"
}

docker compose up -d postgres

Write-Host "Aguardando Postgres..."
for ($i = 0; $i -lt 30; $i++) {
  docker compose exec -T postgres pg_isready -U turnwise -d turnwise_events 2>$null
  if ($LASTEXITCODE -eq 0) { break }
  Start-Sleep -Seconds 1
}

npm install
npx prisma migrate deploy
npx prisma db seed

Write-Host ""
Write-Host "Pronto. API local:"
Write-Host "  npm run start:dev"
Write-Host ""
Write-Host "Ou API em container:"
Write-Host "  npm run start:docker"
Write-Host ""
Write-Host "Frontend (outro terminal):"
Write-Host "  cd ..\web; npm install; npm start"
Write-Host "  (useMocks: false em src/environments/environment.ts)"
