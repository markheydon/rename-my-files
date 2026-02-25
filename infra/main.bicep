// main.bicep — Azure resources for Rename My Files
// Provisions the cheapest capable Azure OpenAI resource and a GPT-4o mini model deployment.
//
// SKU rationale:
//   - Resource SKU 'S0': standard pay-as-you-go for Azure OpenAI / Cognitive Services.
//     There is no free tier for Azure OpenAI beyond the initial free-trial credits.
//   - Deployment SKU 'GlobalStandard': gpt-4o-mini is available in uksouth and other regions 
//     only with GlobalStandard deployment type (not regional Standard deployment).
//     GlobalStandard provides good performance and global routing at competitive cost.
//   - GPT-4o mini: cheapest capable model for understanding document content and generating
//     descriptive filenames.
//   - Capacity: 1 (minimum) = 1,000 tokens-per-minute for interactive single-file processing.
//     TODO: Increase capacity if batch-processing large folders is needed.

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Name prefix for all resources. Must be unique within your subscription.')
param resourceNamePrefix string = 'rmf'

@description('Name of the Azure OpenAI model deployment.')
param modelDeploymentName string = 'gpt-4o-mini'

// ---------------------------------------------------------------------------
// Variables
// ---------------------------------------------------------------------------

// Use a short unique suffix based on the resource group ID to avoid naming conflicts.
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 6)
var openAIResourceName = '${resourceNamePrefix}-openai-${uniqueSuffix}'

// ---------------------------------------------------------------------------
// Azure OpenAI resource
// ---------------------------------------------------------------------------
//
// SKU: S0 — standard pay-per-use. No idle cost beyond the model deployment.
// Region note: Azure OpenAI is available in a limited set of regions.
// If deployment fails, try eastus, westus, uksouth, or swedencentral.
// See: https://learn.microsoft.com/azure/ai-services/openai/concepts/models#model-summary-table-and-region-availability

resource openAIAccount 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openAIResourceName
  location: location
  kind: 'OpenAI'
  sku: {
    // S0 is the only available SKU for Azure OpenAI.
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAIResourceName
    publicNetworkAccess: 'Enabled'
    // TODO: For a production or sensitive workload, consider restricting to a
    // private endpoint and disabling public network access.
  }
}

// ---------------------------------------------------------------------------
// GPT-4o mini model deployment
// ---------------------------------------------------------------------------
//
// Model: gpt-4o-mini — cheapest capable GPT-4-class model as of 2025.
// Deployment type: GlobalStandard — available in uksouth and other regions.
// Capacity: 1 (minimum) = 1,000 tokens-per-minute.
//   - For a typical document of ~500 words (~700 tokens input + ~60 tokens output),
//     this allows roughly 1 rename per minute. Sufficient for interactive use.
//   - TODO: Increase capacity (e.g. to 10 or 30) if processing large batches.

resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-09-01' = {
  parent: openAIAccount
  name: modelDeploymentName
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
    }
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

@description('The Azure OpenAI endpoint URL to use in Rename-MyFiles.ps1.')
output openAIEndpoint string = openAIAccount.properties.endpoint

@description('The name of the Azure OpenAI resource (used to retrieve the API key).')
output openAIResourceName string = openAIAccount.name

@description('The model deployment name to pass to Rename-MyFiles.ps1.')
output modelDeploymentName string = modelDeployment.name
