# Checklist di consegna e accettazione

Consegna: Metix Azure Deployment Factory Workshop, baseline v0.1.
Data preparazione: 16 settembre 2026. La checklist separa verifica locale e attivazione live.

## Responsabili da nominare

| Ruolo | Referente Metix |
| --- | --- |
| Owner del repository e manutenzione moduli | Da nominare |
| Responsabile subscription e bootstrap RBAC | Da nominare |
| Reviewer infrastruttura e sicurezza | Da nominare |
| Approvatore costi e rilascio | Da nominare |
| Canale privato segnalazioni sicurezza | Da definire |

## Contenuto consegnato

- [x] README e percorso guidato di utilizzo.
- [x] Standard, architettura, primo utilizzo e bootstrap.
- [x] Bicep/AVM, parametri DEV/TEST/PROD e linter.
- [x] Istruzioni Copilot, tre prompt riusabili e guida esercizi.
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

Il controllo completo del repository e' passato, inclusi tutti i link locali. I tre workflow sono stati
validati anche con actionlint 1.7.7 (checksum SHA256 della distribuzione verificato), senza segnalazioni.
Actionlint e' un controllo statico: non esegue le Actions e non prova OIDC o le protezioni GitHub.

Questi controlli non coprono tutte le proprieta ARM, tutte le possibili modifiche malevole o ogni
default transitivo AVM. Checkov non e' incluso tra i prerequisiti e la scansione Checkov non e' stata
eseguita durante la preparazione: integrare lo scanner aziendale prima dell'adozione produttiva.
La compilazione non e' una prova di deployment e non garantisce il rispetto di policy della subscription.

## Attivazione da completare

- [ ] Approvare gli standard con Metix: owner, CostCenter, naming, CIDR e region.
- [ ] Concordare stima costi, durata e autorizzazione DEV.
- [ ] Preparare subscription/RG dedicato, provider e due identita separate.
- [ ] Configurare e verificare il ruolo preview e il ruolo deployment allo scope RG.
- [ ] Creare i due environment DEV con variabili, reviewer e restrizione main.
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
- [ ] Preparare tag/commit di fallback verificato e screenshot con dati riservati rimossi.
- [ ] Concordare cleanup, conservazione log, gestione soft delete e responsabilita residue.

Nessuna risorsa Azure, federazione, assegnazione RBAC, protezione GitHub, push o merge viene
effettuata dalla sola creazione di questi file. TEST/PROD restano esempi, non ambienti autorizzati.

## Registro prove live

Compilare con evidenze reali senza chiavi, token o identificativi sensibili non necessari.

| Data | Ambiente | SHA | PR/run | Prova ed esito | Esecutore/reviewer |
| --- | --- | --- | --- | --- | --- |
| Da compilare | DEV | Da compilare | Da compilare | Nessuna prova live eseguita nella preparazione | Da compilare |

## Criterio di accettazione

Il kit locale e' accettabile se il controllo completo passa e le guide corrispondono ai file.
La demo live e' pronta solo dopo esito positivo di bootstrap, CI, preview, gate, deploy e prove che si
intende mostrare al cliente. Un workshop limitato a build/preview deve dichiarare il perimetro ridotto.
Una versione di produzione richiede un progetto separato con requisiti, sicurezza, costi, SLO, backup,
DR, rete e modello operativo approvati.