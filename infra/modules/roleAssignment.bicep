@description('The principal ID to assign the role to')
param principalId string

@description('The role definition ID to assign')
param roleDefinitionId string

@description('The principal type')
@allowed([
  'ServicePrincipal'
  'User'
  'Group'
])
param principalType string = 'ServicePrincipal'

@description('The ACR resource ID to scope the role assignment to')
param acrResourceId string

// Reference the existing ACR resource
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: split(acrResourceId, '/')[8]
}

// Create role assignment on the ACR
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleDefinitionId, acrResourceId)
  scope: acr
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: principalType
  }
}

@description('The name of the role assignment')
output name string = roleAssignment.name
