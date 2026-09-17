## Requisito

Descrivere obiettivo, ambiente e collegamento alla richiesta approvata.
Indicare codice cliente, workload, ID REQ-nnn del goal e riferimento alla review del piano architetturale.

## Modifiche e scelte WAF

Indicare file/risorse, motivazione, sicurezza, costi, affidabilita e alternative rilevanti.

## Evidenze

- [ ] Goal cliente e parametri coerenti; nessun requisito senza criterio misurabile e owner.
- [ ] Ogni suite automatica indicata nel goal e' realmente collegata alla fase corretta e misura il requisito dichiarato.
- [ ] Verifiche manuali predeploy documentate; prove postdeploy pianificate, senza esiti inventati.
- [ ] `pwsh -File scripts/Test-Repository.ps1` superato.
- [ ] Preview Azure sullo SHA corrente: inserire link alla run e SHA completo.
- [ ] What-If esaminato: create/modify/delete, rumore e risorse non valutate spiegati.
- [ ] Standard, tag, DNS, diagnostica e permessi verificati.
- [ ] Nessun segreto o dato cliente nel diff o negli artefatti.
- [ ] Guide aggiornate e impatto economico approvato, se applicabile.
- [ ] Strategia di recovery e rischi non reversibili descritti.

## Eccezioni

Nessuna, oppure riferimento all'eccezione approvata con owner e scadenza.
Per una modifica solo documentale, motivare la non applicabilita della preview Azure.