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
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) — includes built-in Bicep support
- Contributor (or Owner) access to create resources in your subscription

---

## Deploying Azure Resources

Use the provided deployment script to provision all required Azure resources:

```powershell
.\scripts\Deploy-RenameMyFiles.ps1 `
    -SubscriptionId "<your-subscription-id>" `
    -ResourceGroupName "rg-rename-my-files" `
    -Location "uksouth"
```

The script will:

1. Create a resource group.
2. Deploy an Azure OpenAI resource (S0 SKU — pay-as-you-go).
3. Deploy the GPT-4o mini model with GlobalStandard deployment (available in most regions including uksouth).
4. Output the endpoint and API key needed to run the rename script.

> **Note:** You only need to deploy once. After that, run `scripts\Rename-MyFiles.ps1` as often as you like.

### Cost Estimates

> ⚠️ **Estimates only** — actual costs depend on file sizes and current Azure pricing.

| Usage | Estimated Monthly Cost |
|-------|------------------------|
| Idle (no processing) | **$0.00** — no idle charges |
| 10 files | ~**$0.001** |
| 100 files | ~**$0.015** |
| 1,000 files | ~**$0.15** |

Charging is per token (approximately per word). A typical document (~700 tokens) costs ~**$0.0001** (one hundredth of a cent).

---

## ⚠️ Data Residency and Processing Locations

This tool uses Azure OpenAI with **GlobalStandard deployment type**. This means:

- **File content at rest:** Stays in your specified Azure region
- **File content during processing:** May be processed in any Azure region where the model is deployed
- **Processing duration:** Only during the API call (milliseconds)
- **Data storage:** Not retained after processing

**If your organisation requires strict data residency rules** (e.g., all processing must stay within the EU or US), refer to the [Data Residency and Processing Locations section in the User Guide](docs/user-guide.md#-important-data-residency-and-processing-locations) and read [ADR-0003: Use GlobalStandard Deployment Type](docs/DECISIONS/ADR-0003-globalstandard-deployment-type.md) for alternative deployment options.

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
- Proposed filenames longer than 255 characters are truncated to fit Windows limits.
- Control characters (including tabs and newlines) are removed from proposed filenames.
- Multiple consecutive spaces are collapsed to a single space.
- Windows reserved device names (e.g. CON, PRN, NUL, COM1) are made safe by appending _file.

---

## Tearing Down Resources

To remove all Azure resources when you no longer need them:

```powershell
.\scripts\Remove-RenameMyFilesResources.ps1 `
    -SubscriptionId "<your-subscription-id>" `
    -ResourceGroupName "rg-rename-my-files"
```

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
