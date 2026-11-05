# Safety rules, execution, verification, rollback

## Hard rules
1. **Confirm before acting.** No `mv`/`rm`/`mkdir`/content edits until the user has picked a
   layout (step 3 of SKILL.md). Maintenance tidy-ups also need a per-run confirmation.
2. **Move, never delete.** `mv` only. Stale or questionable items go to
   `ARCHIVE/QUARANTINE-<YYYY-MM-DD>/` (or the agreed equivalent). Deletion is always the
   owner's later, manual decision — agents never run `rm` on user content.
3. **Junk is the only exception**, and only with explicit approval: `.DS_Store`, `desktop.ini`
   are regenerable. `.localized` is a macOS system file — keep it.
4. **Never print sensitive file contents** (credentials, `.env`, keys, tokens). Lock them:
   `chmod 700 <dir>` and `chmod 600` files inside.
5. **Rewrite references before/after moving anything that is referenced.** Procedure:
   1. List referencing files: `grep -rl --include='*.md' --include='*.sh' --include='*.yaml'
      --include='*.yml' --include='*.json' --include='*.toml' --include='*.env'
      --include='*.py' --exclude-dir=.git --exclude-dir=.venv --exclude-dir=venv
      --exclude-dir=node_modules --exclude-dir=__pycache__ '<old-abs-path>' <root>`
   2. `sed -i` each file (BSD: `sed -i ''`), replacing **longest paths first** so suffixed
      names (e.g. `-OLD-CLONE`) are not half-mangled.
   3. Verify with `scripts/check-refs.sh <root>` — every referenced path must report OK
      (pre-existing dangling refs may be noted, not "fixed" silently).
6. **Name collisions:** rename the duplicate/older item with a suffix (`-OLD`, `-OLD-CLONE`,
   `-2025`) rather than overwriting. On case-insensitive APFS use a two-step rename for
   case-only changes if a direct `mv` errors.
7. **Never touch `.git` internals, symlinks (move the link itself), or follow symlinks out
   of the target.**
8. **Same-volume `mv` is atomic and instant** — prefer it over copy+delete.

## Execution checklist (after confirmation)
- [ ] Move plan written (old → new) and shown to the user
- [ ] Bucket dirs created; items moved with `mv`
- [ ] Absolute path references rewritten in the enumerated text files
- [ ] Sensitive dirs locked (700/600)
- [ ] Junk removed only if approved
- [ ] `scripts/check-refs.sh <root>` → no new MISS lines
- [ ] Moved git repos still valid: `git -C <repo> rev-parse --is-inside-work-tree`
- [ ] Key paths spot-checked with `[ -e ... ]`
- [ ] `AGENTS.md` + `README.md` generated/updated at root
- [ ] Summary reported: what moved where, what was renamed, what was locked, caveats
      (e.g. "recreate .venv with `uv sync` in moved Python projects")

## Rollback
Everything is a `mv`, so rollback is the inverse move. Record the move plan in the run
summary (and in README history) so any single item can be restored with one command:
`mv <root>/<new-path> <root>/<old-path>`.

## Known side effects to warn about
- Python `.venv`/`venv` are location-bound → recreate (`uv sync` / `pip install -e .`) after moving a project.
- `node_modules`, `.terraform` similarly.
- Shell aliases / IDE configs outside the target that hardcode old paths (e.g. `~/.zshrc`)
  are out of scope — list them as follow-ups for the owner.
