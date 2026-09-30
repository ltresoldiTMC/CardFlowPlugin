#!/usr/bin/env bash
#
# Self-check for work.sh: run it with `bash scripts/work.test.sh`.
# Exits non-zero on the first failed expectation.

set -euo pipefail
export LC_ALL=C

script="$(dirname "$0")/work.sh"
work=$(mktemp -d)
empty=$(mktemp -d)
trap 'rm -rf "$work" "$empty"' EXIT

check() {
  if ! eval "$2"; then
    echo "FAIL: $1" >&2
    exit 1
  fi
}

# Runs work.sh and stores its output in $out and its exit status in $rc.
run() {
  out=$(bash "$script" "$@" 2>/dev/null) && rc=0 || rc=$?
}

# Writes a branch spec whose header carries the given branch name.
branch_spec() {
  mkdir -p "$work/development/$1"
  printf -- '---\nBRANCH:     %s\nTITOLO:     Test\n---\n' "$2" > "$work/development/$1/SPEC.md"
}

branch_spec feature-cr0412 feature/cr0412
branch_spec old-name feature/renamed
branch_spec feature-x hotfix/other
branch_spec Feature-Y release/Feature-Y
mkdir -p "$work/development/main" "$empty/development" "$work/control"

cat > "$work/development/feature-cr0412/open-points-technical.md" <<'EOF'
# Punti tecnici aperti

### T26280Mc — Paginazione dell'esportazione XML
Oltre 5.000 fatture il file supera il limite del gestionale.
EOF

mkdir -p "$work/development/feature-cr0412/card"
cat > "$work/development/feature-cr0412/card/SPEC.md" <<'EOF'
---
ID:         26285HT
TITOLO:     Validazione dello schema XML
BASE:
BLOCKED BY: Q26255Kb (formato delle date), T26270Bb (timeout), T26280mc (paginazione), Q26299Zz (nessuno)
---

Le due righe sull'idea.
EOF

cat > "$work/development/feature-cr0412/card/OPEN-POINTS.md" <<'EOF'
### Colonne da escludere — PDF
Da decidere con chi usa il PDF.
EOF

cat > "$work/development/feature-cr0412/backlog.md" <<'EOF'
# Backlog

<!-- cardflow: an example that must be ignored.

## Esportazione in PDF

- **Bloccato da:** Q26211Aa (esempio) -->

## Note di credito

Le note di credito si esportano come le fatture.

- **Bloccato da:** Q26255Kb (formato delle date accettato dal gestionale)
EOF

cat > "$work/control/open-points-client.md" <<'EOF'
# Domande aperte

<!-- cardflow: an example that must be ignored.

### Q26211Aa — Esempio -->

## Cliente

### Q26255Kb — Formato delle date accettato dal gestionale
Il gestionale accetta solo date ISO?
EOF

cat > "$work/control/open-points-technical.md" <<'EOF'
# Punti tecnici aperti

### T26275Cd — Timeout del servizio di invio
Chiusa in: feature/cr0412
Il servizio chiude la connessione dopo 30 secondi.
EOF

cat > "$work/control/journal.md" <<'EOF'
### 2026-10-02 — Il gestionale risponde in tempo
Fonte: analisi nostra.
Effetto: si chiude T26270Bb (timeout della connessione al gestionale).
EOF

# branch-dir

run branch-dir "$work" feature/cr0412 main
check "a branch folder is found from the header" '(( rc == 0 )) && [[ "$out" == feature-cr0412 ]]'
run branch-dir "$work" feature/renamed main
check "a renamed branch is found from the header, not from the folder name" '(( rc == 0 )) && [[ "$out" == old-name ]]'
run branch-dir "$work" feature-cr0412 main
check "the folder name is accepted as the argument" '(( rc == 0 )) && [[ "$out" == feature-cr0412 ]]'
run branch-dir "$work" main main
check "the main branch owns its folder before its spec exists" '(( rc == 0 )) && [[ "$out" == main ]]'
run branch-dir "$empty" main main
check "without a folder, the main branch gets its converted name" '(( rc == 1 )) && [[ "$out" == main ]]'
run branch-dir "$work" feature/new main
check "a new branch gets the name with / replaced by -" '(( rc == 1 )) && [[ "$out" == feature-new ]]'
run branch-dir "$work" feature/x main
check "a folder of another branch is a collision" '(( rc == 2 ))'
run branch-dir "$work" feature/y main
check "a folder that differs only in case is a collision" '(( rc == 2 ))'

# blockers

run blockers "$work" feature-cr0412
tab=$'\t'
check "an open blocker of the card" '[[ "$out" == *"Q26255Kb${tab}aperto${tab}card${tab}Validazione dello schema XML"* ]]'
check "a blocker cited only by the journal is closed" '[[ "$out" == *"T26270Bb${tab}chiuso${tab}card"* ]]'
check "an unknown blocker suggests the code that differs only in case" \
  '[[ "$out" == *"T26280mc${tab}sconosciuto${tab}card${tab}Validazione dello schema XML${tab}T26280Mc"* ]]'
check "an unknown blocker without a near code" '[[ "$out" == *"Q26299Zz${tab}sconosciuto${tab}card"* ]]'
check "a blocker of a backlog entry" '[[ "$out" == *"Q26255Kb${tab}aperto${tab}backlog${tab}Note di credito"* ]]'
check "examples inside comments are ignored" '[[ "$out" != *Q26211Aa* ]] && (( $(wc -l <<< "$out") == 5 ))'
run blockers "$work" missing-folder
check "a missing branch folder is reported" '(( rc == 1 ))'

# open-points

run open-points "$work"
check "a question with its file" \
  '[[ "$out" == *"Q26255Kb${tab}Formato delle date accettato dal gestionale${tab}control/open-points-client.md${tab}"* ]]'
check "a common point closed by a branch waiting for its merge" \
  '[[ "$out" == *"T26275Cd${tab}Timeout del servizio di invio${tab}control/open-points-technical.md${tab}feature/cr0412"* ]]'
check "a point of a branch" '[[ "$out" == *"T26280Mc${tab}Paginazione dell'"'"'esportazione XML${tab}development/feature-cr0412/open-points-technical.md"* ]]'
check "a point of a card has no code, and a dash in its title stays in the title" \
  '[[ "$out" == *"${tab}Colonne da escludere — PDF${tab}development/feature-cr0412/card/OPEN-POINTS.md"* ]]'
check "examples inside comments are not entries" '[[ "$out" != *Q26211Aa* ]] && (( $(wc -l <<< "$out") == 4 ))'

# usage

run
check "no arguments is a usage error" '(( rc == 3 ))'
run unknown "$work"
check "an unknown command is a usage error" '(( rc == 3 ))'
run branch-dir "$work" feature/cr0412
check "a missing argument is a usage error" '(( rc == 3 ))'

echo "ok"
