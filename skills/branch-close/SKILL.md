---
name: branch-close
description: Chiude un branch cardflow. Prima del merge verifica i criteri e prepara il testo della pull request; dopo il merge porta punti tecnici, backlog, handover e riepilogo dove è andato il codice, scrive il diario e cancella la cartella del branch.
argument-hint: "<branch>"
arguments: [branch]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work.sh *)
disable-model-invocation: true
---

# /cardflow:branch-close

Branch: `$branch`. È obbligatorio: dopo il merge il branch attivo è quello che ha ricevuto il codice, non quello da
chiudere. Se è vuoto, chiedilo. Sul branch principale fermati: il principale non si chiude.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository e il branch principale stanno
nel blocco cardflow del `CLAUDE.md`.

La cartella di un branch la dà lo script, con lo strumento Bash e non con PowerShell:
`bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" branch-dir "<work>" "<branch>" "<principale>"`. Stampa il nome della
cartella sotto `<work>/development/`: esce con 0 se la cartella esiste, con 1 se non esiste ancora (e il nome è quello
che prenderebbe), con 2 se il nome collide con un'altra cartella, e allora riporta l'errore e fermati. Il branch si
può indicare con il suo nome o con quello della sua cartella; il nome esatto è il `BRANCH` della sua spec. Se il
branch da chiudere non ha una cartella, dillo e fermati.

## Passi

In quest'ordine, fermandoti a ogni passo che chiede una risposta.

1. **Criteri.** Verifica ogni criterio della spec del branch, per il cliente e interni, contro gli handover della sua
   cartella `handovers/` e contro il codice, e riporta per ciascuno se è soddisfatto, parziale o mancante, con il
   riferimento.
2. **Card e backlog.** Elenca la card in corso, se c'è, con Id, titolo e se è partita (`BASE` scritto), e le voci del
   backlog. Qui non decidi ancora niente.
3. **Merge, in sola lettura.** La destinazione è il branch attivo.
   - `git -C <repository> merge-base --is-ancestor <BRANCH> HEAD` deve riuscire, e il branch attivo non deve essere
     quello da chiudere.
   - Se il branch non esiste più o è stato unito con uno *squash*, il controllo fallisce anche a merge fatto: chiedi il
     commit di merge o la pull request, e verifica con `git -C <repository> merge-base --is-ancestor <commit> HEAD`.
   - I riferimenti sono quelli locali: se il merge è avvenuto sul server, prima l'operatore aggiorna la copia locale.

   **Se il branch non è unito**, questa è la verifica prima della pull request. Se c'è una card partita, di' che va
   chiusa con `/cardflow:card-done` prima del merge, perché dopo la sua revisione non sarà più possibile. Poi proponi
   il testo della pull request, cioè l'esito dei criteri e un riassunto degli handover, e fermati.
4. **La destinazione.** Trova la cartella del branch attivo con `work.sh branch-dir`. Se la destinazione è il branch
   principale e non ha una cartella, la crei quando serve, con una `SPEC.md` che porta solo l'intestazione del modello
   `development/branch/SPEC.md`. Se è un altro branch senza cartella, fermati e proponi `/cardflow:branch-new`: quello
   che sale non avrebbe dove andare.
5. **La card in corso**, se c'è.
   - **Non partita** (`BASE` vuoto): diventa una voce in fondo al `backlog.md` della destinazione (una voce
     `## <titolo>`, le righe sull'idea come descrizione, `BLOCKED BY` come nota `Bloccato da:`), oppure si elimina.
   - **Partita**: si può solo eliminare, perché i suoi commit sono già nella destinazione e la revisione di chiusura
     non è più possibile. Il codice già committato resta. Dillo e chiedi conferma.
6. **Il backlog.** Ogni voce va in fondo al `backlog.md` della destinazione, che nasce dal modello se manca, oppure si
   elimina. Chiedi se decidere per tutte insieme o una per una.
7. **Salita**, chiedendo voce per voce e riapplicando la prova dell'essenziale del manuale
   (`${CLAUDE_PLUGIN_ROOT}/manual/overview.md`, sezione *Solo l'essenziale*):
   - i punti del `open-points-technical.md` del branch ancora aperti vanno in `<work>/control/open-points-technical.md`
     se la destinazione è il branch principale, altrimenti nel `open-points-technical.md` della destinazione. Una voce
     che sale tiene il suo codice. Un file che manca nasce dal modello `control/open-points-technical.md`;
   - le voci comuni con `Chiusa in: <BRANCH>`, in `<work>/control/open-points-technical.md` e in
     `<work>/control/improvements.md`: se la destinazione è il branch principale si cancellano, altrimenti la riga
     prende il nome della destinazione. `bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" open-points "<work>"` elenca i
     punti con il branch della loro riga `Chiusa in:`.

   I documenti del repository non si toccano: li ha uniti git insieme al codice.
8. **Riepilogo e handover.** Scrivi il riepilogo dal modello `deploy/SUMMARY.md`: `BRANCH`, `TITOLO`, `MERGE` con il
   commit o la pull request; poi obiettivo, perimetro ed esito dei criteri del passo 1, ciascuno con il riferimento.
   Se la destinazione è il branch principale, il riepilogo va in `<work>/deploy/handovers/pending/<cartella>.md`, e
   ogni file di `handovers/` del branch lo segue in `<work>/deploy/handovers/pending/`, con lo stesso nome; altrimenti
   vanno tutti nella cartella `handovers/` della destinazione. Se un nome è già usato, fermati e chiedi un nome.
9. **Diario.** Aggiungi in fondo a `<work>/control/journal.md` una voce `### <oggi> — Chiuso il branch <BRANCH>
   (<titolo>)`, con `Fonte: merge <commit o pull request>.`, un `Effetto:` con i codici saliti e quelli cancellati,
   ciascuno con il suo titolo, la card eliminata con Id e titolo, le voci di backlog spostate e il riepilogo lasciato,
   e `Branch: <BRANCH>`.
10. **Cancellazione.** Correggi i collegamenti che da altri documenti di `<work>` puntano dentro la cartella del
    branch. Poi mostra che cosa resta nella cartella, e cancellala.

Nessuna operazione sui branch: cardflow non fa merge, non scarica e non cancella branch. La consegna non nasce qui: la
crea `/cardflow:release`.
