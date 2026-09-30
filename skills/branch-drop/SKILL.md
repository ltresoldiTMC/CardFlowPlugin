---
name: branch-drop
description: Abbandona un branch cardflow il cui codice non entrerà in un altro branch. Decide la card e il backlog, chiede che cosa fare dei riferimenti al branch e ai suoi codici, scrive il diario e cancella la cartella del branch; non sale niente.
argument-hint: "<branch>"
arguments: [branch]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work.sh *)
disable-model-invocation: true
---

# /cardflow:branch-drop

Branch: `$branch`. È obbligatorio; se è vuoto, chiedilo. Sul branch principale fermati: il principale non si
abbandona.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository e il branch principale stanno
nel blocco cardflow del `CLAUDE.md`.

La cartella di un branch la dà lo script, con lo strumento Bash e non con PowerShell:
`bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" branch-dir "<work>" "<branch>" "<principale>"`. Stampa il nome della
cartella sotto `<work>/development/`: esce con 0 se la cartella esiste, con 1 se non esiste ancora, con 2 se il nome
collide con un'altra cartella. Il branch si può indicare con il suo nome o con quello della sua cartella; il nome
esatto è il `BRANCH` della sua spec. Se il branch non ha una cartella, dillo e fermati.

## Passi

In quest'ordine, fermandoti a ogni passo che chiede una risposta.

1. **Conferma.** Di' che cosa si perde: i punti tecnici, gli handover e la card del branch, e le voci del backlog che
   non si spostano, perché il suo codice non entra da nessuna parte. I documenti del repository restano sui commit del
   branch, che non entrano. Chiedi conferma.
2. **Card e backlog.** La card in corso, se c'è, diventa una voce del backlog di un altro branch, il principale se
   l'operatore non ne indica un altro (una voce `## <titolo>`, le righe sull'idea come descrizione, `BLOCKED BY` come
   nota `Bloccato da:`), oppure si elimina. Ogni voce del backlog va in fondo al backlog di un altro branch, oppure si
   elimina. Il branch di destinazione deve avere la sua cartella, tranne il principale, la cui cartella nasce, se
   manca, con una `SPEC.md` che porta solo l'intestazione del modello `development/branch/SPEC.md`.
3. **Riferimenti.** Elenca i codici del `open-points-technical.md` del branch, con i loro titoli: spariscono. Poi cerca,
   in `<work>/control/` escluso il diario e nelle card e nei backlog degli altri branch:
   - le voci con la riga `Chiusa in: <BRANCH>`: per ciascuna chiedi se **si riapre**, togliendo la riga, perché il
     lavoro che la chiudeva non entrerà, o **si cancella**;
   - le citazioni dei codici che spariscono, per esempio una domanda che nasce da un punto del branch, o un
     `BLOCKED BY` e una nota `Bloccato da:` che lo citano: per ciascuna chiedi se **si tiene**, correggendone il testo
     perché non citi più un codice che sparisce, o **si cancella**.

   Il diario non si tocca: le voci passate non si riscrivono.
4. **Diario.** Aggiungi in fondo a `<work>/control/journal.md` una voce `### <oggi> — Abbandonato il branch <BRANCH>
   (<titolo>)`, con la fonte che l'operatore indica, un `Effetto:` con i codici che spariscono, la card eliminata con
   Id e titolo, le voci di backlog spostate o eliminate e le voci riaperte o cancellate, ciascuna con il suo titolo, e
   `Branch: <BRANCH>`.
5. **Cancellazione.** Mostra che cosa resta nella cartella, poi cancellala.

Le domande, le analisi, i documenti di altri, le risorse, le migliorie e le voci di diario già scritti nel blocco
comune restano, perché sono veri comunque. Nessuna operazione sui branch.
