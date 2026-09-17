# Standard Azure Azure v0.1

Baseline derivata dalla proposta di workshop, riusata come primo pattern della [factory](factory.md).
il team deve approvare i valori aziendali e il piano cliente prima di riutilizzarla su workload reali.
Il codice attuale implementa il perimetro in [architecture.md](architecture.md).

## Regole della factory

- Un repository privato per cliente/workload; identita, trust OIDC, scope ed evidenze isolati per cliente e ambiente.
- Goal osservabile, vincoli e criteri misurabili prima di scegliere i servizi. Approvazione umana del piano prima del codice.
- Ogni requisito ha ID, criterio, fase, metodo, suite/runbook, evidenza attesa e responsabile. Non inventare esiti o approvazioni.
- Prima del login Azure verificare goal cliente, ambiente ammesso e binding a CUSTOMER_CODE e parametri compilati.
- Per nuove risorse estendere insieme suite reali, pipeline e registro fidato. La semplice citazione di un test non dimostra copertura.
- Distinguere successo del provisioning da accettazione del goal: la seconda richiede tutte le evidenze pertinenti e review.

Le regole della tabella seguente descrivono il pattern PaaS implementato. Per un altro scenario
definire guardrail specifici attraverso una revisione esplicita; non imporre servizi non necessari
e non eliminare controlli falliti per ottenere verde. Le protezioni di Storage e Key Vault restano
obbligatorie quando tali servizi fanno parte del workload, salvo il processo formale delle eccezioni.

## Regole obbligatorie del kit

| Dominio | Regola | Evidenza/controllo |
| --- | --- | --- |
| IaC | Bicep a scope Resource Group, RG preesistente | Build e review dell'entry point |
| Riuso | AVM con versioni verificate e fissate | Restore, build e review dipendenze |
| Region | `italynorth`; DNS privato e' una risorsa globale | Parametri, allowed e review |
| Tag | Environment, Owner, CostCenter, ManagedBy=IaC, Workload | Parametri e guardrail, post-check KV/Storage |
| Storage | Public network e Blob anonimo disabilitati | Guardrail e post-check |
| Storage | Shared Key disabilitata, HTTPS e TLS >= 1.2 | Guardrail e post-check |
| Key Vault | RBAC, purge protection, soft delete | Parametri AVM e guardrail |
| Accesso privato | Endpoint vault e blob, zone e link alla VNet | Build, guardrail e test live DNS separato |
| Credenziali | Nessun segreto/tenant ID/subscription ID hard-coded | Review; secret scanning raccomandato |
| Delivery | CI PR senza OIDC o segreti Azure | Review workflow e branch protection |
| Delivery | Preview autenticata separata, deploy manuale da main | Workflow e environment protetti |
| Delivery | Nessun `pull_request_target` che esegua contenuto PR | Review workflow |
| Osservabilita | Diagnostica KV, Storage account, Blob e VNet verso LAW | Build, guardrail parziali e test live |
| Sicurezza | Nessun Public IP nel pattern | Guardrail sul template compilato |

Le istruzioni Copilot guidano il modello, non fanno enforcement. I test non sono una sandbox per
codice ostile e non sostituiscono Azure Policy o le protezioni di GitHub.

## Naming e configurazione

| Risorsa | Pattern |
| --- | --- |
| Resource Group workload, bootstrap | `rg-workload-<workload>-<env>-itn` |
| VNet | `vnet-workload-<workload>-<env>-itn` |
| Log Analytics | `law-workload-<workload>-<env>-itn` |
| Key Vault | `kv-<workload>-<env>-<hash6>` |
| Storage | `st<workload><env><hash8>` |
| Endpoint privati | `pe-<vault>` e `pe-<storage>-blob` |
| Subnet | `snet-app`, `snet-data`, `snet-private-endpoints` |

`workload` usa 2-8 caratteri alfanumerici minuscoli; `env` e' dev/test/prod.
Il suffisso deterministico deriva da Resource Group ID e workload, non contiene un ID hard-coded.
Storage resta entro 24 caratteri, alfanumerico minuscolo; Key Vault entro 24, con lettere, cifre e trattini.
L'unicita globale effettiva deve comunque essere verificata da ARM. Cambiare RG o workload cambia i nomi:
non e' una migrazione automatica e puo' lasciare risorse precedenti nel RG.

Tag applicati tramite i moduli alle risorse che li supportano. Subnet, diagnostic settings e alcuni
child resource non espongono tag: non forzare proprieta non supportate. Il bootstrap applica i tag al RG.

| Parametro | DEV | TEST | PROD di esempio |
| --- | --- | --- | --- |
| Storage SKU | Standard_LRS | Standard_LRS | Standard_ZRS |
| Retention LAW | 30 giorni | 30 giorni | 90 giorni |
| VNet | 10.40.0.0/16 | 10.41.0.0/16 | 10.42.0.0/16 |
| Subnet | .1.0/24, .2.0/24, .3.0/24 | stesso schema | stesso schema |

Questi CIDR sono esempi, non assegnazioni aziendali. La review deve verificare contenimento, assenza
di sovrapposizioni interne e con reti esistenti. Il validatore locale non calcola la compatibilita con le reti aziendali.

## Default e tradeoff WAF

| Pillar | Scelta | Limite o contropartita |
| --- | --- | --- |
| Reliability | Soft delete/versioning Blob, purge protection KV, ZRS nell'esempio PROD | Versioning non sostituisce backup/DR; nessun RTO/RPO garantito |
| Security | Private access, RBAC, no Shared Key, identita OIDC distinte | Richiede DNS, connettivita privata e gestione delle autorizzazioni |
| Cost Optimization | LRS in DEV/TEST, un solo ambiente live, retention configurabile | Endpoint, DNS e log hanno costi; il budget non blocca la spesa |
| Operational Excellence | IaC, PR, artifact, approvazione, runbook | Bootstrap e protezioni GitHub restano responsabilita amministrativa |
| Performance Efficiency | SKU e retention configurabili | Nessun workload applicativo, benchmark o autoscaling dimostrato |

Nessun NSG viene incluso sulle subnet vuote: non equivale a segmentazione sicura di un workload.
Prima di aggiungere compute definire NSG, flussi autorizzati, egress esplicito e identita applicativa.
Le network policies della subnet PE sono disabilitate esplicitamente: non disabilitano l'accesso privato
ma escludono l'applicazione di quelle policy agli endpoint. Riesaminare per ambienti produttivi.

Log Analytics usa endpoint di ingestion/query pubblici autenticati e local auth disabilitata.
Azure Monitor Private Link Scope, DNS e connettivita necessari per privatizzare Monitor non sono inclusi.
Non disabilitare ingestion/query senza aver disegnato e provato quel percorso.

## Eccezioni

Una richiesta di troubleshooting non autorizza Public IP, accesso pubblico PaaS o rimozione di RBAC.
Registrare una proposta con: regola, esigenza, rischio, alternativa valutata, owner, approvatore,
ambito, scadenza, controllo compensativo e piano di rientro. Nessuna eccezione attiva e' inclusa nel kit.
Un'eccezione approvata che cambia l'architettura richiede modifica di codice, test, guide e policy insieme.

## Controlli e limiti

`Test-Repository.ps1` compila i file, controlla i parametri, valida il goal, verifica il contratto dei wrapper AVM e i link locali.
`Test-WorkloadGoal.ps1` verifica schema, riferimenti e registro delle suite; con `-ForProvisioning`
controlla anche cliente/ambiente/parametri. Non esegue i test citati nel JSON e non valuta semanticamente
il requisito: una review deve verificare che le asserzioni della suite provino il criterio di accettazione.
`Test-Baseline.ps1` legge JSON compilato, non interpreta genericamente tutte le espressioni ARM:
i valori di sicurezza devono restare letterali per essere verificabili. Sette mutazioni in memoria provano
che violazioni rappresentative vengono bloccate. Non sono una certificazione completa dei moduli AVM.

La CI non interroga Azure. Policy, quote, disponibilita regionale, categorie diagnostiche, autorizzazioni
e accesso ai dati richiedono verifiche live. Integrare scanning IaC e segreti nel processo aziendale.

## Evoluzione

La separazione dei repository e il contratto del goal sono implementati come processo e gate locali;
onboarding remoto e prove Azure restano da eseguire. Approfondire region ammesse per servizio,
ruoli custom, policy-as-code, backup/restore, alert operativi, budget, catalogo moduli e gestione delle eccezioni.
Consultare [workshop](workshop.md) e [consegna](handover.md).