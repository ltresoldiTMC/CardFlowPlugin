#!/usr/bin/env bash
#
# Self-check for new-id.sh: run it with `bash scripts/new-id.test.sh`.
# Exits non-zero on the first failed expectation.

set -euo pipefail
export LC_ALL=C

script="$(dirname "$0")/new-id.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

check() {
  if ! eval "$2"; then
    echo "FAIL: $1" >&2
    exit 1
  fi
}

# A fixed moment, 2026-09-29 12:00:00 UTC, so every expected value is exact: day 272, card slot 264 of 529 (N, N),
# code slot 1058 of 2116 (a, A).
export NEW_ID_EPOCH=1790683200

# Writes a card in progress whose header carries the given id.
card_in_progress() {
  mkdir -p "$work/development/$1/card"
  printf -- '---\nID:         %s\nTITOLO:     Test\nBASE:\nBLOCKED BY:\n---\n' "$2" > "$work/development/$1/card/SPEC.md"
}

# Card ids.

first=$(bash "$script" "$work")
check "the id is YYDDD plus two letters for the time of day" '[[ "$first" == 26272NN ]]'
check "the format excludes I, L and O" '[[ "$first" =~ ^[0-9]{5}[A-HJKMNP-Z]{2}$ ]]'

card_in_progress main "$first"
second=$(bash "$script" "$work")
check "a card in progress takes its id, and the slot moves forward" '[[ "$second" > "$first" ]]'

mkdir -p "$work/development/feature-x/handovers"
touch "$work/development/feature-x/handovers/$second-export.md"
third=$(bash "$script" "$work")
check "a handover waiting in a branch takes its id" '[[ "$third" > "$second" ]]'

mkdir -p "$work/deploy/handovers/pending"
touch "$work/deploy/handovers/pending/$third-filter.md"
fourth=$(bash "$script" "$work")
check "a handover waiting for a release takes its id" '[[ "$fourth" > "$third" ]]'

card_in_progress feature-x CR0412
mkdir -p "$work/control"
printf '### 2026-09-20 — Eliminata la card CR0999 (Prova)\nNote about CRX0412.\n' > "$work/control/journal.md"
check "a free requested id is accepted" '[[ "$(bash "$script" "$work" CR0777)" == CR0777 ]]'
check "a requested id held by a card in progress is refused" '! bash "$script" "$work" CR0412 2>/dev/null'
check "a requested id cited in the journal is refused" '! bash "$script" "$work" CR0999 2>/dev/null'
check "an id with dots is not confused with one that differs in those dots" \
  '[[ "$(bash "$script" "$work" CR.0412)" == CR.0412 ]]'
check "a malformed requested id is refused" '! bash "$script" "$work" "bad id" 2>/dev/null'
check "a missing work root is refused" '! bash "$script" "$work/missing" 2>/dev/null'

# Entry codes.

code=$(bash "$script" "$work" --code Q)
check "a code is family, YYDDD and two letters for the time of day" '[[ "$code" == Q26272aA ]]'
for family in T Q MP MS; do
  value=$(bash "$script" "$work" --code "$family")
  check "family $family has the code form" \
    '[[ "$value" =~ ^(T|Q|MP|MS)[0-9]{5}[A-HJKMNP-Za-hjkmnp-z]{2}$ && "$value" == "$family"* ]]'
done
check "the family D no longer exists" '! bash "$script" "$work" --code D 2>/dev/null'
check "an unknown family is refused" '! bash "$script" "$work" --code X 2>/dev/null'
check "an invalid count is refused" '! bash "$script" "$work" --code T 0 2>/dev/null'

mapfile -t three < <(bash "$script" "$work" --code T 3)
check "a count prints that many codes" '(( ${#three[@]} == 3 ))'
check "the codes are distinct and increasing" '[[ "${three[0]}" < "${three[1]}" && "${three[1]}" < "${three[2]}" ]]'

printf '### %s — Timeout della connessione\n' "$code" > "$work/control/open-points-client.md"
check "a code already in a register is skipped" '[[ "$(bash "$script" "$work" --code Q)" > "$code" ]]'

rm "$work/control/open-points-client.md"
mkdir -p "$work/notes"
printf 'Idea: %s\n' "$code" > "$work/notes/ideas.md"
check "a code found only in notes/ does not count" '[[ "$(bash "$script" "$work" --code Q)" == "$code" ]]'

echo "ok: $first < $second < $third < $fourth; codes from $code"
