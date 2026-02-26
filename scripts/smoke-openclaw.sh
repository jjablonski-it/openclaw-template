#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-${BASE_URL:-}}"
if [[ -z "${BASE_URL}" ]]; then
  echo "Usage: BASE_URL=https://your-app.up.railway.app $0"
  exit 2
fi

check() {
  local name="$1"; shift
  if "$@"; then
    echo "[ok] $name"
  else
    echo "[fail] $name"
    return 1
  fi
}

check "public /healthz" curl -fsS "${BASE_URL%/}/healthz" >/dev/null
check "public /readyz" curl -fsS "${BASE_URL%/}/readyz" >/dev/null
check "openclaw status" openclaw status >/dev/null
check "openclaw status --deep" openclaw status --deep >/dev/null

echo "Smoke checks passed."