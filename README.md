# Deploy an AKS Automatic Cluster with Bicep

This repo contains a Bicep template that provisions an Azure Kubernetes Service (AKS) cluster using the **Automatic** SKU, which handles many operational tasks on your behalf such as upgrades, scaling guidance, and guardrail enforcement.

## Files

- `main.bicep` – Bicep template that defines the AKS Automatic cluster and optional Log Analytics workspace.
- `main.parameters.json` – Sample parameter file you can customize per environment.

## Prerequisites

- Azure CLI 2.57.0+ (or Azure PowerShell 11+)
- Contributor rights on the subscription/resource group
- A resource group (create with `az group create` if needed)

## Deploy with Azure CLI

```powershell
# Sign in and pick the subscription
az login
az account set --subscription <subscription-id>

# Deploy into an existing resource group
az deployment group create `
  --resource-group <resource-group-name> `
  --template-file main.bicep `
  --parameters main.parameters.json
```

### Override parameters inline

```powershell
az deployment group create `
  --resource-group <resource-group-name> `
  --template-file main.bicep `
  --parameters clusterName=my-auto-cluster minNodeCount=2 maxNodeCount=5
```

## Deploy from the Azure Portal

1. Open the Azure Portal and search for **Deploy a custom template**.
2. Select **Build your own template in the editor**, choose **Load file**, and upload `main.bicep`.
3. Save the template, then choose **Edit parameters** > **Upload a file** and select `main.parameters.json` (or enter values manually).
4. Pick the subscription, resource group, and review the validation results.
5. Choose **Create** to kick off the deployment.

## Outputs

- `clusterId` – Resource ID of the AKS cluster.
- `clusterNameOut` – Name of the cluster.
- `clusterFqdn` – Control plane FQDN.
- `kubeletIdentity` – Managed identity used by kubelet.
- `oidcIssuerUrl` – URL for workload identity federation.
- `logAnalyticsWorkspaceId` – Workspace resource ID when monitoring is enabled.

## Next steps

After deployment, pull credentials and confirm access:

```powershell
az aks get-credentials --resource-group <resource-group-name> --name <cluster-name>
kubectl get nodes
```

To remove everything when finished:

```powershell
az group delete --name <resource-group-name> --yes --no-wait
```
