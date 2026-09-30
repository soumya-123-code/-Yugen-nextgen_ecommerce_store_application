#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

bash "$ROOT/.cursor/scripts/ensure-mongodb.sh"

PRODUCT_COUNT="$(mongosh payload-template-ecommerce --quiet --eval 'db.products.countDocuments()' 2>/dev/null || echo 0)"
if [[ "${PRODUCT_COUNT}" == "0" ]]; then
  yarn seed
fi
