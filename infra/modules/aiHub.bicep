@description('Name of the AI Foundry Hub')
param name string

@description('Location for the hub')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('Friendly name for the hub')
param friendlyName string = 'Zava Storefront AI Hub'

@description('Description of the hub')
param description string = 'AI Foundry Hub for GPT-4 and Phi models'

@description('Storage account ID for the hub')
param storageAccountId string = ''

@description('Key Vault ID for the hub')
param keyVaultId string = ''

@description('Application Insights ID for the hub')
param applicationInsightsId string = ''

@description('Container Registry ID for the hub')
param containerRegistryId string = ''

resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: friendlyName
    description: description
    storageAccount: !empty(storageAccountId) ? storageAccountId : null
    keyVault: !empty(keyVaultId) ? keyVaultId : null
    applicationInsights: !empty(applicationInsightsId) ? applicationInsightsId : null
    containerRegistry: !empty(containerRegistryId) ? containerRegistryId : null
    publicNetworkAccess: 'Enabled'
  }
}

@description('The resource ID of the AI Hub')
output id string = aiHub.id

@description('The name of the AI Hub')
output name string = aiHub.name

@description('The principal ID of the system assigned identity')
output principalId string = aiHub.identity.principalId
