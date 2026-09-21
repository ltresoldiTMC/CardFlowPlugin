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
`/cardflow:card-done 260916`, `/cardflow:order-close CR0412`. Ogni azione ha la sua descrizione e il suo
suggerimento di argomenti, carica solo le proprie istruzioni, e decide da sé se il modello può lanciarla. I comandi
si scrivono sempre con il prefisso, così le skill possono chiamarsi `init` e `help` anche se `/init` e `/help` sono
comandi di Claude Code. Il modello può lanciare `help`, `card-list` e `card-done`, quest'ultima perché dopo il «sì»
a «Procediamo con la review e chiudiamo?» l'agente avvii da sé la chiusura; le altre le lancia solo l'operatore.

Fonte: [skills](https://code.claude.com/docs/en/skills).

## 0.6 — Come una skill trova i file del plugin

Nel testo di una skill o di un agente di plugin, Claude Code sostituisce `${CLAUDE_PLUGIN_ROOT}` con la cartella
in cui il plugin è installato, e `${CLAUDE_SKILL_DIR}` con quella della skill.

**Conseguenza.** Le skill leggono i modelli da `${CLAUDE_PLUGIN_ROOT}/templates/` e il progetto non ne tiene
copie. L'agente della revisione non ripete il prompt: rimanda a `${CLAUDE_PLUGIN_ROOT}/prompts/closure-review.md`,
che resta l'unica versione del testo.

Fonti: [skills](https://code.claude.com/docs/en/skills),
[plugins-reference](https://code.claude.com/docs/en/plugins-reference).
