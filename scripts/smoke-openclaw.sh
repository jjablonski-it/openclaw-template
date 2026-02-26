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
check "openclaw health --json" bash -lc 'openclaw health --json >/tmp/openclaw-health.json'
check "openclaw status" openclaw status >/dev/null
check "openclaw status --deep" openclaw status --deep >/tmp/openclaw-status-deep.txt
check "discord channel health" grep -E 'Discord' /tmp/openclaw-status-deep.txt | grep -E 'OK' >/dev/null
check "cron scheduler status" openclaw cron status >/dev/null
check "cron jobs present" bash -lc 'openclaw cron list | tail -n +2 | grep -q .'

echo "Smoke checks passed."