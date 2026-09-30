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

1. `SPEC.md` della card: è la `development/*/card/SPEC.md` il cui campo `ID`, nell'intestazione, porta l'Id ricevuto.
   L'intestazione porta anche `BASE`. Se `BASE` è vuoto, o `git -C <repository> rev-parse <base>` non lo risolve,
   fermati e dillo: non ricavare una base dal log.
2. Il resto di `SPEC.md`, per intero, compresa la sezione `Deviazioni` in fondo.
3. La spec del branch della card: il `SPEC.md` della cartella che contiene `card/`, con i suoi criteri, per sapere
   qual è il perimetro.
4. `OPEN-POINTS.md` e `INSTALLATION.md` della card, se esistono.
5. La modifica: `git -C <repository> log --first-parent --no-merges --oneline <base>..HEAD` per l'elenco dei commit
   della card, e `git -C <repository> log --first-parent --no-merges -p <base>..HEAD` per il loro contenuto; poi
   `git -C <repository> status` e `git -C <repository> diff HEAD` per quello che non è ancora committato. Si segue il
   primo genitore e si saltano i merge perché i commit arrivati nel branch con il merge di un altro branch non sono
   lavoro della card.
6. I documenti del repository (architettura, glossario, decisioni, vincoli), ai percorsi scritti nel blocco cardflow
   del `CLAUDE.md` della cartella di lavoro, e la forma delle loro voci in `docs/agents/domain.md`.
7. I file toccati, dove la sola modifica non basta a decidere.

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
6. **Frasi della spec da allineare**: per ogni deviazione che regge, la frase della spec che contraddice e il
   testo che la sostituirebbe. Proponi, non scrivere.
7. **Documenti del repository.** Per ogni decisione, vincolo o termine della spec da portare nei documenti, se supera
   la prova dell'essenziale: una decisione entra solo se un agente, leggendo solo il codice, proporrebbe di rifarlo in
   un altro modo, e dice che cosa è stato scartato e perché, perché il codice non basta a capirla e fino a quando vale.
   Segnala le voci che descrivono soltanto il codice, e come correzione il motivo di un pezzo di codice che il codice
   non spiega e che nessun commento dice. Se la card ha cambiato la struttura, di' che cosa cambia nell'architettura.
   Segnala un documento del repository toccato dalla card che cita `.work` (codici, Id, percorsi) o che non segue la
   lingua e le convenzioni del repository, e una decisione che contraddice un vincolo.
8. **Installazione**: una modifica che un'installazione esistente deve ricevere a mano (schema del database, chiave di
   configurazione, file, servizio) e che non ha la sua voce in `INSTALLATION.md`; una voce che non corrisponde al
   codice; uno script SQL citato che nel repository non c'è, o uno script SQL nella modifica che nessuna voce cita.
   Servi tu, qui, perché sei l'unico che legge tutto il lavoro della card.

Cita la riga della spec per ogni rilievo e dai `file:riga` per ogni riferimento al codice. Se una categoria non
ha nulla, dillo.

## Regole

- **Sola lettura.** Nessuna modifica ai file, nessun comando git che scrive, nessuna build e nessun test: le
  verifiche le fa chi ti ha chiamato.
- Niente rilievi di stile o di standard: li ha già fatti la revisione di ogni ticket.
- Il rapporto è in italiano semplice, un fatto per frase, sotto le 900 parole, raggruppato nelle otto categorie
  e con i rilievi più gravi per primi dentro ciascuna.
