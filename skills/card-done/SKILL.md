---
name: card-done
description: Chiude una card cardflow. Revisione dell'intera card, correzioni, installazione, allineamento della spec, documenti del repository, conoscenza e punti aperti al loro posto con la prova dell'essenziale, handover, diario, cancellazione. Usala anche quando l'operatore risponde sì a «Procediamo con la review e chiudiamo?» dopo l'ultimo ticket.
argument-hint: "[card-id | branch]"
arguments: [card]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh *), Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work.sh *)
---

# /cardflow:card-done

Card: `$card`. Se è vuoto, è la card del branch attivo.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository, il branch principale, la
lingua e i percorsi dei documenti del repository stanno nel blocco cardflow del `CLAUDE.md`.

La cartella di un branch la dà lo script, con lo strumento Bash e non con PowerShell:
`bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" branch-dir "<work>" "<branch>" "<principale>"`. Il branch attivo si legge
con `git -C <repository> branch --show-current`.

Una card è la cartella `card/` di un branch. Si indica con l'Id o con il branch; senza argomento è la card del branch
attivo. Per un Id, è la `<work>/development/*/card/` il cui `SPEC.md` porta `ID: <valore>` nell'intestazione. Il
branch della card è il `BRANCH` della spec della cartella che la contiene.

## Passi

In quest'ordine, fermandoti a ogni passo che chiede una risposta. Ogni passo che tocca il repository finisce come un
ticket: dici che serve un commit, proponi una riga Conventional Commits in inglese, senza corpo né attribuzioni, e
aspetti che l'operatore dica di aver committato. L'agente non committa mai.

0. **Condizioni.** `BASE` deve essere scritto e risolto da `git -C <repository> rev-parse <BASE>`. Se è vuoto, la card
   non è partita: non c'è niente da chiudere, dillo e fermati. Se non si risolve più, per esempio dopo un rebase,
   chiedi da quale commit partire. Se il branch attivo non è quello della card, dillo: quello che la chiusura scrive
   descriverebbe codice che su quel branch non c'è; se l'operatore vuole procedere, si procede. Se `tickets/` contiene
   file, elencali e chiedi se procedere comunque: se sì, la card chiude a metà.
1. **Revisione dell'intera card.** Lancia l'agente `cardflow:closure-reviewer` passandogli l'Id della card, `<work>` e
   il percorso del repository. Presenta il suo rapporto così com'è.
2. **Correzioni.** L'operatore decide che cosa correggere, compresi i buchi di installazione del rapporto e i commenti
   mancanti accanto a un pezzo di codice il cui motivo non si capisce dal codice. Correggi, verifica con i comandi di
   build e di test del progetto e riporta l'esito vero.
3. **Installazione.** Confronta `INSTALLATION.md` della card con la differenza, aiutandoti con la categoria
   *Installazione* del rapporto: una modifica che un'installazione esistente deve ricevere a mano, senza la sua voce,
   è un buco; uno script SQL citato deve esistere nel repository al percorso indicato. Chiedi prima di correggere. Se
   il file manca e serve, nasce dal modello `development/card/INSTALLATION.md`.
4. **Allineamento della spec.** Solo adesso la spec della card recepisce le deviazioni che la revisione ha giudicato
   valide e l'operatore ha confermato: il testo si corregge e la riga della deviazione si toglie. Se la card chiude a
   metà, la parte non fatta esce dalla spec e diventa una voce in testa al `backlog.md` del branch, nella forma del
   modello `development/branch/backlog.md`, con la nota `Bloccato da:` se è ferma per un punto aperto.
5. **File e appunti.** Per ogni file di `files/` chiedi se **muore**, se **entra nel repository** (dati di prova legati
   al codice) o se **diventa una risorsa** in `<work>/knowledge/resources/`. Mostra l'elenco di `.scratch/`: quello che
   serve ancora segue i passi 6 e 7, il resto muore con la card.
6. **Documenti del repository**, chiedendo voce per voce e applicando la prova dell'essenziale del manuale
   (`${CLAUDE_PLUGIN_ROOT}/manual/overview.md`, sezione *Solo l'essenziale*):
   - le decisioni della spec nel documento delle decisioni. Una decisione che ne supera una esistente la riscrive al
     suo posto, e la scelta vecchia passa fra quelle scartate. Una decisione che contraddirebbe un vincolo non si
     scrive: prima si cambia il vincolo;
   - i vincoli nel documento dei vincoli, con l'origine;
   - i termini, nostri e di altri, nel glossario, con l'origine;
   - l'architettura, solo se la card ha cambiato la struttura, sezione per sezione, verificando sul codice.

   La forma delle voci sta in `docs/agents/domain.md`. Scrivi come una persona del team, nella lingua e con le
   convenzioni del repository, senza citare `.work`: niente codici, niente Id, niente percorsi. Un documento che manca
   nasce con il suo titolo e la prima voce.
7. **Conoscenza e controllo**, chiedendo voce per voce e applicando la prova dell'essenziale. I codici nuovi li dà lo
   script, tutti in una chiamata per famiglia:
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh" "<work>" --code <famiglia> <quanti>`. Un file che manca nasce dal
   suo modello.
   - le analisi in `<work>/knowledge/`, con la data nella prima riga; i documenti ricevuti in `<work>/knowledge/docs/`,
     che non si modificano;
   - le domande nuove in `<work>/control/open-points-client.md`, con il codice `Q`;
   - le migliorie nuove in `<work>/control/improvements.md`, con il codice `MP` o `MS` e la data della proposta;
   - i punti ancora aperti di `OPEN-POINTS.md` prendono il codice `T` e vanno in
     `<work>/control/open-points-technical.md` se il branch è il principale, altrimenti nel `open-points-technical.md`
     della cartella del branch;
   - le voci che la card chiude, cioè i punti tecnici risolti e le migliorie realizzate. Chiedi se la card ne chiude.
     Sul branch principale si cancellano. Su un altro branch, un punto del branch si cancella, e una voce comune prende
     sotto il titolo la riga `Chiusa in: <BRANCH>`, e si cancellerà al merge.
8. **Handover.** Scrivi `HANDOVER.md` dal modello `development/card/HANDOVER.md`, con `ID`, `TITOLO`, `BRANCH`,
   `COMMIT: <BASE>..<SHA di HEAD>`, letto dopo l'ultimo commit della chiusura, e i nomi di file, classi e chiavi
   verificati sul codice. Proponi il `TIPO` e chiedi conferma: `funzione`, `correzione` oppure `incompatibile`, quando
   un'installazione esistente non si aggiorna senza toccare dati o configurazione già presenti, o quando cambia un
   comportamento su cui altri contano. La sezione *Installazione* riceve le voci di `INSTALLATION.md`; senza passi, la
   sezione si toglie. Una card chiusa a metà lo dice in *Che cosa è ancora finto o parziale*. Il file si chiama
   `<id>-<slug>.md`, con uno slug breve in inglese ricavato dal titolo, e va in
   `<work>/deploy/handovers/pending/` per una card del branch principale, in
   `<work>/development/<cartella>/handovers/` per gli altri branch.
9. **Diario.** Aggiungi in fondo a `<work>/control/journal.md`, che nasce dal modello se manca, una voce
   `### <oggi> — Chiusa la card <ID> (<titolo>)`, con `Fonte: chiusura della card.`, un `Effetto:` con i codici nati,
   chiusi o cancellati, ciascuno con il suo titolo, i documenti del repository e della conoscenza toccati e la voce di
   backlog nata da una chiusura a metà, e `Branch: <BRANCH>` se il branch non è il principale. La scrive la skill
   stessa: una skill non può lanciarne un'altra.
10. **Cancellazione.** Mostra che cosa resta in `card/`, poi cancellala.

Nessuna operazione sui branch.
