<!-- cardflow:begin — blocco gestito da /cardflow:init: per cambiarlo si rilancia il comando -->
## cardflow

Questo progetto usa **cardflow v1**. Il metodo sta nel plugin `cardflow`: `/cardflow:help` lo riassume e indica
il manuale.

- **Dati di lavoro.** La radice di `.work/` si legge da `.WORKDIR`, in questa cartella. Mai un percorso relativo o
  dedotto.
- **Repository.** `{{REPO}}`. Il ramo attivo si legge con `git -C "{{REPO}}" branch --show-current`.
- **Livelli.** `project/` per quello che vale sempre, `orders/<id>-<slug>/` per un impegno con il suo ramo,
  `cards/<id>-<slug>/` per un blocco di sviluppo. Card, ordini e voci dei registri si citano per Id o codice con il
  titolo accanto, mai per percorso. Gli Id nuovi li genera lo script del plugin, mai un calcolo a mente.
- **Ticket.** Prima di implementarne uno, e per chiuderlo, si segue `docs/agents/issue-tracker.md`, sezioni
  *Prima di un ticket* e *Chiudere un ticket*.
- **Registri** (`2-`, `3-`, `4-`, `6-`, `7-`, `8-`). Si scrivono solo a `/cardflow:card-done` e a
  `/cardflow:order-close`, chiedendo prima di ogni voce; fuori da una chiusura, solo se l'operatore lo chiede.
  Durante il lavoro quello che emerge resta nella card. Una voce superata si riscrive al suo posto o si
  cancella: mai due voci contrapposte, nessuno storico.
- **Commit.** L'agente non committa mai, anche se una skill glielo chiede. Se serve un commit lo dice e propone
  una riga Conventional Commits in inglese, senza corpo né `Co-Authored-By` o altre attribuzioni; l'operatore
  committa e lo dice.
- **Codice.** Un commento non cita mai codici di decisioni, punti aperti, card o ticket: dice per esteso il
  motivo.
- **Rami.** cardflow non tocca i rami: avvisa soltanto quando il ramo attivo non è quello dell'ordine.

## Agent skills

Configurazione delle skill `mattpocock-skills`, scritta da `/cardflow:init`:
`/mattpocock-skills:setup-matt-pocock-skills` non serve.

### Issue tracker

Markdown locale dentro `.work/`: spec e ticket nella cartella della card. Vedi `docs/agents/issue-tracker.md`.

### Triage labels

I cinque ruoli canonici, ciascuno con la stringa uguale al nome, sulla riga `Status:` del ticket. Vedi
`docs/agents/triage-labels.md`.

### Domain docs

Single-context sui registri di cardflow: niente `CONTEXT.md`, niente `docs/adr/`. Vedi `docs/agents/domain.md`.
<!-- cardflow:end -->
