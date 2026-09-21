# Documenti di dominio

Come le skill di ingegneria consumano la documentazione di dominio di questo progetto. Il layout è
single-context, ma **non usa `CONTEXT.md` né `docs/adr/`**: i loro ruoli li coprono i registri di cardflow,
dentro `.work/`. La radice di `.work/` si legge da `.WORKDIR`, come dice `issue-tracker.md`; qui si chiama
`<work>`.

**Non creare mai `CONTEXT.md` né `docs/adr/`**, nemmeno quando `/mattpocock-skills:domain-modeling` o
`/mattpocock-skills:grill-with-docs` lo propongono.

## Prima di esplorare, leggi questi

- `<work>/project/6-GLOSSARY.md`: il glossario, al posto di `CONTEXT.md`.
- `<work>/project/4-DECISIONS.md` e il `4-DECISIONS.md` dell'ordine della card: le decisioni in vigore, al posto
  di `docs/adr/`. Si citano con il codice `D<n>`.
- `<work>/project/7-CONSTRAINTS.md`: i vincoli che non abbiamo scelto.

Per sapere che cosa è ancora aperto: `2-OPEN-POINTS-TECHNICAL.md` e `3-OPEN-POINTS-CLIENT.md` del progetto e
dell'ordine, e `2-OPEN-POINTS.md` della card. Aperto e deciso non sono intercambiabili: proporre come aperta una
cosa già decisa riapre discussioni chiuse.

Se uno di questi file non esiste, procedi in silenzio.

## Durante un grilling non si scrive nei registri

I registri si aggiornano solo alle chiusure, di card o di ordine. Quello che emerge in un grilling resta nella
card su cui si sta lavorando:

| Emerge | Dove va durante il lavoro |
|---|---|
| un termine nuovo o precisato | `.scratch/` della card, poi `1-SPEC.md` |
| una decisione | `1-SPEC.md` della card; prima che la spec esista, `.scratch/` |
| una domanda senza risposta | `2-OPEN-POINTS.md` della card: una voce `### <titolo>` e qualche riga se serve, senza codice |
| un vincolo o una miglioria | `.scratch/` della card |

Alla chiusura della card, `/cardflow:card-done` propone di portarli nei registri, uno per uno.

Una decisione arriva al registro solo se risponde a tre domande: che cosa è stato scartato e perché, perché il
codice non basta a capirla, fino a quando vale. È lo stesso filtro con cui `/mattpocock-skills:domain-modeling`
decide se proporre un ADR, detto con altre parole.

## Usa il vocabolario del glossario

Quando nomini un concetto di dominio, in un ticket, in una proposta o nel nome di una classe, usa il termine come
lo definisce il glossario. Un concetto che manca è un segnale: o stai inventando un linguaggio che il progetto
non usa, o c'è una lacuna da annotare nella card.

## Nel codice il vocabolario sì, i codici no

Un commento non cita mai una decisione, un punto aperto, una card o un ticket per codice: dice per esteso il
motivo, la trappola o il vincolo, per chi legge il codice senza accesso a `.work/`.

## Segnala i conflitti

Se quello che proponi contraddice una decisione in vigore, dillo invece di scavalcarla:

> _Contraddice `D12`, ma vale la pena riaprirla perché…_
