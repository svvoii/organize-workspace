#!/bin/sh
# check-refs.sh <dir> — verify that absolute paths pointing into <dir>, referenced from
# text files under <dir>, still exist. Prints OK/MISS per path and a summary.
# Exit code: 0 if no MISS, 1 otherwise.
set -u

DIR="${1:-.}"
[ -d "$DIR" ] || { echo "usage: check-refs.sh <dir>" >&2; exit 2; }
DIR=$(cd "$DIR" && pwd)

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

# extract absolute paths that start with DIR from text files, strip trailing punctuation/anchors
grep -rhoE "$DIR/[^ \"'\`),;<>|]*" \
  --include='*.md' --include='*.sh' --include='*.yaml' --include='*.yml' \
  --include='*.json' --include='*.toml' --include='*.env' --include='*.py' --include='*.txt' \
  --exclude-dir=.git --exclude-dir=.venv --exclude-dir=venv --exclude-dir=node_modules \
  --exclude-dir=__pycache__ --exclude-dir=.terraform \
  "$DIR" 2>/dev/null \
  | sed -e 's/[#?].*$//' -e "s/['\"\`),.;:]*$//" \
  | sort -u > "$TMP"

OK=0; MISS=0
while IFS= read -r P; do
  [ -n "$P" ] || continue
  if [ -e "$P" ]; then
    OK=$((OK + 1)); # echo "OK   $P"
  else
    MISS=$((MISS + 1)); echo "MISS $P"
  fi
done < "$TMP"

echo "== check-refs: $OK ok, $MISS missing (of $(wc -l < "$TMP" | tr -d ' ') referenced paths in $DIR) =="
[ "$MISS" -eq 0 ]
