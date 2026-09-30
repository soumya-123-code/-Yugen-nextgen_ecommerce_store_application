#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [[ -f src/payload/payload.config.ts && -f redirects.js && -f src/server.ts ]]; then
  exit 0
fi

echo "Restoring missing Payload v2 ecommerce template sources..."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --depth 1 --branch v2.32.3 https://github.com/payloadcms/payload.git "$TMP/payload" >/dev/null 2>&1
TEMPLATE="$TMP/payload/templates/ecommerce"

while IFS= read -r -d '' file; do
  rel="${file#"$TEMPLATE"/}"
  dest="$ROOT/$rel"
  if [[ ! -f "$dest" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest"
  fi
done < <(find "$TEMPLATE" -type f -print0)

echo "Template source restore complete."
