@description('The name of the AKS cluster')
param clusterName string = 'aks-automatic-cluster'

@description('The Azure region for all resources')
param location string = resourceGroup().location

@description('DNS prefix used to create the FQDN for the cluster API server')
param dnsPrefix string = '${clusterName}-dns'

@description('Tags to apply to all resources created by this template')
param tags object = {
  environment: 'dev'
  workload: 'aks-automatic'
}

@description('Virtual machine SKU used by the automatic node pool')
@allowed([
  'Standard_DS2_v2'
  'Standard_DS3_v2'
  'Standard_DS4_v2'
  'Standard_D4s_v3'
  'Standard_D8s_v3'
])
param nodeVmSize string = 'Standard_DS3_v2'

@description('Minimum number of nodes for the automatic node pool')
@minValue(1)
@maxValue(100)
param minNodeCount int = 1

@description('Maximum number of nodes for the automatic node pool')
@minValue(1)
@maxValue(100)
param maxNodeCount int = 3

@description('Target Kubernetes version; leave blank to allow AKS Automatic to use a supported default')
param kubernetesVersion string = ''

@description('Enable Azure Monitor for containers (Log Analytics)')
param enableMonitoring bool = true

@description('Enable Azure Policy for Kubernetes')
param enableAzurePolicy bool = true

var logAnalyticsWorkspaceName = '${clusterName}-logs'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = if (enableMonitoring) {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  tags: tags
  sku: {
    name: 'Automatic'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
  dnsPrefix: dnsPrefix
  kubernetesVersion: empty(kubernetesVersion) ? null : kubernetesVersion
    enableRBAC: true
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    agentPoolProfiles: [
      {
        name: 'systempool'
        mode: 'System'
        count: minNodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        osSKU: 'AzureLinux'
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: true
        minCount: minNodeCount
        maxCount: maxNodeCount
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
    addonProfiles: {
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      omsagent: enableMonitoring ? {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      } : {
        enabled: false
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
          rotationPollInterval: '2m'
        }
      }
    }
    autoUpgradeProfile: {
      upgradeChannel: 'stable'
    }
    oidcIssuerProfile: {
      enabled: true
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      defender: {
        securityMonitoring: {
          enabled: true
        }
      }
    }
  }
}

output clusterId string = aksCluster.id
output clusterNameOut string = aksCluster.name
output clusterFqdn string = aksCluster.properties.fqdn
output kubeletIdentity object = aksCluster.properties.identityProfile.kubeletidentity
output oidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL
output logAnalyticsWorkspaceId string = enableMonitoring ? logAnalyticsWorkspace.id : ''
