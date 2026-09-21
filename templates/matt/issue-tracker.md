# Issue tracker: cardflow, Markdown locale dentro `.work/`

Le spec e i ticket di questo progetto vivono come file Markdown dentro `.work/`, una cartella che sta fuori dal
repository. Il tracker lo gestisce il plugin cardflow; questo file dice alle skill di ingegneria dove leggere e
dove scrivere. Il metodo completo si riassume con `/cardflow:help`.

Non usare mai `gh` né `glab`. Non creare mai una `.scratch/` alla radice o nel repository: ogni percorso
`.scratch/` che una skill propone diventa la `.scratch/` della card su cui si sta lavorando.

## Dove sta la radice

La radice di `.work/` si legge da `.WORKDIR`, nella cartella di lavoro: una riga sola con un percorso assoluto.
Se il file manca, o il percorso non è assoluto o non esiste, fermati e rimanda a `/cardflow:init`. Nel resto del
documento `<work>` indica quella radice.

## La forma

```text
<work>/orders/<id>-<slug>/0-ORDER.md       l'ordine: Id, titolo, stato, ramo
<work>/cards/<id>-<slug>/0-CARD.md         la card: Id, titolo, stato, priorità, ordine, base, bloccanti
<work>/cards/<id>-<slug>/1-SPEC.md         la spec della card, scritta da /mattpocock-skills:to-spec
<work>/cards/<id>-<slug>/2-OPEN-POINTS.md  i punti aperti della card, se servono
<work>/cards/<id>-<slug>/tickets/NN-<slug>.md
<work>/cards/<id>-<slug>/files/            i file intermedi, se servono
<work>/cards/<id>-<slug>/.scratch/         le note che muoiono con la card
```

Una card o un ordine si indicano con l'Id o con il nome intero della cartella. Se esiste una cartella con quel nome
esatto, è quella; altrimenti è la cartella `<valore>-*` la cui intestazione porta `Id: <valore>`: la card `26258KD`
è `cards/26258KD-pdf-export/`. Nei testi l'Id va con il titolo, «`26258KD` (esportazione in PDF)».

La riga `Blocked by:` di `0-CARD.md` elenca, con codice e titolo, le voci di registro che tengono ferma la card. Un
codice blocca finché esiste come voce `### <codice> —` in un registro `2-` o `3-OPEN-POINTS` di `<work>/project/` o
di un ordine; una voce risolta si cancella, e il blocco sparisce con lei.

## Quando una skill dice «pubblica sul tracker»

**Una spec**, da `/mattpocock-skills:to-spec`. Individua la card: è l'Id nominato nella conversazione, e se non c'è lo chiedi.
Leggi `0-CARD.md`. **Se il campo `Ordine:` è vuoto, fermati**: chiedi a quale ordine assegnare la card e non
scrivere la spec finché non lo ricevi. L'ordine deve esistere e avere `Stato: OPEN`; scrivilo in `Ordine:`, cosa
permessa perché la card è ancora in `BACKLOG`. Se la card ha bloccanti aperti in `Blocked by:`, dillo prima di
scrivere; se l'operatore vuole procedere, si procede. Poi scrivi `cards/<id>-<slug>/1-SPEC.md`. L'intestazione resta in
`0-CARD.md`; le due righe sull'idea sotto di lei si possono togliere. La spec non porta la riga `Status:`: lo
stato della card sta in `0-CARD.md`.

**Dei ticket**, da `/mattpocock-skills:to-tickets`. Scrivili in `cards/<id>-<slug>/tickets/NN-<slug>.md`, numerati da `01` in
ordine di dipendenza, un file per ticket, con la forma locale della skill: la riga `Blocked by:` con i numeri dei
ticket che devono chiudersi prima, e `Status: ready-for-agent`. Non usare `.scratch/<feature>/issues/`. Se
`tickets/` contiene già dei file, la card è già scomposta: non rifare la scomposizione, rivedila.

## Quando una skill dice «recupera il ticket»

Un ticket si cita `<card-id>/NN`: `26258KD/01` è il file `cards/26258KD-*/tickets/01-*.md`. Un numero da solo non è
un ticket e non si passa a `/mattpocock-skills:implement`: si lavora un ticket per conversazione.

## Prima di un ticket

Tre controlli, sempre, prima di toccare il codice.

1. **Bloccanti del ticket.** Per ogni numero in `Blocked by:` del ticket, se il file di quel ticket esiste ancora il
   ticket è aperto: fermati e dillo.
2. **Bloccanti della card.** Se `Blocked by:` di `0-CARD.md` cita voci che esistono ancora in un registro, dillo.
3. **Ramo.** Confronta `Ramo:` in `0-ORDER.md` dell'ordine della card con il ramo attivo del repository. Se sono
   diversi, dillo.

Se l'operatore, avvisato, vuole procedere, si procede: l'avviso viene prima. Sui rami non si fa nessuna
operazione.

Se `Base:` in `0-CARD.md` è vuoto, questo è il primo ticket della card: scrivi in `Base:` lo SHA di `HEAD` del
repository e porta `Stato:` a `DOING`.

## Chiudere un ticket

In quest'ordine.

1. **Revisione** con `/mattpocock-skills:code-review`. Il lavoro del ticket non è ancora committato, quindi la differenza da
   rivedere è quella fra il codice di lavoro e `HEAD` (`git diff HEAD` più i file non tracciati), non un
   intervallo di commit. La spec è `1-SPEC.md` della card.
2. **Deviazioni.** Se l'implementazione si è discostata dalla spec, aggiungi una riga in fondo a `1-SPEC.md`,
   nella sezione `## Deviazioni`, che crei se manca:

   | Ticket | La spec diceva | Si è fatto | Perché |
   |---|---|---|---|

   Il testo della spec non si corregge adesso: la revisione di chiusura deve poter distinguere una scelta da un
   errore.
3. **Commit.** L'agente non committa mai, anche se una skill glielo chiede. Se serve un commit lo dice e propone
   il messaggio: Conventional Commits in inglese (`feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `build`,
   `perf`), una riga sola che dice a grandi linee che cosa porta, senza corpo e senza `Co-Authored-By` o altre
   righe di attribuzione. Poi aspetta che l'operatore dica di aver committato.
4. **Cancellazione.** Solo allora cancella il file del ticket, e togli il suo numero dalle righe `Blocked by:`
   degli altri ticket.

Quando `tickets/` resta vuota, chiedi **«Procediamo con la review e chiudiamo?»** e aspetta. Alla risposta
affermativa la chiusura è `/cardflow:card-done <card-id>`.

## Commenti e note

I commenti a un ticket si appendono in fondo al suo file, sotto `## Comments`. Il ragionamento di una sessione
che non diventa spec né punto aperto va nella `.scratch/` della card, e muore con lei.

## Dove non si scrive mai

Nel repository del codice non nasce nessun file di tracker, di note o di configurazione delle skill. Una cartella
accessoria che una skill voglia creare nasce dentro la card, oppure in `<work>/project/` se non appartiene a una
card.
