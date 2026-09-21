---
name: card-list
description: Elenca le card cardflow aperte con stato, priorità, ordine, ramo, bloccanti e ticket rimasti, e segnala quelle in corso su un ramo diverso da quello attivo.
---

# /cardflow:card-list

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Il repository è
quello indicato nel blocco cardflow del `CLAUDE.md`.

## Passi

1. Leggi tutti i `<work>/cards/*/0-CARD.md` e, per ogni ordine citato, il suo `0-ORDER.md`.
2. Per ogni card, i **bloccanti aperti** sono i codici della riga `Blocked by:` che esistono ancora come voce
   `### <codice> —` in un registro `2-` o `3-OPEN-POINTS` di `<work>/project/` o di un ordine. Un codice che non
   esiste più è risolto e non si mostra.
3. Stampa una tabella con Id, titolo, stato, priorità, ordine, ramo (da `0-ORDER.md`), bloccanti aperti (solo i
   codici) e ticket rimasti (i file in `tickets/`). Prima le card `DOING`, poi quelle `BACKLOG`; dentro, per
   priorità, e a parità l'Id più vecchio, che è anche il primo in ordine alfabetico.
4. Segna le card `DOING` il cui ramo non è quello attivo, letto con `git -C <repository> branch --show-current`.

Le card chiuse non compaiono: stanno negli `archive/` degli ordini. I titoli dei bloccanti li mostra
`/cardflow:open-points`.
