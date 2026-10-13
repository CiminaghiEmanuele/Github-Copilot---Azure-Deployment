# Projects

Questa cartella contiene pacchetti progetto creati dalla factory. Ogni progetto deve avere IaC,
documentazione, test previsti ed evidenze separate sotto `projects/<project-name>/`.

Usare [project factory](../docs/project-factory.md) per discovery, struttura e criteri di pronto per
build. Il template di partenza e' in [_template](_template/README.md).

Esempio:

```powershell
pwsh -File scripts/New-Project.ps1 -ProjectName contoso-portale -CustomerCode contoso -Workload portal -Owner platform-team
```

Non salvare segreti, chiavi, token, tenant ID o subscription ID nei file progetto.