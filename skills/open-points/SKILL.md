---
name: open-points
description: Elenca i punti aperti di cardflow, tecnici e per il cliente, del progetto, degli ordini e delle card, con i bloccanti per primi e le card che ciascuno tiene ferme. Usala quando l'operatore chiede i punti aperti, le domande al cliente o che cosa blocca il lavoro.
argument-hint: "[order-id | card-id]"
arguments: [target]
---

# /cardflow:open-points

Ambito: `$target`. Vuoto vuol dire tutto il progetto.

Sola lettura: questo comando non scrive in nessun file.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`.

Un ordine o una card si indicano con l'Id o con il nome intero della cartella. Se esiste una cartella con quel nome
esatto, è quella; altrimenti è la cartella `<valore>-*` la cui intestazione (`0-ORDER.md`, `0-CARD.md`) porta
`Id: <valore>`. Cerca fra gli ordini e fra le card: gli Id non si ripetono fra i due. Se non trovi niente, dillo e
fermati.

## Passi

1. **Raccogli le voci** secondo l'ambito:
   - **tutto**: `<work>/project/2-OPEN-POINTS-TECHNICAL.md` e `3-OPEN-POINTS-CLIENT.md`; gli stessi due file di ogni
     ordine con `Stato: OPEN`; `2-OPEN-POINTS.md` di ogni card aperta;
   - **un ordine**: i suoi due file, e `2-OPEN-POINTS.md` delle card con `Ordine: <id>`;
   - **una card**: il suo `2-OPEN-POINTS.md`, più le voci che la sua riga `Blocked by:` cita, ovunque stiano.

   Ogni voce è un titolo `###`. Nei registri il titolo è `### <codice> — <titolo>`; le voci della card non hanno
   codice.
2. **Trova chi blocca chi.** Leggi la riga `Blocked by:` di ogni `<work>/cards/*/0-CARD.md`. Una voce tiene ferma una
   card se la card cita il suo codice. Un codice citato che non esiste in nessun registro è già risolto: la card, per
   quel codice, è libera.
3. **Stampa una tabella**: codice, titolo, livello (progetto, ordine `<id>`, card `<id>`), tipo (tecnico o
   cliente), card che tiene ferme. Prima le voci che bloccano, cioè quelle citate da una card o che dicono di
   bloccare nel proprio testo; poi le altre, progetto, ordini, card.
4. **In fondo, due controlli**, solo se trovano qualcosa:
   - le card con bloccanti già risolti, che si possono riprendere;
   - i codici citati in `Blocked by:` con un titolo diverso da quello della voce, o che non corrispondono a nessuna
     voce, da correggere a mano.

Non inventare stati o priorità che i file non dicono. Se un file non esiste, quel livello non ha punti aperti.
