# cardflow — manuale

**Versione del metodo: v1.**

## A che cosa serve

cardflow organizza lo sviluppo di un progetto quando il lavoro dura più di una sessione. Tiene insieme due casi che
finora avevano bisogno di regole diverse: il progetto in sviluppo continuo, dove si procede per release, e la CR
concordata con il cliente, con una spec e spesso un ramo proprio.

Il metodo vive in una cartella `.work/` che sta **fuori dal repository**: non è versionata, non lascia tracce nel
codice del cliente, e resta la stessa qualunque ramo sia attivo. Dentro ci sono tre cose, ciascuna con un compito
solo: il **progetto** conserva quello che vale per sempre, l'**ordine** dice che cosa si deve fare e dove, la
**card** è un blocco di sviluppo.

Il lavoro dentro una card lo fanno le skill di Matt Pocock: grilling, spec, ticket, implementazione, revisione.
cardflow non le sostituisce, aggiunge il livello sopra, che loro non conoscono.

## I tre livelli

| Livello | Che cos'è | Esempio | Vita |
|---|---|---|---|
| **Progetto** | quello che resta vero oltre ogni ordine: termini, decisioni in vigore, vincoli, migliorie, punti aperti, conoscenza dei sistemi esterni | — | quanto il progetto |
| **Ordine** | un impegno: una CR o una release. Dice che cosa fare, con quali criteri, su quale ramo | `CR0412-invoice-export`, `V2.0.0-release` | settimane o mesi; a fine vita resta, chiuso |
| **Card** | un blocco di sviluppo: nasce da un'idea, passa per il grilling, diventa spec e ticket, si chiude con una revisione | `260916-pdf-export` | giorni; alla chiusura si comprime nell'archivio dell'ordine |

Sotto la card ci sono i **ticket** di Matt: fette implementabili in una sessione, cancellate quando sono fatte.

Una card senza ordine è **backlog**: un'idea che si può esplorare ma non costruire. Se ne può fare il grilling, ma
non se ne può scrivere la spec finché non la si assegna a un ordine, perché una spec è un impegno e ha bisogno di un
perimetro.

## La struttura

```text
.work/
  project/
    2-OPEN-POINTS-TECHNICAL.md
    3-OPEN-POINTS-CLIENT.md
    4-DECISIONS.md
    6-GLOSSARY.md
    7-CONSTRAINTS.md
    8-IMPROVEMENTS.md
    9-MEETINGS.md
    knowledge/            analisi di sistemi esterni e legacy, schema DB, protocolli, come si prova
    sources/              documenti del cliente che non appartengono a un ordine, template
    resources/            file vivi usati da più card: mock, dati di prova
  orders/
    CR0412-invoice-export/
      0-ORDER.md
      1-SPEC.md
      2-OPEN-POINTS-TECHNICAL.md     se serve
      3-OPEN-POINTS-CLIENT.md        se serve
      4-DECISIONS.md                 se serve
      5-DELIVERY.md                  raro, solo se chiesto alla chiusura
      sources/                       file del cliente per quest'ordine, sola lettura
      archive/
        260916-pdf-export/
          5-HANDOVER.md
  cards/
    260916-pdf-export/
      0-CARD.md
      1-SPEC.md                      scritto da /mattpocock-skills:to-spec
      2-OPEN-POINTS.md               se serve
      tickets/
        01-<slug>.md
        02-<slug>.md
      files/                         file intermedi, se servono
      .scratch/                      note che muoiono con la card
```

Nessuna cartella si crea in anticipo: un documento o una sottocartella nascono quando c'è qualcosa da metterci. Nei
nomi non ci sono spazi, perché rompono i comandi, i link e le ricerche.

Due puntatori tengono insieme il progetto, e li scrive entrambi `/cardflow:init`. `.WORKDIR`, nella cartella da cui
parte Claude Code, contiene il percorso assoluto di `.work/`. Il blocco cardflow nel `CLAUDE.md` di progetto contiene
il percorso del repository, che serve per leggere il ramo attivo e la differenza da rivedere.

## I numeri dei documenti

Il numero davanti al nome è **fisso per tipo di documento, a ogni livello**. «Il 4» vuol dire decisioni nel
progetto, nell'ordine e ovunque compaia; un numero che manca in una cartella dice che quel documento lì non c'è. Il
numero dà anche l'ordine di lettura dall'alto in basso.

| Nr | Documento | Progetto | Ordine | Card |
|---|---|---|---|---|
| 0 | intestazione: `ORDER`, `CARD` | — | sì | sì |
| 1 | `SPEC` | — | sì | sì |
| 2 | punti aperti tecnici (nella card: `OPEN-POINTS`) | sì | se serve | se serve |
| 3 | punti aperti per il cliente | sì | se serve | — |
| 4 | `DECISIONS` | sì | se serve | — |
| 5 | documento di fine vita: `DELIVERY` per l'ordine, `HANDOVER` per la card | — | raro | alla chiusura |
| 6 | `GLOSSARY` | sì | — | — |
| 7 | `CONSTRAINTS` | sì | — | — |
| 8 | `IMPROVEMENTS` | sì | — | — |
| 9 | `MEETINGS` | sì | — | — |

## Identificativi e intestazioni

**Ordine.** L'identificativo viene da fuori: il numero della CR o il nome della release. La cartella è
`<id>-<slug>`.

```text
Id: CR0412
Titolo: Esportazione delle fatture
Stato: OPEN
Ramo: cr0412-invoices
```

`Stato` vale `OPEN` o `DONE`. Il ramo è scritto **solo qui**: le card dell'ordine lo ereditano.

**Card.** L'identificativo è la data di creazione, `YYMMdd`; dalla seconda card dello stesso giorno si aggiunge un
suffisso: `260916`, `260916-2`. La cartella è `<id>-<slug>`.

```text
Id: 260916
Titolo: Esportazione in PDF
Stato: BACKLOG
Priorità: alta
Ordine: CR0412
Base:
```

| Campo | Valori e regole |
|---|---|
| `Stato` | `BACKLOG`, `DOING`, `DONE`. Con `Ordine` vuoto lo stato è per forza `BACKLOG`. `DONE` non si scrive: una card chiusa vive solo nell'archivio del suo ordine, con il suo handover |
| `Priorità` | `alta`, `media`, `bassa`. A parità vince l'Id più vecchio |
| `Ordine` | vuoto vuol dire backlog libero. **Si cambia solo finché la card è in `BACKLOG`** |
| `Base` | il commit da cui parte il lavoro. Lo scrive il primo ticket, non prima: fra la nascita della card e il primo ticket possono passare giorni, e altri commit finirebbero nella revisione |

Nel backlog, sotto l'intestazione di `0-CARD.md` stanno due righe sull'idea. Quando nasce `1-SPEC.md`,
l'intestazione resta e le due righe si possono togliere.

Una card o un ordine **si citano per Id**, mai per percorso: una card chiusa cambia cartella, l'Id resta. L'Id si
legge dall'intestazione, non dal nome della cartella.

**Codici delle voci.** I punti aperti e le decisioni hanno un codice: `T` per i punti tecnici, `C` per quelli del
cliente, `D` per le decisioni. Il codice è unico in tutto il progetto, perché il prossimo è il più alto già usato
in `project/` e in ogni ordine, più uno; e non cambia quando la voce sale dall'ordine al progetto. I punti aperti
della card non hanno codice: lo prendono quando salgono all'ordine. Glossario, vincoli e migliorie non hanno codice
e si citano per titolo.

## Il percorso

### Aprire un ordine

`/cardflow:order-new` chiede Id, slug, titolo e ramo; crea la cartella con `0-ORDER.md` e `1-SPEC.md` (che cosa
fare e i criteri di accettazione) e, se ci sono, mette i file del cliente in `sources/`.

### Una card, dalla nascita alla chiusura

| # | Passo | Che cosa succede |
|---|---|---|
| 1 | `/cardflow:card-new` | chiede titolo, priorità, ordine (anche nessuno) e due righe sull'idea. Crea `cards/<id>-<slug>/0-CARD.md` |
| 2 | `/mattpocock-skills:grill-with-docs` | intervista sulla card, anche se è nel backlog. Quello che emerge resta **nella card**: punti aperti in `2-OPEN-POINTS.md`, il resto in `.scratch/`. Nessun registro di progetto si tocca |
| 3 | `/mattpocock-skills:to-spec` | **se la card non ha un ordine, chiede quale e si ferma** finché non lo riceve. Scrive `1-SPEC.md` |
| 4 | `/mattpocock-skills:to-tickets` | scrive i ticket in `tickets/`, ciascuno con la riga `Blocked by:` |
| — | `/clear` | i passi 2–4 stanno nella stessa conversazione; poi si svuota il contesto |
| 5 | `/mattpocock-skills:implement <card-id>/01` | un ticket per conversazione, svuotando il contesto fra l'uno e l'altro. Vedi sotto |
| 6 | dopo l'ultimo ticket | l'agente chiede **«Procediamo con la review e chiudiamo?»** e aspetta |
| 7 | `/cardflow:card-done <card-id>` | la chiusura, vedi sotto. Dopo il «sì» del passo 6 la può avviare l'agente |

`/cardflow:card-list` stampa in tabella le card aperte con stato, priorità, ordine, ramo e ticket rimasti, e segnala
quelle in corso su un ramo diverso da quello attivo. `/cardflow:card-assign <card-id> <order-id>` assegna a un
ordine una card in `BACKLOG`; con `-` al posto dell'ordine la riporta nel backlog libero.

### Un ticket

Prima di cominciare, due controlli. Se un ticket citato in `Blocked by:` esiste ancora, è aperto: ci si ferma e lo
si dice. Se il ramo attivo non è quello dell'ordine, lo si dice. In entrambi i casi, se l'operatore vuole procedere
si procede, ma l'avviso viene prima.

Il primo ticket della card scrive `Base:` e porta la card a `DOING`.

Il ticket si chiude in quest'ordine. Prima la revisione di Matt, `/mattpocock-skills:code-review`: il lavoro non è
ancora committato, quindi si rivede la differenza fra il codice di lavoro e `HEAD`. Poi, se l'implementazione si è
discostata dalla spec, la differenza si annota in fondo a `1-SPEC.md`, nella sezione **Deviazioni**: che cosa diceva
la spec, che cosa si è fatto, perché. Il testo della spec non si corregge in quel momento: la revisione finale deve
poter distinguere una scelta da un errore.

Poi il commit, se serve. **L'agente non committa mai**, nemmeno quando `/mattpocock-skills:implement` glielo chiede:
il blocco cardflow nel `CLAUDE.md` lo vieta. Dice che serve un commit e propone il messaggio: Conventional Commits in
inglese (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`…), una riga sola che dice a grandi linee che cosa
porta il commit, senza corpo e senza `Co-Authored-By` o altre righe di attribuzione, anche se lo strumento le chiede.
L'operatore committa e lo dice; solo allora il file del ticket si cancella.

```text
feat(invoices): add PDF export
```

### Chiudere una card

`/cardflow:card-done` fa, in quest'ordine:

1. **Revisione dell'intera card.** Un agente con ragionamento profondo legge tutta la differenza da `Base:` e la
   confronta con `1-SPEC.md`: requisiti mancanti o sbagliati, cose non richieste, incoerenze che si vedono solo sul
   lavoro intero, un giudizio su ogni deviazione, e le decisioni della spec che non superano le tre domande. Non
   rivede lo stile, che ha già visto la revisione di ogni ticket. Legge soltanto e riporta.
2. **Correzioni**, decise dall'operatore e verificate; il commit segue la stessa regola dei ticket.
3. **Allineamento della spec**: solo adesso `1-SPEC.md` recepisce le deviazioni giudicate valide.
4. **Salita nei registri**, chiedendo prima di scrivere. I punti ancora aperti vanno in `2-` o `3-OPEN-POINTS`
   dell'ordine; le decisioni della spec vanno in `4-DECISIONS` dell'ordine, e ognuna deve superare il criterio
   descritto più sotto; termini, vincoli e migliorie emersi nella card vanno in `6-`, `7-` e `8-` del progetto,
   che esistono solo lì.
5. **I file intermedi.** Per ciascuno si chiede se **tenerlo vivo** (nel repository se è un dato di prova vero,
   altrimenti in `project/resources/`), **archiviarlo** con la card, o **cancellarlo**.
6. **`5-HANDOVER.md`**, scritto per l'operatore.
7. **Archiviazione**: la cartella della card diventa `orders/<ordine>/archive/<card-id>-<slug>/` e contiene solo
   `5-HANDOVER.md` e i file archiviati. Tutto il resto si cancella.

### Chiudere un ordine

`/cardflow:order-close <order-id>` verifica i criteri di `1-SPEC.md`, poi per ogni card dell'ordine ancora aperta
chiede: **backlog** (l'ordine si svuota), **elimina** (si cancella la card, non il codice già committato) o **altro
ordine**. È l'unico momento in cui una card già iniziata cambia ordine.

Poi porta nel progetto i registri dell'ordine, voce per voce: ognuna sale o si cancella. Chiede se serve una
consegna, e solo in quel caso scrive `5-DELIVERY.md`, raccogliendo le modifiche dagli handover dell'archivio e gli
script se ci sono. Infine segna `Stato: DONE`. La cartella dell'ordine resta: è la traccia di quello che è stato
fatto.

Nessuna chiusura, né di card né di ordine, fa operazioni sui rami.

## L'handover

È la scheda con cui l'operatore tiene sotto controllo il lavoro fatto, come un senior con quello di un junior, e con
cui sa spiegarlo senza riaprire il codice. Non va al cliente.

In testa porta l'intervallo di commit `Base..HEAD`: è una fotografia di quel momento e lo dichiara, così non mente
quando più avanti un'altra card toccherà lo stesso codice.

Le sezioni sono fisse: che cosa fa ora; che cosa è stato toccato e come, con i nomi reali di file, classi e chiavi
verificati sul codice; perché, con il riferimento alle decisioni; come si prova; che cosa è ancora finto o parziale;
l'installazione, solo se servono passi manuali. Non racconta come ci si è arrivati.

## I registri

I registri sono i documenti che durano: punti aperti (2 e 3), decisioni (4), glossario (6), vincoli (7), migliorie
(8) e incontri (9). Ognuno porta in testa, in un commento, la regola per scriverci, che vale anche per chi lo
modifica a mano.

**Una voce, un titolo.** Ogni voce è un titolo `###` seguito da poche righe. Una o due frasi bastano quasi sempre, e
devono bastare a capire la voce anche fra mesi; il testo si allunga solo se servono esempi o riferimenti.

**Niente storico.** Una voce fatta o superata si riscrive al suo posto, si modifica o si cancella. Il registro non
tiene mai due voci contrapposte e non conserva la storia di come si è arrivati alla voce di oggi. Se c'è il rischio
di tornare alla scelta vecchia, una riga nella voce dice perché non farlo. Vale per ogni registro, e soprattutto per
le decisioni.

### Punti aperti

Ogni punto ha un titolo con il suo codice e, se serve, qualche riga di dettaglio: abbastanza da non perdere
l'informazione, poco abbastanza da restare leggibile.

```text
### T12 — Formato delle date nell'esportazione
Il gestionale del cliente accetta solo date ISO? Senza conferma, l'esportazione usa il formato locale. Chiesto al
cliente in C3.

### T15 — Timeout della connessione al database
```

L'agente aggiunge un punto quando lo scopre, rilegge il file prima di scrivere e modifica una voce alla volta, così
le correzioni dell'operatore non si perdono. Durante il lavoro su una card il punto va nella card; nei registri
dell'ordine e del progetto arriva alla chiusura. Una voce scritta a mano senza codice lo riceve al passaggio
successivo. Un punto risolto si **cancella**, dopo che il suo contenuto è arrivato dove deve stare.

I punti per il cliente sono scritti per chi risponde senza conoscere il codice: il contesto, la domanda, le risposte
possibili con la loro conseguenza, che cosa resta fermo nel frattempo. Citano il codice del punto tecnico da cui
nascono, e una risposta li chiude insieme a lui.

### Decisioni

Una voce entra in `4-DECISIONS` solo se risponde a tre domande:

1. **Che cosa è stato scartato, e perché.** Una scelta senza alternativa non è una decisione.
2. **Perché il codice non basta a capirla.** Se leggendo il codice si capisce tutto, la voce non serve.
3. **Fino a quando vale.** L'evento che la renderebbe falsa.

```text
### D7 — Si adotta un contenitore di dipendenze
2026-09-12
Scelta: ogni adattatore espone il proprio metodo di registrazione nel contenitore.
Scartato: la composizione a mano con metodi di estensione, perché servirebbe un tipo da estendere inventato in casa.
Perché il codice non basta: mostra il contenitore, non l'alternativa scartata.
Vale finché: il programma ha più di un adattatore da comporre.
```

È `/cardflow:card-done` a controllarlo: una voce che non risponde viene fermata e l'operatore decide se è davvero una
decisione.

Il registro descrive le decisioni **in vigore**. Una decisione superata si riscrive al suo posto, con lo stesso
codice, così i documenti che la citano puntano ancora alla voce giusta: la scelta vecchia passa in `Scartato`, con il
motivo per cui era sbagliata. Una decisione che non vale più si cancella.

### Vincoli e migliorie

Servono a ogni progetto. Un **vincolo** è un fatto che non abbiamo scelto e non possiamo cambiare. Una **miglioria**
è una proposta fuori perimetro: si potrebbe fare, nessuno l'ha ordinata. Le migliorie stanno in due sezioni:
**Prodotto**, per quello che cambia per chi usa il programma, e **Sistema**, per quello che cambia architettura,
infrastruttura o manutenzione.

```text
### Architettura scalabile
Separare il motore di calcolo dall'interfaccia, così che più postazioni possano usarlo insieme.
```

Un vincolo caduto si cancella, uno cambiato si riscrive. Una miglioria realizzata esce dal registro; se realizzarla
ha comportato una scelta che supera le tre domande, quella scelta entra nelle decisioni.

### Glossario e incontri

Il **glossario** ha una voce per termine, con il significato che ha in questo progetto e, se serve, il sinonimo da
evitare. Gli **incontri** registrano quello che è stato detto a voce: una voce per incontro, con data e persone, e per
ogni argomento il posto dove è finito (requisito, decisione, punto aperto, vincolo, miglioria). Un argomento senza
destinazione non è ancora stato istruito.

## Formato dei documenti

| Tipo | Documenti | Forma |
|---|---|---|
| **Finali**: li legge chi non ha seguito il lavoro | handover, delivery, punti aperti per il cliente, decisioni, glossario, vincoli, migliorie, `knowledge/` | prosa italiana compatta e scorrevole, niente elenchi telegrafici |
| **Intermedi**: stato o elenco da decidere | intestazioni, punti aperti tecnici e della card, ticket | elenchi brevi ammessi |

Il test: **il documento sopravvive alla chiusura della card?** Se sì, è finale.

I nomi di file e cartelle sono in inglese; il contenuto è in italiano, salvo dove una regola del progetto chiede
altro.

## Regole trasversali

- **Aggiornare, non aggiungere.** Una voce che esiste si riscrive al suo posto; non se ne aggiunge una nuova che
  dichiara superata la vecchia.
- **I registri si aggiornano solo alle chiusure**, di card o di ordine. Durante il lavoro un registro aggiornato
  descrive un'intenzione, non un fatto.
- **Chiedere prima di scrivere nei registri.** Una conclusione non confermata non ci entra.
- **Il formato esistente non autorizza.** Se una regola scritta dice altro, vince la regola, anche contro le righe
  già presenti.
- **Nessuna cartella per il lavoro di una sessione.** Una correzione che comincia e finisce nella stessa sessione non
  crea né card né ticket.
- **Il codice non cita codici.** Un commento non nomina mai una decisione, un punto aperto o una card: dice per esteso
  il motivo.

## Requisiti

- **Claude Code** con il plugin `cardflow` installato.
- **Il plugin `mattpocock-skills`**: `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `code-review`. cardflow
  lo configura da sé: **non serve lanciare `setup-matt-pocock-skills`**.
- **Il plugin `superpowers` spento** nei progetti che usano cardflow, perché il suo hook di avvio impone un metodo
  concorrente. `/cardflow:init` lo spegne nel progetto se lo trova installato.
- **Un repository git** per il codice. Senza, la revisione di chiusura non ha una differenza da leggere.
- `/cardflow:init` eseguito una volta per progetto, e di nuovo dopo un aggiornamento del plugin: il permesso di
  lettura sui modelli segue la cartella in cui il plugin è installato.

## Comandi

I comandi si scrivono sempre con il prefisso `cardflow:`.

| Comando | Che cosa fa |
|---|---|
| `/cardflow:init` | configura il progetto: modalità (repository che ospita già i file per l'IA, oppure cartella `.ai/` separata), posizione di `.work`, permessi, struttura, file di configurazione delle skill di Matt, blocco nel `CLAUDE.md` |
| `/cardflow:help [argomento]` | riassume comandi e giro di una card; con un argomento risponde su quel tema, dal manuale |
| `/cardflow:order-new [order-id]` | apre un ordine |
| `/cardflow:order-close <order-id>` | chiude un ordine |
| `/cardflow:card-new [order-id]` | crea una card, nell'ordine indicato o nel backlog libero |
| `/cardflow:card-list` | elenca le card aperte |
| `/cardflow:card-assign <card-id> <order-id>` | assegna a un ordine una card in `BACKLOG`; con `-` la riporta nel backlog libero |
| `/cardflow:card-done <card-id>` | chiude una card |

Chi arriva da un metodo precedente non trova nel plugin niente per migrare: il plugin parte pulito. La migrazione
dei progetti esistenti è una procedura a parte, fuori dal plugin.

## Che cosa cardflow non fa

Non tocca i rami git e non committa: propone il messaggio, il commit lo fa l'operatore. Non scrive nel repository del
cliente, salvo i file che l'operatore sceglie di tenere vivi lì. Non produce report per il cliente: i report sono
rimandati a una versione successiva.
