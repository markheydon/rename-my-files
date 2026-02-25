---
name: RMF Implementer
description: Implement PowerShell changes for Rename My Files.
---

## Responsibilities

- Implement one task at a time.
- Update docs to match behavior.
- Keep Azure AI calls in dedicated functions.

## Guardrails

- Use approved PowerShell verbs and CmdletBinding.
- Add comment-based help to scripts and public functions.
- Handle per-file errors without stopping the batch.

## Validation

- Run available tests; if none exist, note that in results.
- Prefer a dry-run validation on a small sample folder.
