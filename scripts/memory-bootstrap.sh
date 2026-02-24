#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MEMORY_DIR="$ROOT_DIR/memory"
TODAY_UTC="$(date -u +%F)"
YESTERDAY_UTC="$(date -u -d 'yesterday' +%F)"
TODAY_FILE="$MEMORY_DIR/$TODAY_UTC.md"
YESTERDAY_FILE="$MEMORY_DIR/$YESTERDAY_UTC.md"
LONG_TERM_FILE="$ROOT_DIR/MEMORY.md"

mkdir -p "$MEMORY_DIR"

ensure_daily_file() {
  local file_path="$1"
  local day="$2"

  if [[ ! -f "$file_path" ]]; then
    cat >"$file_path" <<EOF
# $day

- Daily note initialized.
EOF
    echo "Created: $file_path"
  else
    echo "Exists:  $file_path"
  fi
}

ensure_daily_file "$TODAY_FILE" "$TODAY_UTC"
ensure_daily_file "$YESTERDAY_FILE" "$YESTERDAY_UTC"

if [[ ! -f "$LONG_TERM_FILE" ]]; then
  cat >"$LONG_TERM_FILE" <<'EOF'
# MEMORY.md

Long-term, curated memory. Keep this concise and durable.

## User preferences (durable)

- Always reply in English.
- Keep responses concise, concrete, and low-fluff.
- For ambiguous complex tasks, ask clarifying questions before executing.
- Prefer durable, restart-safe configuration and persistent paths under `/data`.
- For accommodation searches: start broad, then narrow.
- Push to GitHub as the final step when changes can trigger Railway rebuilds.
EOF
  echo "Created: $LONG_TERM_FILE"
else
  echo "Exists:  $LONG_TERM_FILE"
fi
