# Runbook operativo

Usare [deployment](deployment.md) per il percorso ordinario. Nessun troubleshooting autorizza
disabilitazione di controlli, aumento di privilegi o creazione di Public IP.

## Triage

| Sintomo | Verifica | Azione |
| --- | --- | --- |
| `pwsh` non trovato | PowerShell 7 installato e PATH | Seguire i prerequisiti, riaprire il terminale |
| Restore AVM fallisce | Connettivita/proxy verso MCR, versione Bicep | Correggere proxy o rete; non sostituire moduli con versioni casuali |
| BCP037/BCP053 | Parametro/output non presente nella versione fissata | Leggere contratto AVM e correggere il wrapper |
| Linter/guardrail fallisce | Primo errore, diff e valori compilati | Correggere il requisito/codice; non abbassare severita |
| Goal `reference` rifiutato | Scopo del repository e piano cliente | Completare onboarding e requisiti reali; non cambiare solo purpose per aggirare il gate |
| Customer code non corrisponde | Goal e variabile protetta CUSTOMER_CODE | Verificare con l'amministratore repository/tenant/subscription/RG; non ricopiare valori da altri clienti |
| Goal/parametri incoerenti | Workload, owner, regione e ambiente compilati | Allineare al piano approvato e ripetere build, review e preview |
| Suite non collegata o sconosciuta in preview | Registro fidato su main, pipeline e test candidati | Qualificare la suite con PR dedicata prima di usarla; non caricare script PR nel job autenticato |
| Hash goal o manifest non corrisponde | Artefatti, run e variabili target | Fermare il rilascio e rigenerare un piano revisionato; non modificare artefatti a mano |
| CI manca sulla PR | Actions abilitate, workflow presente, approvazione run fork | Configurare repo e policy delle Actions |
| OIDC non trova federazione | Issuer, audience, subject environment, client ID, tenant | Confrontare i valori del bootstrap e attendere propagazione |
| `AuthorizationFailed` | Identity usata, scope e azione nel messaggio | Far correggere il ruolo minimo all'amministratore |
| Preview richiede scrittura | CLI >= 2.76 e ProviderNoRbac | Correggere CLI/opzione; non assegnare Contributor alla preview |
| Deploy non aspetta review | Environment esistente e protection supportata dal piano | Fermare uso della pipeline finche' il gate non e' efficace |
| Policy nega risorsa | Policy assignment/definition e proprieta non conforme | Allineare il pattern o proporre eccezione formale |
| SKU/region non disponibile | Messaggio ARM, quote e disponibilita servizio | Valutare variante approvata, non cambiare regione in silenzio |
| Nome KV non disponibile | Vault soft-deleted o nome globale occupato | Valutare recovery autorizzato; non rimuovere purge protection |
| 403 su blob/segreto dal PC | Rete, DNS e ruolo data plane | Usare client privato autorizzato; login da solo non basta |
| DNS privato non risolve | Zone link, zone group, forwarding, cache DNS | Correggere DNS dalla rete connessa |
| LAW senza eventi | Diagnostic settings, attivita reale del servizio e latenza ingestione | Generare evento autorizzato e attendere tempi di servizio |
| Post-check fallisce dopo deploy | Stato ARM e proprieta reali | Risorse possono gia' esistere; aprire correzione senza rollback automatico |
| Deploy verde ma requisito non provato | Matrice goal/test e prove manuali | Lasciare l'accettazione pendente e completare il test; non registrare un esito sintetico |

## Analizzare un deployment fallito

Azure Portal -> Resource Group workload -> Deployments -> nome `factory-...` -> Operation details.
Annotare error code, resource type e correlation ID nel canale interno autorizzato.
Non pubblicare log integrali, inventari o identificativi in issue pubbliche.

Un deployment ARM puo' fallire dopo aver creato parte delle risorse. Dopo la correzione fare una nuova
preview e rilanciare lo stesso codice corretto a scope RG. Non assumere che cancellare tutto sia necessario.
Verificare limiti o ownership prima di intervenire su risorse preesistenti.

## Verifiche private

Da un client autorizzato nella VNet o su rete connessa, con DNS appropriato:

```powershell
$vaultName = Read-Host 'Nome Key Vault dal deployment'
$storageName = Read-Host 'Nome Storage dal deployment'
Resolve-DnsName "$vaultName.vault.azure.net"
Resolve-DnsName "$storageName.blob.core.windows.net"
Test-NetConnection "$vaultName.vault.azure.net" -Port 443
Test-NetConnection "$storageName.blob.core.windows.net" -Port 443
```

Questi cmdlet DNS/TCP sono per Windows. Su Linux usare strumenti equivalenti gia' approvati.
Confrontare gli indirizzi risolti con le NIC dei PE, non soltanto con un generico intervallo RFC1918.
Un test TCP positivo non prova il ruolo applicativo e un 403 puo' dipendere da rete o autorizzazione.

La demo non crea segreti/container, utenti data plane o client di test. Un test dati richiede una
richiesta approvata: identita con ruolo minimo, oggetto di prova non sensibile, pulizia e verifica audit.
Non usare account keys, SAS con Shared Key o eccezioni firewall temporanee.

## Query dei log

Dopo attivita effettiva, aprire Logs sul workspace. La diagnostica AVM puo' usare tabelle dedicate;
esempio per l'audit Key Vault, adattando il tipo di destinazione osservato:

```kusto
AZKVAuditLogs
| where TimeGenerated > ago(1h)
| summarize Events = count() by OperationName
| order by Events desc
```

Se la tabella non esiste, controllare diagnostica, eventi reali, latenza e destinazione invece di
interpretare il risultato come assenza di problemi. Nessuna raccolta dati reale e' attestata dal build.

## Recovery e rollback

1. Fermare nuovi rilasci e identificare SHA, run, piano, stato reale e dati coinvolti.
2. Preferire una PR correttiva piccola quando preserva lo stato e riduce il rischio.
3. Un revert Git ripristina il codice, non automaticamente lo stato Azure: nuova preview e approval.
4. Valutare rinomine, child resource, soft delete e proprieta irreversibili prima dell'applicazione.
5. Key Vault: usare il recovery previsto dal servizio e autorizzato; purge protection resta attiva.
6. Blob: versioning/soft delete sono aiuti al recupero, non backup indipendenti ne' garanzia di RPO/RTO.

La modalita Incremental non elimina risorse omesse dal template ma puo' riconfigurare risorse gestite.
Il workshop non include backup, restore automatizzato, DR multi-region o failover di un'applicazione.

## Fine demo e costi

Non esiste cleanup automatico. Un amministratore deve:

1. Ottenere approvazione esplicita e verificare che il RG sia dedicato e non contenga dati o risorse condivise.
2. Conservare le evidenze autorizzate, inventariare risorse/soft-deleted object e verificare lock/policy.
3. Eliminare il RG dedicato dal portale solo quando approvato, confermandone esattamente il nome.
4. Verificare risorse rimaste, DNS/link, costi residui e vault in soft delete: non forzare il purge.
5. Revocare le federazioni/assegnazioni demo non piu' necessarie e valutare le identita nel RG separato.
6. Chiudere il registro costi e documentare le risorse conservate con owner e scadenza.

Non sono inclusi comandi di cancellazione non interattiva. Il RG delle identita non va cancellato come
effetto collaterale del cleanup workload. Budget e alert non sono presenti e non sarebbero comunque un blocco di spesa.