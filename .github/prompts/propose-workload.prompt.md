---
description: "Proponi una modifica coerente con il goal cliente, con architettura e test, senza modificare file."
agent: ask
argument-hint: "Requisito della modifica"
---

Leggi [factory](../../docs/factory.md), [goal](../../workload/goal.json),
[standard](../../docs/standards.md), [architettura](../../docs/architecture.md) e i moduli pertinenti in infra.
Parti dal risultato osservabile del cliente e chiedi i vincoli mancanti che cambiano la soluzione.
Per il requisito indicato dall'utente, proponi la modifica minima coerente in Bicep/AVM.
Non imporre la demo PaaS a un workload diverso e non presentare nuove tipologie come gia' verificate.
Elenca assunzioni, file coinvolti, dipendenze di rete/DNS, costi da valutare e tradeoff sui cinque pillar WAF.
Distingui guardrail obbligatori, default ed eccezioni. Proponi un test che possa smentire la soluzione.
Mappa ID requisito, criterio misurabile, suite effettiva, fase, evidenza attesa e owner.
Esplicita le suite mancanti e le modifiche necessarie a pipeline e registro; non inventare esiti o approvazioni.
Non modificare file e non eseguire operazioni Azure. Attendi approvazione per l'implementazione.