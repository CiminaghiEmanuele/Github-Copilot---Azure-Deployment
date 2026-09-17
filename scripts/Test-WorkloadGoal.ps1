[CmdletBinding()]
param(
    [string]$GoalPath = (Join-Path $PSScriptRoot '../workload/goal.json'),
    [ValidateSet('dev', 'test', 'prod')][string]$Environment,
    [string]$ExpectedCustomerCode,
    [switch]$ForProvisioning,
    [switch]$BindingOnly,
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$schemaPath = Join-Path $root 'workload/goal.schema.json'

function Assert-WorkloadGoal {
    param(
        [System.Collections.IDictionary]$Goal,
        [bool]$Provisioning,
        [string]$TargetEnvironment,
        [string]$CustomerCode
    )
    $json = $Goal | ConvertTo-Json -Depth 30
    if (-not (Test-Json -Json $json -SchemaFile $schemaPath -ErrorAction Stop)) { throw 'Goal non conforme allo schema.' }
    $requirementIds = @($Goal.requirements | ForEach-Object { $_.id })
    if (@($requirementIds | Select-Object -Unique).Count -ne $requirementIds.Count) { throw 'ID requisito duplicato.' }
    if (@($Goal.requirements | Where-Object { $_.verification.phase -eq 'postdeploy' }).Count -eq 0) {
        throw 'Serve almeno una verifica postdeploy del risultato.'
    }
    $wiredSuites = @{
        predeploy = @('scripts/Test-Baseline.ps1')
        postdeploy = @('scripts/Test-DeployedResources.ps1')
    }
    foreach ($requirement in $Goal.requirements) {
        $relative = $requirement.verification.path
        if ($relative -match '(^|/)\.\.(/|$)' -or $relative.StartsWith('/') -or $relative -match '//') { throw "Percorso non consentito: $relative" }
        $target = [IO.Path]::GetFullPath((Join-Path $root $relative))
        if (-not $target.StartsWith($root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Percorso esterno al repository.' }
        if (-not $BindingOnly -and -not (Test-Path -LiteralPath $target -PathType Leaf)) { throw "Verifica mancante per $($requirement.id): $relative" }
        if ($requirement.verification.method -eq 'automated' -and $relative -cnotin $wiredSuites[$requirement.verification.phase]) {
            throw "Suite automatica non collegata alla fase di pipeline: $relative. Estendere e revisionare suite, workflow e registro insieme."
        }
    }
    if ($Provisioning) {
        if ($Goal.purpose -ne 'customer') { throw 'Il goal di riferimento non autorizza preview o provisioning. Configurare un goal cliente.' }
        if ([string]::IsNullOrWhiteSpace($CustomerCode) -or $Goal.customerCode -cne $CustomerCode) {
            throw 'Cliente diverso dal binding CUSTOMER_CODE dell environment protetto.'
        }
        if ([string]::IsNullOrWhiteSpace($TargetEnvironment) -or $TargetEnvironment -cnotin $Goal.environments) {
            throw 'Ambiente non incluso nel goal cliente.'
        }
        $parameterFile = Join-Path $root ".artifacts/$TargetEnvironment.parameters.json"
        $parameters = (Get-Content $parameterFile -Raw | ConvertFrom-Json -AsHashtable).parameters
        if ($parameters.workload.value -cne $Goal.workload -or $parameters.location.value -cne $Goal.constraints.region -or $parameters.owner.value -cne $Goal.owner -or $parameters.environment.value -cne $TargetEnvironment) {
            throw 'Goal e parametri compilati non concordano su workload, region, owner o ambiente.'
        }
    }
}

$goal = Get-Content $GoalPath -Raw | ConvertFrom-Json -AsHashtable
if ($BindingOnly -and (-not $ForProvisioning -or $SelfTest)) { throw 'BindingOnly e riservato al gate di artefatti; non sostituisce i controlli locali.' }
Assert-WorkloadGoal $goal $ForProvisioning.IsPresent $Environment $ExpectedCustomerCode
Write-Host 'PASS: contratto goal, tracciabilita e registro delle suite verificate per questa fase.'
Write-Host 'Questo controllo NON esegue le verifiche dichiarate e NON attesta approvazione o raggiungimento del goal.'

if ($SelfTest) {
    $mutations = @{
        'Obiettivo assente' = { param($data) $data.Remove('objective') }
        'Verifica assente' = { param($data) $data.requirements[0].Remove('verification') }
        'ID duplicato' = { param($data) $data.requirements += $data.requirements[0] }
        'File verifica inesistente' = { param($data) $data.requirements[0].verification.path = 'scripts/not-a-real-test.ps1' }
        'Suite non collegata' = { param($data) $data.requirements[0].verification.method = 'automated'; $data.requirements[0].verification.path = 'scripts/Test-Repository.ps1' }
        'Percorso esterno' = { param($data) $data.requirements[0].verification.path = '../external.ps1' }
        'Nessun test risultato' = { param($data) foreach ($requirement in $data.requirements) { $requirement.verification.phase = 'predeploy' } }
    }
    foreach ($testName in $mutations.Keys) {
        $copy = $goal | ConvertTo-Json -Depth 30 | ConvertFrom-Json -AsHashtable
        $null = & $mutations[$testName] $copy
        $rejected = $false
        try { Assert-WorkloadGoal $copy $false '' '' } catch { $rejected = $true }
        if (-not $rejected) { throw "Test non discriminante: $testName" }
        Write-Host "PASS: goal non valido bloccato: $testName"
    }
    foreach ($case in @('Reference', 'CustomerMismatch', 'EnvironmentMismatch')) {
        $copy = $goal | ConvertTo-Json -Depth 30 | ConvertFrom-Json -AsHashtable
        $copy.purpose = 'customer'
        $customer = $copy.customerCode
        $targetEnvironment = $copy.environments[0]
        if ($case -eq 'Reference') { $copy.purpose = 'reference' }
        if ($case -eq 'CustomerMismatch') { $customer = 'different-customer' }
        if ($case -eq 'EnvironmentMismatch') { $copy.environments = @('dev'); $targetEnvironment = 'prod' }
        $rejected = $false
        try { Assert-WorkloadGoal $copy $true $targetEnvironment $customer } catch { $rejected = $true }
        if (-not $rejected) { throw "Gate provisioning non discriminante: $case" }
        Write-Host "PASS: gate provisioning: $case"
    }
    $parameters = (Get-Content (Join-Path $root '.artifacts/dev.parameters.json') -Raw | ConvertFrom-Json -AsHashtable).parameters
    $fixture = $goal | ConvertTo-Json -Depth 30 | ConvertFrom-Json -AsHashtable
    $fixture.purpose = 'customer'
    $fixture.environments = @('dev')
    $fixture.workload = $parameters.workload.value
    $fixture.owner = $parameters.owner.value
    $fixture.constraints.region = $parameters.location.value
    Assert-WorkloadGoal $fixture $true 'dev' $fixture.customerCode
    Write-Host 'PASS: binding cliente/parametri corretto in fixture locale; nessuna autorizzazione reale.'
    foreach ($field in @('workload', 'owner', 'region')) {
        $copy = $fixture | ConvertTo-Json -Depth 30 | ConvertFrom-Json -AsHashtable
        if ($field -eq 'region') { $copy.constraints.region = 'not-a-region' }
        elseif ($field -eq 'workload') { $copy.workload = 'zzzz9999'; if ($copy.workload -eq $fixture.workload) { $copy.workload = 'yyyy8888' } }
        else { $copy.owner = $fixture.owner + '-mismatch' }
        $rejected = $false
        try { Assert-WorkloadGoal $copy $true 'dev' $copy.customerCode } catch { $rejected = $true }
        if (-not $rejected) { throw "Mismatch parametri non rilevato: $field" }
        Write-Host "PASS: mismatch goal/parametri bloccato: $field"
    }
}