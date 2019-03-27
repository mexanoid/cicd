$rgName = "storage"
$accountName = 'infrastorm'
$containerName = "dsc"

az group create --name $rgName --location "westeurope"

az storage account create --name $accountName --resource-group $rgName --location "westeurope" --sku "Standard_LRS" --encryption "blob"

az storage container create --account-name $accountName --name $containerName --public-access "blob"

az storage blob upload --account-name $accountName --container-name $containerName --name OctopusServer.zip --file ../OctopusServer/OctopusServer.zip