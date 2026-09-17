using '../main.bicep'

param environment = 'prod'
param location = 'italynorth'
param workload = 'demo'
param owner = 'platform-team'
param costCenter = 'workshop'
param storageSku = 'Standard_ZRS'
param logRetentionInDays = 90
param network = {
  addressPrefix: '10.42.0.0/16'
  appSubnetPrefix: '10.42.1.0/24'
  dataSubnetPrefix: '10.42.2.0/24'
  privateEndpointSubnetPrefix: '10.42.3.0/24'
}
