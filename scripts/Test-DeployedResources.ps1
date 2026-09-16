[CmdletBinding()]
param([Parameter(Mandatory)][string]$DeploymentFile)

$ErrorActionPreference = 'Stop'
$deployment = Get-Content $DeploymentFile -Raw | ConvertFrom-Json
if ($deployment.properties.provisioningState -ne 'Succeeded') { throw 'Deployment non riuscito.' }
$resources = $deployment.properties.outputs.resources.value
if (-not $resources.keyVaultId -or -not $resources.storageAccountId) { throw 'Output risorse mancanti.' }

foreach ($resourceId in @($resources.keyVaultId, $resources.storageAccountId)) {
    $json = & az resource show --ids $resourceId --output json
    if ($LASTEXITCODE -ne 0) { throw "Impossibile leggere $resourceId" }
    $resource = $json | ConvertFrom-Json
    if ($resource.properties.publicNetworkAccess -ne 'Disabled') { throw "Accesso pubblico rilevato: $resourceId" }
    foreach ($tag in @('Environment', 'Owner', 'CostCenter', 'ManagedBy', 'Workload')) {
        if ([string]::IsNullOrWhiteSpace($resource.tags.$tag)) { throw "Tag $tag mancante: $resourceId" }
    }
    if ($resource.tags.ManagedBy -cne 'IaC') { throw "ManagedBy non conforme: $resourceId" }
    $connections = @($resource.properties.privateEndpointConnections)
    if ($connections.Count -eq 0 -or @($connections | Where-Object { $_.properties.privateLinkServiceConnectionState.status -ne 'Approved' }).Count -gt 0) {
        throw "Private Endpoint assente o non approvato: $resourceId"
    }
    if ($resourceId -eq $resources.keyVaultId) {
        if ($resource.properties.enableRbacAuthorization -ne $true -or $resource.properties.enablePurgeProtection -ne $true) { throw 'Key Vault: RBAC o purge protection non conformi.' }
    } else {
        if ($resource.properties.allowSharedKeyAccess -ne $false -or $resource.properties.allowBlobPublicAccess -ne $false) { throw 'Storage: Shared Key o accesso Blob pubblico non conformi.' }
        if ($resource.properties.minimumTlsVersion -ne 'TLS1_2' -or $resource.properties.supportsHttpsTrafficOnly -ne $true) { throw 'Storage: TLS/HTTPS non conformi.' }
    }
    Write-Host "PASS management plane: $($resource.name)"
}
Write-Host 'DNS, routing, RBAC applicativo e accesso ai dati vanno provati separatamente dalla rete privata.'