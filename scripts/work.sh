#!/usr/bin/env bash
#
# Reads a cardflow work root and prints what the skills need, as lines of tab-separated fields, so that a skill reads
# fields instead of interpreting free text. Never writes.
#
# Usage:
#   work.sh branch-dir  <work-root> <branch> <main-branch>
#       Prints the folder of a branch under development/: the one whose SPEC.md carries the exact branch name in the
#       BRANCH field, or the one named as the argument. The main branch owns the folder named after it even before
#       its spec exists. Without a folder, prints the name a new one would take: the branch name with every "/"
#       replaced by "-", since "/" cannot appear in a folder name. The name is refused when another folder already
#       uses it, or differs from it only in case, because Windows does not tell case apart in folder names.
#   work.sh blockers    <work-root> <branch-folder>
#       One line per code cited by the BLOCKED BY field of the branch's card and by the "Bloccato da:" notes of its
#       backlog: code, state, source (card or backlog), title of the card or backlog entry, and for an unknown code
#       the code that differs from it only in case. The state is "aperto" when the code titles an entry of an
#       open-points register, "chiuso" when no register has it but the journal cites it, "sconosciuto" otherwise.
#   work.sh open-points <work-root>
#       One line per entry of the open-points registers and of the open points of the cards: code (empty for the
#       points of a card, which have none), title, file relative to the work root, and the branch of its "Chiusa in:"
#       line, empty when the entry is not closed by a branch waiting for its merge.
#
# Exit status: 0 on success; 1 when branch-dir finds no folder or blockers finds no branch folder; 2 when branch-dir
# meets a folder collision; 3 on a usage error.
#
# Entries are "### " headings. Text inside HTML comments is skipped, because every template carries its rules and an
# example entry in a comment.

set -euo pipefail

# Bash string comparison follows the collation of the locale; outside C, lower case interleaves with upper case.
export LC_ALL=C
shopt -s nullglob

readonly HEADER_AWK="$(dirname "$0")/header.awk"
readonly CODE_PATTERN='(MP|MS|T|Q)[0-9]{5}[A-Za-z]{2}'
readonly USAGE="usage: work.sh branch-dir <work-root> <branch> <main-branch> | blockers <work-root> <branch-folder> | open-points <work-root>"

usage() {
  echo "work: $USAGE" >&2
  exit 3
}

# Prints the entries of one register file as "code, title, file, closed-in branch".
# Arguments: the file path, its path relative to the work root, and 1 when titles start with a code.
register_file() {
  awk -v file="$2" -v coded="$3" -v pattern="$CODE_PATTERN" '
    function flush() {
      if (open) print code "\t" title "\t" file "\t" closed_in
      open = 0
    }
    BEGIN { dash = " \342\200\224 " }
    { sub(/\r$/, "") }
    index($0, "<!--") { in_comment = 1 }
    in_comment { if (index($0, "-->")) in_comment = 0; next }
    /^### / {
      flush()
      line = substr($0, 5); code = ""; title = line; closed_in = ""; open = 1
      i = index(line, dash)
      if (coded && i > 0 && substr(line, 1, i - 1) ~ ("^" pattern "$")) {
        code = substr(line, 1, i - 1)
        title = substr(line, i + length(dash))
      }
      next
    }
    /^##? / { flush(); next }
    open && /^Chiusa in:/ { closed_in = $0; sub(/^Chiusa in:[ \t]*/, "", closed_in) }
    END { flush() }
  ' "$1"
}

# Prints the entries of every open-points register: the common ones, then those of each branch.
register_entries() {
  local path
  for path in "$work_root"/control/open-points-technical.md "$work_root"/control/open-points-client.md \
              "$work_root"/development/*/open-points-technical.md; do
    [[ -f "$path" ]] && register_file "$path" "${path#"$work_root"/}" 1
  done
  return 0
}

open_points() {
  local path
  register_entries
  for path in "$work_root"/development/*/card/OPEN-POINTS.md; do
    register_file "$path" "${path#"$work_root"/}" 0
  done
}

branch_dir() {
  local branch=$1 main=$2 spec folder existing converted
  for spec in "$work_root"/development/*/SPEC.md; do
    if [[ "$(awk -v field=BRANCH -f "$HEADER_AWK" "$spec")" == "$branch" ]]; then
      basename "$(dirname "$spec")"
      return 0
    fi
  done
  if [[ "$branch" != */* && -f "$work_root/development/$branch/SPEC.md" ]]; then
    echo "$branch"
    return 0
  fi
  converted=${branch//\//-}
  for folder in "$work_root"/development/*/; do
    existing=$(basename "$folder")
    if [[ "$existing" == "$converted" ]]; then
      if [[ "$branch" == "$main" && ! -f "$folder/SPEC.md" ]]; then
        echo "$existing"
        return 0
      fi
      echo "work: folder '$existing' already belongs to another branch" >&2
      return 2
    fi
    if [[ "${existing,,}" == "${converted,,}" ]]; then
      echo "work: folder '$existing' differs from '$converted' only in case" >&2
      return 2
    fi
  done
  echo "$converted"
  return 1
}

# Prints "source, code, title" for every code the branch's card and backlog cite as blockers. The title comes last
# because it may be empty, and read merges consecutive tabs.
citations() {
  local dir=$1 title code
  if [[ -f "$dir/card/SPEC.md" ]]; then
    title=$(awk -v field=TITOLO -f "$HEADER_AWK" "$dir/card/SPEC.md")
    while read -r code; do
      printf 'card\t%s\t%s\n' "$code" "$title"
    done < <(awk -v field="BLOCKED BY" -f "$HEADER_AWK" "$dir/card/SPEC.md" | grep -oE "$CODE_PATTERN" || true)
  fi
  if [[ -f "$dir/backlog.md" ]]; then
    awk -v pattern="$CODE_PATTERN" '
      { sub(/\r$/, "") }
      index($0, "<!--") { in_comment = 1 }
      in_comment { if (index($0, "-->")) in_comment = 0; next }
      /^## / { title = substr($0, 4); next }
      title != "" && index($0, "Bloccato da:") {
        line = substr($0, index($0, "Bloccato da:"))
        while (match(line, pattern)) {
          print "backlog\t" substr(line, RSTART, RLENGTH) "\t" title
          line = substr(line, RSTART + RLENGTH)
        }
      }
    ' "$dir/backlog.md"
  fi
}

blockers() {
  local dir="$work_root/development/$1" journal="$work_root/control/journal.md"
  local code source title state suggestion candidate
  local -A open=() known=()
  if [[ ! -d "$dir" ]]; then
    echo "work: branch folder not found: $1" >&2
    return 1
  fi
  # cut keeps an empty first field, which read would merge into the next one.
  while read -r code; do
    if [[ -n "$code" ]]; then
      open[$code]=1
      known[$code]=1
    fi
  done < <(register_entries | cut -f1)
  if [[ -f "$journal" ]]; then
    while read -r code; do
      known[$code]=1
    done < <(grep -oE "$CODE_PATTERN" "$journal" || true)
  fi
  while IFS=$'\t' read -r source code title; do
    suggestion=""
    if [[ -n "${open[$code]:-}" ]]; then
      state=aperto
    elif [[ -n "${known[$code]:-}" ]]; then
      state=chiuso
    else
      state=sconosciuto
      for candidate in "${!known[@]}"; do
        if [[ "${candidate,,}" == "${code,,}" ]]; then
          suggestion=$candidate
        fi
      done
    fi
    printf '%s\t%s\t%s\t%s\t%s\n' "$code" "$state" "$source" "$title" "$suggestion"
  done < <(citations "$dir")
}

command=${1:-}
work_root=${2:-}
[[ -n "$command" && -n "$work_root" ]] || usage
if [[ ! -d "$work_root" ]]; then
  echo "work: work root not found: $work_root" >&2
  exit 3
fi

case "$command" in
  branch-dir)  (( $# == 4 )) || usage; branch_dir "$3" "$4" ;;
  blockers)    (( $# == 3 )) || usage; blockers "$3" ;;
  open-points) (( $# == 2 )) || usage; open_points ;;
  *)           usage ;;
esac
