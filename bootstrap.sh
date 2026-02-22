#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"

mkdir -p "$STATE_DIR" "$WORKSPACE_DIR"

# Persistent tool/auth directories
mkdir -p \
  "$STATE_DIR/credentials/gh" \
  "$STATE_DIR/credentials/railway" \
  "$STATE_DIR/credentials/npm" \
  "$STATE_DIR/credentials/pnpm" \
  "$STATE_DIR/credentials/homebrew" \
  /data/npm /data/npm-cache /data/pnpm /data/pnpm-store /data/homebrew

chmod 700 "$STATE_DIR/credentials" || true
chmod 700 "$STATE_DIR/credentials/gh" "$STATE_DIR/credentials/railway" "$STATE_DIR/credentials/npm" "$STATE_DIR/credentials/pnpm" "$STATE_DIR/credentials/homebrew" || true

# GH CLI config persistence
mkdir -p /root/.config
if [ -d /root/.config/gh ] && [ ! -L /root/.config/gh ]; then
  cp -a /root/.config/gh/. "$STATE_DIR/credentials/gh/" || true
  rm -rf /root/.config/gh
fi
ln -sfn "$STATE_DIR/credentials/gh" /root/.config/gh
[ -f "$STATE_DIR/credentials/gh/hosts.yml" ] && chmod 600 "$STATE_DIR/credentials/gh/hosts.yml" || true

# Railway CLI config persistence
if [ -d /root/.railway ] && [ ! -L /root/.railway ]; then
  cp -a /root/.railway/. "$STATE_DIR/credentials/railway/" || true
  rm -rf /root/.railway
fi
ln -sfn "$STATE_DIR/credentials/railway" /root/.railway
[ -f "$STATE_DIR/credentials/railway/config.json" ] && chmod 600 "$STATE_DIR/credentials/railway/config.json" || true

# npm/pnpm auth persistence
if [ -f /root/.npmrc ] && [ ! -L /root/.npmrc ]; then
  cp -a /root/.npmrc "$STATE_DIR/credentials/npm/.npmrc" || true
  rm -f /root/.npmrc
fi
ln -sfn "$STATE_DIR/credentials/npm/.npmrc" /root/.npmrc

mkdir -p /root/.config
if [ -d /root/.config/pnpm ] && [ ! -L /root/.config/pnpm ]; then
  cp -a /root/.config/pnpm/. "$STATE_DIR/credentials/pnpm/" || true
  rm -rf /root/.config/pnpm
fi
ln -sfn "$STATE_DIR/credentials/pnpm" /root/.config/pnpm

# Homebrew user config/cache persistence (formula installs already under /data/homebrew)
if [ -d /root/.cache/Homebrew ] && [ ! -L /root/.cache/Homebrew ]; then
  mkdir -p "$STATE_DIR/credentials/homebrew/cache"
  cp -a /root/.cache/Homebrew/. "$STATE_DIR/credentials/homebrew/cache/" || true
  rm -rf /root/.cache/Homebrew
fi
mkdir -p /root/.cache
ln -sfn "$STATE_DIR/credentials/homebrew/cache" /root/.cache/Homebrew

# Optional non-interactive token hydration (preferred for true rebuild resilience)
# If GH_TOKEN is set, ensure gh auth exists in persisted config.
if [ -n "${GH_TOKEN:-}" ]; then
  if ! gh auth status >/dev/null 2>&1; then
    printf '%s' "$GH_TOKEN" | gh auth login --with-token >/dev/null 2>&1 || true
    gh auth setup-git >/dev/null 2>&1 || true
  fi
fi

# If RAILWAY_TOKEN is set, Railway CLI uses it directly; also persist in config when possible.
if [ -n "${RAILWAY_TOKEN:-}" ] && command -v railway >/dev/null 2>&1; then
  # Trigger config file creation if missing (best effort, no-op when unauthorized endpoints blocked)
  railway --version >/dev/null 2>&1 || true
fi

printf '[bootstrap] persistence ready: state=%s workspace=%s\n' "$STATE_DIR" "$WORKSPACE_DIR"
