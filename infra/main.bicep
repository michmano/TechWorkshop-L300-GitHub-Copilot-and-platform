targetScope = 'resourceGroup'

@description('Name of the environment (e.g., dev, staging, prod)')
param environmentName string

@description('Location for all resources')
param location string = 'westus3'

@description('Tags for all resources')
param tags object = {
  Environment: environmentName
  Application: 'ZavaStorefront'
  ManagedBy: 'Bicep'
}

@description('Docker image and tag to deploy')
param dockerImageAndTag string = 'zavastore:latest'

// Generate unique resource names
var resourceToken = uniqueString(subscription().id, resourceGroup().id, environmentName)
var prefix = 'zavastore'

// Resource names
var logAnalyticsName = '${prefix}-logs-${resourceToken}'
var appInsightsName = '${prefix}-ai-${resourceToken}'
var acrName = '${prefix}acr${resourceToken}'
var appServicePlanName = '${prefix}-plan-${resourceToken}'
var appServiceName = '${prefix}-app-${resourceToken}'
var storageAccountName = '${prefix}st${resourceToken}'
var keyVaultName = '${prefix}-kv-${resourceToken}'
var aiHubName = '${prefix}-aihub-${resourceToken}'

// AcrPull role definition ID (built-in Azure role)
var acrPullRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// Deploy Log Analytics Workspace
module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics-deployment'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

// Deploy Application Insights
module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights-deployment'
  params: {
    name: appInsightsName
    location: location
    tags: tags
    workspaceId: logAnalytics.outputs.id
  }
}

// Deploy Azure Container Registry
module acr 'modules/acr.bicep' = {
  name: 'acr-deployment'
  params: {
    name: acrName
    location: location
    tags: tags
    sku: 'Basic'
    adminUserEnabled: false
  }
}

// Deploy App Service Plan
module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan-deployment'
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: {
      name: 'B1'
      tier: 'Basic'
      capacity: 1
    }
    kind: 'linux'
    reserved: true
  }
}

// Deploy App Service
module appService 'modules/appService.bicep' = {
  name: 'appService-deployment'
  params: {
    name: appServiceName
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    acrLoginServer: acr.outputs.loginServer
    dockerImageAndTag: dockerImageAndTag
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
  }
}

// Deploy Storage Account for AI Hub
module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount-deployment'
  params: {
    name: storageAccountName
    location: location
    tags: tags
    sku: 'Standard_LRS'
  }
}

// Deploy Key Vault for AI Hub
module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault-deployment'
  params: {
    name: keyVaultName
    location: location
    tags: tags
    sku: 'standard'
  }
}

// Deploy AI Hub (Microsoft Foundry)
module aiHub 'modules/aiHub.bicep' = {
  name: 'aiHub-deployment'
  params: {
    name: aiHubName
    location: location
    tags: tags
    friendlyName: 'Zava Storefront AI Hub'
    hubDescription: 'AI Foundry Hub for GPT-4 and Phi models in ${environmentName} environment'
    storageAccountId: storageAccount.outputs.id
    keyVaultId: keyVault.outputs.id
    applicationInsightsId: appInsights.outputs.id
    containerRegistryId: acr.outputs.id
  }
}

// Assign AcrPull role to App Service managed identity
module acrPullRoleAssignment 'modules/roleAssignment.bicep' = {
  name: 'acrPull-roleAssignment'
  params: {
    principalId: appService.outputs.principalId
    roleDefinitionId: acrPullRoleId
    principalType: 'ServicePrincipal'
    scope: acr.outputs.id
  }
}

// Outputs
@description('The name of the resource group')
output resourceGroupName string = resourceGroup().name

@description('The location of the resources')
output location string = location

@description('The name of the App Service')
output appServiceName string = appService.outputs.name

@description('The default hostname of the App Service')
output appServiceUrl string = 'https://${appService.outputs.defaultHostname}'

@description('The name of the ACR')
output acrName string = acr.outputs.name

@description('The login server of the ACR')
output acrLoginServer string = acr.outputs.loginServer

@description('The name of the Application Insights')
output appInsightsName string = appInsights.outputs.name

@description('The connection string for Application Insights')
output appInsightsConnectionString string = appInsights.outputs.connectionString

@description('The name of the AI Hub')
output aiHubName string = aiHub.outputs.name
