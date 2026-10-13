---
description: "Avvia un nuovo progetto Azure con domande guidate, piano e cartella projects/<nome>."
agent: agent
argument-hint: "Descrizione iniziale dell'infrastruttura richiesta"
---

Leggi [project factory](../../docs/project-factory.md), [factory](../../docs/factory.md),
[standard](../../docs/standards.md), [schema goal](../../workload/goal.schema.json) e il template in
[projects/_template](../../projects/_template/README.md).

Parti dal risultato osservabile richiesto dall'utente, non dai servizi Azure ipotizzati. Se manca il nome
progetto, chiedilo subito insieme al codice cliente non sensibile. Poi fai domande in piccoli gruppi su:
ambienti, dati, utenti/carico, rete/DNS, identita, dipendenze esistenti, disponibilita, RTO/RPO, regione,
budget, vincoli di sicurezza/compliance, owner e criteri di accettazione.

Quando hai abbastanza risposte, crea `projects/<project-name>/` copiando la struttura logica del template:
`iac/`, `docs/`, `tests/`, `evidence/` e `project.json`. Inserisci solo bozze verificabili, placeholder
espliciti e decisioni approvate o dichiarate come assunzioni. Non creare risorse Azure, non inserire segreti,
tenant ID o subscription ID, non dichiarare test eseguiti.

Se il piano non e' approvato, fermati alla discovery e alla documentazione di domande aperte. Se e'
approvato, prepara IaC Bicep/AVM coerente, documentazione progettuale vendibile, test previsti e checklist
di delivery. Esegui o chiedi l'esecuzione delle verifiche locali disponibili e riporta solo evidenze reali.