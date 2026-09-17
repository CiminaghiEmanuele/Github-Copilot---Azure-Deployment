# Bootstrap Azure e GitHub

Questa procedura e' per un amministratore autorizzato. **Crea risorse, identita e assegnazioni RBAC:**
eseguirla solo dopo approvazione esplicita di scope e costi. Nessun passaggio e' stato eseguito dalla
preparazione del repository. Il bootstrap non fa parte di `infra/main.bicep`.

Seguire prima [factory](factory.md): un repository privato per cliente/workload, con goal e piano
tecnico approvati. I nomi demo di questa guida sono esempi, non target da condividere tra clienti.
La configurazione GitHub non viene ereditata quando si crea un repository dal template.

## Decisioni da raccogliere

- Codice cliente, repository GitHub privato definitivo e owner organizzazione.
- Subscription/tenant del cliente, RG dedicati per workload/ambiente e region approvata (default Italy North).
- Goal reale, tag, CIDR approvati, ambienti autorizzati e durata/costi della prima prova DEV.
- Amministratore Azure autorizzato a creare RG/identita e assegnare ruoli.
- Maintainer/reviewer GitHub e funzionalita di protezione environment disponibili nel piano GitHub.
- Policy applicabili e disponibilita dei servizi/SKU: non modificare policy per far passare la demo.

## 1. Prerequisiti Azure

Un amministratore prepara:

1. RG workload `rg-workload-demo-dev-itn`, Italy North, con i cinque tag obbligatori.
2. RG separato per le identita di automazione, con tag e ownership amministrativa.
3. Registrazione dei provider Microsoft.Network, Microsoft.Storage, Microsoft.KeyVault,
   Microsoft.OperationalInsights e Microsoft.Insights, secondo il processo aziendale.
4. Due user-assigned managed identities: una per preview e una per deployment DEV.

Per TEST/PROD ripetere con RG e identita separati. Non condividere una identity con diritti su tutti gli ambienti.
Per un altro cliente ripetere l'intero bootstrap: non riusare identita, scope o federazioni OIDC.
Non creare le identita dentro un RG che la identity di deployment puo' amministrare liberamente.

Si puo' usare il portale Azure: Resource groups -> Create; Managed Identities -> Create.
Annotare **client ID** per il login, **principal/object ID** per RBAC e tenant/subscription del contesto.
Non confondere i due ID e non crearne copie hard-coded nei template.

## 2. Ruoli

| Identita | Ruolo/azioni | Scope |
| --- | --- | --- |
| Preview | Ruolo custom con `*/read`, `Microsoft.Resources/deployments/validate/action`, `Microsoft.Resources/deployments/whatIf/action` | Solo RG workload |
| Deployment demo | Contributor, senza ruoli data plane | Solo RG workload |
| Amministratore bootstrap | Permessi di creazione identita e assegnazione ruoli | Solo scope amministrativi necessari |

Il ruolo preview non ha `write`, `delete`, `listKeys/action`, assegnazioni RBAC o DataActions.
`ProviderNoRbac` richiede Azure CLI >= 2.76 e riduce i controlli delle autorizzazioni sulle risorse
alla lettura; l'identita deve comunque poter invocare validate e What-If.

Per il ruolo custom: Azure Portal -> Access control (IAM) -> Add custom role.
Nome suggerito `il team Deployment Preview`, descrizione del solo scopo preview; inserire le tre azioni
elencate, nessuna DataAction, e assegnare lo scope al RG reale. Creare e assegnare il ruolo con un
amministratore autorizzato. Verificarlo live: la compilazione non prova l'effettivo accesso ARM.
In caso di diniego leggere l'azione e lo scope mancanti; non sostituire automaticamente con Contributor.

Contributor al RG e' una semplificazione didattica: puo' modificare/eliminare risorse in quel RG, non e'
il minimo privilegio assoluto. Il workload non crea role assignments, quindi non richiede Owner o User
Access Administrator. Prima dell'adozione aziendale derivare un ruolo deployment custom dalle operazioni
dei moduli AVM e dei post-check effettivamente usati. Non assegnare Contributor alla subscription.

## 3. Environment GitHub

In Settings -> Environments creare per DEV:

- `preview-dev`: credenziali identity preview, reviewer obbligatori, branch di esecuzione solo `main`.
- `dev`: credenziali identity deployment, reviewer obbligatori, branch di esecuzione solo `main`.

Creare `preview-test`/`test` e `preview-prod`/`prod` solo quando quegli ambienti sono approvati.
Impedire self-review e bypass amministrativi ove supportato. Un solo reviewer tra quelli elencati puo'
essere sufficiente per GitHub: definire il processo di separazione dei compiti in base al piano disponibile.

**Bloccare il rilascio se il piano GitHub non permette il gate richiesto.** Il campo `environment` nel YAML
non imposta reviewer o branch restriction. Un environment non protetto non ferma il job.

In ciascun environment creare le cinque **Variables**, non client secret:

| Variabile | Valore |
| --- | --- |
| `CUSTOMER_CODE` | Codice cliente non sensibile, identico a `customerCode` nel goal, rispettando maiuscole/minuscole |
| `AZURE_CLIENT_ID` | Client ID della identity corrispondente |
| `AZURE_TENANT_ID` | Tenant della subscription |
| `AZURE_SUBSCRIPTION_ID` | Subscription target |
| `AZURE_RESOURCE_GROUP` | Nome del RG workload, identico tra preview e deploy dello stesso ambiente |

Il codice cliente deve essere uguale in `preview-dev` e `dev`, e negli eventuali altri environment
dello stesso cliente. Un amministratore ne verifica la corrispondenza con repository, tenant,
subscription e RG reali. Il confronto del codice non dimostra da solo la proprieta del target Azure.
Limitare chi puo' modificare queste variabili e le protezioni degli environment.

Questi ID non sono credenziali. Non condividere comunque inventari di tenant/subscription in una
consegna pubblica. Non usare `AZURE_CREDENTIALS` o password.

## 4. Federazione OIDC

Sulla managed identity Azure -> Federated credentials -> Add credential -> GitHub Actions.
Usare owner/repository **reali** e subject esatto, rispettando maiuscole/minuscole:

| Identity | Issuer | Subject | Audience |
| --- | --- | --- | --- |
| Preview DEV | `https://token.actions.githubusercontent.com` | `repo:ORGANIZZAZIONE/REPOSITORY:environment:preview-dev` | `api://AzureADTokenExchange` |
| Deploy DEV | stesso issuer | `repo:ORGANIZZAZIONE/REPOSITORY:environment:dev` | stessa audience |

Sostituire ORGANIZZAZIONE/REPOSITORY nel portale. Non creare trust generici per branch PR o `pull_request`.
Un subject environment non contiene il branch: la restrizione a `main` deve essere configurata su GitHub.
Per TEST/PROD usare environment e identita corrispondenti. Attendere la propagazione quando si prova il login.

## 5. Proteggere il repository

Settings -> Rulesets/Branches, per `main`:

1. Richiedere PR, almeno una review indipendente, risoluzione delle conversazioni e controlli aggiornati.
2. Dopo la prima run, selezionare il check `Local validation` del workflow Validate come obbligatorio.
3. Revocare approvazioni su nuovi commit; vietare force push e cancellazione del branch.
4. Limitare bypass, ruoli amministrativi, chi puo' avviare workflow e chi puo' approvare gli environment.
5. Aggiungere CODEOWNERS con team reali per infra, script, workflow e standard; richiedere relativa review.
6. Abilitare secret scanning/push protection se disponibili e review delle PR Dependabot.

La preview non pubblica automaticamente uno status obbligatorio sullo SHA della PR. Il maintainer deve
collegare la run e confrontare lo SHA corrente prima del merge. Automatizzare questo binding richiede
un'evoluzione dedicata del processo, non privilegi concessi al workflow della PR.

## 6. Prova di accettazione

- CI locale verde senza login Azure.
- Goal con `purpose: customer`, requisiti reali e ambiente incluso; parametri compilati coerenti con workload, owner e regione.
- Codice cliente errato o goal `reference` bloccato prima del login; verificare in una run controllata, senza mutare i target di produzione.
- Preview manuale da main su SHA completo, con identity preview e zero creazioni di risorse workload.
- Login OIDC riuscito; nessun client secret richiesto.
- Deploy resta in attesa dell'approvazione su `dev` dopo la generazione del piano.
- Reviewer esamina `release-plan`, verifica goal, cliente, RG, commit, subscription, prove predeploy e costi prima di approvare.
- Deploy e post-check verdi; DNS/RBAC data plane verificati separatamente dalla rete privata.
- Evidenza reale per ciascun requisito e accettazione del responsabile, non sola run verde.

Registrare gli esiti in [handover](handover.md), non dichiarare configurato cio' che non e' stato provato.