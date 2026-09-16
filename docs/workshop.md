# Workshop Metix, 10:00-13:00

Guida di conduzione basata sulla proposta V-Valley. Obiettivo: dimostrare un processo ripetibile,
non generare l'intera infrastruttura da zero durante la sessione.

## Agenda e output

| Orario | Attivita | Output da mostrare |
| --- | --- | --- |
| 10:00-10:20 | Discovery del processo Metix | 3-5 problemi prioritari |
| 10:20-10:50 | WAF tradotto in standard | Guardrail, default, eccezioni |
| 10:50-11:25 | Bicep e AVM con lettura del codice | Moduli, parametri, output e build |
| 11:25-11:35 | Pausa tecnica | Repository e sessioni demo pronte |
| 11:35-12:20 | Demo Copilot guidata | Requisito, proposta, modifica, test, documentazione, PR |
| 12:20-12:45 | GitHub Actions | Preview, OIDC, approval e deployment |
| 12:45-13:00 | Roadmap e decisioni | Owner e prossimi passi |

Limitare la teoria pura a 50-55 minuti: nel blocco Bicep usare soprattutto navigazione e prove pratiche.
Non contare sui tempi di provisioning Azure per terminare la sessione: preparare una run completata.

## Discovery, primi 20 minuti

- Quali infrastrutture si ripetono piu' spesso tra clienti?
- Portale, Bicep, Terraform, script o pipeline: quale processo e' in uso?
- Dove si perdono tempo e affidabilita? Quali errori arrivano tardi?
- Naming, tag, region e segmentazione degli ambienti sono formalizzati?
- Chi approva produzione e chi puo' cambiare ruoli o policy?
- Come sono gestite identita di automazione e segreti?
- Quali controlli e quali eccezioni devono diventare tracciabili?

Compilare durante la sessione:

| Problema osservato | Impatto | Regola/controllo candidato | Owner |
| --- | --- | --- | --- |
| Da raccogliere | Da misurare | Da concordare | Da nominare |

Non presentare i parametri di esempio come standard aziendale gia' approvato.

## Demo centrale, 45 minuti

| Minuti | Azione | Verifica di riuscita |
| --- | --- | --- |
| 0-5 | Aprire README, standard, architettura, istruzioni Copilot | Il contesto precede il prompt |
| 5-12 | Prompt di spiegazione e proposta retention DEV | Assunzioni, file, WAF e test espliciti |
| 12-20 | Review del codice e del contratto AVM | Scope RG, output, naming e tag leggibili |
| 20-28 | Approvare la modifica circoscritta a DEV | Diff piccolo, nessun cambio sicurezza |
| 28-35 | Aggiornare documentazione dal codice | Guide coerenti con valore effettivo |
| 35-42 | Eseguire Test-Repository, mostrare un test negativo | Build e guardrail deterministici |
| 42-45 | Commit/PR, solo se autorizzati | Diff, template PR, check locale |

I prompt sono in [copilot.md](copilot.md). Gli esercizi non richiedono costi Azure.
La baseline gia' contiene private endpoint e diagnostica: scegliere una piccola evoluzione, non
disattivare una protezione per costruire una scena artificiale.

## Demo Actions, 25 minuti

1. Mostrare Validate verde e assenza di login Azure nel workflow PR.
2. Il maintainer avvia Azure Preview da main su SHA completo e approva l'environment preview.
3. Leggere artifact What-If e limiti; collegare la run alla PR e verificare lo SHA.
4. Mostrare la review e il merge autorizzato; spiegare che non parte alcun deploy automatico.
5. Avviare Deploy DEV solo se autorizzati a creare risorse e sostenere costi.
6. Mostrare il piano della nuova run, il gate `dev`, OIDC e il post-check finale o una run precedente reale.

In assenza di autorizzazione fermarsi alla preview, dichiarandolo esplicitamente.
Non usare una registrazione o uno screenshot come se fosse un'esecuzione live.

## Messaggi del trainer

| Momento | Messaggio |
| --- | --- |
| Discovery | "Prima dei tool, quali parti del deployment generano variabilita?" |
| WAF | "Un principio diventa utile quando decide una regola verificabile." |
| AVM | "Riusiamo implementazioni, ma rimaniamo responsabili dei parametri e dei default." |
| Copilot | "La proposta AI resta codice revisionabile e testabile." |
| What-If | "Voglio capire cosa cambia e cosa il motore non ha potuto valutare." |
| OIDC | "Nessun client secret statico, ma trust e privilegi restano da governare." |
| Chiusura | "Questo pattern e' un candidato al catalogo, non una landing zone pronta per ogni cliente." |

## Preparazione e piano B

Prima della visita completare [handover](handover.md): moduli risolti, CI e deploy DEV provati,
tre prompt verificati, artifact e screenshot reali con dati sensibili rimossi.

Con autorizzazione Git preparare un tag `demo-working` riferito al commit realmente verificato.
Non creare un tag che suggerisca un deploy riuscito se e' stato testato solo il build.
Per una demo parallela usare un worktree o una copia del repository, non un reset distruttivo del lavoro corrente.

- Internet/restore indisponibile: usare cache e artifact della prova precedente, indicandone data e SHA.
- Login/OIDC non funzionante: mostrare run reale precedente e analizzare il bootstrap dopo la sessione.
- Copilot lento o proposta errata: tornare alla diff pre-verificata e mostrare come i test discriminano.
- Provisioning lento: mostrare operazioni in corso e run precedente; non rimuovere risorse per accelerare.
- Policy nega il deploy: mostrare il diniego come controllo valido, non disattivarla.

## Roadmap dopo il workshop

| Fase | Deliverable | Criterio di completamento |
| --- | --- | --- |
| Standard | Regole, tag, region, eccezioni e responsabilita | Approvazione Metix |
| Moduli | Wrapper AVM versionati e testati | Build, scan, prove live e documentazione |
| Catalogo | Pattern per rete, storage privato, web, VM, backup/DR, AVD | Owner e criteri di utilizzo per pattern |
| Self-service | Parametri limitati -> PR -> controlli -> release | Nessun bypass di review/approval |

KPI: tempo richiesta-PR, tempo PR-deploy, errori prima del rilascio, interventi manuali,
numero/scadenza eccezioni, riuso dei moduli. Raccogliere un valore iniziale prima di promettere miglioramenti.