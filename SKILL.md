---
name: organize-workspace
description: Analyzes a directory or workspace (names, sizes, activity, git repos, cross-file path references, sensitive files), then proposes up to 3 concrete layout options as ASCII worktrees for the user to choose from. Only after the user explicitly picks a layout does it reorganize: moves only (never deletes), rewrites absolute path references in docs/scripts, verifies everything, and generates concise AGENTS.md + README.md index files at the target root. On later runs it maintains the structure: detects drift, proposes tidy-ups, updates the index docs — always asking before moving anything. Activate when the user asks to organize, clean up, restructure, or tidy a folder/workspace (e.g. ~/Documents or a project root), or to keep an already-organized directory maintained.
license: MIT
compatibility: Any agent with shell + filesystem read/write access. Helper scripts are POSIX sh and work on macOS (BSD) and Linux (GNU).
metadata:
  author: serge
  version: "1.0.0"
---

# organize-workspace

Turn a messy directory into a navigable, agent-friendly workspace — with the user in
control of the final layout and of every change.

## Workflow

### 0. Intake
- Confirm the target directory (default: the current working directory) and scope
  (whole tree vs. top level only). If the target is ambiguous, ask one short question.
- If the target already has an `AGENTS.md`/`README.md` index pair from a previous run,
  you are in **maintenance mode** — jump to step 6.

### 1. Analyze (read-only)
Run `<skill-dir>/scripts/scan.sh <target>` (where `<skill-dir>` is the folder containing this `SKILL.md`) and read its report. Additionally check:
- **Git repos** (`git -C <dir> rev-parse --is-inside-work-tree`) — moving a repo dir is safe.
- **Cross-references**: absolute paths to the target written inside text files
  (`<skill-dir>/scripts/check-refs.sh <target>`) — these constrain what may be moved/renamed.
- **Sensitive content**: `.env`, `*credentials*`, `*.pem`, `*.key`, tokens — note them; never print contents.
- **System/junk files**: `.DS_Store`, `desktop.ini` (regenerable), `.localized` (macOS, keep).
- **Symlinks** — never follow blindly; move the link itself.
Summarize findings for the user in a few bullets (what exists, what is active — touched
within ~30 days — what is stale, what is sensitive, what is referenced elsewhere).

### 2. Propose up to 3 layouts — DO NOT change anything yet
Based on the analysis, present **up to 3 options** as ASCII worktrees with a 2–3 line
rationale each, adapted to the user's actual content. Draw from the templates in
[references/layouts.md](references/layouts.md). End with: "Which option — 1, 2, 3, or a
custom variant? Nothing is moved until you confirm."

### 3. Confirm
Wait for the user's explicit choice. Record it. If the user edits the proposal, use
their version. **No `mv`/`rm`/`mkdir` before this confirmation.**

### 4. Execute the chosen layout (safe moves only)
Follow [references/safety.md](references/safety.md). In short:
1. Write the move plan (old path → new path) and show it briefly.
2. Create new bucket dirs; `mv` items (never `rm`). Anything stale/questionable goes to a
   dated quarantine area (e.g. `ARCHIVE/QUARANTINE-<YYYY-MM-DD>/`) — deletion is the owner's later, manual decision.
3. Handle name collisions (rename the older/duplicate with a suffix, e.g. `-OLD-CLONE`).
4. Rewrite absolute path references in text files (grep the old prefix, `sed` to the new,
   longest paths first), then run `<skill-dir>/scripts/check-refs.sh <target>` — every referenced path must resolve.
5. Lock sensitive dirs (`chmod 700` dir, `600` files). Delete regenerable junk (`.DS_Store`,
   `desktop.ini`) only if the user approved it in step 3.
6. Verify: key paths exist, moved git repos still valid, refs check clean. Report a
   what-moved-where summary.

### 5. Document the result
Generate **both** files at the target root, using [references/doc-templates.md](references/doc-templates.md):
- `AGENTS.md` — for agents: layout map (tree), naming conventions, where new things go,
  key absolute paths, rules (content is owner-managed; agents must not delete/move without
  asking; sensitive dirs; how to maintain).
- `README.md` — for humans: the one rule, a table of top-level entries, history of changes,
  notes/caveats (e.g. location-bound `.venv` after moves, stale clones).
Keep both concise (< ~90 lines), cross-link them, human-readable and LLM-parseable.

### 6. Maintain (later runs on an organized directory)
- Re-run `<skill-dir>/scripts/scan.sh <target>`; detect drift: loose new items at root, items in
  "active" areas untouched > 30 days, quarantine aging, doc map out of date.
- Propose small tidy-ups (as a short list) and **ask before moving anything**.
- After any confirmed tidy-up: update `AGENTS.md`/`README.md` (map, history, date) and
  re-run `<skill-dir>/scripts/check-refs.sh <target>`.
- Never delete. Never move without confirmation. The owner decides what stays or goes.

## Reference material
- [references/analysis.md](references/analysis.md) — detailed scan playbook (commands, BSD/GNU variants, what to look for)
- [references/layouts.md](references/layouts.md) — generic layout option templates
- [references/safety.md](references/safety.md) — safety rules, reference rewriting, verification, rollback
- [references/doc-templates.md](references/doc-templates.md) — AGENTS.md / README.md templates

## Scripts (paths relative to this skill directory)
- `<skill-dir>/scripts/scan.sh <dir>` — read-only survey: size, last-activity, git, reference count per top-level entry
- `<skill-dir>/scripts/check-refs.sh <dir>` — verify absolute paths referenced in text files under `<dir>` resolve
