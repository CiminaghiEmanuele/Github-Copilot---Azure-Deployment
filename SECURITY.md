# Sicurezza e segnalazioni

Questo kit e' una baseline didattica, non una certificazione di sicurezza o di idoneita alla produzione.

## Segnalare un problema

Non pubblicare vulnerabilita, token o dati cliente nelle issue pubbliche.
Usare la segnalazione privata delle vulnerabilita di GitHub, se abilitata, oppure il canale interno
di sicurezza che Metix dovra' indicare nella checklist di consegna.
Fornire componente, versione/commit, impatto, riproduzione minima e mitigazione senza allegare segreti.

## Se un segreto e' stato esposto

1. Revocare o ruotare subito il segreto nel sistema di origine.
2. Avvisare il responsabile sicurezza e verificare i log di utilizzo.
3. Controllare commit, PR, artifact e log della pipeline. Limitare l'accesso alle evidenze.
4. Concordare la bonifica della cronologia con gli amministratori; cancellare solo il file non rimuove il segreto dalla storia.

## Confini del modello

- OIDC elimina il client secret statico, non il rischio di un workflow compromesso.
- Branch protection, reviewer, limiti di bypass ed environment vanno configurati su GitHub.
- Un maintainer che modifica i test puo' cambiarne il risultato: review e Azure Policy sono controlli indipendenti.
- Il ruolo Contributor usato nel solo RG demo non equivale a least privilege per una piattaforma di produzione.
- Gli artifact possono contenere nomi e identificativi di risorse: retention breve e accesso ristretto.

Consultare [bootstrap](docs/bootstrap.md), [standard](docs/standards.md) e [runbook](docs/operations.md).