---
name: open-points
description: Elenca i punti aperti di cardflow, cioè i punti tecnici e le domande, comuni, dei branch e delle card, con i bloccanti per primi e quello che ciascuno tiene fermo. Usala quando l'operatore chiede i punti aperti, le domande al cliente o che cosa blocca il lavoro.
argument-hint: "[branch | card-id]"
arguments: [target]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work.sh *)
---

# /cardflow:open-points

Ambito: `$target`. Vuoto vuol dire tutto il progetto.

Sola lettura: questo comando non scrive in nessun file.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. Il repository e il branch principale stanno nel blocco cardflow del `CLAUDE.md`.

L'ambito è un Id di card oppure un branch. Una card con quell'Id è la `<work>/development/*/card/` il cui `SPEC.md`
porta `ID: <valore>` nell'intestazione. Un branch si trova con lo script, con lo strumento Bash e non con PowerShell:
`bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" branch-dir "<work>" "<branch>" "<principale>"`, che esce con 0 se la
cartella esiste. Se non trovi né l'una né l'altro, dillo e fermati.

## Passi

1. **Raccogli le voci** con `bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" open-points "<work>"`: una riga per voce, con
   codice (vuoto per i punti di una card), titolo, file e branch della riga `Chiusa in:`. Tieni quelle dell'ambito:
   - **tutto**: tutte;
   - **un branch**: il `open-points-technical.md` della sua cartella, l'`OPEN-POINTS.md` della sua card, e le voci che
     la sua card e il suo backlog citano come bloccanti, ovunque stiano;
   - **una card**: il suo `OPEN-POINTS.md` e le voci che il suo `BLOCKED BY` cita, ovunque stiano.

   Il tipo si ricava dal file: tecnico per i `open-points-technical.md` e per i punti di una card, domanda per
   `open-points-client.md`.
2. **Trova chi blocca chi.** Per la cartella di ogni branch,
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" blockers "<work>" "<cartella>"` stampa i codici citati dalla card e
   dal backlog, con il loro stato. Una voce tiene fermo quello che la cita con stato `aperto`.
3. **Stampa una tabella**: codice, titolo, dove sta (comune, branch `<nome>`, card `<id>`), tipo, che cosa tiene fermo
   (la card con il suo Id, o una voce del backlog con il suo branch). Prima le voci che bloccano, cioè quelle citate
   come bloccanti o che dicono di bloccare nel proprio testo; poi le altre: comuni, dei branch, delle card. Una voce con
   `Chiusa in:` si mostra come chiusa nel branch indicato, in attesa del merge.
4. **In fondo, i controlli**, solo se trovano qualcosa:
   - le card e le voci del backlog con i bloccanti tutti chiusi, che si possono riprendere;
   - i codici citati che non corrispondono a nessuna voce (stato `sconosciuto`), con il codice che differisce solo per
     le maiuscole, se lo script lo suggerisce: vanno corretti a mano;
   - i codici citati con un titolo diverso da quello della voce.

Non inventare stati o priorità che i file non dicono. Se un file non esiste, quel livello non ha punti aperti.
