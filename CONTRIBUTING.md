# Contribuire

1. Leggere [factory](docs/factory.md), [goal](workload/goal.json), [standard](docs/standards.md) e [architettura](docs/architecture.md).
2. Raccogliere obiettivo, cliente, ambiente, owner, criteri misurabili e costi; ottenere approvazione del piano tecnico prima del codice.
3. Creare un branch breve dalla versione corrente di `main`. Una modifica logica per PR.
4. Proporre il diff con Copilot o manualmente, senza alterare i controlli per far passare la modifica.
5. Eseguire `pwsh -File scripts/Test-Repository.ps1` dalla root.
6. Aprire la PR usando il template e richiedere al maintainer una preview sullo SHA esatto.
7. Dopo ogni nuovo commit, ripetere controlli e preview. L'approvazione di un vecchio SHA non vale per il nuovo.
8. Fare merge solo dopo review. Il merge non avvia un deployment.

## Convenzioni

- Bicep con indentazione a due spazi, PowerShell a quattro, YAML a due.
- Codice e nomi dei parametri in inglese; guide e note di consegna in italiano.
- AVM e Actions a versioni fissate. Non aggiornare tutti i moduli durante la demo.
- Niente chiavi, token, certificati, dati cliente o file `.artifacts` nei commit.
- Evitare refactoring non necessari e duplicazione tra ambienti.
- Un cliente/workload per repository: non introdurre dati, identita o scope di altri clienti.
- Mantenere tracciabilita tra REQ-nnn, decisione, asserzioni del test ed evidenza. Non scrivere risultati non osservati.

## Responsabilita

il team deve nominare i responsabili di piattaforma, sicurezza, finanza e approvazione dei rilasci.
Configurare CODEOWNERS con utenti/team reali e review obbligatorie su infra, workflow, script e standard.
Non viene consegnato un CODEOWNERS fittizio: un file con team inesistenti darebbe una falsa garanzia.

I controlli locali sono specifici del pattern, non un motore universale di compliance ARM.
Nuove risorse richiedono nuovi test, review dei permessi e, dove opportuno, Azure Policy.
Per suite nuove aggiornare insieme implementazione, test negativi, pipeline e registro del validatore
goal. Qualificare prima su main i validatori usati dalla preview autenticata; non eseguire script della
PR con credenziali. Un test dichiarato nel goal deve essere revisionato per la sua copertura effettiva.