# Verifiche preliminari

Le risposte alle verifiche della tappa 0 del piano, controllate sulla documentazione ufficiale il 21 settembre
2026. Ogni risposta dice che cosa cambia nel plugin. Le verifiche 0.5 e 0.6 non erano nel piano: sono nate
scrivendo le altre, perché il plugin non si può costruire senza saperle.

## 0.1 — Installazione da cartella locale o da repository privato

Da una cartella locale il marketplace si aggiunge con `/plugin marketplace add <percorso>` e il plugin si
installa con `/plugin install cardflow@cardflow`. Un plugin indicato con un percorso relativo dentro un
marketplace locale si carica sul posto, senza copia nella cache: le modifiche ai file arrivano al riavvio di
Claude Code o con `/reload-plugins`, e `/plugin marketplace update` non serve.

Da un repository privato Claude Code usa le credenziali git già configurate. L'aggiornamento automatico in
background invece le disattiva: o si aggiorna a mano, o si configura `gh auth setup-git`, o si imposta una
riscrittura dell'URL git con un token.

**Conseguenza.** Durante lo sviluppo il plugin si installa dalla sua cartella e ogni modifica si prova con
`/reload-plugins`, senza reinstallare.

Fonte: [plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces).

## 0.2 — Disattivare `superpowers` in un solo progetto

`enabledPlugins` si può scrivere a ogni livello, e vince il livello più vicino al progetto: le impostazioni
locali su quelle di progetto, quelle di progetto su quelle dell'utente. Un `false` in
`.claude/settings.local.json` spegne quindi il plugin in quel progetto anche se l'utente lo tiene attivo. Fanno
eccezione i plugin imposti dalle impostazioni gestite dall'organizzazione, che non si possono spegnere.

Che un plugin spento non esegua nemmeno il suo hook di avvio sessione la documentazione non lo dice con una
frase esplicita: lo si ricava dal fatto che gli hook sono una parte del plugin e si caricano con lui. Si conferma
alla prima sessione nel progetto, quando il messaggio di avvio di `superpowers` non compare.

**Conseguenza.** `/cardflow:init` scrive il `false` in `.claude/settings.local.json`. La chiave ha la forma
`<plugin>@<marketplace>` e il marketplace cambia da un'installazione all'altra, quindi l'init la ricava dai
plugin installati; se `superpowers` non è installato non scrive nulla.

Fonte: [settings-reference, `enabledPlugins`](https://code.claude.com/docs/en/settings-reference#enabledplugins).

## 0.3 — Il campo `effort` nell'intestazione di un agente del plugin

È rispettato. Gli agenti distribuiti con un plugin accettano `name`, `description`, `model`, `effort`, `maxTurns`,
`tools`, `disallowedTools`, `skills`, `memory`, `background`, `omitClaudeMd` e `isolation`. I valori di `effort`
sono `low`, `medium`, `high`, `xhigh` e `max`, secondo quelli che il modello ammette. Per sicurezza vengono
invece ignorati `hooks`, `mcpServers` e `permissionMode`.

**Conseguenza.** L'agente della revisione di chiusura dichiara `model` ed `effort: xhigh` nell'intestazione, e
il prompt non deve chiedere un ragionamento profondo a parole.

Fonti: [plugins-reference](https://code.claude.com/docs/en/plugins-reference),
[sub-agents](https://code.claude.com/docs/en/sub-agents).

## 0.4 — Come si impacchetta un plugin per Codex

Codex ha un suo sistema di plugin dalla versione 0.117 del marzo 2026. Il manifest è un `plugin.json` alla
radice nel formato portabile, oppure `.codex-plugin/plugin.json`; le skill stanno in `skills/<nome>/SKILL.md`
con `name` e `description`; l'installazione passa da un marketplace aggiunto con `codex plugin marketplace add`.
La documentazione non chiarisce se un plugin Codex possa portare agenti, né come una skill riceva argomenti.

**Conseguenza.** L'adattatore per Codex si rimanda, come il piano prevedeva. Il repository resta pronto a
riceverlo: le skill stanno in `skills/` alla radice, il metodo è in prosa, e la revisione di chiusura vive in
`prompts/closure-review.md`, separata dall'adattatore per Claude.

Fonti: [Package your plugin](https://developers.openai.com/plugins/build/plugins),
[Build skills](https://developers.openai.com/codex/skills).

## 0.5 — Come si invocano le skill del plugin

Una skill di plugin prende il prefisso del plugin: `skills/card-done/SKILL.md` di `cardflow` diventa
`/cardflow:card-done`. La forma breve `/card-done` funziona finché nessun altro comando usa lo stesso nome. Il nome
ha un solo livello: il namespace annidato con i due punti, come `/frontend:component`, esiste solo per i file nelle
sottocartelle di `.claude/commands/`, non per le skill di un plugin. Gli argomenti arrivano nella skill come
`$ARGUMENTS`, uno per uno come `$0` e `$1`, oppure per nome se la skill li dichiara in `arguments`.

Una skill con `disable-model-invocation: true` la lancia soltanto l'operatore: il modello non può richiamarla, e
nessuna skill può richiamarne un'altra. È il motivo per cui le skill di Matt si lanciano a mano.

**Conseguenza.** Una skill per azione, con il nome `<oggetto>-<azione>` e solo i parametri come argomenti:
`/cardflow:card-done 26258KD`, `/cardflow:branch-close feature/cr0412`. Ogni azione ha la sua descrizione e il suo
suggerimento di argomenti, carica solo le proprie istruzioni, e decide da sé se il modello può lanciarla. I comandi
si scrivono sempre con il prefisso, così le skill possono chiamarsi `init` e `help` anche se `/init` e `/help` sono
comandi di Claude Code. Il modello può lanciare `help`, `journal`, `branch-plan`, `open-points`, `status` e
`card-done`: le prime cinque rispondono a richieste come «dimmi i punti aperti», «annota nel diario» o «quali card
servono?», e scrivono solo dopo una conferma o non scrivono affatto; l'ultima perché dopo il «sì» a «Procediamo con la review e chiudiamo?» l'agente avvii da sé la
chiusura. Le altre le lancia solo l'operatore.

Fonte: [skills](https://code.claude.com/docs/en/skills).

## 0.6 — Come una skill trova i file del plugin

Nel testo di una skill o di un agente di plugin, Claude Code sostituisce `${CLAUDE_PLUGIN_ROOT}` con la cartella
in cui il plugin è installato, e `${CLAUDE_SKILL_DIR}` con quella della skill.

**Conseguenza.** Le skill leggono i modelli da `${CLAUDE_PLUGIN_ROOT}/templates/` e il progetto non ne tiene
copie. L'agente della revisione non ripete il prompt: rimanda a `${CLAUDE_PLUGIN_ROOT}/prompts/closure-review.md`,
che resta l'unica versione del testo.

Fonti: [skills](https://code.claude.com/docs/en/skills),
[plugins-reference](https://code.claude.com/docs/en/plugins-reference).

## 0.7 — Versione e aggiornamenti

Se `plugin.json` dichiara `version`, un plugin installato da git resta a quella versione: i commit nuovi non
arrivano finché il numero non cambia. Senza `version`, per le sorgenti git la versione è lo SHA del commit, e ogni
commit pubblicato è un aggiornamento. La documentazione indica questa seconda strada come la più semplice per un
plugin in sviluppo. Un plugin caricato da una cartella locale non è mai fermato dalla versione.

**Conseguenza.** `plugin.json` non dichiara `version`. Chi usa il plugin lo aggiorna aggiornando il marketplace:
dal pannello `/plugins` dell'estensione di VS Code, scheda *Marketplaces*, oppure con
`/plugin marketplace update cardflow`.

Fonti: [plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces),
[VS Code](https://code.claude.com/docs/en/vs-code).

## 0.8 — Il controllo del merge in sola lettura

`git merge-base --is-ancestor <A> <B>` esce con 0 se `A` è un antenato di `B`, con 1 se non lo è, e non scrive
niente. Dopo un merge normale o un *fast-forward* i commit del branch sono antenati del branch che li ha ricevuti, e il
controllo riesce. Dopo uno *squash* o un *rebase and merge* i commit che arrivano sono nuovi, con altri SHA, e il
controllo fallisce anche a merge fatto; lo stesso succede se il branch è stato cancellato, perché il suo nome non si
risolve più. I riferimenti sono quelli locali: un merge fatto solo sul server non si vede finché l'operatore non
aggiorna la copia locale.

**Conseguenza.** Il passo 3 di `branch-close`: se il controllo sul branch fallisce, la skill chiede il commit di merge
o la pull request e ripete il controllo su quel commit. cardflow non esegue `fetch` né `pull`.

La risposta viene dalla documentazione; la prova pratica, con uno *squash* e con un branch cancellato, è nel passo 10
della prova sul progetto giocattolo.

Fonte: [git-merge-base](https://git-scm.com/docs/git-merge-base).

## 0.9 — `to-spec` e l'intestazione della card

`/mattpocock-skills:to-spec`, nella versione 1.2.3, non scrive un file da sé: compone la spec e la «pubblica sul
tracker», cioè segue le istruzioni di `docs/agents/issue-tracker.md`. Chi scrive il file è quindi l'agente, con le
regole di cardflow. Il rischio è che l'agente usi Write, che riscrive il file intero e perde l'intestazione.

**Conseguenza.** `issue-tracker.md` chiede di aggiungere la spec con Edit, sotto la riga `---` che chiude
l'intestazione, e vieta Write su `SPEC.md`. La prova pratica è nel passo 4 della prova sul progetto giocattolo; se
l'intestazione si perde lo stesso, l'agente la rimette subito dopo la scrittura.

Fonte: il testo della skill, `skills/engineering/to-spec/SKILL.md` del plugin `mattpocock-skills` 1.2.3.

## 0.10 — I commit della card dopo un merge

`git log --first-parent` segue solo il primo genitore di ogni merge, cioè la storia del branch su cui si lavora, e
`--no-merges` toglie i commit di merge. Su un branch che riceve il branch principale a metà card,
`git log --first-parent --no-merges <base>..HEAD` elenca quindi solo i commit fatti sul branch: quelli arrivati con il
merge stanno sul secondo genitore e restano fuori, e con loro la risoluzione dei conflitti, che vive nel commit di
merge. Con `-p` ogni commit mostra la sua differenza rispetto al primo genitore, cioè il lavoro della card.

**Conseguenza.** Il punto 5 di `prompts/closure-review.md`. Un *rebase* a metà card riscrive i commit e può togliere
`BASE` dalla storia del branch: in quel caso `git rev-parse <BASE>` non basta più a dire che la base è giusta, e
`card-done` chiede da quale commit partire.

La risposta viene dalla documentazione; la prova pratica è nel passo 9 della prova sul progetto giocattolo.

Fonte: [git-log](https://git-scm.com/docs/git-log).

## 0.11 — Gli script nella bash di Git per Windows

Provato il 29 settembre 2026 con GNU bash 5.2.26 (msys), GNU grep 3.0, GNU Awk 5.0.0 e Git 2.45.1 per Windows, facendo
girare `scripts/new-id.test.sh` e `scripts/work.test.sh`: tutti i casi passano.

- `grep -w` e `grep -Fqw` trovano un codice o un Id come parola intera, e `grep -rqw --exclude-dir=notes` salta la
  cartella delle note.
- Con `LC_ALL=C` il confronto delle stringhe di bash segue l'ordine dei byte, quindi le maiuscole vengono prima delle
  minuscole e i codici si ordinano per data di nascita. Senza, con una lingua diversa da C, le minuscole si mescolano
  alle maiuscole.
- `${nome,,}` porta a minuscolo i nomi delle cartelle, e così lo script trova due cartelle che differiscono solo per le
  maiuscole.
- Awk legge il trattino lungo dei titoli `### <codice> — <titolo>` come sequenza di byte, anche con `LC_ALL=C`.

**Conseguenza.** Gli script della v2 fissano `LC_ALL=C` e si provano con le loro prove prima di ogni pubblicazione.
