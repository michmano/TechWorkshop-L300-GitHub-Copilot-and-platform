@description('Name of the Log Analytics workspace')
param name string

@description('Location for the workspace')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('SKU for the workspace')
param sku string = 'PerGB2018'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: 30
  }
}

@description('The resource ID of the Log Analytics workspace')
output id string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics workspace')
output name string = logAnalyticsWorkspace.name
