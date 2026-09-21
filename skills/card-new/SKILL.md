---
name: card-new
description: Crea una card cardflow, nel backlog libero o in un ordine aperto, con un Id passato o generato.
argument-hint: "[card-id]"
arguments: [id]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh *)
disable-model-invocation: true
---

# /cardflow:card-new

Id richiesto: `$id`. Se è vuoto, l'Id lo genera lo script.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. I modelli
stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`.

Un ordine si indica con l'Id o con il nome intero della sua cartella. Se in `<work>/orders/` esiste una cartella con
quel nome esatto, è quella; altrimenti è la cartella `<valore>-*` il cui `0-ORDER.md` porta `Id: <valore>`.

## Passi

1. Chiedi il titolo, la priorità (`alta`, `media` o `bassa`; se l'operatore non la dice, `media`), l'ordine, che
   può mancare (la card nasce allora nel backlog libero), e due righe sull'idea. Proponi uno slug breve in inglese.
2. Se c'è un ordine, deve esistere ed essere `OPEN`.
3. **L'Id lo dà lo script, mai un calcolo a mente.** Con lo strumento Bash, non con PowerShell:
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh" "<work>"`, aggiungendo `"$id"` in fondo se l'Id è stato passato.
   Lo script stampa un Id libero, oppure esce con un errore: in quel caso riportalo e fermati. Come nasce l'Id lo
   spiega `${CLAUDE_PLUGIN_ROOT}/manual/identifiers.md`.
4. Crea `<work>/cards/<id>-<slug>/0-CARD.md` dal modello `card/0-CARD.md`, compilato, con `Stato: BACKLOG`, `Base:`
   vuoto e `Blocked by:` vuoto; sotto l'intestazione, dopo una riga vuota, le due righe sull'idea.
5. Se l'operatore dice che la card aspetta una risposta o una decisione già registrata, scrivila in `Blocked by:`
   con codice e titolo, per esempio `Blocked by: C3 (formato delle date accettato dal gestionale)`. Il codice deve
   esistere in un registro di `project/` o di un ordine.
6. Indica il passo successivo: `/mattpocock-skills:grill-with-docs` sulla card.
