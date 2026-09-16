param virtualNetworkResourceId string
param tags object

module keyVaultDns 'br/public:avm/res/network/private-dns-zone:0.8.1' = {
  name: 'key-vault-dns'
  params: {
    name: 'privatelink.vaultcore.azure.net'
    tags: tags
    enableTelemetry: false
    virtualNetworkLinks: [
      {
        name: 'link-demo-vnet'
        virtualNetworkResourceId: virtualNetworkResourceId
        registrationEnabled: false
      }
    ]
  }
}

module blobDns 'br/public:avm/res/network/private-dns-zone:0.8.1' = {
  name: 'blob-dns'
  params: {
    name: 'privatelink.blob.${environment().suffixes.storage}'
    tags: tags
    enableTelemetry: false
    virtualNetworkLinks: [
      {
        name: 'link-demo-vnet'
        virtualNetworkResourceId: virtualNetworkResourceId
        registrationEnabled: false
      }
    ]
  }
}

output keyVaultDnsZoneResourceId string = keyVaultDns.outputs.resourceId
output blobDnsZoneResourceId string = blobDns.outputs.resourceId
