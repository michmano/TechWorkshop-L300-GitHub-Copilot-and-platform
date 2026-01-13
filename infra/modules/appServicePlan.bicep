@description('Name of the App Service Plan')
param name string

@description('Location for the plan')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('SKU for the plan')
param sku object = {
  name: 'B1'
  tier: 'Basic'
  capacity: 1
}

@description('Kind of plan')
param kind string = 'linux'

@description('Reserved (true for Linux)')
param reserved bool = true

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    reserved: reserved
  }
  sku: sku
}

@description('The resource ID of the App Service Plan')
output id string = appServicePlan.id

@description('The name of the App Service Plan')
output name string = appServicePlan.name
