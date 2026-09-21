# Etichette di triage

Le skill ragionano in termini di cinque ruoli canonici di triage. Su un tracker a file l'etichetta è il valore
della riga `Status:` in testa al ticket, come dice `issue-tracker.md`, e le stringhe coincidono con i nomi
canonici.

| Ruolo in mattpocock/skills | Stringa nel nostro tracker | Significato |
|---|---|---|
| `needs-triage` | `needs-triage` | Va ancora valutato |
| `needs-info` | `needs-info` | In attesa di informazioni da chi l'ha segnalato |
| `ready-for-agent` | `ready-for-agent` | Specificato del tutto, pronto per un agente |
| `ready-for-human` | `ready-for-human` | Richiede un'implementazione umana |
| `wontfix` | `wontfix` | Non verrà preso in carico |

Quando una skill nomina un ruolo, usa la stringa della colonna centrale.
