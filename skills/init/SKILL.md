---
name: init
description: Configura un progetto per cardflow. Chiede la modalità, fissa la radice di .work, scrive permessi, struttura, file per le skill di Matt e blocco nel CLAUDE.md. Idempotente. Si lancia una volta per progetto, e di nuovo dopo un aggiornamento del plugin.
disable-model-invocation: true
---

# /cardflow:init

Configura per cardflow il progetto della cartella di lavoro attuale. **Idempotente**: rilanciato, adotta quello che
trova e non cambia nulla che sia già giusto. Non crea mai una cartella che esiste già. Nessuna operazione git che
scrive.

I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`.

Tieni un registro di quello che fai, con uno di tre esiti per voce: **creato**, **adottato** (esisteva già ed era
giusto), **da decidere**. Alla fine lo riporti.

## 1. Modalità

Chiedila sempre, senza dedurla:

- **nel repository**: il repository ospita già i file per l'IA (`CLAUDE.md`, `.claude/`), e la cartella di lavoro
  è la sua radice;
- **cartella `.ai/` separata**: il repository resta pulito; la cartella di lavoro è una `.ai/` accanto al
  repository, e tutti i file per l'IA stanno lì.

Controlla che la cartella di lavoro sia coerente con la risposta, con `git rev-parse --show-toplevel` in sola
lettura. Nel repository, la cartella di lavoro deve esserne la radice. Con la cartella separata, la cartella di
lavoro non deve stare dentro un repository. Se non torna, fermati e dillo.

## 2. Repository

Nel repository, è la cartella di lavoro. Con la cartella separata, chiedi il percorso assoluto del repository e
verifica con `git -C <percorso> rev-parse --show-toplevel` che ne sia la radice. Se non è un repository git,
avvisa: la revisione di chiusura di una card non avrà una differenza da leggere. Il percorso finisce nel blocco del
`CLAUDE.md`.

## 3. Radice di `.work/`

Se `.WORKDIR` esiste, leggine il percorso togliendo gli spazi, un eventuale BOM iniziale e i separatori
raddoppiati, e chiedi conferma. Altrimenti chiedi il percorso assoluto: mai un default relativo. La radice deve
stare **fuori dal repository**. Se la cartella esiste la adotti; se non esiste la crei, dopo conferma. `.WORKDIR`
non si scrive ancora: lo scrive il passo 9.

## 4. Permessi

In `.claude/settings.local.json` della cartella di lavoro, sotto `permissions.allow`:

- `Read` ed `Edit` sulla radice di `.work/`; `Edit` copre anche la scrittura di file nuovi;
- `Read` sulla cartella del plugin, `${CLAUDE_PLUGIN_ROOT}`, perché le skill ne leggono i modelli. Se sta sotto
  `~/.claude/plugins/cache/`, il permesso copre la cartella del plugin senza la versione, così sopravvive agli
  aggiornamenti;
- `Read` sulle cartelle di riferimento in sola lettura che l'operatore indica: chiedile;
- con la cartella separata, `Read` ed `Edit` sul repository.

La forma, anche su Windows, è `Read(//d/percorso/**)`: lettera di unità minuscola dopo `//`, barre in avanti,
`/**` in fondo. Aggiungi quello che manca senza toccare le altre voci. **Ripara** le voci malformate che riguardano
gli stessi percorsi: barre rovesciate, lettera di unità con i due punti, spazi dentro il pattern, `/**` mancante.
Una voce malformata non dà errore: fallisce in silenzio, e l'operatore si ritrova la domanda di permesso a cui
credeva di aver già risposto.

## 5. Struttura

Crea dentro la radice `project/`, `orders/` e `cards/`, se mancano. Nessun file dentro: un documento nasce quando
c'è qualcosa da metterci. Quello che esiste già accanto a queste cartelle non si tocca.

## 6. File per le skill di Matt

Scrivi `docs/agents/issue-tracker.md`, `domain.md` e `triage-labels.md` nella cartella di lavoro, copiandoli da
`${CLAUDE_PLUGIN_ROOT}/templates/matt/`. Un file identico al modello è adottato. Uno diverso si mostra, riassumendo
le differenze, e si sovrascrive solo dopo conferma.

## 7. Blocco nel `CLAUDE.md`

Prendi `${CLAUDE_PLUGIN_ROOT}/templates/claude-block.md` e sostituisci `{{REPO}}` con il percorso del repository.
Nel `CLAUDE.md` della cartella di lavoro:

- se c'è già un blocco fra `<!-- cardflow:begin` e `<!-- cardflow:end -->`, sostituiscilo al suo posto;
- altrimenti aggiungilo in fondo; se il file non esiste, crealo con il solo blocco.

Se fuori dal blocco il file ha una sezione `## Agent skills`, o sezioni che descrivono un altro metodo di lavoro
(tracker, registri, commit), mostrale e chiedi se toglierle: il blocco le sostituisce. Non toglierle da solo.

## 8. superpowers

Cerca `superpowers` fra i plugin installati, in `~/.claude/plugins/installed_plugins.json`. Se c'è, scrivi la sua
chiave (`superpowers@<marketplace>`) con valore `false` sotto `enabledPlugins` in `.claude/settings.local.json`: il
suo hook di avvio impone un metodo concorrente. Se non è installato, non scrivere nulla.

## 9. Controllo finale e `.WORKDIR`

Prima di dichiarare riuscita la configurazione, verifica che:

- il percorso di `.work/` sia assoluto, la cartella esista e stia fuori dal repository;
- con la cartella separata, nessun file scritto da questo comando stia dentro il repository;
- nessun permesso che riguarda `.work/`, il plugin o il repository sia malformato;
- `docs/agents/` abbia i tre file e il `CLAUDE.md` abbia il blocco.

Se tutto regge, scrivi `.WORKDIR` nella cartella di lavoro: una riga sola, il percorso assoluto, senza BOM. Se
esiste già con lo stesso percorso, lascialo com'è. **Se il controllo non passa, `.WORKDIR` non si scrive** e riporti
che cosa blocca: un `.WORKDIR` presente promette che la configurazione funziona.

## 10. Rapporto

Una tabella con voce, esito e nota, poi le decisioni ancora aperte. Rilanciato su un progetto già configurato,
tutto deve risultare adottato.

Con la cartella separata, ricorda che Claude Code deve partire dalla `.ai/`: in un workspace di VS Code con più
cartelle, la `.ai/` va messa per prima.
