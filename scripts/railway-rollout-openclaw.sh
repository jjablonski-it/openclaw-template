#!/usr/bin/env bash
set -euo pipefail

# Safe Railway rollout with rollback gate.
# Defaults to dry-run. Requires --apply for real changes.

PROJECT_ID=""
SERVICE_ID=""
ENV_ID=""
VAR_KEY="OPENCLAW_GIT_REF"
TARGET_VERSION=""
BASE_URL=""
TIMEOUT_SEC=420
APPLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ID="$2"; shift 2 ;;
    --service) SERVICE_ID="$2"; shift 2 ;;
    --env) ENV_ID="$2"; shift 2 ;;
    --var-key) VAR_KEY="$2"; shift 2 ;;
    --target) TARGET_VERSION="$2"; shift 2 ;;
    --url) BASE_URL="$2"; shift 2 ;;
    --timeout-sec) TIMEOUT_SEC="$2"; shift 2 ;;
    --apply) APPLY=true; shift ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

[[ -n "$PROJECT_ID" && -n "$SERVICE_ID" && -n "$ENV_ID" && -n "$TARGET_VERSION" && -n "$BASE_URL" ]] || {
  echo "Required: --project --service --env --target --url [--var-key] [--apply]";
  exit 2;
}

railway link -p "$PROJECT_ID" -e "$ENV_ID" -s "$SERVICE_ID" >/dev/null

CURRENT_VALUE=$(railway variable list --json | python3 - <<PY
import json,sys
v=json.load(sys.stdin)
print(v.get('${VAR_KEY}',''))
PY
)

echo "Current ${VAR_KEY}: ${CURRENT_VALUE}"
echo "Target  ${VAR_KEY}: ${TARGET_VERSION}"

if [[ "$APPLY" != "true" ]]; then
  echo "Dry-run only. Re-run with --apply to execute."
  exit 0
fi

echo "Setting ${VAR_KEY}=${TARGET_VERSION} (this triggers deploy)..."
railway variable set "${VAR_KEY}=${TARGET_VERSION}"

echo "Waiting for readiness up to ${TIMEOUT_SEC}s..."
start=$(date +%s)
while true; do
  if curl -fsS "${BASE_URL%/}/readyz" >/dev/null; then
    echo "Readiness OK. Running smoke checks..."
    if BASE_URL="$BASE_URL" /data/workspace/scripts/smoke-openclaw.sh; then
      echo "Rollout succeeded."
      exit 0
    fi
  fi

  now=$(date +%s)
  if (( now - start > TIMEOUT_SEC )); then
    echo "Readiness/smoke failed before timeout. Rolling back ${VAR_KEY}=${CURRENT_VALUE}"
    railway variable set "${VAR_KEY}=${CURRENT_VALUE}"
    echo "Rollback triggered."
    exit 1
  fi
  sleep 10
done
