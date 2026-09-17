using '../main.bicep'

param environment = 'dev'
param location = 'italynorth'
param workload = 'demo'
param owner = 'platform-team'
param costCenter = 'workshop'
param storageSku = 'Standard_LRS'
param logRetentionInDays = 30
param network = {
  addressPrefix: '10.40.0.0/16'
  appSubnetPrefix: '10.40.1.0/24'
  dataSubnetPrefix: '10.40.2.0/24'
  privateEndpointSubnetPrefix: '10.40.3.0/24'
}
