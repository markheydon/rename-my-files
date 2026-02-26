<#
.SYNOPSIS
    Removes all Azure resources created by Deploy-RenameMyFiles.ps1.

.DESCRIPTION
    Remove-RenameMyFilesResources.ps1 deletes the resource group (and all resources within it)
    that was created by Deploy-RenameMyFiles.ps1.

    By default the script will prompt for confirmation before deleting. Use -Force to skip
    the prompt in automated scenarios.

.PARAMETER SubscriptionId
    The Azure subscription ID containing the resource group to remove.

.PARAMETER ResourceGroupName
    The name of the resource group to delete. Defaults to 'rg-rename-my-files'.

.PARAMETER Force
    Skips the confirmation prompt. Use with caution — deletion is irreversible.

.EXAMPLE
    .\Remove-RenameMyFilesResources.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000"

    Removes the default resource group after prompting for confirmation.

.EXAMPLE
    .\Remove-RenameMyFilesResources.ps1 `
        -SubscriptionId "00000000-0000-0000-0000-000000000000" `
        -ResourceGroupName "rg-myfiles-prod" `
        -Force

    Removes the specified resource group without prompting.

.NOTES
    Requires PowerShell 7.2 or later and the Azure CLI.
    Install Azure CLI from: https://learn.microsoft.com/cli/azure/install-azure-cli

    This action is irreversible. All resources inside the resource group will be permanently deleted.
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param (
    [Parameter(Mandatory, HelpMessage = 'Azure subscription ID.')]
    [ValidateNotNullOrEmpty()]
    [string]$SubscriptionId,

    [Parameter(HelpMessage = 'Resource group to delete. Defaults to rg-rename-my-files.')]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = 'rg-rename-my-files',

    [Parameter(HelpMessage = 'Skip the confirmation prompt.')]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host 'Rename My Files — Resource Removal' -ForegroundColor Cyan
Write-Host '────────────────────────────────────' -ForegroundColor Cyan
Write-Host " Subscription  : $SubscriptionId"
Write-Host " Resource Group: $ResourceGroupName"
Write-Host ''

# Check Azure CLI is installed.
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI not found. Install from: https://learn.microsoft.com/cli/azure/install-azure-cli"
}

# Connect / set subscription.
try {
    # Check current Azure CLI context.
    $accountJson = az account show 2>$null
    $currentAccount = if ($accountJson) { $accountJson | ConvertFrom-Json } else { $null }
    
    if (-not $currentAccount -or $currentAccount.id -ne $SubscriptionId) {
        if (-not $currentAccount) {
            Write-Host 'Not logged in to Azure. Initiating login...' -ForegroundColor Cyan
            az login --use-device-code | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "Azure login failed."
            }
        }
        
        Write-Host "Setting subscription to: $SubscriptionId" -ForegroundColor Cyan
        az account set --subscription $SubscriptionId 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to set subscription. Verify subscription ID is correct and you have access."
        }
    }
    
    Write-Host "Using subscription: $SubscriptionId" -ForegroundColor Green
}
catch {
    throw "Failed to authenticate with Azure: $_"
}

# Check the resource group exists.
$rgJson = az group show --name $ResourceGroupName 2>$null
$rg = if ($rgJson) { $rgJson | ConvertFrom-Json } else { $null }

if (-not $rg) {
    Write-Host "Resource group '$ResourceGroupName' does not exist. Nothing to remove." -ForegroundColor Yellow
    exit 0
}

# List resources for information.
Write-Host ''
Write-Host 'The following resource group and ALL resources within it will be permanently deleted:' -ForegroundColor Yellow
Write-Host "  Resource group: $ResourceGroupName (location: $($rg.location))" -ForegroundColor Yellow

$resourcesJson = az resource list --resource-group $ResourceGroupName --output json 2>$null
$resources = if ($resourcesJson) { $resourcesJson | ConvertFrom-Json } else { @() }

if ($resources -is [object[]] -and $resources.Count -gt 0) {
    Write-Host '  Resources:' -ForegroundColor Yellow
    foreach ($resource in $resources) {
        Write-Host "    • $($resource.name) [$($resource.type)]" -ForegroundColor Yellow
    }
}
elseif ($resources -is [psobject]) {
    Write-Host '  Resources:' -ForegroundColor Yellow
    Write-Host "    • $($resources.name) [$($resources.type)]" -ForegroundColor Yellow
}
else {
    Write-Host '  (no resources found in this group)' -ForegroundColor Yellow
}
Write-Host ''

# Confirm and delete.
$confirmMessage = "Permanently delete resource group '$ResourceGroupName' and all its resources?"

if ($Force -or $PSCmdlet.ShouldProcess($ResourceGroupName, $confirmMessage)) {
    Write-Host "Deleting resource group '$ResourceGroupName'..." -ForegroundColor Cyan

    try {
        az group delete --name $ResourceGroupName --yes --no-wait | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Delete command failed with exit code $LASTEXITCODE"
        }
        Write-Host "Resource group '$ResourceGroupName' is being deleted (this may take a few minutes)." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to delete resource group '$ResourceGroupName': $_"
        throw
    }
}
else {
    Write-Host 'Deletion cancelled.' -ForegroundColor Yellow
}
