---
description: Bootstrap a new repo with Copilot instructions, a minimal agent team, prompts, and baseline docs from a rough app idea.
agent: Repo Bootstrapper
argument-hint: "Describe the app idea + target stack + UI type (e.g., '.NET 10, Blazor Server') + MVP must-haves"
---

Using the user’s idea, initialise the repository for AI-assisted development.

Create/update:
- `.github/copilot-instructions.md`
- `.github/instructions/*.instructions.md`
- `.github/agents/*` (minimal team)
- `.github/prompts/*` (plan/next-task/implement/review/docs)
- `docs/SCOPE.md`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/RUNBOOK.md`
- `docs/DECISIONS/ADR-0001-architecture.md`

Rules:
- Keep it minimal (start with 4 agents unless strongly justified).
- Include build/test commands as gates.
- Write docs that match reality and label assumptions clearly.
- Default to .NET unless the user specifies otherwise.