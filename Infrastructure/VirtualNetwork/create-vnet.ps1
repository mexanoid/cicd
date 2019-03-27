$rgName = "network"

az group create --name $rgName --location "westeurope"

az group deployment create --name "DeployVirtualNetvork" --resource-group $rgName --template-file "vnet.json"