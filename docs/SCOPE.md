# Scope

## Purpose

Rename files in a folder using AI-generated, descriptive names based on file contents.

## In Scope (MVP)

- Read file contents from a single, user-specified folder.
- Use Azure OpenAI to propose a descriptive filename.
- Rename files on disk while preserving the original extension.
- Provide a dry-run mode that previews renames.
- Log renamed, skipped, and failed files.

## Out of Scope

- Editing or rewriting file contents.
- Recursively scanning subfolders.
- Image or audio understanding.
- Non-Azure AI providers or third-party services.
- A GUI or web UI.

## Assumptions

- The utility runs as a local PowerShell 7 script.
- Azure OpenAI is the only AI backend.
- Users provide credentials via environment variables or secure prompts.

## Definition of Done (MVP)

- A user can run a dry-run and see proposed renames without changes.
- A user can run a real rename with Azure OpenAI credentials provided.
- The tool preserves extensions and avoids overwriting by applying a suffix.
- Errors for individual files do not stop the batch.
- Documentation describes the current behavior and limitations.
