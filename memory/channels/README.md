# Channel Memory Layout

Per-channel memory is isolated by directory to reduce context leakage and keep logs focused.

## Directories

- `memory/channels/notifast/`
- `memory/channels/harry-prompter/`
- `memory/channels/work/`

## File convention

Use daily files per channel:

- `memory/channels/<channel-key>/YYYY-MM-DD.md`

Examples:

- `memory/channels/notifast/2026-02-25.md`
- `memory/channels/harry-prompter/2026-02-25.md`
- `memory/channels/work/2026-02-25.md`

## DM visibility rule

DM/control session may read across all channel memory directories when needed for coordination, summaries, and decision support.
