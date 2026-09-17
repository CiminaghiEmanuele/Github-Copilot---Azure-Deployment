# Checklist di consegna e accettazione

Consegna: template Azure Deployment Factory multi-cliente, con pattern PaaS e workshop, baseline v0.1.
Data preparazione: 16 settembre 2026. La checklist separa verifica locale e attivazione live.

## Responsabili da nominare

| Ruolo | Referente il team |
| --- | --- |
| Owner del repository e manutenzione moduli | Da nominare |
| Responsabile subscription e bootstrap RBAC | Da nominare |
| Reviewer infrastruttura e sicurezza | Da nominare |
| Approvatore costi e rilascio | Da nominare |
| Canale privato segnalazioni sicurezza | Da definire |

## Contenuto consegnato

- [x] Percorso guidato di utilizzo della factory.
- [ ] README disponibile nel worktree finale: attualmente rimosso, ripristino da confermare.
- [x] Standard, architettura, primo utilizzo e bootstrap.
- [x] Bicep/AVM e parametri DEV/TEST/PROD.
- [ ] Configurazione linter Bicep disponibile nel worktree finale: attualmente rimossa, ripristino da confermare.
- [x] Istruzioni Copilot, tre prompt riusabili e guida esercizi.
- [x] Agenti Plan/Build a tool limitati e guida di onboarding cliente/workload.
- [x] Goal/schema, registro delle suite e gate cliente/ambiente/parametri prima del login Azure.
- [x] Goal nell'artefatto di rilascio e binding cliente/hash nel manifest.
- [x] CI locale, preview autenticata separata e deploy manuale con OIDC.
- [x] Script di guardrail, test negativi e post-check di management plane.
- [x] Runbook errori/recovery/cleanup e scaletta del workshop.
- [x] Processo PR, contributi e segnalazioni sicurezza.

## Verifica locale

Comando di accettazione dalla root:

```powershell
pwsh -File scripts/Test-Repository.ps1
```

Build iniziale verificato con Bicep CLI 0.44.1 e tool Bicep: cinque file compilati, tre set di parametri,
zero diagnostiche nel build dell'entry point. Sette mutazioni rappresentative sono state bloccate:
Storage pubblico, Shared Key, RBAC disabilitato, purge protection disabilitata, PE rimosso,
tag mancante e DNS senza VNet. Lo script completo verifica anche sintassi PowerShell e link locali.

La verifica locale della factory ha inoltre bloccato sette goal malformati (obiettivo/verifica assenti,
ID duplicato, file inesistente, suite non registrata, percorso esterno, nessun test postdeploy),
tre gate provisioning (reference, cliente errato, ambiente errato) e tre mismatch dei parametri
(workload, owner, regione). Una fixture sintetica cliente/parametri DEV corretti passa: non e'
un'approvazione o una prova live. Le mutazioni operano in memoria, senza modificare Azure.

Il controllo completo del repository era passato, inclusi tutti i link locali, prima delle rimozioni
riportate sotto. I tre workflow sono stati
validati anche con actionlint 1.7.7 (checksum SHA256 della distribuzione verificato), senza segnalazioni.
Actionlint e' un controllo statico: non esegue le Actions e non prova OIDC o le protezioni GitHub.

**Ultima verifica completa non superata:** il worktree presenta la rimozione di `README.md` e
`bicepconfig.json`, non effettuata durante le modifiche della factory. Build, parametri, test del
goal, guardrail e sintassi PowerShell sono passati, poi il controllo si e' fermato sul link al README
in getting-started. In assenza della configurazione Bicep non si attesta l'applicazione delle regole
linter originali. Le rimozioni sono state preservate in attesa di conferma; non sono stati disattivati
controlli per ottenere verde. Dopo la decisione sui file rieseguire l'intero comando di accettazione.

Questi controlli non coprono tutte le proprieta ARM, tutte le possibili modifiche malevole o ogni
default transitivo AVM. Checkov non e' incluso tra i prerequisiti e la scansione Checkov non e' stata
eseguita durante la preparazione: integrare lo scanner aziendale prima dell'adozione produttiva.
La compilazione non e' una prova di deployment e non garantisce il rispetto di policy della subscription.

## Attivazione da completare

- [ ] Abilitare il repository centrale come template e creare repository privato del cliente/workload.
- [ ] Raccogliere goal reale, vincoli e criteri misurabili; approvare piano tecnico e corrispondenza requisito/test.
- [ ] Qualificare eventuali nuovi pattern e suite: il solo pattern PaaS della demo e' attualmente implementato.
- [ ] Approvare gli standard con il team: owner, CostCenter, naming, CIDR e region.
- [ ] Concordare stima costi, durata e autorizzazione DEV.
- [ ] Preparare subscription/RG dedicato, provider e due identita separate.
- [ ] Configurare e verificare il ruolo preview e il ruolo deployment allo scope RG.
- [ ] Creare i due environment DEV con cinque variabili, incluso CUSTOMER_CODE, reviewer e restrizione main.
- [ ] Verificare corrispondenza amministrativa cliente/repository/tenant/subscription/RG e blocco goal reference/cliente errato prima del login.
- [ ] Verificare che il piano GitHub supporti davvero i required reviewer necessari.
- [ ] Configurare trust OIDC esatti, senza client secret.
- [ ] Proteggere main, check obbligatori, CODEOWNERS reali e limiti di bypass.
- [ ] Eseguire Validate su GitHub Actions.
- [ ] Eseguire preview su SHA noto e collegarla alla PR.
- [ ] Verificare il blocco del deploy in attesa di approvazione e il binding del target.
- [ ] Provare deploy DEV end-to-end e post-check.
- [ ] Provare risoluzione DNS privata, connettivita e accesso dati con identita autorizzata, se mostrati.
- [ ] Verificare ricezione dei log e categorie diagnostiche reali.
- [ ] Provare i tre prompt Copilot e registrare il comportamento.
- [ ] Provare Plan/Build nel client VS Code, strumenti disponibili e rispetto dei passaggi di approvazione.
- [ ] Raccogliere evidenze per ogni REQ-nnn; completare le prove manuali e l'accettazione con il responsabile cliente.
- [ ] Preparare tag/commit di fallback verificato e screenshot con dati riservati rimossi.
- [ ] Concordare cleanup, conservazione log, gestione soft delete e responsabilita residue.

Nessuna risorsa Azure, federazione, assegnazione RBAC, protezione GitHub, push o merge viene
effettuata dalla sola creazione di questi file. TEST/PROD restano esempi, non ambienti autorizzati.

## Registro prove live

Compilare con evidenze reali senza chiavi, token o identificativi sensibili non necessari.

| Data | Ambiente | SHA | PR/run | Prova ed esito | Esecutore/reviewer |
| --- | --- | --- | --- | --- | --- |
| Da compilare | DEV | Da compilare | Da compilare | Nessuna prova live eseguita nella preparazione | Da compilare |

## Accettazione del goal cliente

Compilare questa matrice nel repository cliente o nel sistema di evidenze aziendale approvato.
Associare al verbale cliente, workload, ambiente, target Azure verificato, SHA e hash del goal.
Il campo evidence del goal descrive cosa raccogliere: non e' il verbale di esecuzione.

| Requisito | Criterio misurabile | Evidenza/run e data | Esito osservato | Reviewer |
| --- | --- | --- | --- | --- |
| Da compilare dal goal cliente | Da compilare | Nessuna prova cliente ancora eseguita | Pendente | Da nominare |

Non segnare una prova manuale come superata sulla base del solo riepilogo Actions. Un requisito
non coperto o fallito mantiene pendente l'accettazione; correggere o rinegoziare formalmente il goal.

## Criterio di accettazione

Il kit locale e' accettabile se il controllo completo passa e le guide corrispondono ai file.
La demo live e' pronta solo dopo esito positivo di bootstrap, CI, preview, gate, deploy e prove che si
intende mostrare al cliente. Un workshop limitato a build/preview deve dichiarare il perimetro ridotto.
Ogni adozione cliente richiede il proprio repository/workload, con requisiti, sicurezza, costi, SLO,
backup, DR, rete e modello operativo approvati secondo il goal. Sicurezza e provisioning verificato
non sono garantiti dalle risposte AI: dipendono da controlli pertinenti, protezioni attive e prove reali.