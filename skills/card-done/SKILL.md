---
name: card-done
description: Chiude una card cardflow. Revisione dell'intera card, correzioni, allineamento della spec, registri, handover, archivio. Usala anche quando l'operatore risponde sì a «Procediamo con la review e chiudiamo?» dopo l'ultimo ticket.
argument-hint: "<card-id>"
arguments: [card]
---

# /cardflow:card-done

Card: `$card`. Se è vuoto, elenca le card `DOING` e chiedi quale chiudere.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. I modelli
stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository è quello indicato nel blocco cardflow del `CLAUDE.md`.

Una card si indica con l'Id o con il nome intero della cartella. Se in `<work>/cards/` esiste una cartella con quel
nome esatto, è quella; altrimenti è la cartella `<valore>-*` il cui `0-CARD.md` porta `Id: <valore>`. La card
`26258KD`, per esempio, è `<work>/cards/26258KD-pdf-export/`.

## Passi

In quest'ordine, fermandoti a ogni passo che chiede una risposta.

0. **Condizioni.** La card deve essere `DOING`, con `Base:` scritto. Se `tickets/` contiene ancora file, elencali e
   chiedi se procedere comunque.
1. **Revisione dell'intera card.** Lancia l'agente `cardflow:closure-reviewer` passandogli l'Id della card,
   `<work>` e il percorso del repository. Presenta il suo rapporto così com'è.
2. **Correzioni.** L'operatore decide che cosa correggere. Correggi, verifica con i comandi di build e di test del
   progetto e riporta l'esito vero. Per il commit vale la regola di sempre: lo dici, proponi la riga e aspetti.
3. **Allineamento della spec.** Solo adesso `1-SPEC.md` recepisce le deviazioni che la revisione ha giudicato
   valide e l'operatore ha confermato: il testo si corregge e la riga della deviazione si toglie.
4. **Salita nei registri**, chiedendo voce per voce prima di scrivere:
   - i punti ancora aperti di `2-OPEN-POINTS.md` vanno in `2-OPEN-POINTS-TECHNICAL.md` dell'ordine, oppure in
     `3-OPEN-POINTS-CLIENT.md` se solo il cliente può rispondere; lì prendono il codice, il più alto già usato in
     tutto il progetto più uno;
   - le decisioni della spec vanno in `4-DECISIONS.md` dell'ordine, solo se rispondono alle tre domande: che cosa
     è stato scartato e perché, perché il codice non basta a capirla, fino a quando vale. Una voce che non
     risponde si ferma, e l'operatore decide se è davvero una decisione. Una decisione che ne supera una esistente
     la riscrive al suo posto;
   - termini, vincoli e migliorie emersi nella card vanno in `6-GLOSSARY.md`, `7-CONSTRAINTS.md` e
     `8-IMPROVEMENTS.md` del progetto, secondo la regola scritta in testa a ciascun file.

   Un file che non esiste nasce dal modello di `registers/`.
5. **File intermedi.** Per ogni file di `files/` chiedi se **tenerlo vivo** (nel repository se è un dato di prova
   vero, altrimenti in `<work>/project/resources/`), **archiviarlo** con la card o **cancellarlo**. Mostra
   l'elenco di `.scratch/`: una nota che serve ancora dopo la chiusura non era una nota ma conoscenza, e va in
   `<work>/project/knowledge/`.
6. **Handover.** Scrivi `5-HANDOVER.md` dal modello `card/5-HANDOVER.md`, con `Commit:` uguale a
   `<Base>..<SHA di HEAD>`. Nomi di file, classi e chiavi verificati sul codice prima di scriverli.
7. **Archivio.** Crea `<work>/orders/<ordine>/archive/<id>-<slug>/`, spostaci `5-HANDOVER.md` e i file da
   archiviare, poi cancella la cartella della card. Da qui la card è `DONE`, e vive solo nell'archivio.

Nessuna operazione sui rami.
