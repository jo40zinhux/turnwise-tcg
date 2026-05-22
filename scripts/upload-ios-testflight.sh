#!/usr/bin/env bash
# Build + upload TurnWise para TestFlight (App Store Connect).
# Publicação na App Store → manual no App Store Connect.
#
# Uso (a partir da raiz do repo):
#   ./scripts/upload-ios-testflight.sh
#   ./scripts/upload-ios-testflight.sh --build-number 42

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="${ROOT}/ios"
export BUNDLE_GEMFILE="${IOS_DIR}/Gemfile"
export FLUTTER_PROJECT_ROOT="${ROOT}"
export FLUTTER_IOS_DIR="${IOS_DIR}"

# Prefer Homebrew pod + PATH (Flutter usa `which pod` durante flutter build ipa)
for _pod in /opt/homebrew/bin/pod /usr/local/bin/pod; do
  if [[ -x "$_pod" ]]; then
    export POD_BINARY="$_pod"
    export PATH="$(dirname "$_pod"):${PATH}"
    break
  fi
done

cd "$IOS_DIR"

if [[ ! -f fastlane/.env ]]; then
  echo "Falta ios/fastlane/.env — copia de ios/fastlane/.env.example" >&2
  exit 1
fi

if ! command -v bundle >/dev/null 2>&1; then
  echo "Bundler não encontrado. Instala Ruby/Bundler ou corre: cd ios && bundle install" >&2
  exit 1
fi

if ! bundle check >/dev/null 2>&1; then
  echo "A instalar gems em ios/vendor/bundle (primeira vez pode demorar)..."
  bundle install
fi

if ! bundle check >/dev/null 2>&1; then
  echo "bundle install falhou. Corre manualmente:" >&2
  echo "  cd ios && bundle install" >&2
  exit 1
fi

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
    *)
      echo "Argumento desconhecido: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -n "$BUILD_NUMBER_ARG" ]]; then
  exec bundle exec fastlane deploy_testflight "$BUILD_NUMBER_ARG"
else
  exec bundle exec fastlane deploy_testflight
fi
