#!/usr/bin/env bash
# Prepara CocoaPods para builds iOS (evita o `pod` global com Ruby quebrado).
#
# Uso:
#   brew install cocoapods    # se ainda não tiveres
#   ./scripts/setup-ios-pods.sh

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="${ROOT}/ios"

find_pod() {
  if [[ -n "${POD_BINARY:-}" && -x "$POD_BINARY" ]]; then
    echo "$POD_BINARY"
    return
  fi
  for candidate in /opt/homebrew/bin/pod /usr/local/bin/pod; do
    if [[ -x "$candidate" ]]; then
      echo "$candidate"
      return
    fi
  done
  if command -v pod >/dev/null 2>&1; then
    command -v pod
    return
  fi
  return 1
}

if ! POD="$(find_pod)"; then
  echo "CocoaPods não encontrado. Instala primeiro:" >&2
  echo "  brew install cocoapods" >&2
  exit 1
fi

echo "→ flutter pub get"
cd "$ROOT"
flutter pub get

echo "→ pod install ($POD)"
cd "$IOS_DIR"
SHIM_DIR="$IOS_DIR/.pod-shim"
mkdir -p "$SHIM_DIR"
cat > "$SHIM_DIR/pod" <<EOF
#!/bin/sh
exec "$POD" "\$@"
EOF
chmod +x "$SHIM_DIR/pod"
env -u BUNDLE_GEMFILE -u BUNDLE_BIN_PATH -u BUNDLE_PATH -u GEM_PATH -u RUBYOPT \
  PATH="$SHIM_DIR:$(dirname "$POD"):/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  LANG=en_US.UTF-8 \
  "$SHIM_DIR/pod" install

echo "OK. Segue com:"
echo "  ./scripts/upload-ios-testflight.sh"
