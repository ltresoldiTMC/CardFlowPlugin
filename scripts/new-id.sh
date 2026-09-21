#!/usr/bin/env bash
#
# Prints a free cardflow identifier for a new card or order.
#
# Usage: new-id.sh <work-root> [requested-id]
#
# Without a requested id, the identifier is the two-digit UTC year, the ISO
# ordinal day (001-366) and the UTC time of day as two letters, e.g. 26264VV.
# The day is split into 529 slots of about 163 seconds. The letters exclude I,
# L and O, which read like 1 and 0, and no digit follows the date: file managers
# that sort digit runs as numbers would otherwise merge them with the date and
# break the chronological order.
#
# An identifier is taken when a folder named "<id>-<slug>" exists among the
# cards, the orders or the archived cards. A taken slot moves to the next one,
# so identifiers stay unique and still sort by creation time.
#
# With a requested id (an order number such as CR2606, or a chosen card id),
# the script only checks that it is well formed and free, and prints it.

set -euo pipefail

readonly ALPHABET=ABCDEFGHJKMNPQRSTUVWXYZ
readonly BASE=${#ALPHABET}
readonly SLOTS=$(( BASE * BASE ))
readonly SECONDS_PER_DAY=86400
readonly VALID_ID='^[A-Za-z0-9][A-Za-z0-9._]*(-[A-Za-z0-9._]+)*$'

fail() {
  echo "new-id: $*" >&2
  exit 1
}

work_root=${1:-}
requested=${2:-}

[[ -n "$work_root" ]] || fail "usage: new-id.sh <work-root> [requested-id]"
[[ -d "$work_root" ]] || fail "work root not found: $work_root"

# True when any card, order or archived card folder starts with "<id>-".
id_in_use() {
  local matches
  shopt -s nullglob
  matches=( "$work_root"/cards/"$1"-* "$work_root"/orders/"$1"-* "$work_root"/orders/*/archive/"$1"-* )
  shopt -u nullglob
  (( ${#matches[@]} > 0 ))
}

if [[ -n "$requested" ]]; then
  [[ "$requested" =~ $VALID_ID ]] || fail "invalid id '$requested': letters, digits, dots and single dashes only"
  ! id_in_use "$requested" || fail "id '$requested' is already used"
  echo "$requested"
  exit 0
fi

# One call to date, so the day and the time of day cannot straddle midnight.
read -r day epoch < <(date -u '+%y%j %s')
slot=$(( (epoch % SECONDS_PER_DAY) * SLOTS / SECONDS_PER_DAY ))

while (( slot < SLOTS )); do
  id="$day${ALPHABET:slot / BASE:1}${ALPHABET:slot % BASE:1}"
  if ! id_in_use "$id"; then
    echo "$id"
    exit 0
  fi
  slot=$(( slot + 1 ))
done

fail "no free identifier left for day $day"
