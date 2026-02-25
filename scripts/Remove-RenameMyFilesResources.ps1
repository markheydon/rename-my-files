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
    Requires PowerShell 7.2 or later and the Az PowerShell module.
    Install with: Install-Module -Name Az -Scope CurrentUser

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

# Check the resource group exists.
$rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $rg) {
    Write-Host "Resource group '$ResourceGroupName' does not exist. Nothing to remove." -ForegroundColor Yellow
    exit 0
}

# List resources for information.
Write-Host ''
Write-Host 'The following resource group and ALL resources within it will be permanently deleted:' -ForegroundColor Yellow
Write-Host "  Resource group: $ResourceGroupName (location: $($rg.Location))" -ForegroundColor Yellow

$resources = Get-AzResource -ResourceGroupName $ResourceGroupName
if ($resources.Count -gt 0) {
    Write-Host '  Resources:' -ForegroundColor Yellow
    foreach ($resource in $resources) {
        Write-Host "    • $($resource.Name) [$($resource.ResourceType)]" -ForegroundColor Yellow
    }
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
        Remove-AzResourceGroup -Name $ResourceGroupName -Force | Out-Null
        Write-Host "Resource group '$ResourceGroupName' has been successfully deleted." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to delete resource group '$ResourceGroupName': $_"
        throw
    }
}
else {
    Write-Host 'Deletion cancelled.' -ForegroundColor Yellow
}
