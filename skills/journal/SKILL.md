---
name: journal
description: Annota nel diario del progetto un incontro, una risposta o un fatto arrivato da fuori, con data, fonte ed effetto, e propone le modifiche a documenti del repository, conoscenza, punti aperti, migliorie, backlog e spec che ne seguono, chiedendo voce per voce. Usala quando l'operatore riporta una risposta del cliente, una mail, un incontro o una decisione presa fuori dalle chiusure, o chiede di annotare qualcosa nel diario.
argument-hint: "[fatto]"
arguments: [fact]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh *)
---

# /cardflow:journal

Fatto: `$fact`. Se è vuoto, chiedi che cosa è successo.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository, il branch principale, la
lingua e i percorsi dei documenti del repository stanno nel blocco cardflow del `CLAUDE.md`. Il branch attivo si legge
con `git -C <repository> branch --show-current`.

## Passi

1. **Il fatto.** Raccogli che cosa è successo, la data (oggi, se non è detta), la fonte (un incontro con chi, una mail
   di chi, una telefonata, un'analisi nostra) e il branch, se il fatto riguarda il lavoro di un branch aperto.
2. **Che cosa tocca.** Leggi i registri dei punti aperti di `<work>/control/` e dei branch, le migliorie, i backlog e,
   sul branch attivo, i documenti del repository: decisioni, vincoli, glossario. Trova le voci che il fatto risolve,
   cambia o fa nascere.
3. **Gli effetti**, proposti uno per uno con la prova dell'essenziale del manuale
   (`${CLAUDE_PLUGIN_ROOT}/manual/overview.md`, sezione *Solo l'essenziale*), e scritti solo dopo il sì:
   - una domanda che ha trovato risposta si cancella, insieme al punto tecnico da cui nasce, dopo che il contenuto è
     arrivato dove deve stare;
   - un vincolo va nel documento dei vincoli, un termine di altri nel glossario, una scelta nostra che ne segue nel
     documento delle decisioni: tutti nel repository, sul branch attivo, nella forma di `docs/agents/domain.md`, nella
     lingua e con le convenzioni del repository, senza citare `.work`. Se la voce riguarda il branch principale e il
     branch attivo è un altro, dillo: arriverà sul principale solo con il merge, oppure l'operatore passa prima al
     principale;
   - una decisione che contraddirebbe un vincolo non si scrive: prima si cambia il vincolo, e la voce di diario lo
     dice;
   - un documento ricevuto va in `<work>/knowledge/docs/`, com'è arrivato; uno studio che fa fede va in
     `<work>/knowledge/` come analisi, con la data nella prima riga;
   - un cambio di perimetro va nella spec del branch;
   - una cosa nuova da fare diventa una voce del `backlog.md` del branch che la farà;
   - una domanda nuova diventa una voce di `<work>/control/open-points-client.md`;
   - una miglioria nasce in `<work>/control/improvements.md`, con la data; oppure si cancella perché realizzata o
     scartata. Se l'ha realizzata un branch non ancora unito, prende invece la riga `Chiusa in: <branch>`.

   I codici delle voci nuove li dà lo script, tutti in una chiamata per famiglia:
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh" "<work>" --code <famiglia> <quanti>`. Un file che manca nasce dal
   suo modello. Se il repository è stato toccato, di' che serve un commit, proponi una riga Conventional Commits in
   inglese e aspetta: l'agente non committa mai.
4. **La voce.** Scrivila in fondo a `<work>/control/journal.md`, che nasce dal modello se manca: `### <data> — <che
   cosa è cambiato>`, `Fonte:`, `Effetto:` con le voci toccate, ciascuna con il suo codice o il suo titolo (nate,
   chiuse, cancellate) e i documenti toccati, e `Branch:` se il fatto riguarda un branch diverso dal principale. La
   voce si scrive anche se l'operatore rifiuta tutti gli effetti, perché il fatto è accaduto.

Le voci passate non si modificano: un errore si corregge con una voce nuova che lo dice.
