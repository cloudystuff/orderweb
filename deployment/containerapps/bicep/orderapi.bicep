param environmentId string
param location string
param version string
param userAssignedIdentityName string

resource orderapi 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'orderapi'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', identity.name)}': {}
    }
  }  
  properties: {
    managedEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: true
        targetPort: 5000
      }
      registries: [
        {
          server: 'jakob.azurecr.io'
          identity: identity.id
        }
      ]
      dapr: {
        enabled: true
        appPort: 5000
        appId: 'orderapi'
      }
    }
    template: {
      containers: [
        {
          image: 'jakob.azurecr.io/orderapi:${version}'
          name: 'orderapi'
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
