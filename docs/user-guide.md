# User Guide

This guide walks you through everything you need to use **Rename My Files** — a tool that automatically renames files with clear, descriptive names using AI.

---

## Prerequisites

Before you begin, you will need:

1. **PowerShell 7.2 or later** installed on your computer.
   - [Download PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
2. **An Azure account** (free to create at [azure.microsoft.com](https://azure.microsoft.com/free/)).
3. **Azure CLI** installed:
   - [Install Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
   - Bicep support is built-in (no separate installation needed)

---

## Step 1 — Deploy Azure Resources

You only need to do this **once**. It creates the Azure AI service that powers the renaming.

1. Open a PowerShell 7 terminal.
2. Navigate to the folder where you downloaded the Rename My Files scripts.
3. Run:

   ```powershell
   .\scripts\Deploy-RenameMyFiles.ps1 -SubscriptionId "<your-azure-subscription-id>"
   ```

   Replace `<your-azure-subscription-id>` with your Azure subscription ID.  
   (You can find this in the [Azure Portal](https://portal.azure.com) under **Subscriptions**.)

4. When prompted, sign in to your Azure account.
5. Wait for the deployment to finish (usually 2–5 minutes).
6. At the end, the script will print instructions to retrieve your **API key** and **endpoint URL**.
   Follow those instructions and note down the values.

> **Tip:** If your organisation manages Azure, ask your IT administrator to run the deployment script on your behalf and provide you with the endpoint and API key.

---

## Step 2 — Configure Your API Key and Endpoint

Set these as environment variables so the rename script can use them:

```powershell
$env:AZURE_OPENAI_ENDPOINT = "https://your-resource.openai.azure.com/"
$env:AZURE_OPENAI_KEY      = "your-api-key-here"
```

> **Security note:** Do not share your API key or store it in a plain text file. Set it as an environment variable each session, or use a secure secrets manager.

---

## Step 3 — Preview Before Renaming (Recommended)

Before renaming any real files, do a **dry run** to see what the tool would do:

```powershell
.\scripts\Rename-MyFiles.ps1 -FolderPath "C:\Documents\MyUnfiledFolder" -WhatIf
```

This will show you proposed renames **without actually changing anything**. Review the output and make sure it looks sensible.

> **Safety tip:** Always test on a **small sample folder** first (e.g. copy 5–10 files to a test folder). Once you are confident, run on your full folder.

---

## Step 4 — Rename Your Files

Once you are happy with the preview:

```powershell
.\scripts\Rename-MyFiles.ps1 -FolderPath "C:\Documents\MyUnfiledFolder"
```

The script will:
- Read each file in the folder.
- Ask Azure AI to suggest a descriptive name.
- Rename the file, keeping the same extension.
- Show a summary at the end.

Example output:

```
Scanning folder: C:\Documents\MyUnfiledFolder
Found 8 file(s). Processing...

  RENAMED  scan0042.pdf  →  Acme Ltd Invoice - February 2025.pdf
  RENAMED  Document (3).docx  →  HMRC Self Assessment Tax Return 2024-25.docx
  SKIPPED  photo.jpg — Unsupported or unreadable file type
  RENAMED  letter.txt  →  Dr Smith Referral Letter - John Doe.txt

─────────────────────────────────────
 Summary
─────────────────────────────────────
 Files scanned : 8
 Files renamed : 3
 Files skipped : 1
─────────────────────────────────────
```

---

## Limitations and Caveats

| Situation | What happens |
|-----------|-------------|
| Image files (`.jpg`, `.png`, etc.) | Skipped — the tool only reads text content |
| PDF or Office documents | Limited — the tool currently uses the filename as context, so names may be generic |
| Encrypted PDF or password-protected documents | Skipped — the file cannot be read |
| Corrupted files | Skipped — the file cannot be read |
| Very short or empty files | The AI may produce a generic or imperfect name |
| File with the same proposed name already exists | A numeric suffix is added (e.g. `-1`, `-2`) |

- **AI names are suggestions.** The AI does its best but may occasionally produce imperfect names. Review the dry-run output before renaming important files.
- **Only the filename changes.** The tool never modifies the content of any file.
- **Only files in the top-level folder are processed.** Sub-folders are not scanned.

---

## Cost

> ⚠️ These are **rough estimates only**. Actual costs depend on your usage and Azure pricing at the time.

| Usage | Estimated cost |
|-------|---------------|
| Idle (no files being processed) | **$0** — no idle cost |
| Per typical document | **~$0.001–$0.005** |
| 100 documents | **~$0.10–$0.50** |

Azure OpenAI charges per token (roughly per word). A typical letter or invoice uses about 500–1,000 tokens, costing a fraction of a cent.

---

## Removing Azure Resources

If you no longer need the tool and want to stop any future costs:

```powershell
.\scripts\Remove-RenameMyFilesResources.ps1 -SubscriptionId "<your-azure-subscription-id>"
```

This permanently deletes the Azure resource group and everything in it. You will be asked to confirm before anything is deleted.

---

## Getting Help

- Open a [GitHub Issue](https://github.com/markheydon/rename-my-files/issues) if you encounter a bug.
- For Azure-related problems, check the [Azure OpenAI documentation](https://learn.microsoft.com/azure/ai-services/openai/).
