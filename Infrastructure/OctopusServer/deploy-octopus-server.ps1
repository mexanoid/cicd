az group create --name "ci-cd" --location "westeurope"

az group deployment create --name "DeployOctopusServer" --resource-group "ci-cd" --template-file "OctopusServer.json" --parameters "OctopusServer.parameters.json"