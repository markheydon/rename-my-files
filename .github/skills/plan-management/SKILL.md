---
name: plan-management
description: Maintain consistent structure and format for IMPLEMENTATION_PLAN.md and SCOPE.md documents. Use when creating, updating, or reviewing the implementation plan or scope documents to ensure phase naming, section headers, checklist formats, status symbols, and notation follow project conventions.
---

## Overview

This skill guides agents (mat-orchestrator, mat-tech-writer) in maintaining consistency across the Rename My Files project's planning documents. It ensures that IMPLEMENTATION_PLAN.md and SCOPE.md follow established conventions for structure, nomenclature, and progressive disclosure.

**Important:** These documents are **internal only**—for developers and architects. They are not shared with end users. End-user documentation lives separately in `docs/` and must never reference planning documents (SCOPE.md, IMPLEMENTATION_PLAN.md, ADRs, etc.).

## Key Conventions

### Phase Naming & Status

**Format:** `Phase [N] - [Descriptive Title]`

**Status Indicator:**
- ✅ **Complete** — All tasks finished; no blockers
- ⏳ **Not Started** — Backlog; no active work
- 🔄 **In Progress** — Currently being worked on (use sparingly in plan; defer running tasks to actual tracking)

**Example:**
```markdown
## Phase 0 - Cross-Platform Azure Tooling Migration

**Status:** ✅ **Complete**

**Objective:** Replace Azure PowerShell module with Azure CLI for cross-platform compatibility.
```

### Completed Tasks Checklist

Use markdown checkboxes with `[x]` for complete tasks. Include brief descriptive text or code location references after each item.

**Example:**
```markdown
### Completed Tasks

- [x] Replace Azure PowerShell module with Azure CLI.
  - [x] Update `Deploy-RenameMyFiles.ps1` to use `az` CLI commands.
  - [x] Update `Remove-RenameMyFilesResources.ps1` to use `az` CLI commands.
- [x] Add `restore: true` to Bicep template.
```

### Section Structure

Each phase should follow this hierarchy:

```
## Phase [N] - [Title]

**Status:** [✅ **Complete** | ⏳ **Not Started** | ...]

**Objective:** [One sentence describing the phase goal]

### Completed Tasks / Planned Tasks

[Checklist items with descriptions]

### Why [Rationale or Decision Context]

[Optional context about decisions made]

**Note:** [Optional edge cases or limitations]
```

### In-Document Links

Create relative links to planning documents and code:

**Within plan/ folder:**
- `\[SCOPE.md\]\(SCOPE.md\)` or `\[DECISIONS/ADR-0001.md\]\(DECISIONS/ADR-0001.md\)`

**From docs/ folder back to plan/:**
- `\[../plan/DECISIONS/ADR-0003.md\]\(../plan/DECISIONS/ADR-0003.md\)`

**From root README.md:**
- `\[plan/SCOPE.md\]\(plan/SCOPE.md\)`

### Notation & Reserved Symbols

- **✅** = Completed/Done
- **⏳** = Not started/Backlog
- **🔄** = In progress
- **⚠️** = Warning/Caution
- **💡** = Insight or note
- **❌** = Failed/Won't do

Avoid other emoji or ad-hoc symbols; stick to this set for consistency across runs.

### Code Location References

When referencing implementation code, use format:

```markdown
Code location:\[file.ps1\]\(../../scripts/file.ps1#L123-L145) lines 123–145.
Rationale: [Explanation of why this approach was chosen.]
```

## When to Use This Skill

✅ **Use this skill when:**
- Creating or updating IMPLEMENTATION_PLAN.md or SCOPE.md
- Reviewing plan documents for consistency
- Adding new phases, completed tasks, or notes
- Clarifying phase status or phase naming
- Establishing naming conventions for new ADR documents

❌ **Do not use this skill for:**
- Writing ADR documents (use `adr-writing` skill instead)
- Day-to-day task tracking (that's in actual GitHub issues/Projects)
- User-facing documentation (that's in docs/)

## Reference Template

See [references/TEMPLATE.md](references/TEMPLATE.md) for a full phase template you can copy and customize.
