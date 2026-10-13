[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[a-z][a-z0-9-]{1,39}$')]
    [string]$ProjectName,

    [Parameter(Mandatory)]
    [ValidatePattern('^[a-z][a-z0-9-]{2,39}$')]
    [string]$CustomerCode,

    [Parameter(Mandatory)]
    [ValidatePattern('^[a-z0-9]{2,8}$')]
    [string]$Workload,

    [Parameter(Mandatory)]
    [ValidateLength(3, 80)]
    [string]$Owner,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$templateRoot = Join-Path $root 'projects/_template'
$targetRoot = Join-Path $root "projects/$ProjectName"

if (-not (Test-Path $templateRoot)) { throw "Template non trovato: $templateRoot" }
if ((Test-Path $targetRoot) -and -not $Force) { throw "Progetto gia' esistente: $ProjectName. Usare -Force solo per sovrascrivere consapevolmente." }

if ($PSCmdlet.ShouldProcess($targetRoot, 'Create project from template')) {
    if (Test-Path $targetRoot) { Remove-Item $targetRoot -Recurse -Force }
    New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
    Copy-Item -Path (Join-Path $templateRoot '*') -Destination $targetRoot -Recurse -Force

    $replacements = [ordered]@{
        '{{PROJECT_NAME}}' = $ProjectName
        '{{CUSTOMER_CODE}}' = $CustomerCode
        '{{WORKLOAD}}' = $Workload
        '{{OWNER}}' = $Owner
    }

    foreach ($projectFile in Get-ChildItem $targetRoot -Recurse -File) {
        $content = Get-Content $projectFile.FullName -Raw
        foreach ($placeholder in $replacements.Keys) {
            $content = $content.Replace($placeholder, $replacements[$placeholder])
        }
        Set-Content -Path $projectFile.FullName -Value $content -NoNewline
    }

    Write-Host "PASS: progetto creato in projects/$ProjectName"
    Write-Host 'Prossimo passo: completare docs/discovery.md e docs/architecture.md prima di aggiungere risorse reali.'
}