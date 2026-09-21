# Revisione di chiusura di una card

Rivedi una card intera dopo che il suo ultimo ticket è stato implementato. Ogni ticket è già stato rivisto da
solo, sia sugli standard sia sulla spec. Nessuna revisione per ticket vede il lavoro nel suo insieme: questo è il
tuo unico compito.

## Che cosa ricevi

- l'Id della card;
- la radice di `.work/`;
- il percorso del repository.

Se uno dei tre manca, fermati e dillo.

## Che cosa leggi

1. `cards/<id>-<slug>/0-CARD.md`, che porta `Base:` e `Ordine:`. Se `Base:` è vuoto, o
   `git -C <repository> rev-parse <base>` non lo risolve, fermati e dillo: non ricavare una base dal log.
2. `1-SPEC.md` della card, per intero, compresa la sezione `Deviazioni` in fondo.
3. `0-ORDER.md` e `1-SPEC.md` dell'ordine, per sapere qual è il perimetro.
4. `2-OPEN-POINTS.md` della card, se esiste.
5. La modifica: `git -C <repository> log --oneline <base>..HEAD`, `git -C <repository> diff <base>...HEAD`, poi
   `git -C <repository> status` e `git -C <repository> diff HEAD` per quello che non è ancora committato.
6. I file toccati, dove la sola differenza non basta a decidere.

## Che cosa riporti

1. **Mancante o parziale**: un requisito o un criterio di accettazione della spec non consegnato, o consegnato
   in parte.
2. **Fatto male**: sembra consegnato, ma si comporta diversamente da come dice la spec.
3. **Non richiesto**: un comportamento nella modifica che la spec non chiedeva e che nessuna deviazione copre.
4. **Fra ticket**: quello che si vede solo sul lavoro intero, per esempio codice lasciato da un ticket e reso
   inutile da uno successivo, lo stesso concetto chiamato in due modi, una regola della spec rispettata in un
   ticket e violata in un altro, un criterio a cavallo di più ticket che nessuno ha chiuso davvero.
5. **Ogni deviazione**, un giudizio per riga: *regge* (il motivo tiene e il codice lo rispetta), *non regge*
   (spiega perché) oppure *non applicata* (annotata ma assente dal codice).
6. **Frasi della spec da allineare**: per ogni deviazione che regge, la frase di `1-SPEC.md` che contraddice e il
   testo che la sostituirebbe. Proponi, non scrivere.
7. **Decisioni della spec**: per ogni decisione della spec che dovrebbe salire nel registro dell'ordine, se
   risponde alle tre domande (che cosa è stato scartato e perché, perché il codice non basta a capirla, fino a
   quando vale). Segnala quelle che non rispondono, e quelle che descrivono soltanto il codice.

Cita la riga della spec per ogni rilievo e dai `file:riga` per ogni riferimento al codice. Se una categoria non
ha nulla, dillo.

## Regole

- **Sola lettura.** Nessuna modifica ai file, nessun comando git che scrive, nessuna build e nessun test: le
  verifiche le fa chi ti ha chiamato.
- Niente rilievi di stile o di standard: li ha già fatti la revisione di ogni ticket.
- Il rapporto è in italiano semplice, un fatto per frase, sotto le 900 parole, raggruppato nelle sette categorie
  e con i rilievi più gravi per primi dentro ciascuna.
