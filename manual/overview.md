# cardflow — manuale

**Versione del metodo: v2.**

## A che cosa serve

cardflow organizza lo sviluppo di un progetto quando il lavoro dura più di una sessione. Serve a quattro cose:

1. tenere il materiale che arriva da fuori: i documenti di altri, le risorse, le analisi;
2. gestire gli sviluppi, branch per branch;
3. tenere il controllo del progetto: il diario, i punti aperti, le migliorie;
4. preparare le consegne.

Ogni scopo ha il suo blocco, cioè una cartella di `.work` con una regola sola. Il lavoro dentro una card lo fanno le
skill di Matt Pocock: grilling, spec, ticket, implementazione, revisione. cardflow non le sostituisce: aggiunge il
livello sopra, che loro non conoscono.

**Il principio.** `.work` sta fuori da git e non segue i branch: ne esiste una copia sola, qualunque branch sia attivo.
Da un branch all'altro cambia poco: il lavoro in corso e i punti tecnici che quel lavoro apre. Solo questa parte si
divide per branch. Tutto il resto di `.work` è comune, perché una risposta del cliente, un documento ricevuto o una
miglioria valgono su ogni branch.

Quello che serve a chi mantiene il codice, cioè l'architettura, il glossario, le decisioni e i vincoli, non sta in
`.work`: sta nel repository, in quattro documenti che seguono il branch con git. Ogni versione del codice porta con sé
la propria descrizione, e al merge i documenti li unisce git insieme al codice.

**Due tipi di documenti, due regole.** I documenti che l'agente legge per lavorare devono essere corti e aggiornati, e
non tengono la storia, perché la storia confonde l'agente e occupa contesto. I documenti che legge l'operatore, per il
controllo del progetto e per le consegne, tengono la storia, perché la storia è il loro scopo. Ogni blocco è di un
tipo solo, quindi ha una regola sola.

## I blocchi

```text
<repository>/                   il codice, in git
  docs/architecture.md          il minimo che il codice non mostra, con i diagrammi in Mermaid
  docs/glossary.md              i termini nostri e del cliente
  docs/decisions.md             le decisioni in vigore
  docs/constraints.md           i vincoli che non abbiamo scelto

.work/
  knowledge/                    comune: il materiale che arriva da fuori, vero su ogni branch
    docs/                       i documenti di altri, come sono arrivati
    resources/                  le risorse: file d'esempio, mock, dati di prova fuori dal repository
    <analisi>                   gli studi che fanno fede, ciascuno con la sua data
  development/                  una cartella per branch, compreso il principale
    <cartella-del-branch>/
      SPEC.md                   l'impegno del branch: obiettivo, perimetro, criteri
      backlog.md                le cose da fare, in ordine di priorità
      open-points-technical.md  i punti tecnici (T) del branch, in attesa del merge
      handovers/                gli handover delle card chiuse, in attesa del merge
      card/                     lo sviluppo in corso, al massimo uno
        SPEC.md                 l'intestazione della card, poi la spec
        tickets/
        OPEN-POINTS.md
        INSTALLATION.md
        files/
        .scratch/
  control/                      comune; la storia sta nel diario
    journal.md                  il diario: incontri, fatti arrivati da fuori, eventi
    open-points-technical.md    i punti tecnici comuni (T)
    open-points-client.md       le domande (Q) al cliente, ai fornitori, all'IT
    improvements.md             le migliorie (MP, MS)
  deploy/                       comune, con la storia
    handovers/pending/          il lavoro già sul branch principale, non ancora rilasciato
    handovers/<versione>/       gli handover inclusi in quella versione
    releases/<versione>/        la consegna: RELEASE-NOTES.md, INSTALLATION.md, sql/
    INSTALLATION.md             l'installazione completa dell'ultima versione
  notes/                        facoltativa: lo spazio dell'operatore, che non fa fede
```

Nessuna cartella e nessun documento nascono in anticipo: un documento nasce quando c'è qualcosa da metterci, dal suo
modello. I percorsi dei quattro documenti del repository sono quelli di default: `/cardflow:init` li propone, e
l'operatore può indicare quelli che il repository usa già.

| Blocco | Chi lo legge | Storia | Quando si scrive |
|---|---|---|---|
| documenti del repository | l'agente, sempre, e chi mantiene il codice | no: la tiene git | alla chiusura di una card e con `/cardflow:journal` |
| `knowledge/` | l'agente, quando la domanda riguarda il mondo esterno | no | alla chiusura di una card e con `/cardflow:journal` |
| `development/<branch>/` | l'agente, solo la cartella del branch attivo | no | durante il lavoro |
| `control/` | l'operatore; l'agente alle chiusure, al rilascio, per l'avanzamento o se glielo si chiede | sì, nel diario | alle chiusure e con `/cardflow:journal` |
| `deploy/` | l'operatore e chi installa; l'agente al rilascio | sì | alla chiusura di una card e al rilascio |

### `knowledge/`

Tiene il materiale che arriva da fuori, vero su qualunque branch. Si scrive alla chiusura di una card da qualunque
branch, senza aspettare il merge, oppure con `/cardflow:journal`.

- **`docs/`** tiene i documenti di altri, conservati come sono arrivati: la specifica del gestionale, la mail del
  cliente. Si leggono e si citano; non si modificano mai, e le correzioni vanno nei nostri documenti.
- **`resources/`** tiene le risorse: materiale vivo che si usa invece di leggerlo, come un file d'esempio del
  gestionale, il mock di un servizio esterno o dei dati di prova che nel repository non possono stare. Una risorsa si
  sostituisce con una versione nuova.
- **Le analisi** sono gli studi che fanno fede: come funziona un sistema esterno, come si ottiene un'autorizzazione,
  che cosa chiede una norma. Un'analisi porta la data nella prima riga e non si aggiorna: vale per quello che era vero
  quel giorno, e uno studio nuovo è un'analisi nuova.

La differenza fra un documento di altri e una risorsa è una domanda: lo leggo per capire, o lo do in pasto a un
programma o a una prova?

### `development/`

C'è una cartella per ogni branch aperto, compreso il principale, e le cartelle non dipendono l'una dall'altra.

- **`SPEC.md`** è l'impegno del branch: nell'intestazione `BRANCH` e `TITOLO`, poi l'obiettivo, il perimetro, i criteri
  di accettazione e le fonti. Per il branch principale la spec dice che cosa deve fare la prossima versione.
- **`backlog.md`** tiene le cose da fare nel branch, nell'ordine in cui si faranno.
- **`open-points-technical.md`** tiene i punti tecnici aperti dal lavoro del branch, con il loro codice `T`, e aspetta
  il merge.
- **`handovers/`** tiene gli handover delle card chiuse, e aspetta il merge.
- **`card/`** è lo sviluppo in corso.

Il branch principale ha solo la spec, il backlog e la card: le sue card scrivono direttamente in `control/` e in
`deploy/`.

### `control/`

È il blocco dell'operatore, comune a tutti i branch. La sua storia sta nel diario.

- **`journal.md`** è il diario: gli incontri, i fatti arrivati da fuori e gli eventi (un branch aperto, chiuso o
  abbandonato, una card chiusa, una versione rilasciata, una domanda che ha avuto risposta).
- **`open-points-technical.md`** tiene i punti tecnici aperti, con il codice `T`: quello che non sappiamo ancora o non
  abbiamo ancora deciso.
- **`open-points-client.md`** tiene le domande aperte a chi sta fuori, con il codice `Q`. Le domande stanno sempre qui,
  anche quando nascono dal lavoro di un branch, perché una risposta vale su ogni branch.
- **`improvements.md`** tiene le migliorie, con i codici `MP` e `MS`.

### `deploy/`

Tiene quello che si consegna, con la sua storia.

- **`handovers/pending/`** tiene gli handover e i riepiloghi del lavoro già arrivato sul branch principale e non
  ancora rilasciato.
- **`handovers/<versione>/`** tiene quelli inclusi in quella versione. La versione di un handover è la cartella in cui
  si trova, quindi non serve un campo che la dica.
- **`releases/<versione>/`** tiene la consegna: note di rilascio, passi di installazione, script SQL. Contiene solo
  quello che si spedisce, e si può comprimere e inviare senza controllare niente.
- **`INSTALLATION.md`** descrive come si installa da zero l'ultima versione.

### `notes/`

È lo spazio dell'operatore. Non fa fede e non si cita, e l'agente non ci scrive se non glielo si chiede. Gli appunti
che diventano affidabili si trasformano in un'analisi, su richiesta dell'operatore.

## I documenti del repository

Sono quattro, e servono a chi mantiene il codice: l'architettura, il glossario, le decisioni e i vincoli. Stanno nel
repository, sul branch su cui si lavora, e git li porta con il codice al merge. Valgono in tutte e due le modalità di
`/cardflow:init`, anche con la cartella `.ai/` separata: sono documenti di progetto, non file per l'IA.

- **Si scrivono come li scriverebbe una persona del team**: chiari, brevi, senza frasi fatte, nella lingua e con le
  convenzioni del repository, etichette comprese. La lingua sta nel blocco cardflow del `CLAUDE.md`.
- **Non citano mai `.work`**: niente codici di punti aperti o migliorie, niente Id di card, niente percorsi. Il motivo
  si scrive per esteso, come in un commento del codice.
- **Una voce è un titolo `##`** seguito da poche righe. Decisioni, vincoli e termini si citano per titolo.
- **Nessuno storico.** Una voce superata si riscrive al suo posto, una che non vale più si cancella. La storia la
  tiene git.
- **Si scrivono alla chiusura della card**, o con `/cardflow:journal`, mai durante i ticket. L'architettura si
  aggiorna solo se la card ha cambiato la struttura. Dopo la scrittura l'agente propone la riga di commit, come per il
  codice.

| Documento | Una voce dice |
|---|---|
| architettura | il minimo che il codice non mostra: i componenti e come si parlano, i flussi principali, i sistemi esterni, con i diagrammi in Mermaid dentro il file |
| glossario | il termine, la sua origine, che cosa significa nel progetto e, se serve, i sinonimi da evitare |
| decisioni | la data, che cosa si è scelto, che cosa si è scartato e perché, perché il codice da solo non basta a capirla, fino a quando vale |
| vincoli | l'origine, che cosa impone e che cosa lo farebbe cadere |

La forma completa delle voci, con un esempio per ciascuna, sta in `docs/agents/domain.md`, il file che le skill di Matt
leggono prima di esplorare: per loro il glossario e le decisioni prendono il posto di `CONTEXT.md` e `docs/adr/`, che
non si creano.

Un vincolo scoperto su un branch arriva sul principale con il merge. Se serve subito anche lì, l'operatore lo scrive
sul principale con `/cardflow:journal`.

## I nomi e le intestazioni

I documenti di un'unità di lavoro, cioè di una card, di un branch o di una consegna, hanno il nome in maiuscolo:
`SPEC.md`, `OPEN-POINTS.md`, `INSTALLATION.md`, `HANDOVER.md`, `SUMMARY.md`, `RELEASE-NOTES.md`. I registri hanno il
nome in minuscolo: `journal.md`, `open-points-technical.md`, `open-points-client.md`, `improvements.md`, `backlog.md`.
Nessun nome porta un numero. Un handover e un riepilogo, una volta chiusi, prendono il nome dall'unità che
raccontano: `<id>-<slug>.md` per una card, con lo slug ricavato dal titolo, e `<cartella-del-branch>.md` per un branch.
I nomi di file e cartelle sono in inglese; il contenuto è in italiano, tranne i documenti del repository, che seguono
la lingua del repository.

L'intestazione sta in cima al file, fra due righe `---`, nella forma del *front matter*. I campi sono in maiuscolo,
uno per riga, con i valori allineati alla tredicesima colonna, perché chi apre il file la legga a colpo d'occhio. La
riga `---` di chiusura evita anche una trappola del Markdown: una riga `---` subito sotto del testo trasforma quel
testo in un titolo. Il formato è quello che molti strumenti leggono come YAML; per non romperlo, un titolo citato in
un campo non contiene la sequenza «: », che si sostituisce con un trattino.

La card:

```text
---
ID:         26272KD
TITOLO:     Esportazione in PDF
BASE:
BLOCKED BY: Q26255Kb (formato delle date accettato dal gestionale)
---

Le righe sull'idea, e poi la spec quando nasce.
```

Il branch:

```text
---
BRANCH:     feature/cr0412-invoices
TITOLO:     Esportazione delle fatture
---
```

| Campo | Valori e regole |
|---|---|
| `ID` | l'Id della card; vive solo qui |
| `BASE` | il commit da cui parte il lavoro della card. Lo scrive il primo ticket, non prima: fra la nascita della card e il primo ticket possono passare giorni, e altri commit finirebbero nella revisione. Vuoto vuol dire che la card non è ancora partita |
| `BLOCKED BY` | codici e titoli dei punti aperti che tengono ferma la card, separati da virgole; vuoto se nessuno |
| `BRANCH` | il nome esatto del branch in git; la cartella ne deriva |

Una card chiusa non esiste più, e un branch esiste solo finché è aperto: nessuno dei due ha un campo di stato.
Handover, riepilogo e note di rilascio hanno la loro intestazione, descritta nei loro modelli.

## I branch

- **Il branch principale** si dichiara con `/cardflow:init`, e sta nel blocco cardflow del `CLAUDE.md` accanto al
  repository.
- **Il nome della cartella** è il nome del branch con ogni `/` sostituito da `-`: `feature/cr0412` diventa
  `feature-cr0412`.
- **Il nome esatto del branch** sta nel campo `BRANCH` della spec, perché la conversione non si inverte e git ha
  bisogno del nome vero. La cartella di un branch è quella il cui `SPEC.md` porta il nome esatto; per il branch
  principale, finché la sua spec non esiste, è la cartella con il nome convertito. Rinominare un branch vuol dire
  correggere il campo e, se si vuole, rinominare la cartella.
- **Le collisioni.** Se il nome convertito è già usato dalla cartella di un altro branch, o coincide con un'altra
  cartella a meno delle maiuscole, lo script rifiuta: Windows non distingue le maiuscole nei nomi di cartella.
- **L'impegno con il cliente** (la richiesta di modifica, gli obiettivi, i criteri) sta nella spec del branch. Il
  numero della richiesta può stare nel nome del branch. La parola «ordine» resta solo per questo: l'impegno
  commerciale scritto nella spec.

La cartella la trova lo script `work.sh branch-dir`, che le skill usano al posto di un calcolo a mente.

## Il backlog e la card

**Il backlog** tiene le cose da fare in un branch. Ogni voce ha un titolo `##`, una o due righe che dicono che cosa e
perché, e poi solo le note che servono, in un elenco con le etichette in grassetto: `Bloccato da:` con i codici e i
titoli dei punti aperti che la tengono ferma, `Vedi:` per il materiale, `Note:` per il resto. L'ordine delle voci è la
priorità: la prima è la prossima.

```markdown
## Esportazione in PDF

Ogni fattura esportata arriva al gestionale anche in PDF, allegata alla registrazione.

- **Bloccato da:** Q26255Kb (formato delle date accettato dal gestionale)
- **Vedi:** specifica del gestionale, in knowledge/docs/
```

Il backlog lo scrivono l'operatore, l'agente quando l'operatore glielo chiede, `/cardflow:branch-plan` quando lo
propone dalla spec del branch, `/cardflow:card-done` per la parte non fatta di una card chiusa a metà, `/cardflow:journal` per una cosa nuova da fare, `/cardflow:branch-close` e
`/cardflow:branch-drop` per le voci che arrivano da un altro branch. Una proposta che nessuno ha chiesto non sta nel
backlog: è una miglioria, e la voce che la realizzerà la cita con `Vedi:`.

**La card** è lo sviluppo in corso di un branch. Ce n'è al massimo una per branch, perché la revisione di chiusura
legge i commit fatti dopo `BASE`, e due sviluppi aperti insieme mescolerebbero i loro commit. Nasce da una voce del
backlog, che `/cardflow:card-new` toglie dal backlog, passa per grilling, spec e ticket, e si chiude con
`/cardflow:card-done`: da quel momento non esiste più, e resta il suo handover.

Una card aperta ma non ancora partita, cioè con `BASE` vuoto, può tornare nel backlog: `card-new` lo propone quando
trova la card già occupata. Una card partita che si blocca a metà si chiude con quello che c'è: l'handover dice che
cosa resta finto o parziale, e la parte non fatta torna in testa al backlog con il suo `Bloccato da:`.

## Il percorso

### Aprire un branch

L'operatore crea il branch in git. `/cardflow:branch-new <branch>` crea la cartella con la spec e scrive una voce nel
diario. Sul branch principale la spec dice che cosa deve fare la prossima versione; se la cartella del principale
esiste già con la sola intestazione, perché l'ha creata `card-new`, il comando la completa.

### Pianificare le card

`/cardflow:branch-plan [branch]` legge la spec del branch e propone il backlog: le card da creare, nell'ordine, con i
loro bloccanti. È lo stesso lavoro di `/mattpocock-skills:to-tickets`, un livello sopra: dove `to-tickets` divide una
card in ticket grandi quanto una sessione, `branch-plan` divide un branch in card, ciascuna un pezzo verticale che si
chiude da solo e copre uno o più criteri. Il comando mostra quale voce copre ogni criterio, e dice quali criteri
restano scoperti; confronta la proposta con il backlog che c'è già e con il lavoro già consegnato, e scrive
`backlog.md` solo dopo che l'operatore ha approvato la grana, l'ordine e le voci. Si rilancia quando la spec cambia. Non
scrive il diario, perché pianificare non è un evento.

### Una card, dalla nascita alla chiusura

| # | Passo | Che cosa succede |
|---|---|---|
| 1 | `/cardflow:card-new [branch] [id]` | prende una voce del backlog, o un'idea nuova; genera l'Id se non è passato; crea `card/SPEC.md` con l'intestazione e le righe sull'idea |
| 2 | `/mattpocock-skills:grill-with-docs` | intervista sulla card. Quello che emerge resta **nella card**: punti aperti in `OPEN-POINTS.md`, decisioni e termini nella spec o in `.scratch/`. Nessun registro e nessun documento del repository si tocca |
| 3 | `/mattpocock-skills:to-spec` | scrive la spec sotto l'intestazione di `card/SPEC.md`; se la card ha bloccanti aperti, lo dice prima |
| 4 | `/mattpocock-skills:to-tickets` | scrive i ticket in `tickets/`, ciascuno con la riga `Blocked by:` |
| — | `/clear` | i passi 2–4 stanno nella stessa conversazione; poi si svuota il contesto |
| 5 | `/mattpocock-skills:implement <card-id>/01` | un ticket per conversazione, svuotando il contesto fra l'uno e l'altro |
| 6 | dopo l'ultimo ticket | l'agente chiede **«Procediamo con la review e chiudiamo?»** e aspetta |
| 7 | `/cardflow:card-done` | la chiusura. Dopo il «sì» del passo 6 la può avviare l'agente |

### Un ticket

Prima di cominciare, tre controlli. Se un ticket citato in `Blocked by:` esiste ancora, è aperto: ci si ferma e lo si
dice. Se un codice di `BLOCKED BY` della card esiste ancora come titolo in un registro dei punti aperti, il bloccante è
aperto: ci si ferma e lo si dice. Se il branch attivo non è quello della card, lo si dice, perché il lavoro della card
descriverebbe codice che su quel branch non c'è. In tutti i casi, se l'operatore vuole procedere si procede, ma
l'avviso viene prima. Il primo ticket della card scrive `BASE`.

Il ticket si chiude in quest'ordine. Prima la revisione di Matt, `/mattpocock-skills:code-review`, sulla differenza fra
il codice di lavoro e `HEAD`. Poi, se l'implementazione si è discostata dalla spec, la differenza si annota in fondo a
`card/SPEC.md`, nella sezione **Deviazioni**: che cosa diceva la spec, che cosa si è fatto, perché. Il testo della spec
non si corregge in quel momento: la revisione finale deve poter distinguere una scelta da un errore.

Poi l'**installazione**: se il ticket introduce qualcosa che un'installazione esistente deve ricevere a mano, scrive il
passo in `card/INSTALLATION.md`. Poi il commit, se serve. **L'agente non committa mai**, nemmeno quando una skill glielo
chiede: dice che serve un commit e propone il messaggio, Conventional Commits in inglese, una riga sola, senza corpo e
senza `Co-Authored-By` o altre righe di attribuzione. L'operatore committa e lo dice; solo allora il file del ticket si
cancella.

```text
feat(invoices): add PDF export
```

### Chiudere una card

`/cardflow:card-done` fa, in quest'ordine, fermandosi a ogni passo che chiede una risposta. Ogni passo che tocca il
repository finisce con la proposta di commit e l'attesa.

1. **Revisione dell'intera card.** Un agente con ragionamento profondo legge tutti i commit della card sul suo branch
   e li confronta con la spec: requisiti mancanti o sbagliati, cose non richieste, incoerenze che si vedono solo sul
   lavoro intero, un giudizio su ogni deviazione, le voci da portare nei documenti, i passi di installazione mancanti.
   Non rivede lo stile, che ha già visto la revisione di ogni ticket. Legge soltanto e riporta.
2. **Correzioni**, decise dall'operatore e verificate. Fra le correzioni entra il commento mancante accanto a un pezzo
   di codice il cui motivo non si capisce dal codice.
3. **Installazione**: `INSTALLATION.md` si confronta con la differenza; un passo mancante è un buco.
4. **Allineamento della spec**: solo adesso la spec recepisce le deviazioni giudicate valide. Se la card chiude a metà,
   la parte non fatta torna nel backlog.
5. **File e appunti**: ogni file di lavoro muore, entra nel repository o diventa una risorsa; degli appunti resta solo
   quello che serve ancora.
6. **Documenti del repository**: decisioni, vincoli, termini e, se la struttura è cambiata, l'architettura.
7. **Conoscenza e controllo**: analisi e documenti ricevuti in `knowledge/`; domande e migliorie nuove in
   `control/`; i punti ancora aperti in `control/` per il principale, nel registro del branch per gli altri; le voci
   che la card chiude si cancellano, oppure prendono la riga `Chiusa in:` se il branch non è il principale.
8. **Handover**, scritto per l'operatore, con la sezione *Installazione* per chi installa. Va in
   `deploy/handovers/pending/` per il principale, nella cartella `handovers/` del branch per gli altri.
9. **Diario** e **cancellazione** della cartella `card/`.

### Chiudere un branch

`/cardflow:branch-close <branch>` si lancia due volte. **Prima del merge** verifica i criteri della spec, per il
cliente e interni, contro gli handover del branch e contro il codice, e prepara il testo della pull request. Se c'è
una card in corso, dice che va chiusa prima del merge.

**Dopo il merge** controlla in sola lettura che il merge sia avvenuto, e poi applica una regola sola: **il documento
segue il codice**. I documenti del repository li ha già uniti git. Il resto lo porta il comando:

- i punti tecnici del branch ancora aperti vanno in `control/` se il branch è stato unito nel principale, nel registro
  dell'altro branch se è stato unito lì, con il loro codice;
- le voci comuni con `Chiusa in: <branch>` si cancellano se il branch è entrato nel principale; altrimenti la riga
  prende il nome della destinazione;
- le voci del backlog vanno nel backlog della destinazione, oppure si eliminano;
- una card non partita diventa una voce del backlog della destinazione, oppure si elimina; una card partita si può
  solo eliminare, perché i suoi commit sono già nella destinazione;
- gli handover seguono il codice: `deploy/handovers/pending/`, oppure la cartella `handovers/` dell'altro branch.
  Accanto a loro il comando lascia il riepilogo del branch: obiettivo, perimetro ed esito dei criteri.

Il diario riceve una voce, e la cartella del branch si cancella. L'argomento è obbligatorio: dopo il merge il branch
attivo è quello che ha ricevuto il codice, non quello da chiudere. Il branch principale non si chiude.

### Abbandonare un branch

`/cardflow:branch-drop <branch>` abbandona un branch il cui codice non entrerà altrove. Non sale niente: i punti
tecnici, gli handover e la card del branch si perdono, e i documenti del repository restano sui commit che non
entrano. Il comando chiede che cosa fare della card in corso e delle voci del backlog, che possono passare a un altro
branch. Cerca poi in `control/` e negli altri branch i riferimenti al branch e ai codici che spariscono, e per ognuno
chiede se tenerlo o cancellarlo: una voce comune `Chiusa in` si riapre o si cancella. Il diario riceve una voce con i
codici che spariscono, e la cartella si cancella. Le domande, le analisi e i documenti già scritti nel blocco comune
restano, perché sono veri comunque.

### Rilasciare

`/cardflow:release`, dal branch principale, mostra gli handover e i riepiloghi in `deploy/handovers/pending/`, ciascun
handover con il suo tipo (funzione, correzione, incompatibile), e l'operatore conferma l'elenco. La versione la dice
l'operatore, aiutato dal tipo degli handover, dalla versione precedente e dai tag esistenti. Il comando crea
`deploy/releases/<versione>/` con le note di rilascio, i passi di installazione e gli script SQL, sposta gli handover in
`deploy/handovers/<versione>/`, aggiorna `deploy/INSTALLATION.md`, scrive il diario e stampa il comando per il tag, che
crea l'operatore. Alla fine chiede se i criteri della spec del branch principale si svuotano per la versione
successiva.

## L'handover e il riepilogo

L'**handover** è la scheda con cui l'operatore tiene sotto controllo il lavoro di una card, come un senior con quello
di un junior, e con cui sa spiegarlo senza riaprire il codice. Non va al cliente, tranne la sezione *Installazione*,
l'unica scritta per chi installa, che il rilascio consolida nella consegna.

In testa porta l'intervallo di commit `BASE..HEAD`: è una fotografia di quel momento e lo dichiara, così non mente
quando più avanti un'altra card toccherà lo stesso codice. Porta anche il `TIPO`: `funzione`, `correzione` oppure
`incompatibile`, quando un'installazione esistente non si aggiorna senza toccare dati o configurazione già presenti, o
quando cambia un comportamento su cui altri contano. Il tipo lo propone `card-done` e lo conferma l'operatore; il
rilascio lo mostra quando si sceglie la versione.

Le sezioni sono fisse: che cosa fa ora; che cosa è stato toccato e come, con i nomi reali di file, classi e chiavi
verificati sul codice; perché, con le decisioni citate per titolo; come si prova; che cosa è ancora finto o parziale;
l'installazione, solo se servono passi manuali.

Il **riepilogo** racconta un branch chiuso: obiettivo, perimetro ed esito di ogni criterio, con il riferimento che lo
prova. Lo scrive `branch-close` dopo il merge.

Handover e riepiloghi vivono nella cartella `handovers/` del branch finché il branch non è unito, in
`deploy/handovers/pending/` finché il loro lavoro non è rilasciato, e in `deploy/handovers/<versione>/` per sempre.

## L'installazione, i criteri, l'avanzamento

**L'installazione.** Un ticket che introduce qualcosa che un'installazione esistente deve ricevere a mano (una tabella
o una colonna del database, una chiave di configurazione, un file, un servizio) scrive o riscrive la voce in
`INSTALLATION.md` della card. Una voce per cosa toccata: se la cosa ha già una voce, la si riscrive con lo stato
finale. Gli script SQL sono codice: li scrive un ticket, stanno nel repository e passano dalla revisione di chiusura;
il passo ne cita il percorso. Un passo su un file di configurazione dice sezione, chiave, valore e come verificarlo.
La chiusura della card verifica e copia le voci nell'handover; il rilascio riunisce i passi di tutti gli handover
inclusi, nell'ordine di esecuzione, e non scrive script.

Il lavoro fatto senza card non entra in nessuna consegna. Una correzione che richiede un SQL o un passo di
configurazione deve quindi passare da una card, anche piccola.

**I criteri.** I criteri di accettazione della spec di un branch si dividono in due gruppi. *Per il cliente*: quello
che il cliente può osservare, scritto con le sue parole, senza codici né nomi di classi, per esempio «la fattura
esportata si apre nel gestionale senza correzioni a mano». *Interni*: quello che serve a noi e che il cliente non vede,
per esempio «i test automatici dell'esportazione passano». Il report per il cliente mostra solo il primo gruppo. Un
criterio che non si sa in quale gruppo mettere di solito è scritto male.

**L'avanzamento.** `/cardflow:status [branch]` dice, in sola lettura, a che punto è un branch: per ogni criterio della
sua spec se è soddisfatto, parziale o mancante, e da che cosa lo ricava; poi i bloccanti, con da quando sono aperti e
quali voci tengono ferme; poi la card in corso e il backlog. Non inventa stati, date o percentuali che i file non
dicono.

## I registri

I registri sono i documenti fatti di voci: in `.work` i punti aperti, le migliorie e il backlog; nel repository il
glossario, le decisioni e i vincoli. Ogni registro di `.work` porta in testa, in un commento, la regola per scriverci,
che vale anche per chi lo modifica a mano.

**Una voce, un titolo.** Ogni voce è un titolo seguito da poche righe. Una o due frasi bastano quasi sempre, e devono
bastare a capire la voce anche fra mesi.

**Nessuno storico nei documenti che l'agente legge.** Una voce fatta o superata si riscrive al suo posto o si
cancella. Un registro non tiene mai due voci contrapposte e non conserva la storia di come si è arrivati alla voce di
oggi. La storia del controllo sta nel diario, quella dei documenti del repository in git.

### I codici

I punti tecnici, le domande e le migliorie hanno un codice, generato dallo script del plugin dalla data e dall'ora:

| Famiglia | Voce | Dove sta |
|---|---|---|
| `T` | punto tecnico | `control/open-points-technical.md`, o quello di un branch |
| `Q` | domanda a chi sta fuori | `control/open-points-client.md` |
| `MP` | miglioria di prodotto: cambia che cosa fa il programma per chi lo usa | `control/improvements.md` |
| `MS` | miglioria di sistema: cambia architettura, infrastruttura o manutenzione | `control/improvements.md` |

Decisioni, vincoli e termini non hanno codice: stanno nel repository e si citano per titolo. I punti aperti di una card
non hanno codice: lo prendono quando la card si chiude. La forma dei codici e le regole per citarli stanno in
[`identifiers.md`](identifiers.md).

### Punti aperti e domande

Un punto tecnico è quello che non sappiamo ancora o non abbiamo ancora deciso, con il contenuto tecnico che serve a chi
lavora. Un lavoro da fare non è un punto: è una voce del backlog. Un punto che ripeterebbe soltanto una domanda non si
scrive: basta la domanda. Un punto risolto si **cancella**, dopo che il suo contenuto è arrivato dove deve stare, e il
diario lo registra.

Una domanda è scritta per chi risponde senza conoscere il codice: il contesto, la domanda, le risposte possibili con la
loro conseguenza, che cosa resta fermo nel frattempo e, se c'è, il punto tecnico da cui nasce. Se nel frattempo il
programma fa una scelta provvisoria, la domanda dice quale. **Una risposta è un evento, non un tipo di conoscenza**: si
registra con `/cardflow:journal`, che porta il contenuto dove deve stare (un vincolo o un termine nei documenti del
repository, una scelta nostra nelle decisioni, un cambio di perimetro nella spec del branch) e cancella la domanda,
insieme al punto tecnico da cui nasce.

Durante il lavoro su una card, un punto aperto va nella card; nei registri arriva alla chiusura. Si leggono con
`/cardflow:open-points`: tutti, oppure quelli di un branch o di una card, i bloccanti per primi e con quello che
ciascuno tiene fermo.

### Le migliorie

Una miglioria è una proposta fuori perimetro: si potrebbe fare, nessuno l'ha ordinata. Porta sotto il titolo la data
della proposta. Una miglioria realizzata si cancella alla chiusura della card che la realizza, e il diario lo
registra; una miglioria scartata si cancella con `/cardflow:journal`, e il diario dice perché. Quando qualcuno la
ordina, la voce di backlog che la realizzerà la cita. Se realizzarla ha comportato una scelta che supera la prova
dell'essenziale, quella scelta entra nelle decisioni.

### La chiusura in attesa

Una voce comune che il lavoro di un branch non ancora unito chiude, cioè un punto tecnico di `control/` risolto o una
miglioria realizzata, non si cancella subito, perché sul branch principale il lavoro non c'è ancora. Prende sotto il
titolo la riga `Chiusa in: <branch>`, e resta dov'è. Al merge nel principale si cancella; al merge in un altro branch
la riga prende il nome della destinazione; all'abbandono del branch si riapre, togliendo la riga, oppure si cancella.
Una card del branch principale cancella la voce subito.

```markdown
### T26270Bb — Timeout della connessione al gestionale
Chiusa in: feature/cr0412-invoices
Con più di 5.000 fatture la connessione cade dopo 30 secondi.
```

### Solo l'essenziale

I documenti che l'agente legge per lavorare costano a ogni lettura, e un'informazione scritta in due posti prima o poi
si contraddice. Per questo una voce entra in un registro, in un documento del repository o nella conoscenza solo se
supera la prova del suo tipo. La applica chi scrive, cioè una chiusura o `/cardflow:journal`, prima di proporre la
voce, e quando una voce non la supera dice dove va invece.

| Tipo | Entra | Non entra, e va invece |
|---|---|---|
| decisione | una scelta che il codice da solo non spiega e di cui un agente riproporrebbe l'alternativa; dice che cosa è stato scartato e perché, e fino a quando vale | il motivo di un singolo pezzo di codice va in un commento accanto al codice; una scelta provvisoria in attesa di una risposta va nella domanda, che dice che cosa fa oggi il programma; un dettaglio dell'interfaccia non va da nessuna parte, perché lo mostra il programma; un piano per codice non ancora scritto va nella spec della card che lo scriverà; una regola sugli strumenti va nelle regole dell'agente |
| punto tecnico | quello che non sappiamo o non abbiamo ancora deciso, con il contenuto tecnico che serve a chi lavora | un lavoro da fare è una voce del backlog; un punto che ripete soltanto la sua domanda sparisce, e resta la domanda |
| domanda | la domanda, scritta per chi risponde: il contesto, le risposte possibili con le loro conseguenze, che cosa resta fermo | il dettaglio che serve solo a noi va nel punto tecnico, o nei documenti se è un fatto |
| termine | un termine che si confonde, o che in questo progetto ha un significato suo | la definizione di una parola comune |
| vincolo | un fatto imposto da fuori, con chi lo impone e che cosa lo farebbe cadere | le conseguenze sul nostro disegno, che stanno nelle decisioni |
| conoscenza | quello che il codice non dice: l'architettura minima, un'analisi | la descrizione di quello che il codice mostra da solo; il contenuto di un altro documento, che si cita invece di copiarlo |

Tre regole valgono per tutti i tipi.

- **Un'informazione sta in un posto solo.** Altrove si cita, con il codice e il titolo, con il titolo o con il nome
  del documento.
- **Una voce superata si riscrive o si cancella**: mai due voci contrapposte.
- **Un'analisi fatta una volta** porta la data e non si aggiorna: si cita per quello che era vero quel giorno.

Portare un motivo nel codice è una modifica del codice, quindi passa da una card. Migliorie e diario appartengono
all'operatore: la prova non li sfoltisce, chiede solo che ogni voce sia breve.

### L'origine

I termini e i vincoli portano una riga che dice chi li ha fissati: `progetto` se l'abbiamo stabilito noi, `cliente` se
l'ha stabilito il committente, `norma` se viene da una norma o da un regolamento, `fornitore` se viene da chi fornisce
un componente, un servizio o una piattaforma, `legacy` se viene da un sistema che esisteva prima di noi. Nei documenti
del repository la riga e i valori sono nella lingua del repository.

Un vincolo non è mai `progetto`, perché per definizione non l'abbiamo scelto. Una decisione è nostra per definizione,
e porta l'origine solo nel caso raro in cui la scelta l'ha fatta il committente. **Una decisione non può contraddire un
vincolo**: se un vincolo cade, prima si cambia il vincolo con chi lo impone, e il diario registra quando e con quale
fonte; poi si decide.

## Il diario

`control/journal.md` è il diario del progetto: che cosa è cambiato, quando e da quale fonte. Il nome viene dalla
contabilità, dove ogni fatto si scrive prima nel libro giornale, in ordine di data, e poi si riporta nei mastri. È
l'unico documento del controllo con la storia; gli altri dicono come stanno le cose oggi.

```text
### 2026-10-02 — Il gestionale accetta le date in formato ISO
Fonte: mail del cliente del 2026-10-01.
Effetto: si chiude Q26255Kb (formato delle date accettato dal gestionale); nella decisione «Dates are exported in
ISO format» la scelta provvisoria diventa definitiva.
Branch: feature/cr0412-invoices
```

La riga `Branch:` c'è solo se l'evento riguarda un branch diverso dal principale. Le voci si aggiungono in fondo e non
si riscrivono: un errore si corregge con una voce nuova che lo dice. Il diario lo scrivono `/cardflow:journal`,
`branch-new`, `branch-close`, `branch-drop`, `card-done` e `release`. Ogni codice citato porta il suo titolo accanto.
Non è il diario delle sessioni, e non è la storia del codice, che sta in git.

## Analisi e appunti

Uno studio va dove lo porta un test solo: **fa fede?** Se ci si può contare, è un'analisi, e va in `knowledge/` con la
data. Se sono appunti, vanno in `notes/`, che non fanno fede; quando diventano affidabili, l'operatore chiede di
trasformarli in un'analisi. Se servono a uno sviluppo solo, stanno nella `.scratch/` della card, e muoiono con lei.

## Formato dei documenti

| Tipo | Documenti | Forma |
|---|---|---|
| **Finali**: li legge chi non ha seguito il lavoro | handover, riepiloghi, note di rilascio, passi di installazione, domande, documenti del repository, analisi | prosa compatta e scorrevole, niente elenchi telegrafici |
| **Intermedi**: stato o elenco da decidere | intestazioni, punti tecnici e della card, ticket, backlog | elenchi brevi ammessi |

Il test: **il documento sopravvive alla chiusura della card?** Se sì, è finale.

## Regole trasversali

- **Si scrive alla chiusura.** Documenti del repository, registri e conoscenza si scrivono a `card-done`, a
  `branch-close`, a `branch-drop`, al rilascio e con `/cardflow:journal`, chiedendo prima di ogni voce; fuori da
  questi, solo se l'operatore lo chiede. Durante il lavoro un documento aggiornato descrive un'intenzione, non un
  fatto. Quello che vale su ogni branch va nel blocco comune alla chiusura della card, senza aspettare il merge.
- **Il documento segue il codice.** Quello che descrive il codice sta nel repository e lo porta git; quello che un
  branch lascia in attesa sale, dopo il merge, dove è andato il codice.
- **Un branch, una card alla volta.**
- **Solo l'essenziale.**
- **Chiedere prima di scrivere.** Una conclusione non confermata non entra.
- **Il formato esistente non autorizza.** Se una regola scritta dice altro, vince la regola, anche contro le righe già
  presenti.
- **Nessuna cartella per il lavoro di una sessione.** Una correzione che comincia e finisce nella stessa sessione non
  crea né card né ticket, a meno che richieda un SQL o un passo di configurazione: allora passa da una card, perché il
  lavoro senza card non entra in nessuna consegna.
- **Un documento scritto da altri non si modifica, ovunque stia.**
- **`notes/` non fa fede e non si cita.**
- **Il codice non cita codici.** Un commento non nomina mai un punto aperto, una miglioria, una card o un ticket: dice
  per esteso il motivo. Lo stesso vale per i documenti del repository.

## Requisiti

- **Claude Code** con il plugin `cardflow` installato.
- **Il plugin `mattpocock-skills`**: `grill-with-docs`, `to-spec`, `to-tickets`, `implement`, `code-review`. cardflow
  lo configura da sé: **non serve lanciare `setup-matt-pocock-skills`**.
- **Il plugin `superpowers` spento** nei progetti che usano cardflow, perché il suo hook di avvio impone un metodo
  concorrente. `/cardflow:init` lo spegne nel progetto se lo trova installato.
- **Un repository git** con un branch principale dichiarato, che `/cardflow:init` chiede.
- **La shell bash**, per gli script del plugin. Su Windows è quella di Git, che Claude Code usa già.
- `/cardflow:init` eseguito una volta per progetto, e di nuovo dopo un aggiornamento del plugin: il permesso di
  lettura sui modelli segue la cartella in cui il plugin è installato.

## Comandi

I comandi si scrivono sempre con il prefisso `cardflow:`.

| Comando | Che cosa fa |
|---|---|
| `/cardflow:init` | Dichiara repository, branch principale, lingua e percorsi dei documenti del repository, e scrive il blocco nel `CLAUDE.md`. Non crea cartelle in `.work` |
| `/cardflow:help [argomento]` | Riassume il metodo e indica il manuale; con un argomento risponde su quel tema |
| `/cardflow:branch-new <branch>` | Crea la cartella del branch con la spec e scrive il diario. Sul principale scrive la spec della prossima versione |
| `/cardflow:branch-plan [branch]` | Dalla spec del branch propone il backlog: le card da creare, in ordine, con i criteri che coprono; scrive solo dopo la conferma |
| `/cardflow:card-new [branch] [id]` | Apre la card del branch, di solito prendendo una voce del backlog; l'Id è facoltativo |
| `/cardflow:card-done [card]` | Chiude la card: revisione, correzioni, documenti, registri, handover, diario, cancellazione |
| `/cardflow:branch-close <branch>` | Prima del merge verifica i criteri e prepara il testo della pull request; dopo il merge porta punti tecnici, handover e riepilogo dove è andato il codice |
| `/cardflow:branch-drop <branch>` | Abbandona il branch: decide card, backlog e riferimenti, scrive il diario, cancella la cartella |
| `/cardflow:open-points [branch \| card]` | Elenca punti tecnici e domande aperti, con i bloccanti per primi |
| `/cardflow:journal [fatto]` | Annota nel diario un fatto arrivato da fuori e propone voce per voce gli effetti |
| `/cardflow:status [branch]` | In sola lettura: criteri, bloccanti, card in corso e backlog del branch |
| `/cardflow:release` | Dal branch principale crea la consegna di una versione |

Dove un comando chiede un branch, accetta il nome del branch o quello della sua cartella; dove chiede una card, accetta
l'Id o il branch, e senza argomento vale il branch attivo. `branch-close` e `branch-drop` vogliono sempre il branch.

L'agente può lanciare da solo `help`, `journal`, `branch-plan`, `open-points` e `status`, che scrivono solo dopo una
conferma o non scrivono affatto, e `card-done` quando l'operatore risponde sì alla proposta di chiudere dopo l'ultimo ticket. Gli altri
li lancia solo l'operatore, perché creano, cancellano o consegnano.

Il plugin non migra i progetti di un metodo precedente: tutte le skill si fermano se trovano la struttura della v1,
e la migrazione è una procedura a parte.

## Che cosa cardflow non fa

Non crea branch, non fa merge, non committa e non crea tag, ma al rilascio propone il comando del tag. Il controllo del
merge è in sola lettura e usa i riferimenti locali: cardflow non esegue `fetch` né `pull`. Non scrive script di
installazione: li raccoglie. Non scrive nel repository se non i quattro documenti del repository e, se l'operatore lo
sceglie, i file di lavoro che diventano dati di prova.
