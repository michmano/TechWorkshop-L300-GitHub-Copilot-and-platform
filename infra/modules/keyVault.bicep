@description('Name of the Key Vault')
param name string

@description('Location for the Key Vault')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('SKU for the Key Vault')
param sku string = 'standard'

@description('Tenant ID for the Key Vault')
param tenantId string = subscription().tenantId

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: sku
    }
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
  }
}

@description('The resource ID of the Key Vault')
output id string = keyVault.id

@description('The name of the Key Vault')
output name string = keyVault.name

@description('The URI of the Key Vault')
output vaultUri string = keyVault.properties.vaultUri
