# ADR Template

Copy this template when creating a new ADR in plan/DECISIONS/:

```markdown
# ADR-[NNNN]: [Descriptive Title]

**Date:** [YYYY-MM-DD]

**Status:** ✅ **Accepted** | 🔄 **Proposed** | ❌ **Superseded by ADR-NNNN**

## Context

[Explain the problem, situation, or constraint that led to this decision.]

[Who is affected? What are the requirements or constraints?]

## Decision

We will [describe the decision clearly and concisely].

[Optional 1–2 sentences of additional rationale.]

## Consequences

**Benefits:**
- [Positive outcome or advantage]
- [Standard outcome or feature retained]

**Drawbacks or Limitations:**
- [Trade-off or limitation introduced]
- [Dependency or maintenance consideration]

**Migration Path (if applicable):**
- [What changes to existing code are required]
- [Timeline or phasing if relevant]

## Related Decisions

- \[ADR-0001: Architecture\]\(ADR-0001-architecture.md\)
- \[ADR-0002: Azure CLI Over Az Module\]\(ADR-0002-azure-cli-over-az-module.md\)

## References

- \[Related Documentation\]\(https://example.com\)
- \[External Tool or Specification\]\(https://example.com\)
```

## Real Example

Here is ADR-0002 (Azure CLI over Az Module) as a complete example:

```markdown
# ADR-0002: Use Azure CLI Over Az PowerShell Module

**Date:** 2025-12-15

**Status:** ✅ **Accepted**

## Context

The Rename My Files scripts originally used the Azure PowerShell module (Az) for Azure resource 
management and authentication. However, the Az module is Windows-specific and does not work 
consistently on macOS or Linux. To achieve cross-platform compatibility and align with the 
project's goal of supporting developers on all major operating systems, we needed to evaluate 
alternative tooling for Azure interactions.

## Decision

We will use Azure CLI (`az`) instead of the Az PowerShell module for all Azure resource 
management and authentication in deployment scripts.

Azure CLI has identical functionality, is cross-platform (Windows, macOS, Linux), and includes 
built-in Bicep support without requiring a separate installation step.

## Consequences

**Benefits:**
- Cross-platform compatibility out of the box (Windows, macOS, Linux).
- No need for separate Bicep installation; `az bicep` works immediately.
- Reduced dependency surface; one tool instead of two PowerShell modules.
- Simpler API; `az` CLI is more intuitive than Az module cmdlets.
- Scripts are easier for new contributors unfamiliar with PowerShell.

**Drawbacks:**
- Requires Azure CLI installation (already common; a prerequisite does not add friction).
- Scripts must shell out to `az` commands; less direct PowerShell object piping in some scenarios.
- Error handling differs; PowerShell `try/catch` doesn't catch Azure CLI exit codes automatically.

**Migration Path:**
- Updated `Deploy-RenameMyFiles.ps1` to use `az` commands (Phase 0).
- Updated `Remove-RenameMyFilesResources.ps1` to use `az` commands (Phase 0).
- Updated README, user-guide, and runbook to list Azure CLI as prerequisite (Phase 5).

## Related Decisions

- \[ADR-0001: Architecture\]\(ADR-0001-architecture.md\) — Overall project architecture.
- \[ADR-0003: GlobalStandard Deployment Type\]\(ADR-0003-globalstandard-deployment-type.md\) — Azure OpenAI deployment strategy.

## References

- [Azure CLI Documentation](https://learn.microsoft.com/cli/azure/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
```

## Key Points for Agents

1. **Sequence numbers are immutable** — Once an ADR is assigned ADR-0005, it remains 0005 forever, even if superseded
2. **Status drives future reference** — Superseded ADRs should point to their replacement
3. **Keep consequences neutral** — Document trade-offs objectively; avoid justifying decisions as "obviously correct"
4. **Link within the DECISIONS folder** — Use relative paths: `[ADR-0001.md](ADR-0001.md)`
5. **Date format is ISO 8601** — YYYY-MM-DD for consistency and sorting
