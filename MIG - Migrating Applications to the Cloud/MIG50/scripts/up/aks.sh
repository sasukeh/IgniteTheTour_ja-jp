#!/bin/bash
set -eou pipefail
source ./scripts/variables.sh

echo "Creating AKS cluster $(clustername) in resource group $(rg)"
echo ''
az aks create \
--resource-group $(rg) \
--name $(clustername) \
--node-count $(nodecount) \
--kubernetes-version $(kubernetesversion) \
--enable-addons monitoring,http_application_routing \
--generate-ssh-keys

echo "AKS Cluster $(clustername) has successfully been created."
echo ''

# Get the id of the service principal configured for AKS
CLIENT_ID=$(az aks show --resource-group $(rg) --name $(clustername) --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
ACR_ID=$(az acr show --name $(acrname) --resource-group $(rg) --query "id" --output tsv)

# Create role assignment
az role assignment create --assignee $CLIENT_ID --role Reader --scope $ACR_ID

# Show http application routing zone
az aks show --resource-group $(rg) --name $(clustername) --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o tsv
