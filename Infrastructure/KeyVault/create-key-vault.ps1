$rgName = "security"
$keyVaultName = 'main-vault'
$containerName = "dsc"

az group create --name $rgName --location "westeurope"

az keyvault create --name $keyVaultName --resource-group $rgName --location eastus