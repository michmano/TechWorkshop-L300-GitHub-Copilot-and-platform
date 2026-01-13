@description('Name of the Application Insights resource')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('Log Analytics workspace ID')
param workspaceId string

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspaceId
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The resource ID of the Application Insights')
output id string = applicationInsights.id

@description('The name of the Application Insights')
output name string = applicationInsights.name

@description('The instrumentation key')
output instrumentationKey string = applicationInsights.properties.InstrumentationKey

@description('The connection string')
output connectionString string = applicationInsights.properties.ConnectionString
