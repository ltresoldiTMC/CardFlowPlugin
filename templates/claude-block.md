<!-- cardflow:begin — blocco gestito da /cardflow:init: per cambiarlo si rilancia il comando -->
## cardflow

Questo progetto usa **cardflow v2**. Il metodo sta nel plugin `cardflow`: `/cardflow:help` lo riassume e indica
il manuale.

- **Dati di lavoro.** La radice di `.work/` si legge da `.WORKDIR`, in questa cartella. Mai un percorso relativo o
  dedotto. `.work/notes/`, se esiste, è dell'operatore: non fa fede, non si cita, e non ci si scrive se non chiesto.
- **Repository.** `{{REPO}}`, branch principale `{{MAIN}}`. Il branch attivo si legge con
  `git -C "{{REPO}}" branch --show-current`.
- **Documenti del repository.** Architettura `{{ARCHITECTURE}}`, glossario `{{GLOSSARY}}`, decisioni
  `{{DECISIONS}}`, vincoli `{{CONSTRAINTS}}`, in {{LANGUAGE}}. Servono a chi mantiene il codice e seguono il branch
  con git. Si scrivono come li scriverebbe una persona del team, chiari e brevi, nella lingua e con le convenzioni del
  repository, e non citano mai `.work`: né codici né percorsi.
- **Quattro blocchi.** `knowledge/` tiene il materiale che arriva da fuori: documenti di altri, risorse, analisi.
  `development/` ha una cartella per branch con la spec, il backlog e al massimo una card in corso. `control/` tiene il
  diario, i punti aperti e le migliorie; `deploy/` gli handover e le consegne. Si leggono sempre `knowledge/`, i
  documenti del repository e la cartella del branch attivo; `control/` e `deploy/` solo alle chiusure, al rilascio,
  per l'avanzamento o se l'operatore lo chiede.
- **Si scrive alla chiusura.** Durante i ticket quello che emerge resta nella card. Documenti del repository, registri
  e conoscenza si scrivono a `/cardflow:card-done`, `/cardflow:branch-close`, `/cardflow:branch-drop`,
  `/cardflow:release` e con `/cardflow:journal`, chiedendo prima di ogni voce; fuori da questi, solo se l'operatore
  lo chiede. Quello che vale su ogni branch va nel blocco comune alla chiusura della card, senza aspettare il merge.
- **Solo l'essenziale.** Una voce entra in un registro o in un documento solo se supera la prova del suo tipo,
  descritta nel manuale. Il motivo di un singolo pezzo di codice va in un commento accanto al codice.
- **Ticket.** Prima di implementarne uno, e per chiuderlo, si segue `docs/agents/issue-tracker.md`, sezioni
  *Prima di un ticket* e *Chiudere un ticket*. Un passo che un'installazione esistente deve eseguire a mano va in
  `INSTALLATION.md` della card; un aggiornamento del database è uno script SQL nel repository.
- **Citazioni.** Card e voci si citano per Id o codice con il titolo accanto, mai per percorso; decisioni, vincoli e
  termini per titolo. Id e codici nuovi li genera lo script del plugin, mai un calcolo a mente.
- **Commit.** L'agente non committa mai, anche se una skill glielo chiede. Se serve un commit lo dice e propone
  una riga Conventional Commits in inglese, senza corpo né `Co-Authored-By` o altre attribuzioni; l'operatore
  committa e lo dice.
- **Codice.** Un commento non cita mai codici di punti aperti, migliorie, card o ticket: dice per esteso il motivo.
- **Git.** cardflow non crea branch, non fa merge, non crea tag e non committa: avvisa quando il branch attivo non è
  quello della card, controlla in sola lettura che un branch sia unito prima di chiuderlo, e al rilascio propone il
  comando del tag.

## Agent skills

Configurazione delle skill `mattpocock-skills`, scritta da `/cardflow:init`:
`/mattpocock-skills:setup-matt-pocock-skills` non serve.

### Issue tracker

Markdown locale dentro `.work/`: spec e ticket nella card del branch. Vedi `docs/agents/issue-tracker.md`.

### Triage labels

I cinque ruoli canonici, ciascuno con la stringa uguale al nome, sulla riga `Status:` del ticket. Vedi
`docs/agents/triage-labels.md`.

### Domain docs

Single-context: il glossario e le decisioni sono i documenti del repository indicati sopra; niente `CONTEXT.md`, niente
`docs/adr/`. Vedi `docs/agents/domain.md`.
<!-- cardflow:end -->
