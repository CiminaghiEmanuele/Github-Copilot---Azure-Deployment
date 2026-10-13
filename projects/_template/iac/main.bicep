targetScope = 'resourceGroup'

@description('Azure region for project resources.')
param location string = resourceGroup().location

@description('Short workload code used for naming. Use 2-8 lowercase alphanumeric characters.')
param workload string

@description('Deployment environment.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Required tags applied to taggable resources.')
param tags object

output projectScope string = resourceGroup().id
output projectWorkload string = workload
output projectEnvironment string = environment