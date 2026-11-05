# AGENTS.md / README.md templates

Generate **both** at the target root after organizing. Keep each under ~90 lines.
`AGENTS.md` = for agents (loaded into context); `README.md` = for humans. Cross-link them.
Both must state: what the directory is, the layout map, where things live / where new things
go, the rules (owner-managed, no deletes/moves by agents without asking, sensitive dirs), and
key absolute paths that must not move.

## AGENTS.md template

````markdown
# <DIR> — Agent Navigation Guide

Last organized: <YYYY-MM-DD> by the `organize-workspace` skill (option chosen: <name>).
Human version: `README.md`. Read this file first when starting any agent session in `<DIR>`.

## Layout map

```text
<DIR>/
├── AGENTS.md / README.md      <- index pair (you are here)
├── <ENTRY>/                   <- one line per top-level entry: what it is, active?
└── ...
```

## Conventions

- Root rule: <one sentence, e.g. "root = fixed entries only; everything else in a bucket">
- Naming: <e.g. "ALL-CAPS for root dirs and bucket/project folders; inner project content unchanged">
- Where new things go: <project → ..., doc → ..., personal → ...; never loose files at root>

## Key absolute paths (referenced elsewhere — do not move)

- <path>: <what>

## Rules for agents

1. Content of buckets is owner-managed: never `rm`/`mv` anything here without explicit user approval.
2. <SENSITIVE> dirs (if any) are locked (700/600): never read/print/exfiltrate credential contents.
3. System files (`.localized`, ...) — leave alone.
4. To maintain: run `SKILL: organize-workspace` — it rescans, proposes tidy-ups, asks before moving, and updates these docs.
````

## README.md template

````markdown
# <DIR> — Index

Organized <YYYY-MM-DD> (skill: `organize-workspace`, option <name>). Agent rules: `AGENTS.md`.

## The one rule

<one sentence root rule>

| Path | What it is |
|---|---|
| `<ENTRY>/` | <description> |

## Layout

```text
<ASCII worktree>
```

## History

- `<YYYY-MM-DD>`: organized via `organize-workspace`; <what moved where in one line>; nothing deleted.

## Notes

- Ownership/permissions: everything owned by <user>; <sensitive dirs> locked 700.
- Caveats: moved projects with `.venv` need `uv sync`; <other>.
- Maintenance: ask an agent with the `organize-workspace` skill to re-run it; it will propose
  tidy-ups and always ask before moving anything.
````

## Quality bar
- Concise, scannable, accurate: every path mentioned must exist.
- Human-readable first (tables, trees), LLM-parseable second (explicit rules, key paths).
- Run `<skill-dir>/scripts/check-refs.sh <root>` afterwards so no mentioned path dangles.
