#!/usr/bin/env bash
# Publica a landing page (web-page/) no Firebase Hosting.
#
# Uso (a partir da raiz do repo):
#   ./scripts/deploy-landing.sh
#
# Antes do primeiro deploy: firebase login (se ainda não estiver autenticado).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ensure_firebase_cli() {
  if command -v firebase >/dev/null 2>&1; then
    return 0
  fi

  echo "Firebase CLI não encontrado. A instalar..." >&2

  if command -v brew >/dev/null 2>&1; then
    brew install firebase-cli
  elif command -v npm >/dev/null 2>&1; then
    npm install -g firebase-tools
  else
    echo "Instala o Firebase CLI manualmente:" >&2
    echo "  brew install firebase-cli" >&2
    echo "  # ou: npm install -g firebase-tools" >&2
    exit 1
  fi

  if ! command -v firebase >/dev/null 2>&1; then
    echo "Firebase CLI instalado mas não está no PATH. Reinicia o terminal ou adiciona ao PATH." >&2
    exit 1
  fi
}

ensure_firebase_logged_in() {
  if firebase login:list 2>/dev/null | grep -q "Logged in"; then
    return 0
  fi

  echo ""
  echo "Não há sessão Firebase ativa nesta máquina." >&2
  echo "Corre: firebase login" >&2
  echo "Depois volta a executar: ./scripts/deploy-landing.sh" >&2
  exit 1
}

ensure_firebase_cli
ensure_firebase_logged_in

echo "Deploy TurnWise landing -> Firebase Hosting (turnwise-tcg)..."
firebase deploy --only hosting

echo ""
echo "URLs de produção:"
echo "  https://turnwise-tcg.web.app"
echo "  https://turnwise-tcg.firebaseapp.com"
echo ""
echo "Para atualizar links de download, edita web-page/js/config.js e corre este script de novo."
