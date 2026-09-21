# cardflow — identificativi

cardflow dà un nome a quattro cose: gli ordini, le card, i ticket e le voci dei registri. Questa pagina dice come
nasce ciascun identificativo, come si legge e come si cita.

## Ordini e card

Ordini e card usano lo stesso identificativo e lo stesso spazio di nomi: una card e un ordine non hanno mai lo
stesso Id, quindi un Id da solo basta a dire di chi si parla.

L'Id si può **dare**, oppure lo **genera** il plugin. Un ordine di solito lo porta da fuori: il numero della CR
(`CR2606`) o il nome della release (`V1.0.0-ALPHA`), e lo si passa a `/cardflow:order-new`. Una card di solito se
lo fa generare da `/cardflow:card-new`, ma accetta anche un Id scelto. In entrambi i casi il plugin controlla che
sia libero prima di usarlo.

### L'Id generato

```text
26264VV
││└┬┘└┴─ ora del giorno, in una di 529 fasce di circa 163 secondi
││ └──── giorno dell'anno, 001–366 (data ordinale ISO 8601)
└┴────── anno, due cifre
```

Tutto è in **tempo universale (UTC)**. Le due lettere vengono da un alfabeto di 23: le lettere dalla `A` alla `Z`
senza `I`, `L` e `O`, che si confondono con `1` e `0`.

| A | B | C | D | E | F | G | H | J | K | M | N | P | Q | R | S | T | U | V | W | X | Y | Z |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 |

La fascia è `prima lettera × 23 + seconda lettera`. Per leggere `26264VV`: anno 2026, giorno 264, cioè il 21
settembre; la fascia è `18 × 23 + 18 = 432`, e cominciava alle 19:35:57 UTC. Nessuno ha bisogno di fare il conto
a mano: serve solo a sapere che le lettere codificano un orario.

L'Id è fatto così per quattro ragioni:

- **si ordina da solo.** Tutti gli Id generati hanno la stessa lunghezza, e dopo la data vengono solo lettere in
  ordine alfabetico. L'ordine alfabetico coincide quindi con quello di creazione, anche in Esplora risorse e in VS
  Code, che leggono le cifre come numeri: una cifra subito dopo la data si fonderebbe con lei e manderebbe la
  cartella in fondo;
- **la data si legge**: le prime cinque cifre dicono l'anno e il giorno;
- **è corto**: sette caratteri, da dire a voce o da scrivere a mano;
- **è sicuro su qualunque disco**: solo maiuscole, perché Windows non distingue `a` da `A` nei nomi delle cartelle.

**Scartato.** La data `AAMMGG` con un suffisso `-2` per la seconda card del giorno, che dava lunghezze diverse. Un
tempo Unix in base 36, illeggibile e da calcolare. Cifre dopo la data, che rompono l'ordinamento naturale. Un hash,
che per costruzione disperde l'ordine. Lettere casuali, che perdono l'ordine fra le card dello stesso giorno.

### Come nasce, e che cosa succede se è già preso

L'Id lo produce lo script `scripts/new-id.sh` del plugin, mai l'agente a mente: contare i giorni dell'anno e
convertire un orario sono calcoli che un modello sbaglia.

```bash
bash scripts/new-id.sh <radice di .work>            # genera un Id libero
bash scripts/new-id.sh <radice di .work> CR2606     # controlla un Id scelto e lo restituisce
```

Un Id è preso quando esiste una cartella `<id>-<slug>` fra le card, fra gli ordini o negli archivi delle card
chiuse. Se la fascia di adesso è presa, lo script passa alla successiva: l'Id resta unico e resta dopo quello già
esistente, quindi l'ordine regge. Il caso capita solo con due card create a meno di tre minuti l'una dall'altra.
Resta scoperto soltanto il caso di due sessioni che creano nello stesso istante, ed è trascurabile.

Un Id scelto può contenere lettere, cifre, punti e trattini singoli; niente spazi e niente `/`. Lo script si
verifica con `bash scripts/new-id.test.sh`.

**Una conseguenza dell'UTC.** In Italia il giorno UTC comincia all'una d'inverno e alle due d'estate: una card
creata poco dopo la mezzanotte porta la data del giorno prima.

### La cartella

La cartella di un ordine o di una card è `<id>-<slug>`: `26264VV-certificate-numbering`, `CR2606-calendar`. Lo
slug è breve, in inglese, con i trattini al posto degli spazi. L'Id vero è quello scritto nel campo `Id:`
dell'intestazione, non quello che si ricava dal nome della cartella.

## Come si citano

**Nei comandi** si passa l'Id oppure il nome intero della cartella: `/cardflow:card-done 26264VV` e
`/cardflow:card-done 26264VV-certificate-numbering` fanno la stessa cosa.

**Nei documenti** si scrivono l'Id e il titolo insieme: «`26264VV` (numerazione dei certificati)». Mai il
percorso: una card chiusa cambia cartella, l'Id resta.

**Non c'è gerarchia.** Una card non sta dentro il suo ordine: le card sono tutte in `cards/`, e l'ordine è il campo
`Ordine:` dell'intestazione. Assegnare una card a un altro ordine cambia quella riga e nient'altro.

## Ticket

Un ticket si cita `<card-id>/NN`: `26264VV/01` è il primo ticket della card `26264VV`. I numeri partono da `01`
dentro `tickets/` della card, in ordine di dipendenza. È l'unico riferimento composto del metodo.

## Voci dei registri

Le voci dei punti aperti e delle decisioni hanno un codice fatto di una lettera e di un numero:

| Lettera | Voce | Registro |
|---|---|---|
| `T` | punto aperto tecnico | `2-OPEN-POINTS-TECHNICAL.md` |
| `C` | punto aperto per il cliente | `3-OPEN-POINTS-CLIENT.md` |
| `D` | decisione | `4-DECISIONS.md` |

La lettera dice il tipo della voce, non il livello. Il livello lo dice il file in cui la voce sta in quel momento:
il progetto (`project/`) o un ordine (`orders/<id>-<slug>/`). Il codice non cambia quando la voce sale
dall'ordine al progetto, alla chiusura dell'ordine: se contenesse il livello, ogni citazione si romperebbe.

Il codice è unico in tutto il progetto: il prossimo è il numero più alto già usato con quella lettera, in
`project/` e in ogni ordine, più uno. I punti aperti di una card non hanno codice: lo prendono quando salgono
all'ordine. Glossario, vincoli e migliorie non hanno codice e si citano per titolo.

Un progetto arrivato da un metodo precedente può conservare codici con altre lettere, perché altri documenti li
citano. Il commento in testa al registro ne dà la legenda.

Come le card, una voce si cita con il codice e il titolo: «`I16` (che cosa codifica il prefisso del numero di
certificato)». Il codice da solo non dice niente a chi legge.

## Blocked by

Il meccanismo viene dai ticket. Ogni ticket ha la riga `Blocked by:` con i ticket che devono chiudersi prima, e un
bloccante è aperto finché il suo file esiste: chiuso il ticket, il file si cancella e il blocco sparisce da solo.

Una card usa la stessa riga, nell'intestazione di `0-CARD.md`, con i codici e i titoli delle voci di registro che
la tengono ferma:

```text
Blocked by: I16 (che cosa codifica il prefisso del numero di certificato)
```

La logica è la stessa, perché nei registri una voce risolta si cancella: il blocco resta aperto finché la voce con
quel codice esiste in un registro, e sparisce quando la voce se ne va. Vuoto vuol dire che la card può procedere.

`/cardflow:card-list` mostra i bloccanti ancora aperti di ogni card, e `/cardflow:open-points` dice, per ogni voce,
quali card tiene ferme. Prima della spec e prima di un ticket l'agente avvisa se la card ha bloccanti aperti; se
l'operatore vuole procedere si procede, ma l'avviso viene prima.
