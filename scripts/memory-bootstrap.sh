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

CHANNELS_ROOT="$MEMORY_DIR/channels"
DEFAULT_CHANNEL_KEYS=("notifast" "harry-prompter" "work")
CHANNEL_KEYS=("${DEFAULT_CHANNEL_KEYS[@]}")

# Optional override/extension via env var, e.g. OPENCLAW_CHANNEL_MEMORY_KEYS="notifast,harry-prompter,work,new-channel"
if [[ -n "${OPENCLAW_CHANNEL_MEMORY_KEYS:-}" ]]; then
  IFS=',' read -r -a CHANNEL_KEYS <<<"$OPENCLAW_CHANNEL_MEMORY_KEYS"
fi

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

# Ensure per-channel isolated memory files exist for both UTC today and UTC yesterday.
mkdir -p "$CHANNELS_ROOT"
for channel_key in "${CHANNEL_KEYS[@]}"; do
  # Trim whitespace and skip empty entries
  channel_key="$(echo "$channel_key" | xargs)"
  [[ -z "$channel_key" ]] && continue

  channel_dir="$CHANNELS_ROOT/$channel_key"
  mkdir -p "$channel_dir"

  channel_today_file="$channel_dir/$TODAY_UTC.md"
  channel_yesterday_file="$channel_dir/$YESTERDAY_UTC.md"

  if [[ ! -f "$channel_today_file" ]]; then
    cat >"$channel_today_file" <<EOF
# $TODAY_UTC ($channel_key)

- Daily channel note initialized.
EOF
    echo "Created: $channel_today_file"
  else
    echo "Exists:  $channel_today_file"
  fi

  if [[ ! -f "$channel_yesterday_file" ]]; then
    cat >"$channel_yesterday_file" <<EOF
# $YESTERDAY_UTC ($channel_key)

- Daily channel note initialized.
EOF
    echo "Created: $channel_yesterday_file"
  else
    echo "Exists:  $channel_yesterday_file"
  fi
done

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
