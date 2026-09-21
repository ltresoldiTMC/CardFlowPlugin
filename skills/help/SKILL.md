---
name: help
description: Spiega cardflow, cioè i comandi, il giro di una card e dove sta il manuale. Usala quando l'operatore chiede aiuto su cardflow o su uno dei suoi comandi.
argument-hint: "[argomento]"
---

# /cardflow:help

Leggi `${CLAUDE_PLUGIN_ROOT}/manual/overview.md`: è l'unica fonte. Non aggiungere regole che il manuale non
contiene.

**Senza argomenti** stampa soltanto, senza preamboli:

1. la tabella della sezione *Comandi* del manuale;
2. il giro di una card, i passi con il loro comando, dalla sezione *Una card, dalla nascita alla chiusura*;
3. il percorso del manuale, `${CLAUDE_PLUGIN_ROOT}/manual/overview.md`.

**Con un argomento** (`$ARGUMENTS`), per esempio `card done`, `ticket`, `decisioni` o `handover`: rispondi solo con
quello che il manuale dice su quel tema, in breve, e indica la sezione. Se il manuale non ne parla, dillo.

In fondo, una riga sullo stato del progetto: se nella cartella di lavoro manca `.WORKDIR`, «progetto non
configurato: lancia `/cardflow:init`»; altrimenti «configurato, `.work` in <percorso letto da `.WORKDIR`>».
