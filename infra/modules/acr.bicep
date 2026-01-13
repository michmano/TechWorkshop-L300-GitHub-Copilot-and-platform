@description('Name of the Azure Container Registry')
param name string

@description('Location for the registry')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('SKU for the registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Enable admin user')
param adminUserEnabled bool = false

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
}

@description('The resource ID of the ACR')
output id string = containerRegistry.id

@description('The name of the ACR')
output name string = containerRegistry.name

@description('The login server')
output loginServer string = containerRegistry.properties.loginServer
