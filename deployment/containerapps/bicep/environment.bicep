param location string = 'westeurope'
param environment_name string
param containerRegistryName string

var logAnalyticsWorkspaceName = 'logs-${environment_name}'
var appInsightsName = 'appins-${environment_name}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: environment_name
  location: location
  properties: {
    daprAIInstrumentationKey: reference(appInsights.id, '2020-02-02').InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }

  resource daprPubSub 'daprComponents@2022-03-01' = {
    name: 'orderpubsub'
    properties: {
      componentType: 'pubsub.azure.servicebus'
      version: 'v1'
      ignoreErrors: true
      initTimeout: '5s'
      metadata: [
        {
          name: 'connectionString'
          value: '__PUBSUBCONNECTIONSTRING__'
        }
      ]
      scopes:[
        'orderapi'
        'orderprocessor'
      ]
    }
  }

  resource daprState 'daprComponents@2022-03-01' = {
    name: 'statestore'
    properties: {
      componentType: 'state.azure.cosmosdb'
      version: 'v1'
      ignoreErrors: true
      initTimeout: '5s'
      metadata: [
        {
            name: 'url'
            value: '__COSMOSURL__'
        }
        {
            name: 'masterKey'
            value: '__COSMOSMASTERKEY__'
        }
        {
            name: 'database'
            value: '__COSMOSDATABASE__'
        }
        {
            name: 'collection'
            value: '__COSMOSCOLLECTION__'
        }
      ]
      scopes:[
        'orderapi'
        'orderprocessor'
      ]
    }
  }
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: 'containerAppIdentity'
  location: location
}

module roleAssignments 'roleAssignments.bicep' = {
  name: 'roleAssignmentsDeployment'
  scope: resourceGroup('acr')
  params: {
    userAssignedIdentityId: identity.id
    userAssignedIdentityPrincipalId: identity.properties.principalId
    containerRegistryName: containerRegistryName
  }
}

resource loadTest 'Microsoft.LoadTestService/loadTests@2022-12-01' = {
  name: 'loadtest-${environment_name}'
  location: location
  properties: {
    
  }
}

output appUserAssignedIdentityId string = identity.id
