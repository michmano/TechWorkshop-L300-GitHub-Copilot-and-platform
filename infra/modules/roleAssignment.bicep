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

@description('The scope of the role assignment (resource ID)')
param scope string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, roleDefinitionId, scope)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: principalType
  }
}

@description('The name of the role assignment')
output name string = roleAssignment.name
