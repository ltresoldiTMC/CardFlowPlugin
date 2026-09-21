---
name: help
description: Spiega cardflow, cioè i comandi, il giro di una card, gli identificativi e dove sta il manuale. Usala quando l'operatore chiede aiuto su cardflow o su uno dei suoi comandi.
argument-hint: "[argomento]"
---

# /cardflow:help

Il manuale sono due file, e sono l'unica fonte: `${CLAUDE_PLUGIN_ROOT}/manual/overview.md`, il metodo, e
`${CLAUDE_PLUGIN_ROOT}/manual/identifiers.md`, come nascono e si citano gli Id di ordini e card, i ticket e i codici
dei registri. Non aggiungere regole che il manuale non contiene.

**Senza argomenti** leggi `overview.md` e stampa soltanto, senza preamboli:

1. la tabella della sezione *Comandi*;
2. il giro di una card, i passi con il loro comando, dalla sezione *Una card, dalla nascita alla chiusura*;
3. il percorso dei due file del manuale.

**Con un argomento** (`$ARGUMENTS`), per esempio `card-done`, `ticket`, `decisioni`, `handover` o `id`: rispondi
solo con quello che il manuale dice su quel tema, in breve, e indica il file e la sezione. Per Id, codici,
riferimenti e `Blocked by` leggi `identifiers.md`; per il resto `overview.md`. Se il manuale non ne parla, dillo.

In fondo, una riga sullo stato del progetto: se nella cartella di lavoro manca `.WORKDIR`, «progetto non
configurato: lancia `/cardflow:init`»; altrimenti «configurato, `.work` in <percorso letto da `.WORKDIR`>».
