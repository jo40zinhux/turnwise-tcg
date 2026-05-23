# Publica a landing page (web-page/) no Firebase Hosting.
#
# Uso:
#   Windows:  .\scripts\deploy-landing.ps1
#   macOS:    ./scripts/deploy-landing.sh
#
# Antes do primeiro deploy: firebase login (se ainda não estiver autenticado).

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "Deploy TurnWise landing -> Firebase Hosting (turnwise-tcg)..." -ForegroundColor Cyan
firebase deploy --only hosting

if ($LASTEXITCODE -eq 0) {
  Write-Host ""
  Write-Host "URLs de producao:" -ForegroundColor Green
  Write-Host "  https://turnwise-tcg.web.app"
  Write-Host "  https://turnwise-tcg.firebaseapp.com"
  Write-Host ""
  Write-Host "Para atualizar links de download, edita web-page/js/config.js e corre este script de novo." -ForegroundColor Yellow
}
