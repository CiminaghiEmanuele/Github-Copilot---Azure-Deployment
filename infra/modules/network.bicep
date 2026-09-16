@export()
type networkConfiguration = {
  addressPrefix: string
  appSubnetPrefix: string
  dataSubnetPrefix: string
  privateEndpointSubnetPrefix: string
}

param name string
param location string
param tags object
param network networkConfiguration
param workspaceResourceId string

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.10.2' = {
  name: 'virtual-network'
  params: {
    name: name
    location: location
    tags: tags
    enableTelemetry: false
    addressPrefixes: [network.addressPrefix]
    subnets: [
      {
        name: 'snet-app'
        addressPrefix: network.appSubnetPrefix
        defaultOutboundAccess: false
      }
      {
        name: 'snet-data'
        addressPrefix: network.dataSubnetPrefix
        defaultOutboundAccess: false
      }
      {
        name: 'snet-private-endpoints'
        addressPrefix: network.privateEndpointSubnetPrefix
        defaultOutboundAccess: false
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
    diagnosticSettings: [
      {
        name: 'diag-to-law'
        workspaceResourceId: workspaceResourceId
        logCategoriesAndGroups: [{ categoryGroup: 'allLogs' }]
        metricCategories: [{ category: 'AllMetrics' }]
      }
    ]
  }
}

output resourceId string = virtualNetwork.outputs.resourceId
output privateEndpointSubnetResourceId string = virtualNetwork.outputs.subnetResourceIds[2]
