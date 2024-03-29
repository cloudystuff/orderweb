param location string
param environment_name string
param version string

var userAssignedIdentityName = 'containerAppIdentity'

module environmentModule 'environment.bicep' = {
  name: 'environmentDeployment'
  params: {
    environment_name: environment_name
    location: location
    containerRegistryName: 'jakob'
  }
}

module orderwebModule 'orderweb.bicep' = {
  name: 'orderwebDeployent'
  params: {
    environmentId: environmentModule.outputs.environmentId
    location: location
    version: version
    userAssignedIdentityName: userAssignedIdentityName
  }
  dependsOn: [
    environmentModule
  ]
}

module orderapiModule 'orderapi.bicep' = {
  name: 'orderapiDeployent'
  params: {
    environmentId: environmentModule.outputs.environmentId
    location: location
    version: version
    userAssignedIdentityName: userAssignedIdentityName    
  }
  dependsOn: [
    environmentModule
  ]  
}

module orderprocessorModule 'orderprocessor.bicep' = {
  name: 'orderprocessorDeployent'
  params: {
    environmentId: environmentModule.outputs.environmentId
    location: location
    version: version
    userAssignedIdentityName: userAssignedIdentityName    
  }
  dependsOn: [
    environmentModule
  ]  
}
