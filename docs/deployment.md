# PR, preview e deployment

Prerequisito: completare e verificare [bootstrap](bootstrap.md). Il percorso supportato e' GitHub Actions.
I comandi locali sotto sono per prove autorizzate del trainer o procedure di emergenza concordate.

Il [goal](../workload/goal.json) incluso e' `reference` e blocca **anche la preview Azure**.
Prima di usare i workflow autenticati serve un goal `customer` revisionato, con criteri reali e
ambiente ammesso; `CUSTOMER_CODE` nell'environment protetto deve coincidere con `customerCode`.
Workload, owner, region e ambiente dei parametri compilati devono corrispondere al goal.
Cambiare `purpose` non costituisce approvazione del piano o dei costi. Seguire [factory](factory.md).

## Tre workflow

| Workflow | Trigger | Identita Azure | Risultato |
| --- | --- | --- | --- |
| [Validate](../.github/workflows/validate.yml) | PR, push main, manuale | Nessuna | Build, contratto goal, guardrail, test negativi, link |
| [Azure Preview](../.github/workflows/preview.yml) | Manuale da main | Identity preview tramite environment | Validate e What-If dello SHA indicato |
| [Deploy](../.github/workflows/deploy.yml) | Manuale da main | Preview, poi deployment | Piano, gate ambiente, applicazione e post-check |

Non sono previsti deploy su merge automatico o da workflow PR. Le Actions sono fissate a SHA completi.
Dependabot propone aggiornamenti delle Actions; i moduli AVM si aggiornano tramite PR dedicata.

## 1. Modifica e PR

1. Dopo l'approvazione tecnica del piano, creare un branch dalla main corrente e modificare goal, IaC, test e guide nel perimetro concordato.
2. Eseguire `pwsh -File scripts/Test-Repository.ps1`.
3. Committare e aprire PR secondo [CONTRIBUTING](../CONTRIBUTING.md).
4. Aspettare la CI Validate e leggere errori/diagnostiche. Non disattivare check per ottenere verde.
5. Annotare lo SHA completo del commit corrente della PR.

Un workflow PR ha accesso al contenuto del branch, quindi non riceve identita Azure. Il suo eventuale
successo non attesta la sicurezza della modifica: un autore potrebbe cambiare anche il codice dei test.
La review di workflow, script e standard rimane obbligatoria.
Per nuove suite, introdurre prima su main i validatori e il registro revisionati, come descritto in
[factory](factory.md). Non eseguire codice candidato nel job autenticato per aggirare un'incompatibilita.

## 2. Preview prima del merge

Il maintainer apre Actions -> Azure Preview -> Run workflow:

- Branch del workflow: `main`.
- `commit`: SHA completo, 40 caratteri, gia' revisionato e raggiungibile nel repository.
- `environment`: `dev` per il workshop.

Il primo job scarica quel commit e compila senza credenziali Azure. Il job autenticato **non esegue
script provenienti dal commit proposto**: scarica template, parametri e goal come dati e usa codice
del commit main fissato all'avvio. Prima del login esegue il validatore/schema fidato con
`-ForProvisioning -BindingOnly`: verifica contratto, registro suite e binding cliente/parametri.
`BindingOnly` omette solo l'esistenza locale dei file di verifica candidati, controllata dal job build;
non esegue le suite dichiarate nel goal e non certifica la loro copertura.
L'environment `preview-dev` deve richiedere approvazione prima del login OIDC.

Il ruolo preview non puo' creare risorse workload. Il template viene inviato ad ARM: non includere
dati riservati, URL o riferimenti esterni non revisionati. La preview conserva il risultato per 7 giorni.
Per PR da fork, verificare disponibilita e provenienza dello SHA; se non e' recuperabile, il maintainer
deve trasferire la modifica in un branch interno revisionato, senza eseguire codice fork con credenziali.

Aprire gli artifact `preview-results`: `goal.json`, `validate.json` e `what-if.json`. Collegare la run alla PR
con SHA, cliente, ambiente, RG e conclusioni. La pipeline non scrive automaticamente commenti o check sulla PR.
Una modifica al commit rende la preview precedente non piu' valida ai fini della review.

## 3. Leggere il What-If

| Esito | Cosa fare |
| --- | --- |
| Create | Confermare nomi, SKU, region, tag e costi delle nuove risorse |
| Modify | Verificare ogni differenza, soprattutto rete, ACL, retention e nomi |
| Delete | Fermare il rilascio e concordare un piano; il job plan del deploy lo blocca |
| NoChange | Non sostituisce i test di funzionamento |
| Ignore/Deploy, diagnostiche o espressioni non valutate | Non assumere assenza di impatto; capire cosa ARM non ha analizzato |

`ProviderNoRbac` valida risorse con permessi di lettura, non verifica che l'identita di deployment
disponga di tutti i permessi di scrittura. What-If puo' riportare rumore o non espandere alcuni moduli
AVM: analizzare i messaggi, non approvare sulla sola presenza di un job verde.
La sola assenza di `Delete` non garantisce che un aggiornamento sia non distruttivo.

## 4. Merge e rilascio

Dopo review e merge, Actions -> Deploy -> Run workflow -> `main` -> `dev`.
Questo avvia una **nuova** preview dello SHA main fissato all'avvio, che puo' essere diverso dallo SHA PR.

1. Il job `plan` esegue build/controlli e binding del goal prima del login della identity preview, poi validate e What-If.
2. Produce `release-plan`: template, parametri, goal, risultati ARM e manifest con commit, target, cliente e hash SHA256 del goal.
3. Il job `deploy` si ferma al gate dell'environment `dev`, se configurato correttamente.
4. Il reviewer legge goal e piano della stessa run, verifica cliente, costi/scope e prove manuali predeploy, poi approva.
5. Il job ricontrolla goal, codice cliente, hash e target prima del login; usa la identity deployment e distribuisce lo **stesso JSON compilato**.
6. Il post-check controlla management plane di Key Vault e Storage, tag e connessioni PE approvate.

Il nome deployment e' `factory-<env>-<run_id>-<run_attempt>`. La concurrency per ambiente non cancella
una run in corso; GitHub puo' sostituire run pending, quindi non usarla come coda garantita di richieste.

Artifact della stessa run e commit fissato evitano ricompilazioni da branch mobili dopo l'approvazione.
Non sono una transazione: cambiamenti manuali su Azure tra piano e deploy possono alterare il risultato.
Se il piano e' vecchio o si sospetta drift, annullare l'approvazione e avviare una nuova run.

## 5. Esito e verifiche

Conservare cliente, ID requisito, hash goal, link a PR, SHA, run, reviewer e deployment Azure. Gli artifact hanno retention di 7 giorni:
prima della scadenza trasferire le evidenze autorizzate nella destinazione aziendale approvata.
Non caricare log integrali in repository pubblici.

Un post-check fallito **non annulla il deploy**: le risorse possono esistere gia'. Aprire un incidente
o una PR correttiva e seguire [operations](operations.md). Non lanciare una cancellazione automatica.
Il post-check non testa DNS, query dei log, accesso ai blob/segreti, identita applicative o performance.
Il riepilogo finale elenca i requisiti manuali; non ne certifica l'esecuzione e non blocca la run in
attesa di un verbale. La consegna richiede evidenze per tutti i requisiti del goal e accettazione umana.
Per il modello di registrazione usare [handover](handover.md).

## Comandi locali del trainer

Eseguire solo su un contesto autorizzato. Questi comandi assumono PowerShell 7, RG gia' creato,
parametri DEV controllati e login Azure effettuato con il proprio utente, non una identity pipeline.

```powershell
pwsh -File scripts/Test-Repository.ps1
if ($LASTEXITCODE -ne 0) { throw 'Controlli locali falliti.' }
$customerCode = Read-Host 'Codice cliente dal target amministrativo approvato'
pwsh -File scripts/Test-WorkloadGoal.ps1 -ForProvisioning -Environment dev -ExpectedCustomerCode $customerCode
if ($LASTEXITCODE -ne 0) { throw 'Goal o binding cliente non valido.' }
az login
$subscriptionId = Read-Host 'Subscription approvata'
az account set --subscription $subscriptionId
if ($LASTEXITCODE -ne 0) { throw 'Contesto Azure non impostato.' }
$resourceGroup = 'rg-workload-demo-dev-itn'
az group show --name $resourceGroup --query '{name:name,location:location}' --output table
if ($LASTEXITCODE -ne 0) { throw 'RG non disponibile.' }
```

Non trasmettere credenziali alla chat. `az login` usa il flusso interattivo della CLI.
L'ID subscription non e' un segreto, ma non deve essere committato nei file della demo.
Usare il RG reale approvato al posto del nome di esempio. Ottenere il codice cliente dall'inventario
amministrativo del target, non copiarlo dal goal soltanto per far passare il confronto.
Il flusso locale non dispone del binding environment GitHub: l'operatore deve verificare direttamente
cliente, account, subscription e RG. Non e' una scorciatoia al processo di rilascio della factory.

Preview, senza creazione di risorse workload:

```powershell
az deployment group validate --resource-group $resourceGroup --template-file .artifacts/main.json --parameters '@.artifacts/dev.parameters.json' --validation-level ProviderNoRbac
if ($LASTEXITCODE -ne 0) { throw 'Validate fallita.' }
az deployment group what-if --resource-group $resourceGroup --template-file .artifacts/main.json --parameters '@.artifacts/dev.parameters.json' --validation-level ProviderNoRbac
if ($LASTEXITCODE -ne 0) { throw 'What-If fallito.' }
```

**Il comando successivo crea/modifica risorse e genera costi. Richiede autorizzazione separata.**
Per il rilascio ordinario usare gli environment GitHub; il comando locale non ne applica le approvazioni.

```powershell
$deploymentName = 'factory-demo-' + (Get-Date -Format 'yyyyMMddHHmmss')
az deployment group create --name $deploymentName --resource-group $resourceGroup --template-file .artifacts/main.json --parameters '@.artifacts/dev.parameters.json' --mode Incremental --confirm-with-what-if --output json > .artifacts/deployment.json
if ($LASTEXITCODE -ne 0) { throw 'Deployment fallito.' }
pwsh -File scripts/Test-DeployedResources.ps1 -DeploymentFile .artifacts/deployment.json
```

La conferma What-If non sostituisce l'autorizzazione aziendale. Mai usare `--mode Complete` nella demo.