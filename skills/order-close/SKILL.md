---
name: order-close
description: Chiude un ordine cardflow. Verifica i criteri, decide le card rimaste, porta i registri nel progetto, scrive la consegna se richiesta.
argument-hint: "<order-id>"
arguments: [order]
disable-model-invocation: true
---

# /cardflow:order-close

Ordine: `$order`. Se è vuoto, elenca gli ordini `OPEN` e chiedi quale chiudere.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. I modelli
stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`.

Un ordine o una card si indicano con l'Id o con il nome intero della cartella. Se esiste una cartella con quel nome
esatto, è quella; altrimenti è la cartella `<valore>-*` la cui intestazione (`0-ORDER.md`, `0-CARD.md`) porta
`Id: <valore>`.

## Passi

In quest'ordine, fermandoti a ogni passo che chiede una risposta.

1. **Criteri.** Verifica ogni criterio di `1-SPEC.md` contro gli handover in `archive/` e contro il codice.
   Riporta per ciascuno se è soddisfatto, parziale o mancante, con il riferimento.
2. **Card rimaste.** Elenca le card di `<work>/cards/` con `Ordine: <id>`. Per ciascuna chiedi:
   - **backlog**: `Ordine:` vuoto, `Stato: BACKLOG`, `Base:` vuoto; spec e ticket restano come materiale di
     partenza, e prima di riprenderla servirà un ordine;
   - **elimina**: si cancella la cartella della card, non il codice già committato;
   - **altro ordine**: `Ordine:` prende l'Id indicato, che deve esistere ed essere `OPEN`; il resto non cambia.

   È l'unico momento in cui una card già iniziata cambia ordine.
3. **Registri.** Per ogni voce di `2-OPEN-POINTS-TECHNICAL.md`, `3-OPEN-POINTS-CLIENT.md` e `4-DECISIONS.md`
   dell'ordine chiedi se **sale** nel file omonimo di `<work>/project/` o **si cancella**. Una voce che sale tiene il
   suo codice. Una decisione che sale deve rispondere alle tre domande, e se ne supera una del progetto la riscrive
   al suo posto invece di affiancarla. Un file di `project/` che non esiste nasce dal modello di `registers/`. Le
   voci trattate si tolgono dall'ordine, e un file rimasto vuoto si cancella.
4. **Consegna.** Chiedi se serve. Solo se sì, scrivi `5-DELIVERY.md` dal modello `order/5-DELIVERY.md`,
   raccogliendo le modifiche dagli handover di `archive/` e gli script, se ci sono.
5. **Stato.** `Stato: DONE` in `0-ORDER.md`. La cartella dell'ordine resta: è la traccia di quello che è stato
   fatto.

Nessuna operazione sui rami: se il ramo sia stato unito lo sa l'operatore, e la chiusura non lo controlla.
