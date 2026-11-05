#!/bin/sh
# scan.sh <dir> — read-only survey of a directory's top-level entries.
# Prints: days-since-last-activity | size | type | git? | referencing-files | name
# Portable: macOS (BSD stat/find) and Linux (GNU stat/find).
set -u

DIR="${1:-.}"
[ -d "$DIR" ] || { echo "usage: scan.sh <dir>" >&2; exit 2; }
DIR=$(cd "$DIR" && pwd)

# pick stat variant: BSD (macOS) uses -f '%m', GNU (Linux) uses -c '%Y'
if stat -f '%m' "$DIR" >/dev/null 2>&1; then
  STARGS='-f %m'
else
  STARGS='-c %Y'
fi

NOW=$(date +%s)

REF_TMP=$(mktemp)
trap 'rm -f "$REF_TMP"' EXIT

# Single pass to collect all absolute-path references into DIR from text files
grep -rHoE "$DIR/[^ \"'\`),;<>|]*" \
  --include='*.md' --include='*.sh' --include='*.yaml' --include='*.yml' \
  --include='*.json' --include='*.toml' --include='*.env' --include='*.py' --include='*.txt' \
  --exclude-dir=.git --exclude-dir=.venv --exclude-dir=venv --exclude-dir=node_modules \
  --exclude-dir=__pycache__ --exclude-dir=.terraform \
  "$DIR" 2>/dev/null \
  | sed -e 's/[#?].*$//' -e "s/['\"\`),.;:]*$//" > "$REF_TMP" || true

echo "== scan of $DIR =="
printf '%6s | %-8s | %-3s | %-3s | %-4s | %s\n' DAYS SIZE TYPE GIT REFS NAME

for ENTRY in "$DIR"/* "$DIR"/.[!.]*; do
  [ -e "$ENTRY" ] || continue
  BASE=$(basename "$ENTRY")
  if [ -d "$ENTRY" ]; then TYPE=d; else TYPE=f; fi

  SIZE=$(du -sh "$ENTRY" 2>/dev/null | cut -f1)

  # newest file mtime inside the entry, pruning heavy/internal directories
  # shellcheck disable=SC2086
  NEWEST=$(find "$ENTRY" \
    \( -name .git -o -name .venv -o -name venv -o -name node_modules -o -name __pycache__ -o -name .terraform \) -prune \
    -o -type f -exec stat $STARGS {} + 2>/dev/null | sort -rn | head -1)
  if [ -n "$NEWEST" ]; then
    DAYS=$(( (NOW - NEWEST) / 86400 ))
  else
    DAYS='-'
  fi

  if [ "$TYPE" = d ] && git -C "$ENTRY" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    GIT=yes
  else
    GIT=no
  fi

  # how many distinct text files under DIR reference this entry's absolute path
  REFS=$(awk -v e="$ENTRY" '
    {
      sep = index($0, ":")
      if (sep > 0) {
        f = substr($0, 1, sep - 1)
        p = substr($0, sep + 1)
        if (p == e || substr(p, 1, length(e) + 1) == e "/") {
          files[f] = 1
        }
      }
    }
    END {
      c = 0
      for (f in files) c++
      print c
    }
  ' "$REF_TMP")

  printf '%6s | %-8s | %-3s | %-3s | %-4s | %s\n' "$DAYS" "$SIZE" "$TYPE" "$GIT" "$REFS" "$BASE"
done
