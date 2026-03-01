---
name: adr-writing
description: Write consistent Architecture Decision Records (ADRs) for the Rename My Files project. Use when documenting significant architectural decisions, trade-offs, or technical direction choices. Ensures all ADRs follow standard structure, naming conventions, and cross-referencing patterns.
---

## Overview

This skill guides agents (mat-tech-writer, mat-orchestrator) in writing Architecture Decision Records (ADRs) that document significant technical decisions made in the Rename My Files project. ADRs provide historical context for why choices were made and what alternatives were considered.

## ADR Naming Convention

**Format:** `ADR-[NNNN]-[kebab-case-title].md`

**Examples:**
- `ADR-0001-architecture.md`
- `ADR-0002-azure-cli-over-az-module.md`
- `ADR-0003-globalstandard-deployment-type.md`

**Rules:**
- Start with `ADR-` prefix
- Use 4-digit zero-padded sequence number (0001, 0002, 0003, etc.)
- Use lowercase kebab-case for title
- Keep filenames under 80 characters total
- Increment sequence number sequentially; do not reuse or leave gaps

## Standard ADR Structure

### Title (H1)

```markdown
# ADR-[NNNN]: [Descriptive Title]
```

**Example:** `# ADR-0002: Use Azure CLI Over Az PowerShell Module`

### Metadata

Include date and decision status:

```markdown
**Date:** [YYYY-MM-DD]

**Status:** ✅ **Accepted** | 🔄 **Proposed** | ❌ **Superseded by ADR-NNNN**
```

### Context (H2)

Describe the situation or problem that prompted the decision:

```markdown
## Context

[1–3 paragraphs explaining:]
- What problem or decision point we faced
- Why this decision was necessary
- What constraints or requirements apply
- What stakeholders are affected
```

**Example:**
```markdown
## Context

The Rename My Files scripts originally used the Azure PowerShell module (Az) for 
Azure resource management and authentication. However, the Az module is 
Windows-specific and does not work consistently on macOS or Linux. To achieve 
cross-platform compatibility and align with the project's goal of supporting 
developers on all major operating systems, we needed to evaluate alternative 
tooling for Azure interactions.
```

### Decision (H2)

State the decision clearly and concisely:

```markdown
## Decision

We will [use/adopt/migrate to] [technology/approach] [for/to accomplish] [goal/context].

[Optional: 1–2 sentences of additional rationale.]
```

**Example:**
```markdown
## Decision

We will use Azure CLI (`az`) instead of the Az PowerShell module for all 
Azure resource management and authentication in deployment scripts.

Azure CLI has identical functionality, is cross-platform (Windows, macOS, Linux), 
and includes built-in Bicep support without requiring a separate installation step.
```

### Consequences (H2)

Describe the trade-offs, benefits, and drawbacks of this decision:

```markdown
## Consequences

**Benefits:**
- [Positive outcome or advantage]
- [Standard outcome or feature retained]

**Drawbacks or Limitations:**
- [Trade-off or limitation introduced]
- [Dependency or maintenance consideration]

**Migration Path (if applicable):**
- [What changes to existing code or scripts are required]
- [Timeline or phasing if relevant]
```

**Example:**
```markdown
## Consequences

**Benefits:**
- Cross-platform compatibility out of the box (Windows, macOS, Linux).
- No need for separate Bicep installation; `az bicep` works immediately.
- Reduced dependency surface; one tool instead of two PowerShell modules.
- Simpler API; `az` CLI is more intuitive than Az module cmdlets.

**Drawbacks:**
- Requires Azure CLI installation (already common; a prerequisite does not add friction).
- Scripts must shell out to `az` commands; less direct PowerShell object piping.

**Migration Path:**
- Update `Deploy-RenameMyFiles.ps1` to use `az` commands (completed in Phase 0).
- Update `Remove-RenameMyFilesResources.ps1` to use `az` commands (completed in Phase 0).
- Update documentation (README, user-guide, runbook) to list Azure CLI as prerequisite.
```

### Related Decisions (H2 - Optional)

Link to related ADRs or dependencies if applicable:

```markdown
## Related Decisions

- \[ADR-0001: Architecture\]\(ADR-0001-architecture.md\) — Overall project architecture (parent decision)
- \[ADR-0003: GlobalStandard Deployment Type\]\(ADR-0003-globalstandard-deployment-type.md\) — Data residency implications of Azure OpenAI deployment strategy
```

### References (H2 - Optional)

Link to external documentation, specifications, or tools:

```markdown
## References

- [Azure CLI Documentation](https://learn.microsoft.com/cli/azure/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure CLI Installation Guide](https://learn.microsoft.com/cli/azure/install-azure-cli)
```

## When to Write an ADR

✅ **Write an ADR when:**
- A significant architectural or technology choice is made
- Multiple alternatives were considered and one was chosen
- The decision affects future development or maintenance
- Trade-offs need to be documented for historical context
- Team consensus was required or dissent was noted

❌ **Do not write an ADR for:**
- Routine code changes or bug fixes
- Minor documentation updates
- Temporary workarounds (use code comments instead)
- Decisions that are trivial or have no alternatives

## ADR Sections Checklist

When reviewing or writing an ADR, confirm:

- [x] Filename follows `ADR-[NNNN]-[kebab-case].md` convention
- [x] Metadata includes date and status
- [x] **Context** explains the problem clearly
- [x] **Decision** is a clear, actionable statement
- [x] **Consequences** covers benefits and drawbacks
- [x] **Related Decisions** links to connected ADRs (if any)
- [x] **References** provides useful external links (if needed)
- [x] Relative links use `\[ADR-NNNN-title.md\]\(ADR-NNNN-title.md\)` format
- [x] Language is neutral, past-tense, and accessible to future readers

## File Location

All ADRs reside in:

```
plan/DECISIONS/
├── ADR-0001-architecture.md
├── ADR-0002-azure-cli-over-az-module.md
├── ADR-0003-globalstandard-deployment-type.md
└── ADR-0004-restore-soft-deleted-resources.md
```

Link to ADRs from IMPLEMENTATION_PLAN.md using relative paths:
- `\[DECISIONS/ADR-0001.md\]\(DECISIONS/ADR-0001.md\)` (from plan/)
- `\[plan/DECISIONS/ADR-0001.md\]\(plan/DECISIONS/ADR-0001.md\)` (from root or docs/)
