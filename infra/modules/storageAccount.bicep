@description('Name of the storage account')
param name string

@description('Location for the storage account')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('SKU for the storage account')
param sku string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

@description('The resource ID of the storage account')
output id string = storageAccount.id

@description('The name of the storage account')
output name string = storageAccount.name
