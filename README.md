# Rename My Files

> **Single purpose:** Point at a folder of files and automatically rename them based on their content using AI — saving you time and making your files easier to find.
# Rename My Files

> **Single purpose:** Point at a folder of files and automatically rename them based on their content using AI — saving you time and making your files easier to find.

---

## Overview

**Rename My Files** is a PowerShell-based command-line utility that:

1. Accepts a folder path as input.
2. Reads the content of each file in that folder.
3. Sends that content to an Azure AI model.
4. Receives a meaningful, human-readable filename suggestion.
5. Renames each file on disk, preserving the original extension.

Example: a PDF letter from "Acme Ltd" about a contract renewal dated 13 January 2026 might be renamed to:

```
Acme Ltd Contract Renewal Notice - 13th January 2026.pdf
```

---

## Architecture

```
[Your machine]                         [Azure]
  Rename-MyFiles.ps1
       │
       ├─ Reads file content
       │
       └─ Calls Azure OpenAI ──────► Azure OpenAI resource
              (GPT-4o mini)                  │
                                         Returns proposed
                                         filename
```

- **Client:** PowerShell script (`Rename-MyFiles.ps1`) running locally.
- **AI Backend:** Azure OpenAI (GPT-4o mini by default — cheapest capable model).
- **Infrastructure:** Defined as Bicep templates in the `infra/` folder.

---

## Prerequisites

- PowerShell 7.2 or later
- An Azure subscription
- The [Azure PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell) (`Az` module): `Install-Module -Name Az -Scope CurrentUser`
- Contributor (or Owner) access to create resources in your subscription

---

## Deploying Azure Resources

Use the provided deployment script to provision all required Azure resources:

```powershell
.\scripts\Deploy-RenameMyFiles.ps1 `
    -SubscriptionId "<your-subscription-id>" `
    -ResourceGroupName "rg-rename-my-files" `
    -Location "eastus"
```

The script will:

1. Create a resource group.
2. Deploy an Azure OpenAI resource.
3. Deploy the GPT-4o mini model deployment.
4. Output the endpoint and API key needed to run the rename script.

> **Note:** You only need to deploy once. After that, run `scripts\Rename-MyFiles.ps1` as often as you like.

---

## Running the Rename Script

After deployment, run:

```powershell
.\scripts\Rename-MyFiles.ps1 -FolderPath "C:\MyDocuments\Unfiled"
```

To preview changes without renaming (dry-run mode):

```powershell
.\scripts\Rename-MyFiles.ps1 -FolderPath "C:\MyDocuments\Unfiled" -WhatIf
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-FolderPath` | Yes | Path to the folder containing files to rename |
| `-AzureOpenAIEndpoint` | No | Azure OpenAI endpoint URL (can also be set via `AZURE_OPENAI_ENDPOINT` env var) |
| `-AzureOpenAIKey` | No | Azure OpenAI API key (can also be set via `AZURE_OPENAI_KEY` env var) |
| `-DeploymentName` | No | Azure OpenAI model deployment name (default: `gpt-4o-mini`) |
| `-WhatIf` | No | Show proposed renames without making changes |
| `-Verbose` | No | Show detailed progress |

---

## Current Limitations

- Plain text files are fully supported.
- PDF and Office files currently use the filename as context (no real text extraction yet).

---

## Tearing Down Resources

To remove all Azure resources when you no longer need them:

```powershell
.\scripts\Remove-RenameMyFilesResources.ps1 `
    -SubscriptionId "<your-subscription-id>" `
    -ResourceGroupName "rg-rename-my-files"
```

---

## Cost Estimates

> ⚠️ These are **rough estimates only**, not guarantees. Actual costs depend on usage and Azure pricing at time of use. Always check [Azure pricing](https://azure.microsoft.com/en-us/pricing/) for current rates.

| Component | Estimated Cost |
|-----------|---------------|
| Azure OpenAI resource (idle) | ~$0/month (no charge when idle) |
| GPT-4o mini — input tokens | ~$0.00015 per 1,000 tokens |
| GPT-4o mini — output tokens | ~$0.00060 per 1,000 tokens |
| **Typical cost per document** | **~$0.001–$0.005** depending on file size |

For a folder of 100 typical documents (letters, invoices, etc.), expect to spend **less than $0.50** in AI costs.

---

## Repository Structure

```
rename-my-files/
├── README.md                          # This file (technical audience)
├── .github/                           # Repo instructions and prompts
├── scripts/
│   ├── Rename-MyFiles.ps1             # Main rename script
│   ├── Deploy-RenameMyFiles.ps1       # Azure resource deployment script
│   └── Remove-RenameMyFilesResources.ps1  # Azure resource teardown script
├── infra/
│   └── main.bicep                     # Bicep template for Azure resources
└── docs/
    ├── index.md                       # GitHub Pages entry point (end users)
    └── user-guide.md                  # Step-by-step end-user guide
```

---

## Security & Privacy

- Only the **minimum necessary** file content is sent to Azure AI to generate a filename.
- No file content is stored by this tool; Azure OpenAI's data handling applies.
- API keys should be stored as environment variables, not hardcoded.
- Consider using [Azure Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) for passwordless authentication in production.
