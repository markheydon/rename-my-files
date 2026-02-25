<#
.SYNOPSIS
    Deploys the Azure resources required by the Rename My Files utility.

.DESCRIPTION
    Deploy-RenameMyFiles.ps1 provisions all necessary Azure resources for the Rename My Files
    utility, including an Azure OpenAI resource and a GPT-4o mini model deployment.

    The script uses the Bicep template in the infra/ folder. On completion it outputs the
    Azure OpenAI endpoint and API key so you can configure Rename-MyFiles.ps1.

.PARAMETER SubscriptionId
    The Azure subscription ID in which to deploy resources.

.PARAMETER ResourceGroupName
    The name of the resource group to create (or reuse if it already exists).
    Defaults to 'rg-rename-my-files'.

.PARAMETER Location
    The Azure region for the resources. Defaults to 'ukwest'.
    Note: Azure OpenAI is not available in all regions. See:
    https://learn.microsoft.com/azure/ai-services/openai/concepts/models#model-summary-table-and-region-availability

.EXAMPLE
    .\Deploy-RenameMyFiles.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000"

    Deploys resources with default resource group name and location.

.EXAMPLE
    .\Deploy-RenameMyFiles.ps1 `
        -SubscriptionId "00000000-0000-0000-0000-000000000000" `
        -ResourceGroupName "rg-myfiles-prod" `
        -Location "uksouth"

    Deploys resources to UK South in a custom resource group.

.NOTES
    Requires PowerShell 7.2 or later and the Az PowerShell module.
    Install with: Install-Module -Name Az -Scope CurrentUser
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, HelpMessage = 'Azure subscription ID.')]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(HelpMessage = 'Resource group name. Defaults to rg-rename-my-files.')]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = 'rg-rename-my-files',

    [Parameter(HelpMessage = 'Azure region. Defaults to ukwest.')]
    [ValidateNotNullOrEmpty()]
    [string]$Location = 'ukwest'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$bicepTemplatePath = Join-Path $PSScriptRoot 'infra' 'main.bicep'

if (-not (Test-Path -LiteralPath $bicepTemplatePath)) {
    throw "Bicep template not found at: $bicepTemplatePath"
}

Write-Host 'Rename My Files — Azure Deployment' -ForegroundColor Cyan
Write-Host '────────────────────────────────────' -ForegroundColor Cyan
Write-Host " Subscription  : $SubscriptionId"
Write-Host " Resource Group: $ResourceGroupName"
Write-Host " Location      : $Location"
Write-Host ''

# Connect / set subscription.
try {
    $context = Get-AzContext
    if (-not $context -or $context.Subscription.Id -ne $SubscriptionId) {
        Write-Host 'Connecting to Azure...' -ForegroundColor Cyan
        Connect-AzAccount -SubscriptionId $SubscriptionId | Out-Null
    }
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    Write-Host "Using subscription: $SubscriptionId" -ForegroundColor Green
}
catch {
    throw "Failed to authenticate with Azure: $_"
}

# Create resource group if it does not exist.
if ($PSCmdlet.ShouldProcess($ResourceGroupName, 'Create resource group')) {
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $rg) {
        Write-Host "Creating resource group '$ResourceGroupName' in '$Location'..." -ForegroundColor Cyan
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location | Out-Null
        Write-Host "Resource group created." -ForegroundColor Green
    }
    else {
        Write-Host "Resource group '$ResourceGroupName' already exists." -ForegroundColor Yellow
    }
}

# Deploy Bicep template.
if ($PSCmdlet.ShouldProcess($ResourceGroupName, 'Deploy Bicep template')) {
    Write-Host 'Deploying Azure resources (this may take a few minutes)...' -ForegroundColor Cyan

    $deploymentName = "rename-my-files-$(Get-Date -Format 'yyyyMMddHHmmss')"

    $deploymentParams = @{
        Name                  = $deploymentName
        ResourceGroupName     = $ResourceGroupName
        TemplateFile          = $bicepTemplatePath
        location              = $Location
    }

    try {
        $deployment = New-AzResourceGroupDeployment @deploymentParams -Verbose:$VerbosePreference

        if ($deployment.ProvisioningState -ne 'Succeeded') {
            throw "Deployment finished with state: $($deployment.ProvisioningState)"
        }

        Write-Host 'Deployment succeeded!' -ForegroundColor Green
        Write-Host ''
        Write-Host '────────────────────────────────────' -ForegroundColor Cyan
        Write-Host ' Next steps' -ForegroundColor Cyan
        Write-Host '────────────────────────────────────' -ForegroundColor Cyan
        Write-Host ' Set these environment variables before running Rename-MyFiles.ps1:' -ForegroundColor White
        Write-Host ''

        $endpoint = $deployment.Outputs['openAIEndpoint'].Value
        Write-Host "  `$env:AZURE_OPENAI_ENDPOINT = '$endpoint'"

        Write-Host ''
        Write-Host ' To retrieve your API key, run:' -ForegroundColor White

        $openAIName = $deployment.Outputs['openAIResourceName'].Value
        Write-Host "  Get-AzCognitiveServicesAccountKey -ResourceGroupName '$ResourceGroupName' -Name '$openAIName'"
        Write-Host ''
        Write-Host ' Then set:' -ForegroundColor White
        Write-Host '  $env:AZURE_OPENAI_KEY = "<key from above>"'
        Write-Host ''
        Write-Host ' Run the rename script:' -ForegroundColor White
        Write-Host '  .\Rename-MyFiles.ps1 -FolderPath "C:\YourFolder"'
        Write-Host '────────────────────────────────────' -ForegroundColor Cyan
    }
    catch {
        Write-Error "Deployment failed: $_"
        throw
    }
}
