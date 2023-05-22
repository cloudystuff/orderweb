param location string
param environmentId string
param version string
param userAssignedIdentityName string

resource orderprocessor 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'orderprocessor'
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
      secrets: [
        {
          name: 'servicebus-connectionstring'
          value: '__PUBSUBCONNECTIONSTRING__'
        }        
      ]
      registries: [
        {
          server: 'jakob.azurecr.io'
          identity: identity.id
        }
      ]
      dapr: {
        enabled: true
        appPort: 5000
        appId: 'orderprocessor'
      }
    }
    template: {
      containers: [
        {
          image: 'jakob.azurecr.io/orderprocessor:${version}'
          name: 'orderprocessor'
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
        minReplicas: 0
        maxReplicas: 10
        rules: [
          {
            name: 'queue-based-autoscaling'
            custom: {
              type: 'azure-servicebus'
              metadata: {
                topicName: 'ordercreated'
                subscriptionName: 'orderprocessor'
                queueLength: '1'
              }
              auth: [
                {
                  secretRef: 'servicebus-connectionstring'
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing =  {
  name: userAssignedIdentityName
}
