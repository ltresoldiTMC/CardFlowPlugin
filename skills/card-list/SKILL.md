---
name: card-list
description: Elenca le card cardflow aperte con stato, priorità, ordine, ramo e ticket rimasti, e segnala quelle in corso su un ramo diverso da quello attivo.
---

# /cardflow:card-list

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Il repository è
quello indicato nel blocco cardflow del `CLAUDE.md`.

## Passi

1. Leggi tutti i `<work>/cards/*/0-CARD.md` e, per ogni ordine citato, il suo `0-ORDER.md`.
2. Stampa una tabella con Id, titolo, stato, priorità, ordine, ramo (da `0-ORDER.md`) e ticket rimasti (i file in
   `tickets/`). Prima le card `DOING`, poi quelle `BACKLOG`; dentro, per priorità, e a parità l'Id più vecchio.
3. Segna le card `DOING` il cui ramo non è quello attivo, letto con `git -C <repository> branch --show-current`.

Le card chiuse non compaiono: stanno negli `archive/` degli ordini.
