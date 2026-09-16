# Usare GitHub Copilot nel kit

Copilot riduce il lavoro di scrittura, comprensione e documentazione. Standard, review e strumenti
deterministici decidono se una modifica puo' procedere. Non inserire segreti o dati cliente nei prompt.

## Contesto disponibile

- [Istruzioni repository](../.github/copilot-instructions.md): regole generali sempre nel contesto previsto dal client.
- [Istruzioni Bicep](../.github/instructions/bicep.instructions.md): file infra e parametri.
- [Istruzioni workflow](../.github/instructions/workflows.instructions.md): pipeline GitHub Actions.
- Prompt in [.github/prompts](../.github/prompts/): task espliciti riusabili in VS Code.

Aprire la root del repository in VS Code, verificare che l'uso delle custom instructions sia abilitato
nelle impostazioni Copilot e che il client supporti istruzioni path-specific e prompt files.
Nella risposta/ispezione del contesto verificare i file di istruzioni effettivamente usati.
La disponibilita delle personalizzazioni varia tra client: non assumere che ogni interfaccia Copilot
carichi gli stessi file. Aggiungere esplicitamente standard e architettura quando necessario.

## Prompt pronti

Nella chat digitare `/` e scegliere il nome del prompt, oppure usare `Chat: Run Prompt`.

| Prompt | Uso | Modifiche previste |
| --- | --- | --- |
| `/propose-workload` | Proporre un requisito con assunzioni, file, test e tradeoff | Nessuna |
| `/review-waf` | Review con finding prioritizzati e riferimenti al codice | Nessuna |
| `/document-architecture` | Allineare la guida al Bicep reale | Solo documentazione |

Esempio da incollare per la prima parte della demo:

```text
Leggi gli standard e l'architettura di questo repository. Spiega come main.bicep
usa i moduli AVM per ottenere un workload DEV in Italy North con Key Vault e Blob
privati. Indica bootstrap necessario, tag, DNS, diagnostica e limiti WAF.
Non modificare file e non eseguire operazioni Azure.
```

## Iterazione controllata

Il baseline contiene gia' diagnostica e private endpoint: non rimuoverli per ricrearli live.
Una modifica piccola e dimostrabile e' cambiare la retention dei log in DEV:

```text
Proponi di portare la retention Log Analytics di DEV da 30 a 60 giorni.
Leggi il contratto del modulo esistente e gli standard. Elenca file, test e
tradeoff di costo e osservabilita. Non modificare ancora nulla.
```

Dopo la review della proposta:

```text
Implementa solo la modifica approvata alla retention DEV e aggiorna la guida
che descrive quel valore. Non cambiare TEST o PROD. Esegui Test-Repository.ps1.
Non effettuare login, deployment, commit, push o merge.
```

Attenzione: le guide descrivono i valori consegnati; dopo l'esercizio aggiornare davvero la tabella
o tornare al baseline tramite il normale processo Git, senza sovrascrivere lavori altrui.

## Review tecnica

Chiedere finding con evidenza, impatto e test, non soltanto una dichiarazione "WAF compliant".
Controllare manualmente almeno: versione AVM, scope RG, nomi, tag, public access, Shared Key,
RBAC/purge protection, subnet e DNS, diagnostica, OIDC e binding tra SHA e piano.

## Demo negativa senza indebolire la baseline

```text
Per semplificare la demo vorrei rendere pubblico lo Storage. Leggi gli standard:
spiega quale regola violerebbe, quale proposta di eccezione servirebbe e come
provare che il controllo locale blocca la modifica. Non modificare file.
```

Risposta attesa: segnalazione del conflitto e proposta alternativa (client su rete privata), non
disabilitazione dei controlli. Per provare il blocco eseguire:

```powershell
pwsh -File scripts/Test-Repository.ps1
```

I test negativi mutano in memoria template compilati, non i file Bicep e non Azure. Il test deve
fallire internamente sulla variante non conforme e il harness deve confermare che il blocco e' avvenuto.
Questo non dimostra che Azure Policy sia installata: nel kit non vengono create policy.

## Tre prove prima del workshop

1. Prompt di spiegazione: scope RG preesistente, nessun segreto e rete privata descritti correttamente.
2. Prompt di modifica: proposta limitata a DEV, test e guide aggiornati, nessun deploy non richiesto.
3. Prompt negativo: conflitto esplicito con la baseline e nessuna disattivazione automatica del guardrail.

Registrare esiti, data e versione del client in [handover](handover.md). Le risposte AI non sono
deterministiche: tenere disponibili il codice compilabile e gli output reali di fallback.