# Runtime Paths Standard

## Canonical paths

- OpenClaw state/config: `/data/.openclaw`
- Agent workspace: `/data/workspace`

## Why

- `/data` is persistent-volume friendly across container restarts/redeploys.
- Avoids coupling to runtime user home (`/root/.openclaw/...`).
- Keeps state + workspace co-located for backup/restore.

## Required config

Set in `/data/.openclaw/openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "workspace": "/data/workspace"
    }
  }
}
```

## Compatibility bridge during migration

Use temporary symlinks to avoid breaking old references:

```bash
ln -sfn /data/workspace /root/.openclaw/workspace
ln -sfn /data/.openclaw /data/.clawdbot
```

## Validation checklist

1. Restart gateway.
2. Confirm `openclaw status` is healthy.
3. Write/read `memory/YYYY-MM-DD.md` in workspace.
4. Restart once more and re-check the same file.

## Template guidance

For reusable templates, expose these as env vars in compose/runtime scripts:

- `OPENCLAW_STATE_DIR=/data/.openclaw`
- `OPENCLAW_HOME=/data` (optional; keeps path resolution under `/data`)
- `OPENCLAW_WORKSPACE=/data/workspace`

Then render config from env during startup if not already set.
