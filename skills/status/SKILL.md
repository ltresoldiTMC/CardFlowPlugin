---
name: status
description: Dice a che punto è un branch cardflow, in sola lettura. Per ogni criterio di accettazione della sua spec dice se è soddisfatto, parziale o mancante e da che cosa lo ricava, poi elenca i bloccanti con da quando sono aperti, la card in corso e il backlog. Usala quando l'operatore chiede a che punto siamo, lo stato di avanzamento, che cosa resta da fare o che cosa blocca un lavoro.
argument-hint: "[branch]"
arguments: [branch]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work.sh *)
---

# /cardflow:status

Branch: `$branch`. Se è vuoto, vale il branch attivo.

Sola lettura: questo comando non scrive in nessun file.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. Il repository e il branch principale stanno nel blocco cardflow del `CLAUDE.md`.

La cartella di un branch la dà lo script, con lo strumento Bash e non con PowerShell:
`bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" branch-dir "<work>" "<branch>" "<principale>"`. Esce con 0 se la cartella
esiste; altrimenti il branch non ha niente da mostrare: dillo e fermati. Senza un branch indicato vale il branch
attivo, `git -C <repository> branch --show-current`.

## Passi

1. **L'impegno.** I criteri della spec del branch. Come prove, gli handover della sua cartella `handovers/` e la sua
   card; per il branch principale, gli handover in `<work>/deploy/handovers/pending/` e la sua card. Se i criteri
   mancano, dillo, e mostra comunque bloccanti, card e backlog.
2. **I criteri.** Per ciascuno: soddisfatto, parziale o mancante, e da che cosa lo ricavi, cioè un handover con Id e
   titolo, la card in corso, un file del codice con la riga. Prima i criteri per il cliente, poi quelli interni.
3. **I bloccanti.** `bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" blockers "<work>" "<cartella>"` stampa, per ogni
   codice citato dalla card e dal backlog, il codice, lo stato, la fonte, il titolo della card o della voce e un
   suggerimento. Per ogni bloccante `aperto`: codice e titolo della voce, a chi va chiesto (per una domanda, il
   destinatario scritto nella voce o nella sua sezione; per un punto tecnico, a noi), da quando è aperto (la data della
   voce di diario in cui il codice è nato, oppure «non registrata») e che cosa tiene fermo. Per un codice
   `sconosciuto`, di' che va corretto e proponi il suggerimento, se c'è.
4. **La card e il backlog.** La card in corso: Id, titolo, se è partita (`BASE` scritto) e quanti ticket restano. Il
   backlog: i titoli delle voci, nell'ordine, segnando quelle bloccate.
5. **Stampa**: la tabella dei criteri, la tabella dei bloccanti, poi la card e il backlog in un elenco breve. Nella
   tabella dei criteri, i criteri per il cliente non portano codici: i riferimenti stanno nella colonna delle prove.

Non inventare stati, date o percentuali che i file non dicono.
