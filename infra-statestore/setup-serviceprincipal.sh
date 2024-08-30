# need to be done per branch


$AZURE_TENANT = az account show -o tsv --query tenantId
$SUBSCRIPTION_ID = az account show -o tsv --query id


# create a service principal
$APP_ID = az ad app create --display-name terraform-demo-action-oidc --query appId -otsv

az ad sp create --id $APP_ID --query appId -otsv

$OBJECT_ID = az ad app show --id $APP_ID --query id -otsv


# create a federated identity to allow access 
az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$OBJECT_ID/federatedIdentityCredentials" --body '{\"name\":\"terraform-demo-actions-federated-identity\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:waiholiu/terraform-demo:ref:refs/heads/actions\",\"description\":\"GitHub\",\"audiences\":[\"api://AzureADTokenExchange\"]}' --headers "Content-Type=application/json"


# give the service principal access to the subscription
az role assignment create --assignee $APP_ID --role contributor --scope /subscriptions/$SUBSCRIPTION_ID
az role assignment create --assignee $APP_ID --role 'User Access Administrator' --scope /subscriptions/$SUBSCRIPTION_ID


# to chuck into the github secrets

# AZURE_SUBSCRIPTION_ID
echo $SUBSCRIPTION_ID
# AZURE_TENANT_ID
echo $AZURE_TENANT
# AZURE_CLIENT_ID
echo $APP_ID
