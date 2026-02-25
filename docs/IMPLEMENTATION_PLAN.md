# Implementation Plan

This plan breaks the MVP into small, testable tasks. Update it when the code changes.

## Current State Snapshot

- Scripts live under `scripts/` and run locally with PowerShell 7.
- Dry-run uses `ShouldProcess` for `-WhatIf` behavior.
- Per-file errors are handled without stopping the batch.
- Filename sanitization removes invalid characters and trims trailing dots.
- Collision handling appends a numeric suffix.
- PDF and Office extraction are placeholders (use filename as context).
- A summary is printed with renamed and skipped counts.

## Phase 0 - Baseline Verification

- Verify the README and docs refer to `scripts/` paths.
- Confirm `Rename-MyFiles.ps1` uses `ShouldProcess` for dry-run.
- Confirm Azure OpenAI calls are isolated in a single function.

## Phase 1 - File Intake and Safety

- Validate folder path input and handle missing or empty folders.
- Confirm only top-level files are processed (no recursion).
- Ensure per-file error handling does not stop the batch.

## Phase 2 - Content Extraction

- Replace PDF placeholder logic with real text extraction (when added).
- Replace Office placeholder logic with real text extraction (when added).
- Add a size/length limit to reduce content sent to Azure OpenAI.

## Phase 3 - AI Naming and Sanitization

- Ensure prompt produces filename-safe output.
- Add truncation rules for long filenames.
- Confirm collisions are resolved without overwriting.

## Phase 4 - Reporting and Docs

- Emit a consistent summary (renamed, skipped, failed).
- Improve verbose logging for troubleshooting.
- Keep README and docs aligned with real behavior.
- Record any architecture changes in ADRs.

## Assumptions

- No automated tests exist yet; validation is manual.
- Azure OpenAI is the only AI backend.
- Users supply credentials via environment variables or parameters.
