---
name: order-new
description: Apre un ordine cardflow, cioè una CR o una release, con la sua spec e il suo ramo.
argument-hint: "[order-id]"
arguments: [order]
disable-model-invocation: true
---

# /cardflow:order-new

Id dell'ordine: `$order`. Se è vuoto, chiedilo: viene da fuori, è il numero della CR o il nome della release.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. I modelli
stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`.

L'Id di un ordine si legge dal campo `Id:` del suo `0-ORDER.md`, non dal nome della cartella.

## Passi

1. Se esiste già un ordine con quell'Id, fermati.
2. Chiedi uno slug breve in inglese, il titolo e il ramo.
3. Crea `<work>/orders/<id>-<slug>/` con `0-ORDER.md` dal modello `order/0-ORDER.md`, compilato, e `1-SPEC.md` dal
   modello `order/1-SPEC.md`: obiettivo, perimetro e criteri di accettazione, presi dalla conversazione o chiesti.
   I criteri sono quello che `/cardflow:order-close` verificherà, quindi devono essere controllabili.
4. Se l'operatore indica file del cliente per quest'ordine, copiali in `sources/`. Da lì in poi sono in sola
   lettura.
