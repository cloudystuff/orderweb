Demo 1:
	• Show environment containerappdemo in portal
	• Create new containerapp
		mcr.microsoft.com
		azuredocs/containerapps-helloworld
		
	• Browse to URL
	• Ingress
	• Revisions

Demo 2:
	• Edit revision -> change scaling to 3 -> 5

Demo 3:
	• Run application locally
	• Show deployment bicep
	• Post orders
	• View revision list
	• Show KEDA web 

	• Show logs
		ContainerAppConsoleLogs_CL | where ContainerAppName_s == "orderprocessor" and Log_s contains "listening"
		| summarize count() by bin(TimeGenerated, 1m) | render timechart 

Show application insightsaz contain