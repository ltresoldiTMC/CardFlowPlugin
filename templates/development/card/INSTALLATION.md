# Installazione: i passi manuali

<!-- cardflow: i passi che un'installazione esistente deve eseguire a mano per ricevere il lavoro di questa card:
database, configurazione, file, servizi. Scritto per chi installa, che non conosce il codice. Una voce per cosa
toccata, `### <che cosa>`, nell'ordine in cui si eseguono, con il passo e il modo di verificarlo. Il documento è
consolidato, non accodato: se un ticket successivo cambia la stessa cosa, la voce si riscrive con lo stato finale, e
una voce annullata si cancella. Un aggiornamento del database è uno script SQL nel repository, e la voce ne cita il
percorso; un passo su un file di configurazione dice sezione, chiave, valore. Alla chiusura della card le voci passano
nella sezione Installazione dell'handover. La forma:

### Chiave `export.folder` nel file di configurazione
Aggiungere la chiave nella sezione `export`, con il percorso della cartella di esportazione di quella postazione.
Verifica: il programma parte e l'esportazione scrive nella cartella indicata.

### Colonna `ExportedAt` nella tabella `Invoice`
Eseguire `db/migrations/2026-10-02-invoice-exported-at.sql`.
Verifica: la tabella ha la colonna, vuota sulle righe esistenti. -->
