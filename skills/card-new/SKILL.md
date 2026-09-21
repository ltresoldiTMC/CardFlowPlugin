---
name: card-new
description: Crea una card cardflow, nel backlog libero o in un ordine aperto.
argument-hint: "[order-id]"
arguments: [order]
disable-model-invocation: true
---

# /cardflow:card-new

Ordine della card: `$order`. Se è vuoto, chiedilo; la card può anche nascere senza ordine, nel backlog libero.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. I modelli
stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`.

L'Id di una card o di un ordine si legge dal campo `Id:` della sua intestazione, non dal nome della cartella.

## Passi

1. Chiedi il titolo, la priorità (`alta`, `media` o `bassa`; se l'operatore non la dice, `media`) e due righe
   sull'idea. Proponi uno slug breve in inglese.
2. Se c'è un ordine, deve esistere in `<work>/orders/` ed essere `OPEN`.
3. L'Id è la data di oggi, `YYMMdd`. Se una card con quell'Id esiste già, in `cards/` o nell'`archive/` di un
   ordine, aggiungi `-2`, poi `-3` e così via.
4. Crea `<work>/cards/<id>-<slug>/0-CARD.md` dal modello `card/0-CARD.md`, compilato, con `Stato: BACKLOG` e
   `Base:` vuoto; sotto l'intestazione, dopo una riga vuota, le due righe sull'idea.
5. Indica il passo successivo: `/mattpocock-skills:grill-with-docs` sulla card.
