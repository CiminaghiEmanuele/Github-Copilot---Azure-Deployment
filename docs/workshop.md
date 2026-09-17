# Workshop Azure, 10:00-13:00

Guida di conduzione basata sulla proposta iniziale. Obiettivo: dimostrare un processo ripetibile,
non generare l'intera infrastruttura da zero durante la sessione.

Il percorso e' ora la [factory multi-cliente](factory.md): dal goal a requisiti, architettura approvata,
codice e test, fino alle evidenze del risultato. Il pattern PaaS e' il caso pratico disponibile,
non una soluzione da proporre automaticamente a ogni cliente.

## Agenda e output

| Orario | Attivita | Output da mostrare |
| --- | --- | --- |
| 10:00-10:20 | Discovery del processo il team | 3-5 problemi prioritari |
| 10:20-10:50 | WAF tradotto in standard | Guardrail, default, eccezioni |
| 10:50-11:25 | Bicep e AVM con lettura del codice | Moduli, parametri, output e build |
| 11:25-11:35 | Pausa tecnica | Repository e sessioni demo pronte |
| 11:35-12:20 | Demo Copilot guidata | Goal, Plan/Build, modifica, test, documentazione, PR |
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
- Come si traduce il goal di un cliente in una prova misurabile e chi ne accetta l'esito?
- Come sono isolati repository, target e identita tra clienti e ambienti?

Compilare durante la sessione:

| Problema osservato | Impatto | Regola/controllo candidato | Owner |
| --- | --- | --- | --- |
| Da raccogliere | Da misurare | Da concordare | Da nominare |

Non presentare i parametri di esempio come standard aziendale gia' approvato.

## Demo centrale, 45 minuti

| Minuti | Azione | Verifica di riuscita |
| --- | --- | --- |
| 0-5 | Aprire factory, goal, standard, architettura e agenti | Distinzione tra riferimento e cliente reale |
| 5-12 | Plan: chiarire goal ed evoluzione retention DEV | Assunzioni, criteri misurabili, WAF e test espliciti |
| 12-20 | Review del codice e del contratto AVM | Scope RG, output, naming e tag leggibili |
| 20-28 | Approvare il piano e usare Build per la modifica DEV | Diff piccolo, nessun cambio sicurezza, nessun terminale nell'agente |
| 28-35 | Aggiornare documentazione dal codice | Guide coerenti con valore effettivo |
| 35-42 | Il tecnico esegue Test-Repository e mostra test negativi | Goal incoerenti e violazioni di sicurezza bloccati |
| 42-45 | Commit/PR, solo se autorizzati | Diff, template PR, check locale |

I prompt sono in [copilot.md](copilot.md). Gli esercizi non richiedono costi Azure.
La baseline gia' contiene private endpoint e diagnostica: scegliere una piccola evoluzione, non
disattivare una protezione per costruire una scena artificiale.

## Demo Actions, 25 minuti

Prerequisito: repository e goal cliente DEV preparati e revisionati, CUSTOMER_CODE configurato
nel bootstrap. Con il goal `reference` fermarsi ai test locali e mostrare il blocco atteso prima del login.

1. Mostrare Validate verde e assenza di login Azure nel workflow PR.
2. Il maintainer avvia Azure Preview da main su SHA completo e approva l'environment preview.
3. Leggere goal, artifact What-If e limiti; collegare la run alla PR e verificare cliente e SHA.
4. Mostrare la review e il merge autorizzato; spiegare che non parte alcun deploy automatico.
5. Avviare Deploy DEV solo se autorizzati a creare risorse e sostenere costi.
6. Mostrare il piano della nuova run, il gate `dev`, OIDC e il post-check finale o una run precedente reale. Evidenziare le prove del goal ancora da raccogliere.

Senza autorizzazione al deploy fermarsi alla preview soltanto se anche quella e' autorizzata e
configurata; altrimenti restare in locale, dichiarandolo esplicitamente.
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
agenti e prompt provati nel client, goal cliente revisionato, artifact e screenshot reali con dati sensibili rimossi.

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
| Pilota cliente | Repository privato, goal reale, binding, identita e prove | Accettazione di tutti i criteri con evidenze reali |
| Standard | Regole, tag, region, eccezioni e responsabilita | Approvazione il team |
| Moduli | Wrapper AVM versionati e testati | Build, scan, prove live e documentazione |
| Catalogo | Pattern per rete, storage privato, web, VM, backup/DR, AVD | Owner e criteri di utilizzo per pattern |
| Self-service | Parametri limitati -> PR -> controlli -> release | Nessun bypass di review/approval |

KPI: tempo richiesta-PR, tempo PR-deploy, errori prima del rilascio, interventi manuali,
numero/scadenza eccezioni, riuso dei moduli. Raccogliere un valore iniziale prima di promettere miglioramenti.