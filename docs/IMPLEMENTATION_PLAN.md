# Implementation Plan

This plan breaks work into small, testable tasks. Update it when the code changes.

## Current State Snapshot

**MVP Status:** ✅ Complete — all core features are functional and documented. See below for details.

### What Works Now
- Scripts live under `scripts/` and run locally with PowerShell 7.
- `Rename-MyFiles.ps1` calls Azure OpenAI REST API directly — already cross-platform.
- `Deploy-RenameMyFiles.ps1` uses Azure CLI (`az`) for resource deployment — cross-platform with built-in Bicep support.
- `Remove-RenameMyFilesResources.ps1` uses Azure CLI (`az`) for resource deletion.
- Bicep template includes `restore: true` to handle soft-deleted resources automatically.
- Dry-run uses `ShouldProcess` for `-WhatIf` behaviour.
- Per-file errors are handled without stopping the batch.
- Filename sanitisation removes invalid characters and trims trailing dots.
- Collision handling appends a numeric suffix.
- Text files are extracted with 8000 character limit.
- A summary is printed with renamed and skipped counts.

### Known Limitations
- PDF extraction uses placeholder logic (returns filename as context).
- Office document extraction uses placeholder logic (returns filename as context).

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
- [x] Update `Remove-RenameMyFilesResources.ps1` to use `az` CLI commands.
  - [x] Replace Azure authentication and context cmdlets with `az` equivalents
  - [x] Replace `Get-AzResourceGroup` → `az group show --name`
  - [x] Replace `Get-AzResource` → `az resource list --resource-group`
  - [x] Replace `Remove-AzResourceGroup` → `az group delete --name`
  - [x] Syntax validated successfully
  - [x] Updated script `.NOTES` to reference Azure CLI instead of Az module
  - Validation: Script ready for functional testing in live Azure environment
- [x] Add `restore: true` to Bicep template to handle soft-deleted Azure OpenAI resources.
  - [x] Added property to Azure OpenAI resource in `infra/main.bicep`
  - [x] Bicep template validated (build + lint successful)
  - [x] Created ADR-0004 documenting the decision
  - [x] Added troubleshooting section to RUNBOOK.md with manual purge steps for edge cases
  - Validation: Deployment automatically restores soft-deleted resources without errors
- [x] Update documentation to reflect new prerequisites and behaviour.
  - [x] Removed Az PowerShell module requirement from all scripts
  - [x] Added Azure CLI installation requirement
  - [x] Removed separate Bicep installation requirement (built into az CLI)
  - [x] Updated README.md, user-guide.md, and RUNBOOK.md
  - [x] Created ADR-0002: Use Azure CLI Instead of Azure PowerShell Module
  - [x] Created ADR-0003: Use GlobalStandard Deployment Type for Azure OpenAI
  - [x] Created ADR-0004: Use Restore Flag for Soft-Deleted Azure OpenAI Resources

## Phase 1 - Baseline Verification

- [x] Verify the README and docs refer to `scripts/` paths.
- [x] Confirm `Rename-MyFiles.ps1` uses `ShouldProcess` for dry-run.
- [x] Confirm Azure OpenAI calls are isolated in a single function.

## Phase 2 - File Intake and Safety

- [x] Validate folder path input and handle missing or empty folders.
- [x] Confirm only top-level files are processed (no recursion).
- [x] Ensure per-file error handling does not stop the batch.

## Phase 3 - Content Extraction

- [x] Add a size/length limit to reduce content sent to Azure OpenAI (8000 chars implemented).
- [x] Implement placeholder logic for PDF files (returns filename as context).
- [x] Implement placeholder logic for Office documents (returns filename as context).

**Note:** Real PDF and Office extraction moved to Phase 6 (Post-MVP).

## Phase 4 - AI Naming and Sanitisation

- [x] Ensure prompt produces filename-safe output.
- [x] Add truncation rules for long filenames (Windows filename length enforced in sanitization).
- [x] Remove control characters, tabs, and newlines from filenames.
- [x] Collapse excess whitespace to a single space.
- [x] Make Windows reserved device names (e.g. CON, PRN, NUL, COM1) safe by appending _file.
- [x] Confirm collisions are resolved without overwriting (numeric suffix implemented).

## Phase 5 - Reporting and Documentation

- [x] Update README.md prerequisites (Azure CLI instead of Az module)
- [x] Update README.md with GlobalStandard deployment info and cost estimates
- [x] Update user-guide.md prerequisites (Azure CLI instead of Az module)
- [x] Update user-guide.md with region support and detailed cost estimates
- [x] Update RUNBOOK.md prerequisites (Azure CLI instead of Az module)
- [x] Remove all references to separate Bicep installation
- [x] Create ADR-0002: Use Azure CLI Instead of Azure PowerShell Module
- [x] Create ADR-0003: Use GlobalStandard Deployment Type for Azure OpenAI
- [x] Create ADR-0004: Use Restore Flag for Soft-Deleted Azure OpenAI Resources
- [x] Document data residency implications, deployment alternatives, and compliance guidance
- [x] Document soft-delete troubleshooting in RUNBOOK.md

## Phase 6 - Enhanced Content Extraction (In Progress)

**Goal:** Replace placeholder extraction logic with real text extraction for PDF and Office documents to improve AI-generated filename quality.

### PDF Text Extraction (Priority)

- [ ] Research and select PDF extraction approach (cross-platform, PowerShell-compatible)
  - Options: PdfPig (.NET library), pdftotext (external utility), iTextSharp, Azure Document Intelligence
  - Criteria: Cross-platform support, ease of installation, licensing, error handling
- [ ] Implement chosen PDF extraction solution in `Get-FileContentAsText` function
  - Replace placeholder logic at line ~92-99 in `Rename-MyFiles.ps1`
  - Handle malformed/encrypted PDFs gracefully (fall back to filename context)
  - Maintain 8000 character limit for content sent to Azure OpenAI
- [ ] Add prerequisite documentation for PDF extraction dependencies (if required)
- [ ] Test with sample PDF files (text-based PDFs, scanned PDFs, encrypted PDFs)
- [ ] Update user guide with PDF extraction capabilities and limitations

### Office Document Text Extraction (Secondary)

- [ ] Research and select Office extraction approach (cross-platform, PowerShell-compatible)
  - Options: Open XML SDK, DocumentFormat.OpenXml, LibreOffice CLI, Azure Document Intelligence
  - Criteria: Cross-platform support (.docx, .xlsx, .pptx minimum), ease of installation, licensing
- [ ] Implement chosen Office extraction solution in `Get-FileContentAsText` function
  - Replace placeholder logic at line ~102-106 in `Rename-MyFiles.ps1`
  - Handle corrupted/password-protected documents gracefully
  - Maintain 8000 character limit for content sent to Azure OpenAI
- [ ] Add prerequisite documentation for Office extraction dependencies (if required)
- [ ] Test with sample Office documents (.docx, .xlsx, .pptx formats)
- [ ] Update user guide with Office document extraction capabilities and limitations

### Validation

- [ ] Verify cross-platform behaviour (Windows, macOS, Linux)
- [ ] Confirm error handling does not break batch processing
- [ ] Update IMPLEMENTATION_PLAN.md to reflect completion

## Future Enhancements (Out of Scope for Current Phase)

These features are documented as potential future work but not planned for immediate implementation:

- [ ] Recursive subfolder processing
- [ ] Batch capacity optimisation for large folders (increase TPM quota)
- [ ] Alternative AI backends (non-Azure providers)
- [ ] GUI or web interface

## Assumptions

- No automated tests exist yet; validation is manual.
- Azure OpenAI is the only AI backend.
- Users supply credentials via environment variables or parameters.
- PowerShell 7 is available on Windows, macOS, and Linux (cross-platform by default).
- Azure CLI works consistently across Windows, macOS, and Linux.
- Bicep support is built into Azure CLI (no separate installation needed).
- Soft-deleted Azure OpenAI resources are automatically restored during redeployment via `restore: true` property.
- Users understand the data residency implications of GlobalStandard deployment (documented in ADR-0003).
- PDF and Office extraction must work cross-platform (Windows, macOS, Linux) without requiring commercial licenses.
- Content extraction solutions should prefer native .NET libraries over external CLI tools for better portability.
