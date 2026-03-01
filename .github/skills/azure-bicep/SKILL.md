---
name: azure-bicep
description: Implement Azure Bicep infrastructure for the AI-based file renaming workflow. Use when deploying or updating Bicep templates for Azure resources required by the rename script's AI integration. Covers secure parameterization, avoiding hardcoded secrets, resource configuration for file renaming operations, and validation.
---

# Azure AI Infrastructure (Bicep) Skill

## Purpose

Use this skill when implementing or updating Azure Bicep for infrastructure that directly supports AI-based filename generation in this repository.

## In Scope

- Bicep for Azure resources required by the rename workflow's AI integration.
- Parameters/outputs needed by PowerShell automation to call Azure AI.
- Secure configuration patterns that avoid hardcoded secrets.

## Out of Scope

- General platform infrastructure unrelated to file renaming.
- Broad CI/CD architecture changes not required for this workflow.
- Non-essential Azure services that do not directly support AI filename generation.

## Implementation Requirements

- Follow current Azure Bicep best practices.
- Keep templates focused and minimal for the rename workflow.
- Do not hardcode API keys, secrets, or subscription IDs.
- Use secure parameterization and environment-based configuration where applicable.
- Keep documentation aligned with what templates currently deploy.

## Validation

Run before committing:

- `az bicep build --file <path-to-main.bicep>`

If multiple entry files exist, build each relevant entry file changed by the PR.

## Definition of Done

- Bicep changes directly support AI-based file renaming.
- Templates compile successfully.
- No secrets are hardcoded.
- Documentation accurately reflects deployed resources and current behavior.