param(
  $resourceGroup,
  $location,
  $logAnalyticsWorkspace,
  $environment,
  $version,
  $acrRegistry,
  $acrRegistryUsername,
  $acrRgistryPassword
)

"resourceGroup: $resourceGroup"
"location: $location"
"logAnalyticsWorkspace: $logAnalyticsWorkspace"
"environment: $environment"
"version: $version"
"acrRegistry: $acrRegistry"
"acrRegistryPassword: $acrRegistryPassword"

az config set extension.use_dynamic_install=yes_without_prompt
#az upgrade --all -y
az --version

# Create resource group
az group create `
  --name $resourceGroup `
  --location "$location"

# Create log analytics workspace
az monitor log-analytics workspace create `
  --resource-group $resourceGroup `
  --workspace-name $logAnalyticsWorkspace

$LOG_ANALYTICS_WORKSPACE_CLIENT_ID=(az monitor log-analytics workspace show --query customerId -g $resourceGroup -n $logAnalyticsWorkspace --out tsv)
$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=(az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $resourceGroup -n $logAnalyticsWorkspace --out tsv)

# Create container apps environment
az containerapp env create `
  --name $environment `
  --resource-group $resourceGroup `
  --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID `
  --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET `
  --location "$location"

# Deploy orderweb
az containerapp create `
    --name orderweb `
    --resource-group $resourceGroup `
    --environment $environment `
    --image $acrRegistry/orderweb:$appVersion `
    --target-port 5000 `
    --ingress 'external' `
    --enable-dapr `
    --dapr-app-port 5000 `
    --dapr-app-id orderweb `
    --dapr-components .\statestore.yaml `
    --registry-login-server $acrRegistry `
    --registry-username $acrRegistryUsername `
    --registry-password $acrRegistryPassword `
    --environment-variables DAPR_HTTP_PORT=3500

# Deploy orderapi
az containerapp create `
    --name orderapi `
    --resource-group $resourceGroup `
    --environment $environment `
    --image $acrRegistry/orderapi:$appVersion `
    --target-port 5000 `
    --ingress 'internal' `
    --enable-dapr `
    --dapr-app-port 5000 `
    --dapr-app-id orderapi `
    --dapr-components .\statestore.yaml `
    --registry-login-server $acrRegistry `
    --registry-username $acrRegistryUsername `
    --registry-password $acrRegistryPassword `
    --environment-variables DAPR_HTTP_PORT=3500

# Deploy orderprocessor
az containerapp create `
    --name orderprocessor `
    --resource-group $resourceGroup `
    --environment $environment `
    --image $acrRegistry/orderprocessor:$appVersion `
    --target-port 5000 `
    --ingress 'internal' `
    --min-replicas 1 `
    --max-replicas 10 `
    --enable-dapr `
    --dapr-app-port 5000 `
    --dapr-app-id orderprocessor `
    --dapr-components .\statestore.yaml `
    --registry-login-server $acrRegistry `
    --registry-username $acrRegistryUsername `
    --registry-password $acrRegistryPassword `
    --environment-variables DAPR_HTTP_PORT=3500