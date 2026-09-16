param keyVaultName string
param storageAccountName string
param location string
param tags object
@allowed(['Standard_LRS', 'Standard_ZRS'])
param storageSku string
param workspaceResourceId string
param privateEndpointSubnetResourceId string
param keyVaultDnsZoneResourceId string
param blobDnsZoneResourceId string

module keyVault 'br/public:avm/res/key-vault/vault:0.14.2' = {
  name: 'key-vault'
  params: {
    name: keyVaultName
    location: location
    tags: tags
    enableTelemetry: false
    sku: 'standard'
    enableRbacAuthorization: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
    diagnosticSettings: [
      {
        name: 'diag-to-law'
        workspaceResourceId: workspaceResourceId
        logCategoriesAndGroups: [{ categoryGroup: 'allLogs' }]
        metricCategories: [{ category: 'AllMetrics' }]
      }
    ]
    privateEndpoints: [
      {
        name: 'pe-${keyVaultName}'
        subnetResourceId: privateEndpointSubnetResourceId
        tags: tags
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            { privateDnsZoneResourceId: keyVaultDnsZoneResourceId }
          ]
        }
      }
    ]
  }
}

module storage 'br/public:avm/res/storage/storage-account:0.33.0' = {
  name: 'storage-account'
  params: {
    name: storageAccountName
    location: location
    tags: tags
    enableTelemetry: false
    skuName: storageSku
    kind: 'StorageV2'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    requireInfrastructureEncryption: true
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
    diagnosticSettings: [
      {
        name: 'diag-to-law'
        workspaceResourceId: workspaceResourceId
        metricCategories: [{ category: 'AllMetrics' }]
      }
    ]
    blobServices: {
      deleteRetentionPolicyEnabled: true
      deleteRetentionPolicyDays: 7
      containerDeleteRetentionPolicyEnabled: true
      containerDeleteRetentionPolicyDays: 7
      isVersioningEnabled: true
      diagnosticSettings: [
        {
          name: 'diag-blob-to-law'
          workspaceResourceId: workspaceResourceId
          logCategoriesAndGroups: [{ categoryGroup: 'allLogs' }]
          metricCategories: [{ category: 'AllMetrics' }]
        }
      ]
    }
    privateEndpoints: [
      {
        name: 'pe-${storageAccountName}-blob'
        service: 'blob'
        subnetResourceId: privateEndpointSubnetResourceId
        tags: tags
        privateDnsZoneGroup: {
          privateDnsZoneGroupConfigs: [
            { privateDnsZoneResourceId: blobDnsZoneResourceId }
          ]
        }
      }
    ]
  }
}

output keyVaultResourceId string = keyVault.outputs.resourceId
output storageAccountResourceId string = storage.outputs.resourceId
