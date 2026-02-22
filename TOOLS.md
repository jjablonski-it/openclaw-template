# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

## Interactive Story/Visual Pages (Obsidian + MDX)

### What this tool is

A pipeline for creating shareable interactive pages from MDX notes.

- Source notes: `/data/notes/visuals/*.mdx`
- Reusable components: `/data/notes/visuals/_components/*`
- Built HTML output: `/data/publish/html/*.html`
- Served route (protected): `/stories/*`
- Auth: Basic Auth password from `OPENCLAW_VISUALS_PASSWORD`

### When to use it

Use MDX story pages when the user asks for content that benefits from structure/visualization/shareability, for example:

- Trip plans and itineraries
- Comparisons (options, pros/cons, pricing)
- Decision summaries
- Multi-step plans with map links/ratings/images
- Anything the user may share with another person

Prefer plain chat replies when:

- The answer is short/simple
- The user wants quick facts only
- There is no need for a persistent/shareable artifact

### Decision rule

Default to **not** generating a story page unless at least one of these is true:

- User explicitly asks for a page/story/visualization/shareable link
- The plan has multiple sections/places/timelines and would be clearer as a page
- The result is likely to be reused later (travel, project plan, checklist)

If uncertain, ask once: “Want this as an interactive shareable page?”

---

Add whatever helps you do your job. This is your cheat sheet.
