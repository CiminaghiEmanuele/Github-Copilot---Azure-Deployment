[CmdletBinding()]
param([switch]$SkipDocumentation)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$artifacts = Join-Path $root '.artifacts'
$null = New-Item -ItemType Directory -Path $artifacts -Force

function Invoke-AzChecked {
    param([string[]]$Arguments)
    $messages = @(& az @Arguments 2>&1)
    $exitCode = $LASTEXITCODE
    $messages | ForEach-Object { Write-Host $_ }
    if ($exitCode -ne 0) { throw "Azure CLI terminata con codice ${exitCode}: $($Arguments -join ' ')" }
    if ($messages -match '\bWarning [a-zA-Z0-9-]+:') { throw 'Warning Bicep: risolvere prima della consegna.' }
}

if (-not (Get-Command az -ErrorAction SilentlyContinue)) { throw 'Installare Azure CLI >= 2.76 e Bicep 0.44.1. Vedere docs/getting-started.md.' }
$demoSources = @(
    Get-Item (Join-Path $root 'infra/main.bicep')
    Get-ChildItem (Join-Path $root 'infra/modules') -Filter '*.bicep'
)
foreach ($source in $demoSources) {
    Invoke-AzChecked @('bicep', 'build', '--file', $source.FullName, '--outfile', (Join-Path $artifacts "$($source.BaseName).json"))
    Write-Host "PASS: build $($source.Name)"
}

$patternRoot = Join-Path $root 'infra/patterns'
if (Test-Path $patternRoot) {
    foreach ($source in Get-ChildItem $patternRoot -Recurse -Filter '*.bicep') {
        $relativeName = [System.IO.Path]::GetRelativePath($root, $source.FullName).Replace([System.IO.Path]::DirectorySeparatorChar, '-')
        Invoke-AzChecked @('bicep', 'build', '--file', $source.FullName, '--outfile', (Join-Path $artifacts "$relativeName.json"))
        Write-Host "PASS: build pattern $([System.IO.Path]::GetRelativePath($root, $source.FullName))"
    }
    foreach ($source in Get-ChildItem $patternRoot -Recurse -Filter '*.bicepparam') {
        $relativeName = [System.IO.Path]::GetRelativePath($root, $source.FullName).Replace([System.IO.Path]::DirectorySeparatorChar, '-')
        Invoke-AzChecked @('bicep', 'build-params', '--file', $source.FullName, '--outfile', (Join-Path $artifacts "$relativeName.json"))
        Write-Host "PASS: parametri pattern $([System.IO.Path]::GetRelativePath($root, $source.FullName))"
    }
}
foreach ($environment in @('dev', 'test', 'prod')) {
    $parameterOutput = Join-Path $artifacts "$environment.parameters.json"
    Invoke-AzChecked @('bicep', 'build-params', '--file', (Join-Path $root "infra/parameters/$environment.bicepparam"), '--outfile', $parameterOutput)
    $parameters = (Get-Content $parameterOutput -Raw | ConvertFrom-Json -AsHashtable).parameters
    if ($parameters.environment.value -cne $environment) { throw "Environment non coerente: $environment" }
    if ($parameters.workload.value -cnotmatch '^[a-z0-9]{2,8}$') { throw 'Workload deve contenere 2-8 caratteri alfanumerici minuscoli.' }
    if ($parameters.location.value -cne 'italynorth') { throw 'Region fuori dalla baseline demo.' }
    foreach ($required in @('owner', 'costCenter')) {
        if ([string]::IsNullOrWhiteSpace($parameters[$required].value)) { throw "Parametro obbligatorio vuoto: $required" }
    }
    Write-Host "PASS: parametri $environment"
}

& (Join-Path $PSScriptRoot 'Test-WorkloadGoal.ps1') -SelfTest
Copy-Item (Join-Path $root 'workload/goal.json') (Join-Path $artifacts 'goal.json') -Force
& (Join-Path $PSScriptRoot 'Test-Baseline.ps1') -TemplateDirectory $artifacts -SelfTest

foreach ($script in Get-ChildItem $PSScriptRoot -Filter '*.ps1') {
    $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$null, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0) { throw ($parseErrors -join "`n") }
}
Write-Host 'PASS: sintassi PowerShell.'

if (-not $SkipDocumentation) {
    $documents = @(Get-ChildItem $root -Filter '*.md') + @(Get-ChildItem (Join-Path $root 'docs') -Recurse -Filter '*.md') + @(Get-ChildItem (Join-Path $root '.github') -Recurse -Filter '*.md')
    foreach ($document in $documents) {
        $content = Get-Content $document.FullName -Raw
        foreach ($link in [regex]::Matches($content, '\[[^\]]+\]\(([^)]+)\)')) {
            $target = $link.Groups[1].Value
            if ($target -match '^(https?://|mailto:|#)') { continue }
            $relativePath = [Uri]::UnescapeDataString(($target -split '#')[0])
            if (-not (Test-Path (Join-Path $document.DirectoryName $relativePath))) { throw "Link mancante in $($document.Name): $target" }
        }
    }
    Write-Host 'PASS: link locali della documentazione.'
}
Write-Host 'PASS: verifiche locali completate. Nessuna risorsa Azure modificata.'