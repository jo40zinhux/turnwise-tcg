# Gera APK release assinado (requer android/key.properties + upload-keystore.jks).
# Saida: build/app/outputs/flutter-apk/app-release.apk
#
# Uso:
#   Windows:  .\scripts\build-release-apk.ps1
#   macOS:    ./scripts/build-release-apk.sh

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

$keyProps = "android\key.properties"
$keystore = "android\upload-keystore.jks"

if (-not (Test-Path $keyProps)) {
  Write-Error "Falta $keyProps. Cria o keystore e key.properties primeiro."
}
if (-not (Test-Path $keystore)) {
  Write-Error "Falta $keystore."
}

Write-Host "Building signed release APK..." -ForegroundColor Cyan
flutter build apk --release

$apk = "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apk) {
  $info = Get-Item $apk
  Write-Host ""
  Write-Host "APK assinado:" -ForegroundColor Green
  Write-Host "  $($info.FullName)"
  Write-Host "  $([math]::Round($info.Length / 1MB, 2)) MB"
  Write-Host ""
  Write-Host "Proximo passo: envia o APK para o Drive (ou outro host) e coloca o link em web-page/js/config.js" -ForegroundColor Yellow
  Write-Host "Depois: .\scripts\deploy-landing.ps1" -ForegroundColor Yellow
}
