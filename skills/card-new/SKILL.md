---
name: card-new
description: Apre la card di un branch cardflow, di solito prendendo la prima voce del suo backlog. Un branch ha al massimo una card aperta. L'Id si passa, se viene da fuori, oppure lo genera il plugin.
argument-hint: "[branch] [card-id]"
arguments: [branch, id]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh *), Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work.sh *)
disable-model-invocation: true
---

# /cardflow:card-new

Branch: `$branch`. Se è vuoto, vale il branch attivo. Id richiesto: `$id`. Se è vuoto, l'Id lo genera lo script.
Per dare un Id sul branch attivo, si passa anche il branch: `/cardflow:card-new main CR2606`.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository e il branch principale stanno
nel blocco cardflow del `CLAUDE.md`.

La cartella di un branch la dà lo script, con lo strumento Bash e non con PowerShell:
`bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" branch-dir "<work>" "<branch>" "<principale>"`. Stampa il nome della
cartella sotto `<work>/development/`: esce con 0 se la cartella esiste, con 1 se non esiste ancora (e il nome è quello
che prenderebbe), con 2 se il nome collide con un'altra cartella, e allora riporta l'errore e fermati. Senza un branch
indicato vale il branch attivo, `git -C <repository> branch --show-current`. Il branch si può indicare con il suo nome
o con quello della sua cartella.

## Passi

1. **Il branch.** Trova la sua cartella con `work.sh branch-dir`. Se la cartella del branch principale non esiste,
   creala con una `SPEC.md` che porta solo l'intestazione del modello `development/branch/SPEC.md`, con `BRANCH` uguale
   al branch principale: la spec della prossima versione la scriverà `/cardflow:branch-new`. Per un altro branch senza
   cartella, fermati e proponi `/cardflow:branch-new`.
2. **La card già aperta.** Se la cartella ha già `card/`, fermati e di' quale card è aperta, con Id e titolo: un branch
   ne ha al massimo una, perché due sviluppi sullo stesso branch mescolerebbero i loro commit. Se quella card non è
   partita, cioè ha `BASE` vuoto, proponi di rimetterla in testa al backlog: una voce `## <titolo>`, le righe
   sull'idea come descrizione, `BLOCKED BY` come nota `Bloccato da:`. Solo dopo il sì, e dopo aver scritto la voce,
   cancella `card/` e prosegui.
3. **L'idea.** Mostra le voci del `backlog.md` del branch, la prima in evidenza perché è la prossima, e chiedi quale
   prendere, oppure un'idea nuova dall'operatore. Da una voce: il titolo diventa `TITOLO`; la descrizione e le note
   `Vedi:` e `Note:` diventano le righe sotto l'intestazione; la nota `Bloccato da:` diventa `BLOCKED BY`. Per un'idea
   nuova chiedi il titolo e una o due righe.
4. **L'Id lo dà lo script, mai un calcolo a mente.** Con lo strumento Bash:
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh" "<work>"`, aggiungendo `"$id"` in fondo se l'Id è stato passato.
   Lo script stampa un Id libero, oppure esce con un errore: in quel caso riportalo e fermati. Come nasce l'Id lo
   spiega `${CLAUDE_PLUGIN_ROOT}/manual/identifiers.md`.
5. **La card.** Crea `<work>/development/<cartella>/card/SPEC.md` dal modello `development/card/SPEC.md`, con `ID`,
   `TITOLO`, `BASE` vuoto e `BLOCKED BY` vuoto o compilato; sotto l'intestazione una riga vuota e le righe sull'idea.
   Un titolo nell'intestazione non contiene la sequenza «: », che si sostituisce con un trattino. Solo dopo, se la card
   viene da una voce del backlog, togli la voce da `backlog.md`.
6. **I bloccanti.** Ogni codice di `BLOCKED BY` deve esistere: controllali con
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" blockers "<work>" "<cartella>"`. Per un codice `sconosciuto`,
   proponi quello che differisce solo per le maiuscole, se lo script lo suggerisce; se è `chiuso`, dillo, perché non
   blocca più. Se un bloccante è `aperto`, la card può nascere, ma dillo.
7. Di' a quale branch appartiene la card e indica il passo successivo: `/mattpocock-skills:grill-with-docs` sulla
   card.
