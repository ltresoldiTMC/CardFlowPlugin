---
name: branch-new
description: Apre un branch cardflow. Crea la sua cartella con la spec, cioè obiettivo, perimetro e criteri di accettazione divisi fra per il cliente e interni, e scrive il diario. Sul branch principale scrive la spec della prossima versione.
argument-hint: "<branch>"
arguments: [branch]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work.sh *)
disable-model-invocation: true
---

# /cardflow:branch-new

Branch: `$branch`. Se è vuoto, chiedilo: cardflow non crea branch, quindi il branch esiste già o lo crea l'operatore.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository, il branch principale, la
lingua e i percorsi dei documenti del repository stanno nel blocco cardflow del `CLAUDE.md`.

La cartella di un branch la dà lo script, con lo strumento Bash e non con PowerShell:
`bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" branch-dir "<work>" "<branch>" "<principale>"`. Stampa il nome della
cartella sotto `<work>/development/`: esce con 0 se la cartella esiste, con 1 se non esiste ancora (e il nome è quello
che prenderebbe), con 2 se il nome collide con un'altra cartella, e allora riporta l'errore e fermati.

## Passi

1. **Il branch.** Verifica in sola lettura che esista, con `git -C <repository> rev-parse --verify <branch>`. Se non
   esiste, dillo e fermati: lo crea l'operatore, e cardflow non tocca i branch.
2. **La cartella**, con `work.sh branch-dir`.
   - **Esce con 1**: crea `<work>/development/<cartella>/SPEC.md` dal modello `development/branch/SPEC.md`, con
     `BRANCH` uguale al nome esatto del branch.
   - **Esce con 0**: se la `SPEC.md` della cartella ha già sezioni `##`, il branch è già aperto: dillo e fermati. Se ha
     solo l'intestazione, perché l'ha creata `/cardflow:card-new` sul branch principale, o se manca, completala dal
     modello conservando l'intestazione.
3. **La spec**: il titolo, in `TITOLO` e al posto di `{{TITOLO}}`; l'obiettivo; il perimetro; i criteri di
   accettazione, divisi fra *Per il cliente* e *Interni*; le fonti. Prendili dalla conversazione o chiedili. I criteri
   devono essere controllabili, perché `/cardflow:branch-close` li verificherà e `/cardflow:status` li leggerà. I
   criteri per il cliente si scrivono con le parole del cliente, senza codici né nomi di classi: se un criterio
   proposto è tecnico, proponi di spostarlo fra gli interni o di riscriverlo. Sul branch principale la spec dice che
   cosa deve fare la prossima versione.
4. **I documenti ricevuti** per questo lavoro vanno in `<work>/knowledge/docs/`, così come sono arrivati, e non si
   modificano. La spec li cita fra le fonti, per nome.
5. **Diario.** Aggiungi in fondo a `<work>/control/journal.md`, che nasce dal modello `control/journal.md` se manca,
   una voce `### <oggi> — Aperto il branch <BRANCH> (<titolo>)`, con `Fonte:` (la richiesta, l'incontro o la
   richiesta di modifica da cui nasce) e `Branch: <BRANCH>`. Sul branch principale la voce è
   `### <oggi> — Spec della prossima versione (<titolo>)`, senza `Branch:`.

Indica il passo successivo: `/cardflow:branch-plan` propone dalla spec le voci del `backlog.md`, cioè le card da
creare; poi il primo sviluppo si apre con `/cardflow:card-new`.
