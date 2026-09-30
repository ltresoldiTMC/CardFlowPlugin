# cardflow — identificativi

cardflow dà un nome a quattro cose: le card, i ticket, i branch e le voci dei registri. Questa pagina dice come nasce
ciascun identificativo, come si legge e come si cita.

## Le card

L'Id di una card di solito lo **genera** `/cardflow:card-new`; si può anche **dare**, come secondo argomento, quando
viene da fuori, per esempio il numero di una richiesta: `/cardflow:card-new main CR2606`. In entrambi i casi il plugin
controlla che sia libero prima di usarlo.

### L'Id generato

```text
26264VV
││└┬┘└┴─ ora del giorno, in una di 529 fasce di circa 163 secondi
││ └──── giorno dell'anno, 001–366 (data ordinale ISO 8601)
└┴────── anno, due cifre
```

Tutto è in **tempo universale (UTC)**. Le due lettere vengono da un alfabeto di 23: le lettere dalla `A` alla `Z`
senza `I`, `L` e `O`, che si confondono con `1` e `0`.

| A | B | C | D | E | F | G | H | J | K | M | N | P | Q | R | S | T | U | V | W | X | Y | Z |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 |

La fascia è `prima lettera × 23 + seconda lettera`. Per leggere `26264VV`: anno 2026, giorno 264, cioè il 21
settembre; la fascia è `18 × 23 + 18 = 432`, e cominciava alle 19:35:57 UTC. Nessuno ha bisogno di fare il conto
a mano: serve solo a sapere che le lettere codificano un orario.

L'Id è fatto così per quattro ragioni:

- **si ordina da solo.** Tutti gli Id generati hanno la stessa lunghezza, e dopo la data vengono solo lettere in
  ordine alfabetico. L'ordine alfabetico coincide quindi con quello di creazione, anche in Esplora risorse e in VS
  Code, che leggono le cifre come numeri: una cifra subito dopo la data si fonderebbe con lei e manderebbe il file in
  fondo;
- **la data si legge**: le prime cinque cifre dicono l'anno e il giorno;
- **è corto**: sette caratteri, da dire a voce o da scrivere a mano;
- **è sicuro su qualunque disco**: solo maiuscole, perché l'Id dà il nome agli handover e Windows non distingue `a`
  da `A` nei nomi dei file.

**Scartato.** La data `AAMMGG` con un suffisso `-2` per la seconda card del giorno, che dava lunghezze diverse. Un
tempo Unix in base 36, illeggibile e da calcolare. Cifre dopo la data, che rompono l'ordinamento naturale. Un hash,
che per costruzione disperde l'ordine. Lettere casuali, che perdono l'ordine fra le card dello stesso giorno.

### Come nasce, e quando è preso

L'Id lo produce lo script `scripts/new-id.sh` del plugin, mai l'agente a mente: contare i giorni dell'anno e
convertire un orario sono calcoli che un modello sbaglia.

```bash
bash scripts/new-id.sh <radice di .work>            # genera un Id libero
bash scripts/new-id.sh <radice di .work> CR2606     # controlla un Id scelto e lo restituisce
```

Un Id è **preso** quando:

- lo porta il campo `ID` di una card in corso, in `development/*/card/SPEC.md`;
- esiste un handover con quell'Id, in `development/*/handovers/` (le card chiuse di un branch non ancora unito) o in
  `deploy/handovers/*/` (le card chiuse già arrivate sul branch principale);
- il diario lo cita. Il diario ricorda le card eliminate, che non hanno un handover: senza questo controllo, l'Id di
  una card eliminata si potrebbe riprendere a mano.

Se la fascia di adesso è presa, lo script passa alla successiva: l'Id resta unico e resta dopo quello già esistente,
quindi l'ordine regge. Il caso capita solo con due card create a meno di tre minuti l'una dall'altra.

Un Id scelto può contenere lettere, cifre, punti e trattini singoli; niente spazi e niente `/`. Lo script si
verifica con `bash scripts/new-id.test.sh`.

**Una conseguenza dell'UTC.** In Italia il giorno UTC comincia all'una d'inverno e alle due d'estate: una card
creata poco dopo la mezzanotte porta la data del giorno prima.

### La cartella

La card sta sempre nella cartella `card/` del suo branch, e un branch ne ha al massimo una. L'Id vive solo nel campo
`ID` dell'intestazione di `SPEC.md`: la card `26264VV` è la `development/*/card/` il cui `SPEC.md` porta
`ID: 26264VV`. Quando la card si chiude, il suo handover prende il nome `<id>-<slug>.md`, con uno slug breve, in
inglese, ricavato dal titolo: `26264VV-invoice-email.md`.

## Come si citano

**Nei comandi** si passa l'Id della card oppure il branch: `/cardflow:card-done 26264VV` e
`/cardflow:card-done feature/cr0412-invoices` fanno la stessa cosa, se la card è quella. Senza argomento vale il branch
attivo.

**Nei documenti** si scrivono l'Id e il titolo insieme: «`26264VV` (invio delle fatture per email)». Mai il percorso:
una card chiusa sparisce, e il suo Id resta nel diario e nel suo handover.

## Ticket

Un ticket si cita `<card-id>/NN`: `26264VV/01` è il primo ticket della card `26264VV`. I numeri partono da `01`
dentro `tickets/` della card, in ordine di dipendenza. È l'unico riferimento composto del metodo.

## I branch

Un branch non ha un Id: il suo nome è quello di git, e sta nel campo `BRANCH` della spec. La cartella ne deriva, con
ogni `/` sostituito da `-`, e la trova lo script `work.sh branch-dir`. Nei comandi un branch si passa con il suo nome
o con quello della sua cartella.

## Voci dei registri

I punti tecnici, le domande e le migliorie hanno un codice. La lettera dice il tipo della voce, non il file in cui sta:
una voce che sale dal registro di un branch a quello comune tiene il suo codice.

| Famiglia | Voce | Registro |
|---|---|---|
| `T` | punto tecnico | `control/open-points-technical.md`, o quello di un branch |
| `Q` | domanda a chi sta fuori | `control/open-points-client.md` |
| `MP` | miglioria di prodotto | `control/improvements.md` |
| `MS` | miglioria di sistema | `control/improvements.md` |

Decisioni, vincoli e termini non hanno codice: stanno nei documenti del repository e si citano per titolo. I punti
aperti di una card non hanno codice: lo prendono quando la card si chiude.

### La forma

```text
Q26272Kb
│└┬┘└┬┘└┴─ ora del giorno, in una di 2116 fasce di circa 41 secondi
│ │  └──── giorno dell'anno, 001–366
│ └─────── anno, due cifre
└───────── famiglia
```

Le due lettere vengono da un alfabeto di 46: le stesse 23 maiuscole degli Id delle card, seguite dalle 23 minuscole
senza `i`, `l` e `o`. La fascia è `prima lettera × 46 + seconda lettera`. Per leggere `Q26272Kb`: una domanda nata il
29 settembre 2026, nella fascia `9 × 46 + 24 = 438`, che cominciava alle 04:58:04 UTC.

Le minuscole portano la precisione a circa 41 secondi senza allungare il codice. Stanno solo nei codici, e non negli Id
delle card, perché un codice non dà mai il nome a un file o a una cartella. Le maiuscole vengono prima delle
minuscole, come nell'ordine dei byte, quindi i codici si ordinano per data di nascita.

**Le maiuscole contano**: `Q26272Kb` e `Q26272KB` sono due codici diversi. Quando una skill trova citato un codice
che non esiste, cerca quello che differisce solo per le maiuscole e lo propone: «forse intendevi `Q26272Kb`?». Così un
errore di copiatura non passa in silenzio.

### Unico per costruzione

Il codice lo genera lo script, mai l'agente a mente:

```bash
bash scripts/new-id.sh <radice di .work> --code Q        # una domanda
bash scripts/new-id.sh <radice di .work> --code T 3      # tre punti tecnici, in fasce consecutive
```

Un codice è preso quando compare esatto, come parola intera, in un file di `.work` fuori da `notes/`, e in quel caso
lo script passa alla fascia successiva. Una voce chiusa sparisce dal suo registro, ma il diario la ricorda, quindi il
suo codice resta preso. Poiché la data sta dentro il codice, un codice non torna mai, e non serve nessuna regola sul
riuso. Una chiusura che crea più voci chiede tutti i codici in una volta.

### I codici di un metodo precedente

Un progetto che arriva da un metodo precedente converte i suoi codici alla migrazione: ogni voce prende un codice
nuovo dallo script, e ogni citazione si corregge in tutto `.work`, fuori da `notes/` e dai documenti di altri. La
sostituzione cerca il codice come parola intera, perché `Q1` non deve colpire `Q10`. La voce di diario della
migrazione conserva la corrispondenza fra codici vecchi e nuovi, per chi ritrova un codice vecchio in un appunto o in
una mail. Da quel momento nel progetto esiste una forma sola.

### Come si citano

Una voce si cita sempre con il codice e il titolo: «`Q26255Kb` (formato delle date accettato dal gestionale)». Il
codice serve a ritrovare la voce, il titolo a capirla. Vale anche nel diario e nei campi dell'intestazione.

## Blocked by

Il meccanismo viene dai ticket. Ogni ticket ha la riga `Blocked by:` con i ticket che devono chiudersi prima, e un
bloccante è aperto finché il suo file esiste: chiuso il ticket, il file si cancella e il blocco sparisce da solo.

Una card usa lo stesso meccanismo nel campo `BLOCKED BY` della sua intestazione, con i codici e i titoli dei punti
aperti che la tengono ferma, separati da virgole:

```text
BLOCKED BY: Q26255Kb (formato delle date accettato dal gestionale)
```

Una voce del backlog fa lo stesso con la nota `Bloccato da:`, e quando `card-new` la prende la nota diventa il campo
`BLOCKED BY` della card.

La logica è la stessa, perché nei registri una voce risolta si cancella: il blocco resta aperto finché esiste un
titolo `### <codice> —` in un registro dei punti aperti, di `control/` o di un branch, e sparisce quando la voce se ne
va. Vuoto vuol dire che la card può procedere.

`/cardflow:status` mostra i bloccanti ancora aperti della card e del backlog di un branch, e `/cardflow:open-points`
dice, per ogni voce, che cosa tiene fermo. Prima della spec e prima di un ticket l'agente avvisa se la card ha
bloccanti aperti; se l'operatore vuole procedere si procede, ma l'avviso viene prima.
