param containerRegistryName string
param userAssignedIdentityId string
param userAssignedIdentityPrincipalId string

var acrPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}

resource roleAssignmentContainerRegistry 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(userAssignedIdentityId, containerRegistry.id, acrPullRoleDefinitionId)
  scope: containerRegistry
  properties: {
    principalId: userAssignedIdentityPrincipalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionId)
  }
}
