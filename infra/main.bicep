targetScope = 'resourceGroup'

import { networkConfiguration } from './modules/network.bicep'

@description('Environment del workload. PROD richiede una valutazione architetturale separata.')
@allowed(['dev', 'test', 'prod'])
param environment string

@description('Region approvata per questa demo.')
@allowed(['italynorth'])
param location string = 'italynorth'

@description('Identificativo del workload: da 2 a 8 caratteri alfanumerici minuscoli.')
@minLength(2)
@maxLength(8)
param workload string = 'demo'

@description('Team responsabile del workload, non una credenziale.')
@minLength(1)
param owner string

@description('Centro di costo approvato.')
@minLength(1)
param costCenter string

@description('SKU Storage consentite nel pattern. La disponibilita regionale va verificata prima del deploy.')
@allowed(['Standard_LRS', 'Standard_ZRS'])
param storageSku string = 'Standard_LRS'

@description('Retention di Log Analytics in giorni.')
@minValue(30)
@maxValue(730)
param logRetentionInDays int = 30

@description('Spazio indirizzi e subnet, da concordare con il responsabile di rete.')
param network networkConfiguration

var tags = {
  Environment: environment
  Owner: owner
  CostCenter: costCenter
  ManagedBy: 'IaC'
  Workload: workload
}
var suffix = '${workload}-${environment}-itn'
var uniqueSuffix = take(uniqueString(resourceGroup().id, workload), 8)

module monitoring './modules/monitoring.bicep' = {
  name: 'monitoring-${environment}'
  params: {
    name: 'law-workload-${suffix}'
    location: location
    tags: tags
    retentionInDays: logRetentionInDays
  }
}

module virtualNetwork './modules/network.bicep' = {
  name: 'network-${environment}'
  params: {
    name: 'vnet-workload-${suffix}'
    location: location
    tags: tags
    network: network
    workspaceResourceId: monitoring.outputs.resourceId
  }
}

module privateAccess './modules/private-access.bicep' = {
  name: 'private-access-${environment}'
  params: {
    virtualNetworkResourceId: virtualNetwork.outputs.resourceId
    tags: tags
  }
}

module services './modules/services.bicep' = {
  name: 'services-${environment}'
  params: {
    keyVaultName: 'kv-${workload}-${environment}-${take(uniqueSuffix, 6)}'
    storageAccountName: 'st${workload}${environment}${uniqueSuffix}'
    location: location
    tags: tags
    storageSku: storageSku
    workspaceResourceId: monitoring.outputs.resourceId
    privateEndpointSubnetResourceId: virtualNetwork.outputs.privateEndpointSubnetResourceId
    keyVaultDnsZoneResourceId: privateAccess.outputs.keyVaultDnsZoneResourceId
    blobDnsZoneResourceId: privateAccess.outputs.blobDnsZoneResourceId
  }
}

@description('Identificativi di management plane; nessun segreto o chiave viene restituito.')
output resources object = {
  resourceGroupName: resourceGroup().name
  virtualNetworkId: virtualNetwork.outputs.resourceId
  workspaceId: monitoring.outputs.resourceId
  keyVaultId: services.outputs.keyVaultResourceId
  storageAccountId: services.outputs.storageAccountResourceId
}
