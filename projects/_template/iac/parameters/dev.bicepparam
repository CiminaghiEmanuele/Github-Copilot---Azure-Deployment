using '../main.bicep'

param workload = '{{WORKLOAD}}'
param environment = 'dev'
param location = 'italynorth'
param tags = {
  Environment: 'dev'
  Owner: '{{OWNER}}'
  CostCenter: 'TBD'
  ManagedBy: 'IaC'
  Workload: '{{WORKLOAD}}'
}