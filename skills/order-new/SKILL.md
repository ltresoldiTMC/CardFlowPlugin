---
name: order-new
description: Apre un ordine cardflow, cioè una CR o una release, con la sua spec e il suo ramo. L'Id si passa, di solito il numero della CR, oppure lo genera il plugin.
argument-hint: "[order-id]"
arguments: [id]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh *)
disable-model-invocation: true
---

# /cardflow:order-new

Id richiesto: `$id`. Se è vuoto, chiedi se l'ordine ha un Id da fuori, come il numero della CR o il nome della
release; se non ce l'ha, lo genera lo script.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. I modelli
stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`.

## Passi

1. **L'Id lo dà lo script, mai un calcolo a mente.** Con lo strumento Bash, non con PowerShell:
   `bash "${CLAUDE_PLUGIN_ROOT}/scripts/new-id.sh" "<work>"`, aggiungendo l'Id in fondo se ce n'è uno. Con un Id
   passato lo script controlla soltanto che sia valido e libero; senza, ne genera uno. Se esce con un errore,
   riportalo e fermati. Come nasce l'Id lo spiega `${CLAUDE_PLUGIN_ROOT}/manual/identifiers.md`.
2. Chiedi uno slug breve in inglese, il titolo e il ramo.
3. Crea `<work>/orders/<id>-<slug>/` con `0-ORDER.md` dal modello `order/0-ORDER.md`, compilato, e `1-SPEC.md` dal
   modello `order/1-SPEC.md`: obiettivo, perimetro e criteri di accettazione, presi dalla conversazione o chiesti.
   I criteri sono quello che `/cardflow:order-close` verificherà, quindi devono essere controllabili. Una verifica
   che non scrive codice, come una prova a schermo, entra qui come criterio.
4. Se l'operatore indica file del cliente per quest'ordine, copiali in `sources/`. Da lì in poi sono in sola
   lettura.
