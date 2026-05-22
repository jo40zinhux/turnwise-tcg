#!/usr/bin/env bash
# Build + upload TurnWise AAB para Google Play (faixa internal = testes internos).
# Publicação em produção → manual no Play Console.
#
# Uso (a partir da raiz do repo):
#   ./scripts/upload-android-play.sh
#   ./scripts/upload-android-play.sh --build-number 42
#   ./scripts/upload-android-play.sh --track beta

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="${ROOT}/android"
export BUNDLE_GEMFILE="${ANDROID_DIR}/Gemfile"

cd "$ANDROID_DIR"

if [[ ! -f fastlane/.env ]]; then
  echo "Falta android/fastlane/.env — copia de android/fastlane/.env.example" >&2
  exit 1
fi

if [[ ! -f key.properties ]]; then
  echo "Falta android/key.properties (keystore de release)." >&2
  exit 1
fi

if ! command -v bundle >/dev/null 2>&1; then
  echo "Bundler não encontrado. Corre: cd android && bundle install" >&2
  exit 1
fi

if ! bundle check >/dev/null 2>&1; then
  echo "A instalar gems em android/vendor/bundle (primeira vez pode demorar)..."
  bundle install
fi

if ! bundle check >/dev/null 2>&1; then
  echo "bundle install falhou. Corre manualmente:" >&2
  echo "  cd android && bundle install" >&2
  exit 1
fi

LANE="internal"
BUILD_NUMBER_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-number)
      BUILD_NUMBER_ARG="build_number:$2"
      shift 2
      ;;
    --build-number=*)
      BUILD_NUMBER_ARG="build_number:${1#*=}"
      shift
      ;;
    --track)
      case "$2" in
        internal) LANE="internal" ;;
        beta) LANE="upload_beta" ;;
        *)
          echo "Track inválida: $2 (usa internal ou beta)" >&2
          exit 1
          ;;
      esac
      shift 2
      ;;
    *)
      echo "Argumento desconhecido: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -n "$BUILD_NUMBER_ARG" ]]; then
  exec bundle exec fastlane "$LANE" "$BUILD_NUMBER_ARG"
else
  exec bundle exec fastlane "$LANE"
fi
