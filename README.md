# Rename My Files

Rename My Files is a PowerShell tool that reads file content and uses Azure OpenAI to suggest clearer, descriptive filenames.

## Documentation Map

| Audience | Location | Content |
|----------|----------|---------|
| **End users** | [`docs/index.md`](docs/index.md) | Overview and key features |
| **End users** | [`docs/user-guide.md`](docs/user-guide.md) | Step-by-step setup and usage, cost estimates |
| **Developers** | [`plan/RUNBOOK.md`](plan/RUNBOOK.md) | How to run, deploy, and troubleshoot |
| **Architects** | [`plan/DECISIONS/`](plan/DECISIONS/) | Architecture decisions (ADR-0001 to ADR-0004) |
| **Developers** | [`plan/SCOPE.md`](plan/SCOPE.md) | MVP scope and out-of-scope items |
| **Developers** | [`plan/IMPLEMENTATION_PLAN.md`](plan/IMPLEMENTATION_PLAN.md) | Phases 0–6, completed tasks, and design assumptions |

## What it does

1. Scans files in a folder (top level only).
2. Reads supported text content from each file.
3. Sends minimal context to Azure OpenAI.
4. Renames each file while keeping its original extension.

Example result:

```
scan0042.pdf  ->  Acme Ltd Contract Renewal Notice - 13th January 2026.pdf
```

## Prerequisites

- PowerShell 7.2 or later
- Azure subscription
- Azure CLI
- Permission to create resources in the target subscription

## Quick start

Deploy Azure resources (one-time setup):

```powershell
.\scripts\Deploy-RenameMyFiles.ps1 -SubscriptionId "<your-subscription-id>"
```

The deployment script creates the required resource group and Azure OpenAI resources, then prints:
- the endpoint to set as `AZURE_OPENAI_ENDPOINT`
- a command to retrieve the API key to set as `AZURE_OPENAI_KEY`

Run a dry run first:

```powershell
.\scripts\Rename-MyFiles.ps1 -FolderPath "C:\MyDocuments\Unfiled" -WhatIf
```

Run for real:

```powershell
.\scripts\Rename-MyFiles.ps1 -FolderPath "C:\MyDocuments\Unfiled"
```

## Parameters (`Rename-MyFiles.ps1`)

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-FolderPath` | Yes | Folder containing files to rename |
| `-AzureOpenAIEndpoint` | No | Azure OpenAI endpoint (or `AZURE_OPENAI_ENDPOINT`) |
| `-AzureOpenAIKey` | No | Azure OpenAI API key (or `AZURE_OPENAI_KEY`) |
| `-DeploymentName` | No | Model deployment name (default `gpt-4o-mini`) |
| `-WhatIf` | No | Preview renames without changing files |
| `-Verbose` | No | Show detailed progress |

## Current behaviour and limits

- Plain text formats are read directly (`.txt`, `.md`, `.csv`, `.log`, `.json`, `.xml`, `.html`, `.htm`, `.yaml`, `.yml`).
- PDF and Office formats currently use filename context only (no text extraction).
- Unsupported or unreadable files are skipped.
- Name collisions are handled with numeric suffixes (`-1`, `-2`, ...).
- Invalid filename characters and control characters are removed.
- Repeated whitespace is collapsed.
- Windows reserved names are made safe by appending `_file`.
- Overlong filenames are truncated to fit Windows filename limits.

## Remove resources

When finished, remove Azure resources:

```powershell
.\scripts\Remove-RenameMyFilesResources.ps1 -SubscriptionId "<your-subscription-id>"
```

## User docs

- End-user documentation: [docs/index.md](docs/index.md)
- Step-by-step usage: [docs/user-guide.md](docs/user-guide.md)
- Cost details and estimates: [docs/user-guide.md#cost](docs/user-guide.md#cost)

## Technical references

- Architecture decision: [plan/DECISIONS/ADR-0001-architecture.md](plan/DECISIONS/ADR-0001-architecture.md)
- Azure CLI deployment decision: [plan/DECISIONS/ADR-0002-azure-cli-over-az-module.md](plan/DECISIONS/ADR-0002-azure-cli-over-az-module.md)
- Deployment type and pricing rationale: [plan/DECISIONS/ADR-0003-globalstandard-deployment-type.md](plan/DECISIONS/ADR-0003-globalstandard-deployment-type.md)
- Soft-delete restore behaviour: [plan/DECISIONS/ADR-0004-restore-soft-deleted-resources.md](plan/DECISIONS/ADR-0004-restore-soft-deleted-resources.md)
- Operational runbook: [plan/RUNBOOK.md](plan/RUNBOOK.md)

## Developer checks

Validate Bicep:

```bash
az bicep build --file infra/main.bicep
```

Lint PowerShell:

```powershell
Invoke-ScriptAnalyzer -Path .\scripts -Settings .\PSScriptAnalyzerSettings.psd1 -Recurse
```

## Security and privacy

- Send only the minimum required file content to Azure OpenAI.
- Do not hardcode secrets.
- Prefer environment variables for credentials.
