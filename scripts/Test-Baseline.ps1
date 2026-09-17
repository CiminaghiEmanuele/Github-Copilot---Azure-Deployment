[CmdletBinding()]
param(
    [string]$TemplateDirectory = (Join-Path $PSScriptRoot '../.artifacts'),
    [switch]$SelfTest
)

$ErrorActionPreference = 'Stop'

function Get-TemplateResources {
    param([System.Collections.IDictionary]$Template)
    if ($Template.resources -is [System.Collections.IDictionary]) {
        return @($Template.resources.Values)
    }
    return @($Template.resources)
}

function Get-ModuleValues {
    param([System.Collections.IDictionary]$Template, [string]$Name)
    $matches = @(Get-TemplateResources $Template | Where-Object { $_.name -eq $Name })
    if ($matches.Count -ne 1) { throw "Modulo atteso non trovato o duplicato: $Name" }
    return $matches[0].properties.parameters
}

function Find-PublicIp {
    param([System.Collections.IDictionary]$Template)
    foreach ($resource in (Get-TemplateResources $Template)) {
        if ($resource.type -eq 'Microsoft.Network/publicIPAddresses') { return $true }
        if ($resource.properties.template -and (Find-PublicIp $resource.properties.template)) { return $true }
    }
    return $false
}

function Get-BaselineViolations {
    param([System.Collections.IDictionary]$Templates)
    $violations = [System.Collections.Generic.List[string]]::new()
    $storage = Get-ModuleValues $Templates.services 'storage-account'
    $vault = Get-ModuleValues $Templates.services 'key-vault'
    foreach ($entry in @(
        @{ Label = 'Storage'; Values = $storage },
        @{ Label = 'KeyVault'; Values = $vault }
    )) {
        if ($entry.Values.publicNetworkAccess.value -cne 'Disabled') {
            $violations.Add("$($entry.Label): publicNetworkAccess deve essere Disabled letterale.")
        }
        if ($entry.Values.networkAcls.value.defaultAction -cne 'Deny' -or $entry.Values.networkAcls.value.bypass -cne 'None') {
            $violations.Add("$($entry.Label): network ACL richiede Deny e bypass None.")
        }
        $endpoints = $entry.Values.privateEndpoints.value
        if ($endpoints -isnot [array] -or $endpoints.Count -ne 1) {
            $violations.Add("$($entry.Label): atteso un endpoint privato.")
        } elseif (-not $endpoints[0].subnetResourceId -or -not $endpoints[0].privateDnsZoneGroup.privateDnsZoneGroupConfigs[0].privateDnsZoneResourceId) {
            $violations.Add("$($entry.Label): subnet o zona DNS privata mancante.")
        }
        if (-not $entry.Values.diagnosticSettings.value[0].workspaceResourceId) {
            $violations.Add("$($entry.Label): diagnostica verso Log Analytics mancante.")
        }
    }
    foreach ($property in @('allowBlobPublicAccess', 'allowSharedKeyAccess')) {
        if ($storage[$property].value -isnot [bool] -or $storage[$property].value -ne $false) {
            $violations.Add("Storage: $property deve essere false letterale.")
        }
    }
    if ($storage.minimumTlsVersion.value -cne 'TLS1_2' -or $storage.supportsHttpsTrafficOnly.value -ne $true) {
        $violations.Add('Storage: HTTPS e TLS 1.2 obbligatori.')
    }
    foreach ($property in @('enableRbacAuthorization', 'enablePurgeProtection')) {
        if ($vault[$property].value -isnot [bool] -or $vault[$property].value -ne $true) {
            $violations.Add("KeyVault: $property deve essere true letterale.")
        }
    }
    if (-not $storage.blobServices.value.diagnosticSettings[0].workspaceResourceId) {
        $violations.Add('Blob: diagnostica del data plane mancante.')
    }
    foreach ($tag in @('Environment', 'Owner', 'CostCenter', 'ManagedBy', 'Workload')) {
        if (-not $Templates.main.variables.tags.Contains($tag)) { $violations.Add("Tag obbligatorio mancante: $tag") }
    }
    if ($Templates.main.variables.tags.ManagedBy -cne 'IaC') { $violations.Add('ManagedBy deve essere IaC.') }
    if (Find-PublicIp $Templates.main) { $violations.Add('Public IP non consentito nel pattern demo.') }
    foreach ($zone in @('key-vault-dns', 'blob-dns')) {
        $dns = Get-ModuleValues $Templates['private-access'] $zone
        if (-not $dns.virtualNetworkLinks.value[0].virtualNetworkResourceId -or $dns.virtualNetworkLinks.value[0].registrationEnabled -ne $false) {
            $violations.Add("DNS: link VNet non valido in $zone.")
        }
    }
    return $violations.ToArray()
}

$templates = @{}
foreach ($templateName in @('main', 'services', 'private-access')) {
    $templates[$templateName] = Get-Content (Join-Path $TemplateDirectory "$templateName.json") -Raw | ConvertFrom-Json -AsHashtable
}
$violations = @(Get-BaselineViolations $templates)
if ($violations.Count -gt 0) { throw ($violations -join "`n") }
Write-Host 'PASS: guardrail il team sul pattern compilato.'

if ($SelfTest) {
    $mutations = @{
        'Storage pubblico' = { param($data) (Get-ModuleValues $data.services 'storage-account').publicNetworkAccess.value = 'Enabled' }
        'Shared Key' = { param($data) (Get-ModuleValues $data.services 'storage-account').allowSharedKeyAccess.value = $true }
        'RBAC disabilitato' = { param($data) (Get-ModuleValues $data.services 'key-vault').enableRbacAuthorization.value = $false }
        'Purge protection disabilitata' = { param($data) (Get-ModuleValues $data.services 'key-vault').enablePurgeProtection.value = $false }
        'Private Endpoint rimosso' = { param($data) (Get-ModuleValues $data.services 'storage-account').privateEndpoints.value = @() }
        'Tag mancante' = { param($data) $data.main.variables.tags.Remove('Owner') }
        'DNS senza VNet' = { param($data) (Get-ModuleValues $data['private-access'] 'blob-dns').virtualNetworkLinks.value[0].virtualNetworkResourceId = '' }
    }
    foreach ($testName in $mutations.Keys) {
        $copy = $templates | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable
        $null = & $mutations[$testName] $copy
        if (@(Get-BaselineViolations $copy).Count -eq 0) { throw "Guardrail non discriminante: $testName" }
        Write-Host "PASS: modifica non conforme bloccata: $testName"
    }
}