@description('Name of the App Service')
param name string

@description('Location for the app')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('App Service Plan ID')
param appServicePlanId string

@description('ACR login server')
param acrLoginServer string

@description('Docker image and tag')
param dockerImageAndTag string = 'nginx:latest'

@description('Application Insights connection string')
param appInsightsConnectionString string = ''

@description('Application Insights instrumentation key')
param appInsightsInstrumentationKey string = ''

resource webApp 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${dockerImageAndTag}'
      acrUseManagedIdentityCreds: true
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrLoginServer}'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
      ]
      alwaysOn: false
      http20Enabled: true
    }
  }
}

@description('The resource ID of the App Service')
output id string = webApp.id

@description('The name of the App Service')
output name string = webApp.name

@description('The default hostname')
output defaultHostname string = webApp.properties.defaultHostName

@description('The principal ID of the system assigned identity')
output principalId string = webApp.identity.principalId
