---
name: card-assign
description: Assegna a un ordine una card cardflow ancora nel backlog, oppure la riporta nel backlog libero.
argument-hint: "<card-id> <order-id | ->"
arguments: [card, order]
disable-model-invocation: true
---

# /cardflow:card-assign

Card: `$card`. Ordine: `$order`; `-` vuol dire nessun ordine. Se manca uno dei due, chiedilo.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`.

Una card o un ordine si indicano con l'Id o con il nome intero della cartella. Se esiste una cartella con quel nome
esatto, è quella; altrimenti è la cartella `<valore>-*` la cui intestazione (`0-CARD.md`, `0-ORDER.md`) porta
`Id: <valore>`. La card `26258KD`, per esempio, è `<work>/cards/26258KD-pdf-export/`.

## Passi

1. **Rifiuta se la card non è in `BACKLOG`.** Una card iniziata ha già codice sul ramo del suo ordine, e cambia
   ordine solo a `/cardflow:order-close`.
2. Se l'ordine non è `-`, deve esistere ed essere `OPEN`.
3. Scrivi l'Id dell'ordine in `Ordine:` di `0-CARD.md`, oppure svuota il campo se l'ordine è `-`.
4. Se il campo si è svuotato e la card ha già `1-SPEC.md`, avvisa che prima di riprenderla servirà di nuovo un
   ordine.
