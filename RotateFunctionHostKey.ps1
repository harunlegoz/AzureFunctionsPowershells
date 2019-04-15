param($resourceGroup, $appName, $keyName = "default")

# Get publishing credentials and create authorization header
$publishCredentials = Invoke-AzureRmResourceAction -ResourceGroupName $resourceGroup -ResourceType "Microsoft.Web/sites/config" -ResourceName "$appName/publishingcredentials" -Action list -ApiVersion 2015-08-01 -Force
$authorization = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $publishCredentials.Properties.PublishingUserName, $publishCredentials.Properties.PublishingPassword)))

# Get access token for Kudu API
$accessToken = Invoke-RestMethod -Uri "https://$appName.scm.azurewebsites.net/api/functions/admin/token" -Headers @{Authorization=("Basic {0}" -f $authorization)} -Method GET

# Rotate the key
$result = Invoke-RestMethod -Method POST -Headers @{Authorization = ("Bearer {0}" -f $accessToken)} -ContentType "application/json" -Uri "https://$appName.azurewebsites.net/admin/host/keys/$keyName"

# Get the new key
$keys = Invoke-RestMethod -Method GET -Headers @{Authorization = ("Bearer {0}" -f $accessToken)} -ContentType "application/json" -Uri "https://$appName.azurewebsites.net/admin/host/keys/$keyName"

# Return keys
$keys
