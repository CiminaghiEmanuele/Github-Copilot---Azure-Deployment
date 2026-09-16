# Primo utilizzo

Obiettivo: aprire il repository, comprendere i file ed eseguire controlli locali senza creare risorse.

## Prerequisiti

| Strumento | Requisito |
| --- | --- |
| Git | Versione supportata e accesso al repository consegnato |
| VS Code | Versione aggiornata; aprire la cartella root |
| PowerShell | 7.x (`pwsh`), non Windows PowerShell 5.1 |
| Azure CLI | >= 2.76.0 per ProviderNoRbac; nessun login per il build |
| Bicep CLI | 0.44.1 usata per i test e fissata nei workflow |
| Internet | Download tool, restore AVM da Microsoft Container Registry |
| GitHub Copilot | Licenza e accesso dell'utente per gli esercizi AI; non necessario per compilare |

Installare Azure CLI e PowerShell dalle [fonti ufficiali](references.md). In VS Code usare le estensioni
consigliate in [extensions.json](../.vscode/extensions.json). Non concedere trust a cartelle non revisionate.

I comandi delle guide usano PowerShell 7; su macOS/Linux eseguirli in `pwsh` o adattare quoting e variabili
al proprio shell. I workflow usano Ubuntu con PowerShell.

```powershell
git --version
pwsh --version
az version
az bicep install --version v0.44.1
az bicep version
```

L'installazione locale di Bicep scarica un eseguibile, non risorse Azure. Non servono subscription o secret.
La prima compilazione puo' richiedere piu' tempo per il download dei moduli.

## Aprire ed esplorare

1. Ottenere l'URL reale del repository dal referente Metix e clonarlo con Git, oppure aprire questa cartella.
2. Aprire [README](../README.md), poi [standard](standards.md) e [architettura](architecture.md).
3. Aprire [main](../infra/main.bicep) e usare Vai alla definizione sui moduli.
4. Confrontare [DEV](../infra/parameters/dev.bicepparam), [TEST](../infra/parameters/test.bicepparam) e [PROD](../infra/parameters/prod.bicepparam).

## Validazione locale

Dalla root:

```powershell
pwsh -File scripts/Test-Repository.ps1
```

Risultato atteso: `PASS` per cinque build, tre set di parametri, guardrail, sette test negativi,
sintassi PowerShell e link locali. Un errore termina il comando con codice diverso da zero.
Le notifiche di nuove versioni CLI non sono warning del template; non aggiornare tool durante una demo.

Il comando genera `.artifacts`, ignorata da Git, con template e parametri JSON compilati.
Non modificarli a mano e non commetterli: la fonte rimane Bicep.
`-SkipDocumentation` serve solo durante la costruzione del kit; la consegna e la CI usano il controllo completo.

Per compilare un singolo file durante un esercizio:

```powershell
az bicep build --file infra/main.bicep --outfile .artifacts/main.json
az bicep build-params --file infra/parameters/dev.bicepparam --outfile .artifacts/dev.parameters.json
```

La cartella `.artifacts` deve gia' esistere; il controllo completo la crea.

## Personalizzare DEV

Modificare il file di parametri tramite una PR:

- `owner` e `costCenter`: valori reali approvati, senza dati riservati.
- `workload`: 2-8 caratteri minuscoli alfanumerici; modifica i nomi delle risorse.
- `network`: indirizzi approvati, non sovrapposti alle reti aziendali.
- SKU e retention: coerenti con costi, requisiti e disponibilita.

Non aggiungere subscription/tenant ID ai parametri. Sono contesto di esecuzione, configurato in Azure CLI
o negli environment GitHub. Non rendere pubblico Storage per poter provare la demo dal portatile.

## Passaggio ad Azure

Prima di qualunque provisioning seguire [bootstrap](bootstrap.md), ottenere approvazione di costi/scope,
poi [deployment](deployment.md). Il solo successo locale non dimostra che il deploy riuscira'.
Per gli esercizi senza Azure passare alla [guida Copilot](copilot.md) e al [workshop](workshop.md).