#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TODAY_UTC="$(date -u +%F)"
YESTERDAY_UTC="$(date -u -d 'yesterday' +%F)"

# Ensure baseline memory files exist before optimization review logic runs.
bash "$ROOT_DIR/scripts/memory-bootstrap.sh" >/dev/null

required_files=(
  "$ROOT_DIR/SOUL.md"
  "$ROOT_DIR/USER.md"
  "$ROOT_DIR/MEMORY.md"
  "$ROOT_DIR/memory/$TODAY_UTC.md"
  "$ROOT_DIR/memory/$YESTERDAY_UTC.md"
)

missing=0
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "MISSING: $file"
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "Preflight failed: required context files are missing."
  exit 1
fi

echo "Preflight OK: core context files present for daily optimization review."
