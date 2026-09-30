# Issue tracker: cardflow, Markdown locale dentro `.work/`

Le spec e i ticket di questo progetto vivono come file Markdown dentro `.work/`, una cartella che sta fuori dal
repository. Il tracker lo gestisce il plugin cardflow; questo file dice alle skill di ingegneria dove leggere e
dove scrivere. Il metodo completo si riassume con `/cardflow:help`.

Non usare mai `gh` né `glab`. Non creare mai una `.scratch/` alla radice o nel repository: ogni percorso
`.scratch/` che una skill propone diventa la `.scratch/` della card su cui si sta lavorando.

## Dove sta la radice

La radice di `.work/` si legge da `.WORKDIR`, nella cartella di lavoro: una riga sola con un percorso assoluto.
Se il file manca, o il percorso non è assoluto o non esiste, fermati e rimanda a `/cardflow:init`. Nel resto del
documento `<work>` indica quella radice. Il repository e il branch principale stanno nel blocco cardflow del
`CLAUDE.md`; il branch attivo si legge con `git -C <repository> branch --show-current`.

## La forma

```text
<work>/development/<cartella>/SPEC.md                  la spec del branch: BRANCH, TITOLO, obiettivo, criteri
<work>/development/<cartella>/backlog.md               le cose da fare nel branch, in ordine di priorità
<work>/development/<cartella>/card/SPEC.md             la card: ID, TITOLO, BASE, BLOCKED BY, poi la spec
<work>/development/<cartella>/card/tickets/NN-<slug>.md
<work>/development/<cartella>/card/OPEN-POINTS.md      i punti aperti della card, se servono
<work>/development/<cartella>/card/INSTALLATION.md     i passi di installazione della card, se servono
<work>/development/<cartella>/card/files/              i file di lavoro, se servono
<work>/development/<cartella>/card/.scratch/           le note che muoiono con la card
```

La cartella di un branch è quella il cui `SPEC.md` porta il nome esatto del branch nel campo `BRANCH`; il branch
principale, finché la sua spec non esiste, ha la cartella che porta il suo nome.

**Un branch ha al massimo una card**, perché due sviluppi sullo stesso branch mescolerebbero i loro commit. La card si
indica con l'Id o con il branch: la card `26285HT` è la `<work>/development/*/card/` il cui `SPEC.md` porta
`ID: 26285HT` nell'intestazione. Nei testi l'Id va con il titolo, «`26285HT` (validazione dello schema XML)».

Il campo `BLOCKED BY` dell'intestazione elenca, con codice e titolo, i punti aperti che tengono ferma la card. Un codice
blocca finché esiste come titolo `### <codice> —` in un registro dei punti aperti: `<work>/control/open-points-technical.md`,
`<work>/control/open-points-client.md` o il `open-points-technical.md` di un branch. Una voce risolta si cancella, e il
blocco sparisce con lei.

## Quando una skill dice «pubblica sul tracker»

**Una spec**, da `/mattpocock-skills:to-spec`. La card è quella del branch attivo, oppure quella dell'Id nominato
nella conversazione. Se il branch non ha una card, fermati e proponi `/cardflow:card-new`. Se la card ha bloccanti
aperti in `BLOCKED BY`, dillo prima di scrivere; se l'operatore vuole procedere, si procede.

Poi aggiungi la spec a `card/SPEC.md` **con Edit**, sotto la riga `---` che chiude l'intestazione. Le righe fra i due
`---` restano come sono; le righe sull'idea, sotto l'intestazione, si possono sostituire. **Mai Write su `SPEC.md`**:
riscriverebbe il file intero e perderebbe l'intestazione. La spec non porta la riga `Status:`.

**Dei ticket**, da `/mattpocock-skills:to-tickets`. Scrivili in `card/tickets/NN-<slug>.md`, numerati da `01` in
ordine di dipendenza, un file per ticket, con la forma locale della skill: la riga `Blocked by:` con i numeri dei
ticket che devono chiudersi prima, e `Status: ready-for-agent`. Non usare `.scratch/<feature>/issues/`. Se
`tickets/` contiene già dei file, la card è già scomposta: non rifare la scomposizione, rivedila.

## Quando una skill dice «recupera il ticket»

Un ticket si cita `<card-id>/NN`: `26285HT/01` è il file `tickets/01-*.md` della card con quell'Id. Un numero da solo
non è un ticket e non si passa a `/mattpocock-skills:implement`: si lavora un ticket per conversazione.

## Prima di un ticket

Tre controlli, sempre, prima di toccare il codice.

1. **Bloccanti del ticket.** Per ogni numero in `Blocked by:` del ticket, se il file di quel ticket esiste ancora il
   ticket è aperto: fermati e dillo.
2. **Bloccanti della card.** Per ogni codice in `BLOCKED BY` della card, cerca il titolo `### <codice> —` nei registri
   dei punti aperti elencati sopra. Se uno esiste, il bloccante è aperto: fermati e dillo.
3. **Branch.** Se il branch attivo non è il `BRANCH` della cartella che contiene la card, dillo: il lavoro della card
   descriverebbe codice che su quel branch non c'è.

Se l'operatore, avvisato, vuole procedere, si procede: l'avviso viene prima. Sui branch non si fa nessuna
operazione.

Se `BASE` nell'intestazione è vuoto, questo è il primo ticket della card: scrivi in `BASE` lo SHA di `HEAD` del
repository.

## Chiudere un ticket

In quest'ordine.

1. **Revisione** con `/mattpocock-skills:code-review`. Il lavoro del ticket non è ancora committato, quindi la differenza da
   rivedere è quella fra il codice di lavoro e `HEAD` (`git diff HEAD` più i file non tracciati), non un
   intervallo di commit. La spec è `card/SPEC.md`.
2. **Deviazioni.** Se l'implementazione si è discostata dalla spec, aggiungi una riga in fondo a `card/SPEC.md`,
   nella sezione `## Deviazioni`, che crei se manca:

   | Ticket | La spec diceva | Si è fatto | Perché |
   |---|---|---|---|

   Il testo della spec non si corregge adesso: la revisione di chiusura deve poter distinguere una scelta da un
   errore.
3. **Installazione.** Se il ticket introduce qualcosa che un'installazione esistente deve ricevere a mano (una tabella
   o una colonna del database, una chiave di configurazione, un file, un servizio), scrivi o riscrivi la sua voce in
   `card/INSTALLATION.md`: una voce `### <che cosa>` per ogni cosa toccata, con il passo e il modo di verificarlo,
   nell'ordine in cui si eseguono. Se la cosa ha già una voce, riscrivila con lo stato finale. Un aggiornamento del
   database è uno script SQL nel repository, scritto dal ticket, e la voce ne cita il percorso; un passo su un file di
   configurazione dice sezione, chiave e valore. Il passo si scrive qui perché è qui che si sa: la chiusura della card
   lo verifica soltanto.
4. **Commit.** L'agente non committa mai, anche se una skill glielo chiede. Se serve un commit lo dice e propone
   il messaggio: Conventional Commits in inglese (`feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `build`,
   `perf`), una riga sola che dice a grandi linee che cosa porta, senza corpo e senza `Co-Authored-By` o altre
   righe di attribuzione. Poi aspetta che l'operatore dica di aver committato.
5. **Cancellazione.** Solo allora cancella il file del ticket, e togli il suo numero dalle righe `Blocked by:`
   degli altri ticket.

Quando `tickets/` resta vuota, chiedi **«Procediamo con la review e chiudiamo?»** e aspetta. Alla risposta
affermativa la chiusura è `/cardflow:card-done`.

## Durante il lavoro

Nessun registro, nessun documento del repository (architettura, glossario, decisioni, vincoli) e nessun file di
`.work` fuori dalla card si tocca: un documento aggiornato a metà lavoro descrive un'intenzione, non un fatto. Quello
che emerge resta nella card, e `/cardflow:card-done` lo porta al suo posto:

- una domanda senza risposta va in `OPEN-POINTS.md`, come voce `### <titolo>` senza codice;
- una decisione o un termine vanno nella spec, oppure in `.scratch/` se la spec non esiste ancora;
- un vincolo, un fatto esterno, un'idea di miglioria vanno in `.scratch/`;
- un file di lavoro (un'estrazione, un campione, uno script di analisi) va in `files/`.

Una risposta del cliente che arriva mentre si lavora si registra con `/cardflow:journal`.

## Commenti e note

I commenti a un ticket si appendono in fondo al suo file, sotto `## Comments`. Il ragionamento di una sessione
che non diventa spec né punto aperto va nella `.scratch/` della card, e muore con lei.

## Dove non si scrive mai

Nel repository del codice non nasce nessun file di tracker, di note o di configurazione delle skill. Una cartella
accessoria che una skill voglia creare nasce dentro la card. Mai in `<work>/notes/`, che è dell'operatore.
