# ADR-0001: PowerShell CLI with Azure OpenAI Backend

## Status

Accepted

## Context

We need a simple, local utility that reads file contents and renames files using AI. The user base is non-developers who can run PowerShell scripts and have access to Azure OpenAI.

## Decision

- Implement the client as PowerShell scripts executed locally.
- Use Azure OpenAI as the AI backend.
- Keep infrastructure in Bicep templates for repeatable deployment.
- Keep Azure AI calls isolated in dedicated functions for testability.

## Consequences

- The tool remains lightweight and easy to run without a separate runtime.
- Users must have PowerShell 7 and Azure credentials.
- Non-Azure backends are out of scope for the MVP.
