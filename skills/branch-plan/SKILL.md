---
name: branch-plan
description: Dalla spec di un branch cardflow propone il backlog, cioè le card da creare, ciascuna un pezzo che si chiude da solo e copre uno o più criteri, in ordine e con i bloccanti, e mostra quali criteri restano scoperti. Scrive backlog.md solo dopo la conferma. Usala quando l'operatore chiede quali card servono, di pianificare un branch o di proporre il backlog dalla spec.
argument-hint: "[branch]"
arguments: [branch]
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/work.sh *)
---

# /cardflow:branch-plan

Branch: `$branch`. Se è vuoto, vale il branch attivo.

Questo comando scrive solo `backlog.md`, e solo dopo la conferma dell'operatore.

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository, il branch principale, la
lingua e i percorsi dei documenti del repository stanno nel blocco cardflow del `CLAUDE.md`.

La cartella di un branch la dà lo script, con lo strumento Bash e non con PowerShell:
`bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" branch-dir "<work>" "<branch>" "<principale>"`. Esce con 0 se la cartella
esiste; altrimenti il branch non ha una spec da cui partire: dillo, proponi `/cardflow:branch-new` e fermati. Senza un
branch indicato vale il branch attivo, `git -C <repository> branch --show-current`.

## Passi

1. **La spec.** Leggi la spec del branch: obiettivo, perimetro e criteri, per il cliente e interni. Se i criteri
   mancano, dillo e fermati: senza criteri non c'è niente da coprire, e la spec si scrive con `/cardflow:branch-new`.
2. **Che cosa c'è già.** Leggi:
   - le voci del `backlog.md` del branch, se esiste;
   - la card in corso, se c'è;
   - il lavoro già fatto: gli handover della cartella `handovers/` del branch, e per il branch principale quelli in
     `<work>/deploy/handovers/pending/`;
   - i documenti del repository: il glossario per il vocabolario, le decisioni e i vincoli da rispettare,
     l'architettura per sapere dove cade il lavoro;
   - i punti aperti, con `bash "${CLAUDE_PLUGIN_ROOT}/scripts/work.sh" open-points "<work>"`, per i bloccanti;
   - il codice, quanto basta a sapere che cosa esiste già.
3. **Le voci.** Dividi quello che resta da fare in voci, una per card.
   - **Una voce è un pezzo verticale**: attraversa tutti gli strati che servono (dati, logica, interfaccia, prove) e,
     chiuso, si mostra o si verifica da solo. È lo stesso principio dei ticket di `/mattpocock-skills:to-tickets`, un
     livello sopra: una card è fatta di più ticket.
   - **La misura è una card**: un grilling, una spec e una manciata di ticket. Una voce che ne richiederebbe molti di
     più si divide; una che sta in un ticket solo si unisce a un'altra, o è una correzione di una sessione, che non
     passa dal backlog se non richiede un SQL o un passo di configurazione.
   - **Copre uno o più criteri.** Un criterio può richiedere più voci.
   - **Prima le fondamenta**: un intervento che rende facile il resto, per esempio un riordino del codice, è una voce
     a sé e viene prima.
   - **Una voce ferma per un punto aperto** porta la nota `Bloccato da:` con il codice e il titolo. Se per definire una
     voce manca una risposta che nessun punto chiede ancora, dillo: la domanda si registra con `/cardflow:journal`.
   - **Non diventa una voce** quello che è già fatto (ha un handover), la card in corso, e una proposta che nessuno ha
     chiesto: quella è una miglioria, e la segnali soltanto.
   - Usa il vocabolario del glossario, e non proporre niente che contraddica una decisione o un vincolo senza dirlo.
4. **L'ordine.** Prima le voci da cui altre dipendono, poi quelle che danno al cliente di più. La prima voce è la
   prossima card.
5. **Il confronto con il backlog che c'è.** Per ogni voce già scritta, di' se resta com'è, se va riscritta, divisa o
   unita a una nuova, o se non serve più perché fuori dal perimetro o già fatta. Non toccarla senza conferma.
6. **La copertura.** Stampa una tabella con ogni criterio, per il cliente e interno, e quello che lo copre: gli
   handover già chiusi, la card in corso, le voci proposte. Un criterio senza copertura è **scoperto**: dillo. Una voce
   che non copre nessun criterio o è fuori dal perimetro, o rivela un criterio che manca nella spec: chiedi quale dei
   due. La spec non la correggi tu: se va cambiata, dillo, e la cambia l'operatore.
7. **La proposta.** Presenta le voci come elenco numerato, nell'ordine: titolo, che cosa consegna in una o due righe,
   criteri che copre, bloccanti. Chiedi se la grana va bene (troppo grossa, troppo fine), se l'ordine regge, se qualche
   voce va unita o divisa. Ripeti finché l'operatore approva.
8. **La scrittura.** Scrivi le voci approvate in `backlog.md` della cartella del branch, che nasce dal modello
   `development/branch/backlog.md` se manca, nella forma del modello: un titolo `##`, una o due righe su che cosa e
   perché, poi le note che servono in elenco (`Bloccato da:`, `Vedi:`, `Note:`). Applica alle voci già esistenti le
   decisioni del passo 5. L'ordine del file è l'ordine approvato.

Il diario non si scrive: pianificare non è un evento. Indica il passo successivo: `/cardflow:card-new` prende la prima
voce.
