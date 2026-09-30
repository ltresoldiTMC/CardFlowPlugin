---
name: release
description: Crea una consegna cardflow. Prende gli handover e i riepiloghi non ancora rilasciati, chiede la versione all'operatore, crea la cartella della versione con note di rilascio, passi di installazione e script SQL, aggiorna l'installazione completa, scrive il diario e propone il tag.
disable-model-invocation: true
---

# /cardflow:release

## Prima di tutto

Leggi `.WORKDIR` nella cartella di lavoro: una riga, togliendo spazi ed eventuale BOM. Se manca, se il percorso non
è assoluto o la cartella non esiste, fermati e rimanda a `/cardflow:init`. Quel percorso è `<work>`. Se nella radice
di `<work>` c'è una cartella `cards/`, `orders/` o `project/`, la struttura è quella della v1: fermati e dillo, perché
va migrata prima. I modelli stanno in `${CLAUDE_PLUGIN_ROOT}/templates/`. Il repository e il branch principale stanno
nel blocco cardflow del `CLAUDE.md`. Il branch attivo si legge con `git -C <repository> branch --show-current`.

## Passi

In quest'ordine, fermandoti a ogni passo che chiede una risposta.

1. **Condizioni.** Il branch attivo è il principale; se no, dillo e fermati. In `<work>/deploy/handovers/pending/` c'è
   almeno un file, oppure non esiste ancora nessuna consegna in `<work>/deploy/releases/`; se no, non c'è niente da
   rilasciare. Il secondo caso è il primo rilascio di un progetto nuovo o migrato: il lavoro fatto prima di cardflow
   non ha handover.
2. **Elenco.** Mostra i file in attesa, in ordine di chiusura: Id, titolo e `TIPO` per gli handover; branch ed esito
   dei criteri per i riepiloghi. L'operatore conferma, oppure esclude qualcosa, che resta in attesa.
3. **Versione.** Chiedila all'operatore, e aiutalo:
   - la versione precedente è la più alta fra le cartelle di `<work>/deploy/releases/`; si confronta con l'ultimo tag
     del repository, letto in sola lettura, e se non coincidono lo si dice;
   - i `TIPO` degli handover inclusi si mostrano con quello che di solito comportano in
     [Semantic Versioning](https://semver.org/): `incompatibile` la prima cifra, `funzione` quella centrale,
     `correzione` l'ultima;
   - la forma del tag, con o senza la `v` davanti, si ricava dai tag esistenti; al primo rilascio si chiede;
   - se il repository dichiara una versione nel codice, per esempio in un file di progetto, e non coincide, lo si dice:
     allinearla è un commit dell'operatore.
4. **Prossima versione.** Se la spec del branch principale ha dei criteri, valutali come fa `/cardflow:status` e chiedi
   se l'esito entra nella consegna.
5. **Consegna.** Crea `<work>/deploy/releases/<versione>/` con:
   - `RELEASE-NOTES.md`, dal modello `deploy/RELEASE-NOTES.md`: che cosa cambia per chi usa il programma, dalle sezioni
     *Che cosa fa ora* degli handover, verificato sul codice; i limiti noti, dalle sezioni *Che cosa è ancora finto o
     parziale*; l'elenco delle card e dei branch inclusi, con Id e titolo. Al primo rilascio, quello che il programma
     fa già si descrive dalla spec del branch principale e dai documenti del repository, perché il lavoro fatto prima
     degli handover non ha un racconto suo;
   - `INSTALLATION.md`, dal modello `deploy/release/INSTALLATION.md`: i passi delle sezioni *Installazione* degli
     handover, consolidati nell'ordine di esecuzione, con lo stato finale di ogni cosa toccata. Al primo rilascio,
     l'installazione completa;
   - `sql/`, con gli script SQL citati dai passi, copiati dal repository e numerati nell'ordine in cui si eseguono;
   - il riepilogo di ogni branch incluso e, se richiesto al passo 4, l'esito dei criteri della prossima versione.

   Non scrivere script: un passo che cita un SQL assente dal repository si ferma, e l'operatore decide.
6. **Handover.** Sposta ogni file incluso da `<work>/deploy/handovers/pending/` a `<work>/deploy/handovers/<versione>/`.
7. **Installazione completa.** Aggiorna `<work>/deploy/INSTALLATION.md`, che nasce dal modello `deploy/INSTALLATION.md`
   se manca, con i passi della versione, chiedendo: un'installazione nuova deve già avere la tabella e la chiave nuove.
8. **Prossima versione.** Chiedi se i criteri della spec del branch principale si svuotano, per l'impegno successivo.
9. **Diario.** Aggiungi in fondo a `<work>/control/journal.md` una voce `### <oggi> — Rilasciata la versione
   <versione>`, con `Fonte: rilascio.` e un `Effetto:` con le card e i branch inclusi, con Id e titolo, e il percorso
   della consegna.
10. **Tag.** Stampa il comando per il tag, nella forma dei tag esistenti, per esempio
    `git -C "<repository>" tag -a v1.3.0 -m "1.3.0"`, e ricorda che, se il progetto ricava la versione dal tag, il tag
    va creato prima di compilare quello che si installa.

Nessuna operazione su git che scrive.
