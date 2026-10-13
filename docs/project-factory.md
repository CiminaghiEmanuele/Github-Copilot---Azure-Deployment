# Project factory

Questa factory aggiunge un livello di lavoro per ridurre il tempo tra richiesta cliente, progetto
vendibile e deployment Azure. Il perimetro resta controllato: Copilot aiuta a raccogliere requisiti,
preparare file e generare IaC/documentazione, ma non approva costi, non crea risorse e non inventa
evidenze.

## Quando parte il flusso

Se una conversazione inizia con una richiesta del tipo "devo tirare su questa infrastruttura Azure",
l'assistente deve avviare discovery guidata prima di scrivere IaC. La prima risposta deve chiarire:

- obiettivo osservabile del cliente;
- nome progetto da usare in `projects/<nome-progetto>/`;
- codice cliente non sensibile;
- ambienti richiesti;
- vincoli mancanti che cambiano architettura, costi o rischio.

Non scegliere subito i servizi solo perche' sono familiari. La demo PaaS nel repository e' un pattern
riusabile quando il goal lo giustifica, non una soluzione universale.

## Struttura progetto

Ogni nuovo progetto locale usa questa struttura:

```text
projects/<project-name>/
  project.json
  iac/
    main.bicep
    parameters/
  docs/
    discovery.md
    architecture.md
    delivery-plan.md
    estimate.md
    acceptance.md
  tests/
    README.md
  evidence/
    README.md
```

`iac/` contiene solo Infrastructure as Code e parametri non sensibili. `docs/` contiene materiale
progettuale consegnabile: scope, architettura, assunzioni, WAF tradeoff, piano di delivery,
dipendenze cliente, criteri di accettazione e limiti. `tests/` descrive suite automatiche e prove
manuali previste. `evidence/` raccoglie indici e riferimenti alle prove reali, mai segreti.

## Domande minime

Raccogliere le risposte in piccoli gruppi, fermandosi quando un blocco modifica la soluzione:

| Area | Domande |
| --- | --- |
| Cliente e progetto | Nome progetto, codice cliente, owner, stakeholder, urgenza, ambienti. |
| Risultato | Quale capacita deve esistere dopo il deploy, chi la usa, cosa misura il successo. |
| Dati | Classificazione, volumi, retention, cifratura, backup, requisiti normativi. |
| Accesso | Utenti, applicazioni, identita, ruoli, segregazione, accesso amministrativo. |
| Rete | VNet nuove/esistenti, CIDR, DNS, connettivita privata, firewall, peering, VPN/ExpressRoute. |
| Resilienza | SLO, RTO/RPO, single/multi-region, restore test, finestre di manutenzione. |
| Operazioni | Logging, alert, runbook, escalation, monitoraggio costi, handover. |
| Vincoli | Regione, budget, policy aziendali, servizi vietati, risorse esistenti da integrare. |
| Accettazione | REQ-001..REQ-nnn con evidenza, owner, fase e metodo di verifica. |

Non chiedere password, token, chiavi, secret, tenant ID o subscription ID in chat. Gli identificativi
Azure necessari al bootstrap e alle pipeline si configurano fuori dalla documentazione vendibile.

## Comandi utili

Creare una cartella progetto dal template:

```powershell
pwsh -File scripts/New-Project.ps1 -ProjectName contoso-portale -CustomerCode contoso -Workload portal -Owner platform-team
```

Il comando copia [projects/_template](../projects/_template/README.md), crea le directory previste e
sostituisce i placeholder non sensibili. Dopo la creazione, completare discovery e piano prima di
riempire il Bicep con risorse reali.

## Regole di vendita e consegna

- La documentazione deve essere utile a un cliente: obiettivi, assunzioni, decisioni, rischi, costi da
  validare, dipendenze e responsabilita devono essere espliciti.
- Ogni requisito deve indicare una prova reale. Una build Bicep dimostra sintassi, non risultato.
- Un progetto in `projects/` puo' servire a pre-sales, offerta tecnica, implementazione o handover;
  il deployment effettivo resta soggetto a PR, preview, approvazioni e bootstrap.
- Se piu' clienti entrano nello stesso repository, non mischiare segreti, environment, OIDC trust o
  subscription. Per produzione isolata resta preferibile un repository privato per cliente/workload.
- Non dichiarare approvazioni, test superati o stime definitive se non sono stati verificati da persone
  e strumenti autorizzati.

## Criterio di pronto per build

Un progetto e' pronto per implementazione IaC quando esistono:

- `project.json` con progetto, cliente, owner, ambienti e stato;
- [discovery](../projects/_template/docs/discovery.md) con domande risolte e aperte;
- [architecture](../projects/_template/docs/architecture.md) con opzione raccomandata, alternativa e tradeoff WAF;
- [delivery plan](../projects/_template/docs/delivery-plan.md) con fasi, test e responsabilita;
- requisiti REQ misurabili con evidenze attese;
- approvazione umana del piano, registrata fuori dal file come review o conferma tracciabile.

Solo dopo questo punto Build puo' produrre risorse Bicep, suite e guide operative coerenti.