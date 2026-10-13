# Template progetto Azure

Copiare questa struttura con [New-Project](../../scripts/New-Project.ps1) e completare le parti
contrassegnate come placeholder. Il template non autorizza deployment e non contiene risorse Azure
reali oltre a un entry point Bicep vuoto.

## Contenuto

| Percorso | Uso |
| --- | --- |
| [project.json](project.json) | Metadati non sensibili del progetto e stato della discovery. |
| [iac](iac/README.md) | IaC Bicep/AVM e parametri non sensibili. |
| [docs](docs/discovery.md) | Documentazione progettuale vendibile e handover. |
| [tests](tests/README.md) | Piano delle verifiche automatiche e manuali. |
| [evidence](evidence/README.md) | Indice delle evidenze reali raccolte dopo test e deploy. |

Prima di implementare risorse reali, completare discovery, architettura, piano di delivery e criteri
di accettazione.