#!/usr/bin/env bash
#
# Self-check for new-id.sh: run it with `bash scripts/new-id.test.sh`.
# Exits non-zero on the first failed expectation.

set -euo pipefail

script="$(dirname "$0")/new-id.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/cards" "$work/orders/CR0412-invoices/archive"

check() {
  if ! eval "$2"; then
    echo "FAIL: $1" >&2
    exit 1
  fi
}

first=$(bash "$script" "$work")
check "format is YYDDD plus two letters without I, L, O" '[[ "$first" =~ ^[0-9]{5}[A-HJKMNP-Z]{2}$ ]]'

mkdir "$work/cards/$first-one"
second=$(bash "$script" "$work")
check "a taken slot moves forward" '[[ "$second" > "$first" ]]'

mkdir "$work/orders/CR0412-invoices/archive/$second-two"
third=$(bash "$script" "$work")
check "archived cards count as taken" '[[ "$third" > "$second" ]]'

check "a free requested id is accepted" '[[ "$(bash "$script" "$work" CR0999)" == CR0999 ]]'
check "a taken requested id is refused" '! bash "$script" "$work" CR0412 2>/dev/null'
check "a malformed requested id is refused" '! bash "$script" "$work" "bad id" 2>/dev/null'
check "a missing work root is refused" '! bash "$script" "$work/missing" 2>/dev/null'

echo "ok: $first < $second < $third"
