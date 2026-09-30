#!/usr/bin/env bash
#
# Prints free cardflow identifiers: the id of a new card, or the codes of new register entries.
#
# Usage:
#   new-id.sh <work-root> [requested-id]            a card id
#   new-id.sh <work-root> --code <family> [count]   entry codes, one per line
#
# Both forms start from the UTC date and time of a single call to date: the two-digit year, the ISO ordinal day
# (001-366) and the time of day as two letters.
#
# A card id uses 23 upper-case letters (A-Z without I, L and O, which read like 1 and 0), so the day has 529 slots of
# about 163 seconds, e.g. 26264VV. Upper case only, because a card id names handover files and Windows does not tell
# case apart in file names. No digit follows the date: file managers that sort digit runs as numbers would merge it
# with the date and break the chronological order. An id is taken when the ID field of a card in progress holds it,
# when a handover of a closed card carries it, or when the project journal mentions it: the journal remembers deleted
# cards, whose id must not come back as a requested id.
#
# An entry code is a family (T, Q, MP or MS), the date and two letters from 46: the 23 upper-case letters followed by
# the same 23 in lower case. The day has 2116 slots of about 41 seconds, e.g. Q26272Kb. Lower case is safe here
# because a code never names a file or a folder, and upper case comes first as in byte order, so codes compared under
# LC_ALL=C sort by creation time. A code is taken when it appears as a whole word in any file under the work root
# outside notes/, the operator's space that nothing cites; a closed entry leaves its register, but the journal keeps
# its code taken.
#
# A taken slot moves to the next one, so identifiers stay unique and still sort by creation time. With a count, the
# codes come from consecutive free slots.
#
# With a requested id (a number that comes from outside, such as CR2606), the script only checks that it is well
# formed and free, and prints it.
#
# NEW_ID_EPOCH, when set, replaces the current time with a Unix timestamp: the self-check uses it to get exact values.

set -euo pipefail

# Bash string comparison follows the collation of the locale; outside C, lower case interleaves with upper case.
export LC_ALL=C

readonly CARD_ALPHABET=ABCDEFGHJKMNPQRSTUVWXYZ
readonly CODE_ALPHABET=ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz
readonly SECONDS_PER_DAY=86400
readonly VALID_ID='^[A-Za-z0-9][A-Za-z0-9._]*(-[A-Za-z0-9._]+)*$'
readonly VALID_COUNT='^[1-9][0-9]*$'
readonly USAGE="usage: new-id.sh <work-root> [requested-id] | new-id.sh <work-root> --code <T|Q|MP|MS> [count]"
readonly HEADER_AWK="$(dirname "$0")/header.awk"

fail() {
  echo "new-id: $*" >&2
  exit 1
}

work_root=${1:-}
[[ -n "$work_root" ]] || fail "$USAGE"
[[ -d "$work_root" ]] || fail "work root not found: $work_root"

# One call to date, so the day and the time of day cannot straddle midnight.
read -r day epoch < <(date -u ${NEW_ID_EPOCH:+-d "@$NEW_ID_EPOCH"} '+%y%j %s')
seconds_of_day=$(( epoch % SECONDS_PER_DAY ))

# Prints the slot of the current time of day for an alphabet of the given size.
first_slot() {
  local base=$1
  echo $(( seconds_of_day * base * base / SECONDS_PER_DAY ))
}

# Prints the two letters that encode a slot in the given alphabet.
slot_letters() {
  local alphabet=$1 slot=$2 base=${#1}
  echo "${alphabet:slot / base:1}${alphabet:slot % base:1}"
}

# True when a card in progress, a handover or the journal already uses the id.
id_in_use() {
  local id=$1 spec handovers
  shopt -s nullglob
  for spec in "$work_root"/development/*/card/SPEC.md; do
    if [[ "$(awk -v field=ID -f "$HEADER_AWK" "$spec")" == "$id" ]]; then
      shopt -u nullglob
      return 0
    fi
  done
  handovers=( "$work_root"/development/*/handovers/"$id"-*.md "$work_root"/deploy/handovers/*/"$id"-*.md )
  shopt -u nullglob
  (( ${#handovers[@]} > 0 )) && return 0
  # Fixed string: a requested id may contain dots, which a regular expression reads as any character.
  [[ -f "$work_root/control/journal.md" ]] && grep -Fqw -- "$id" "$work_root/control/journal.md"
}

# True when the code appears as a whole word in any file of the work root outside notes/.
code_in_use() {
  grep -rqw --exclude-dir=notes -- "$1" "$work_root"
}

if [[ "${2:-}" == --code ]]; then
  family=${3:-}
  count=${4:-1}
  case "$family" in
    T|Q|MP|MS) ;;
    *) fail "unknown family '$family': use T, Q, MP or MS" ;;
  esac
  [[ "$count" =~ $VALID_COUNT ]] || fail "invalid count '$count': a positive integer"

  slots=$(( ${#CODE_ALPHABET} * ${#CODE_ALPHABET} ))
  slot=$(first_slot ${#CODE_ALPHABET})
  printed=0
  while (( printed < count )); do
    (( slot < slots )) || fail "no free code left for day $day"
    code="$family$day$(slot_letters "$CODE_ALPHABET" "$slot")"
    if ! code_in_use "$code"; then
      echo "$code"
      printed=$(( printed + 1 ))
    fi
    slot=$(( slot + 1 ))
  done
  exit 0
fi

requested=${2:-}
if [[ -n "$requested" ]]; then
  [[ "$requested" =~ $VALID_ID ]] || fail "invalid id '$requested': letters, digits, dots and single dashes only"
  ! id_in_use "$requested" || fail "id '$requested' is already used"
  echo "$requested"
  exit 0
fi

slots=$(( ${#CARD_ALPHABET} * ${#CARD_ALPHABET} ))
slot=$(first_slot ${#CARD_ALPHABET})
while (( slot < slots )); do
  id="$day$(slot_letters "$CARD_ALPHABET" "$slot")"
  if ! id_in_use "$id"; then
    echo "$id"
    exit 0
  fi
  slot=$(( slot + 1 ))
done

fail "no free identifier left for day $day"
