# Implementation Plan

This plan breaks the MVP into small, testable tasks. Update it when the code changes.

## Current State Snapshot

- Scripts live under `scripts/` and run locally with PowerShell 7.
- `Rename-MyFiles.ps1` calls Azure OpenAI REST API directly — already cross-platform.
- `Deploy-RenameMyFiles.ps1` uses Azure CLI (`az`) for resource deployment — cross-platform with built-in Bicep support.
- `Remove-RenameMyFilesResources.ps1` uses Azure CLI (`az`) for resource deletion.
- Bicep template includes `restore: true` to handle soft-deleted resources automatically.
- Dry-run uses `ShouldProcess` for `-WhatIf` behaviour.
- Per-file errors are handled without stopping the batch.
- Filename sanitization removes invalid characters and trims trailing dots.
- Collision handling appends a numeric suffix.
- PDF and Office extraction are placeholders (use filename as context).
- A summary is printed with renamed and skipped counts.

## Phase 0 - Cross-Platform Azure Tooling Migration

**Issue:** Az PowerShell module requires separate Bicep installation, limiting cross-platform usability.

**Solution:** Migrate deployment scripts to use Azure CLI (`az`), which has built-in Bicep support and works identically on Windows, macOS, and Linux.

### Tasks:
- [x] Update `Deploy-RenameMyFiles.ps1` to use `az` CLI commands instead of Az module cmdlets.
  - [x] Replace `Connect-AzAccount` → `az login --use-device-code`
  - [x] Replace `Set-AzContext` → `az account set --subscription`
  - [x] Replace `Get-AzResourceGroup` → `az group show --name` (with error handling)
  - [x] Replace `New-AzResourceGroup` → `az group create --name --location`
  - [x] Replace `New-AzResourceGroupDeployment` → `az deployment group create --resource-group --template-file`
  - [x] Parse JSON output from `az` commands using `ConvertFrom-Json`
  - [x] Update instructions to reference API key retrieval via `az cognitiveservices account keys list`
  - [x] Added Azure CLI prerequisite check (`Get-Command az`)
  - [x] Tested on Windows with dry-run and full deployment
  - Validation: Script successfully creates resource group and deploys Bicep template via Azure CLI
- [ ] Update `Remove-RenameMyFilesResources.ps1` to use `az` CLI commands.
  - [x] Replace Azure authentication and context cmdlets with `az` equivalents
  - [x] Replace `Get-AzResourceGroup` → `az group show --name`
  - [x] Replace `Get-AzResource` → `az resource list --resource-group`
  - [x] Replace `Remove-AzResourceGroup` → `az group delete --name`
  - [x] Syntax validated successfully
  - Validation: Script ready for functional testing in live Azure environment
- [x] Test script on Windows to ensure it works correctly.
  - Dry-run validation passed
  - Full deployment test passed (resource group and Bicep deployment via az CLI confirmed)
  - Error handling validated
- [x] Update documentation to reflect new prerequisites (in script .NOTES):
  - [x] Removed Az PowerShell module requirement
  - [x] Added Azure CLI installation requirement
  - [x] Removed separate Bicep installation requirement (built into az CLI)

## Phase 1 - Baseline Verification

- [x] Verify the README and docs refer to `scripts/` paths.
- [x] Confirm `Rename-MyFiles.ps1` uses `ShouldProcess` for dry-run.
- [x] Confirm Azure OpenAI calls are isolated in a single function.

## Phase 2 - File Intake and Safety

- [x] Validate folder path input and handle missing or empty folders.
- [x] Confirm only top-level files are processed (no recursion).
- [x] Ensure per-file error handling does not stop the batch.

## Phase 3 - Content Extraction

- [ ] Replace PDF placeholder logic with real text extraction (future enhancement).
- [ ] Replace Office placeholder logic with real text extraction (future enhancement).
- [x] Add a size/length limit to reduce content sent to Azure OpenAI (8000 chars implemented).

## Phase 4 - AI Naming and Sanitization

- [x] Ensure prompt produces filename-safe output.
- [x] Add truncation rules for long filenames (sanitization implemented).
- [x] Confirm collisions are resolved without overwriting (numeric suffix implemented).

## Phase 5 - Reporting and Docs

  - Updated README.md prerequisites (Azure CLI instead of Az module)
  - Updated README.md with GlobalStandard deployment info and cost estimates
  - Updated user-guide.md prerequisites (Azure CLI instead of Az module)
  - Updated user-guide.md with region support and detailed cost estimates
  - Updated RUNBOOK.md prerequisites (Azure CLI instead of Az module)
  - Removed all references to separate Bicep installation
  - Created ADR-0002: Use Azure CLI Instead of Azure PowerShell Module
  - Created ADR-0003: Use GlobalStandard Deployment Type for Azure OpenAI
  - Created ADR-0004: Use Restore Flag for Soft-Deleted Azure OpenAI Resources
  - Documented data residency implications, deployment alternatives, and compliance guidance
  - Documented soft-delete troubleshooting in RUNBOOK.md

## Assumptions

- No automated tests exist yet; validation is manual.
- Azure OpenAI is the only AI backend.
- Users supply credentials via environment variables or parameters.
- PowerShell 7 is available on Windows and macOS (cross-platform by default).
- Azure CLI works consistently across Windows, macOS, and Linux.
- Bicep support is built into Azure CLI (no separate installation needed).
