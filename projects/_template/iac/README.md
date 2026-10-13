# IaC

Questa cartella contiene il codice Bicep/AVM del progetto. L'entry point iniziale e' volutamente
minimo: aggiungere risorse solo dopo approvazione del piano tecnico.

Regole:

- mantenere scope Resource Group salvo decisione approvata;
- non hard-coded tenant ID, subscription ID, chiavi o segreti;
- usare parametri per ambiente, workload, owner e cost center;
- documentare ogni nuova suite di test collegata ai requisiti;
- preferire moduli AVM con versioni verificate.