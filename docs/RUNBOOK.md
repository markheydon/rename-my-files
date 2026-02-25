# Runbook

## Purpose

Explain how to run, validate, and maintain the Rename My Files scripts.

## Prerequisites

- PowerShell 7.2 or later
- Azure subscription with rights to create resources
- Azure PowerShell module (`Az`)

## Setup

1. Deploy Azure resources (one-time):

   ```powershell
   .\Deploy-RenameMyFiles.ps1 -SubscriptionId "<your-subscription-id>"
   ```

2. Set environment variables for Azure OpenAI:

   ```powershell
   $env:AZURE_OPENAI_ENDPOINT = "https://your-resource.openai.azure.com/"
   $env:AZURE_OPENAI_KEY = "your-api-key-here"
   ```

## Run (Dry-Run)

```powershell
.\Rename-MyFiles.ps1 -FolderPath "C:\Documents\MyUnfiledFolder" -WhatIf
```

## Run (Rename)

```powershell
.\Rename-MyFiles.ps1 -FolderPath "C:\Documents\MyUnfiledFolder"
```

## Remove Azure Resources

```powershell
.\Remove-RenameMyFilesResources.ps1 -SubscriptionId "<your-subscription-id>"
```

## Validation Gates

- Tests: none yet. If tests are added, run them by default.
- Manual check: run a dry-run on a small folder and confirm the summary.
