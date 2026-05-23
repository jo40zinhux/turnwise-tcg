#!/usr/bin/env bash
# Gera APK release assinado (requer android/key.properties + upload-keystore.jks).
# Saída: build/app/outputs/flutter-apk/app-release.apk
#
# Uso (a partir da raiz do repo):
#   ./scripts/build-release-apk.sh
#   bash scripts/build-release-apk.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

KEY_PROPS="${ROOT}/android/key.properties"
KEYSTORE="${ROOT}/android/upload-keystore.jks"
APK="${ROOT}/build/app/outputs/flutter-apk/app-release.apk"

if [[ ! -f "$KEY_PROPS" ]]; then
  echo "Falta android/key.properties. Cria o keystore e key.properties primeiro." >&2
  exit 1
fi

if [[ ! -f "$KEYSTORE" ]]; then
  echo "Falta android/upload-keystore.jks." >&2
  exit 1
fi

echo "Building signed release APK..."
flutter build apk --release

if [[ -f "$APK" ]]; then
  size_mb="$(du -m "$APK" | awk '{print $1}')"
  echo ""
  echo "APK assinado:"
  echo "  $APK"
  echo "  ${size_mb} MB"
  echo ""
  echo "Próximo passo: envia o APK para o Drive (ou outro host) e coloca o link em web-page/js/config.js"
  echo "Depois: ./scripts/deploy-landing.sh"
fi
