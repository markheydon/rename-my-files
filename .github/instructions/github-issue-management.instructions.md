---
name: GitHub Issue Management Instructions
description: This file describes repository-specific GitHub Issue management conventions for the rename-my-files project. For universal GitHub Issue management guidelines, see the github-issue-management SKILL.
applyTo: "plan/*.md"
---

# GitHub Issue Management Instructions for rename-my-files

This file contains repository-specific GitHub Issue management conventions for the **rename-my-files** project. For universal GitHub Issue management guidelines, see the [github-issue-management SKILL instructions](../skills/github-issue-management/github-issue-management.instructions.md).

## Repository Context

- **Repository:** markheydon/rename-my-files-ai
- **Planning Documents:** `plan/SCOPE.md`, `plan/IMPLEMENTATION_PLAN.md`, `plan/RUNBOOK.md`
- **Management Approach:** Phase-based development with milestones tracking progress

## Milestone Definitions

The rename-my-files project uses the following milestones:

| Milestone | Status | Phase | Description |
|-----------|--------|-------|-------------|
| Cross-Platform Azure Tooling Migration | Closed | Phase 0 | Migrated from Windows-only az PowerShell module to cross-platform Azure CLI |
| Baseline Verification | Closed | Phase 1 | Verified existing core rename functionality with basic text file content extraction |
| File Intake and Safety | Closed | Phase 2 | Implemented file validation, backup, and error handling |
| Content Extraction | Closed | Phase 3 | Baseline text file content extraction working |
| AI Naming and Sanitisation | Closed | Phase 4 | Azure OpenAI integration for filename generation, sanitisation logic |
| Reporting and Documentation | Closed | Phase 5 | Logging, reporting, user documentation complete |
| Enhanced Content Extraction | Open | Phase 6 | Add PDF text extraction (PdfPig), image OCR (Azure AI Vision), Office document extraction (.docx, .xlsx, .pptx) |
| Validation and Release | Open | Phase 7 | Cross-platform testing, release preparation, final validation |
| Future Enhancements | Open | Phase 8 | Deferred features: recursive subfolder processing, batch optimisation (out of scope) |

### Milestone Assignment Rules

- **All issues** (epics and tasks) must be assigned to exactly one milestone
- **Completed phases** (0-5) are marked as "closed" in GitHub
- **Active/future phases** (6-8) remain "open"
- **Out-of-scope work** (Phase 8) gets both the milestone AND the `out-of-scope` label

## Epic-to-Task Mapping

Current epic issues and their child tasks:

### Phase 6 Epics

**#11: Image Processing: OCR and Vision Support** (Enhanced Content Extraction milestone)
- Child tasks:
  - #8: Add image text extraction with OCR
  - #3: Add PDF text extraction with PdfPig

**#12: Office Document Extraction: DOCX, XLSX, PPTX Support** (Enhanced Content Extraction milestone)
- Child tasks:
  - #2: Add Office document text extraction (.docx, .xlsx, .pptx)

### Phase 7 Epics

**#13: Validation and Release Readiness** (Validation and Release milestone)
- Child tasks:
  - #6: Validate cross-platform functionality (macOS, Linux)

### Phase 8 Epics

**#14: Future Enhancements (Out of Scope)** (Future Enhancements milestone)
- Child tasks:
  - #4: Add recursive subfolder processing support
  - #5: Optimise batch processing for large file sets

## Issue Description Templates

### Epic Issue Template

```markdown
## Objective
[High-level goal for this epic]

## Rationale
[Why this epic is important for the rename-my-files project]

## Scope
- [ ] [Sub-task 1]
- [ ] [Sub-task 2]
- [ ] [Sub-task 3]

## Related Documentation
- [IMPLEMENTATION_PLAN.md Phase X](../../../plan/IMPLEMENTATION_PLAN.md#phase-x)
- [SCOPE.md](../../../plan/SCOPE.md)

## Child Issues
[These will auto-populate when parent/child relationships are established]
```

### Task Issue Template

```markdown
## Description
[What needs to be done]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Parent Epic
See parent epic #[number]

## Related Files
- `scripts/[relevant-script].ps1`
- `plan/IMPLEMENTATION_PLAN.md`
```

## References in Issue Descriptions

When creating issues, use these link patterns:

- **IMPLEMENTATION_PLAN sections:** `[IMPLEMENTATION_PLAN.md Phase 6](../../plan/IMPLEMENTATION_PLAN.md#phase-6---enhanced-content-extraction)`
- **Parent epics:** `See parent epic [#11](https://github.com/markheydon/rename-my-files-ai/issues/11)`
- **Related issues:** `Blocked by #[number]` or `Depends on #[number]`
- **Code files:** `scripts/Rename-MyFiles.ps1` (relative path from repo root)

## Label Usage for This Repository

Apply labels according to the [Label Reference](../../.github/skills/github-issue-management/references/LABELS.md) in the SKILL instructions, with these repository-specific notes:

- **`out-of-scope`**: Always apply to Phase 8 issues (future enhancements intentionally deferred)
- **`priority-high`**: Use only for tasks that unblock critical milestones (currently only #11: Image Processing epic)
- **`priority-medium`**: Historical label; remove if present and prefer omitting to reduce noise (prefer only high or default)
- **Domain labels** (`image-processing`, `office-documents`, `validation`, `release`): Legacy labels from earlier phase structure; can be removed in favour of milestone-based tracking

## Workflow Integration

When using AI agents (mat-orchestrator, mat-plan, mat-next-task):

1. **mat-plan**: Creates epics and tasks from IMPLEMENTATION_PLAN.md, assigns milestones, applies labels
2. **mat-next-task**: Picks the smallest next task from open issues, considering milestone priorities
3. **Manual step**: Establish parent/child relationships in the GitHub UI (not automatable via gh CLI)

## Notes

- Keep IMPLEMENTATION_PLAN.md as the source of truth for project phases and task breakdown
- Sync GitHub Issues with IMPLEMENTATION_PLAN.md regularly (run mat-plan after plan updates)
- Close milestones when all issues in that phase are complete
- Review and clean up legacy labels periodically
