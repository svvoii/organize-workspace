# Analysis playbook (read-only)

Goal: understand a directory before proposing layouts. Everything here is read-only.

## 1. Fast survey
Run `scripts/scan.sh <dir>`. It prints one line per top-level entry:
`days-since-last-file-activity | size | type | git-repo? | files-referencing-it | name`.

Manual equivalents (POSIX sh, BSD/GNU compatible — see `scripts/scan.sh` for the portable pattern):

```sh
du -sh <dir>/*                                   # sizes
find <dir> -type f -not -path '*/.git/*' -not -path '*/.venv/*' \
  -not -path '*/node_modules/*' -print0 | xargs -0 stat -f '%m' _ 2>/dev/null | sort -rn | head -1   # macOS newest mtime
# Linux: stat -c '%Y'
find <dir> -maxdepth 3 -name .git -type d       # git repos
grep -rl --include='*.md' --include='*.sh' --include='*.yaml' --include='*.yml' \
  --include='*.toml' --include='*.env' --include='*.py' --exclude-dir=.git \
  --exclude-dir=.venv --exclude-dir=node_modules '<abs-path-of-entry>' <dir>   # cross-references
```

## 2. Classify every top-level entry
For each entry decide one of:
- **active** — newest file inside touched within ~30 days
- **stale** — untouched for months/years (candidate for quarantine, never auto-delete)
- **reference** — books, certs, courses, configs (kept handy, not "work")
- **personal** — travel, health, media, games, personal creations
- **admin/paperwork** — taxes, government, past employers (keep indefinitely)
- **sensitive** — credentials, `.env`, keys, financial records (lock permissions, never print)
- **system/junk** — `.DS_Store`, `desktop.ini` (regenerable; deletable with approval), `.localized` (macOS; keep)
- **repo/tooling** — git repos and agent tooling dirs

## 3. Constraints to respect before proposing moves
- Absolute paths written in docs/scripts (e.g. `/Users/x/Documents/FOO/...`) break if `FOO`
  moves or is renamed → either keep those entries in place or plan a reference rewrite.
- Location-bound artifacts: `.venv`/`venv` (recreate with `uv sync`/`pip install` after a move),
  `node_modules`, `.terraform`. Note them in the final docs.
- Name collisions on case-insensitive filesystems (APFS): case-only renames are fine;
  renaming to an existing different-case name needs a two-step (`mv a A.tmp && mv A.tmp A`).
- Symlinks: move the link, never dereference.
- Large media (ROMs, videos, datasets): flag as candidate for external storage, don't move by default.

## 4. Output of the analysis phase
A short bullet summary for the user: entry counts by class, the active set, sensitive items
(names only), referenced-by-others entries, total size, and the 2–3 signals that should
drive the layout choice (e.g. "mostly stale projects" → quarantine; "mixed work+life" → split;
"many active repos" → domain buckets).
