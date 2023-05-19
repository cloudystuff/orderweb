param location string
param environment_name string
param version string
param userAssignedIdentityName string


resource orderweb 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'orderweb'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', identity.name)}': {}
    }
  }
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        external: true
        targetPort: 5000
      }
      dapr: {
        enabled: true
        appPort: 5000
        appId: 'orderweb'
      }

      registries: [
        {
          server: 'jakob.azurecr.io'
          identity: identity.id
        }
      ]       
    }
    template: {
      containers: [
        {
          image: 'jakob.azurecr.io/orderweb:${version}'
          name: 'orderweb'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'DAPR_HTTP_PORT'
              value: '3500'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }

    }
  }
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing =  {
  name: userAssignedIdentityName
}

resource environment 'Microsoft.App/managedEnvironments@2022-11-01-preview' existing = {
  name: environment_name
}
