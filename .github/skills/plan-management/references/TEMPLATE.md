# Phase Template

Copy this template when creating a new phase in IMPLEMENTATION_PLAN.md:

```markdown
## Phase [N] - [Descriptive Title]

**Status:** ✅ **Complete** | ⏳ **Not Started** | 🔄 **In Progress**

**Objective:** [One sentence describing what this phase accomplishes]

### Completed Tasks | Planned Tasks

- [x] [Task description with outcome]
  - [x] [Subtask or checkpoint]
  - [ ] [Not yet done subtask]
  - Code location: [file.ps1](../../scripts/file.ps1#L10-L20) lines 10–20.
  - Rationale: [Why this approach was chosen]

- [ ] [Planned task]
  - Estimated effort: [Time estimate or complexity]
  - Dependencies: [Other tasks or external blockers]

### Why [Rationale or Decision Context]

[Optional: Explain the reasoning behind this phase, decisions made, or trade-offs.]

**Note:** [Optional: List known limitations, edge cases, or assumptions for this phase.]

### Definition of Done

- [x] Criterion 1
- [x] Criterion 2
- [ ] Criterion 3 (if applicable)
```

## Key Points

1. **Keep status at phase level** — Use ✅/⏳/🔄 at the `## Phase` line
2. **Use relative links** — When referencing code or other docs, use paths relative from the file's location
3. **One task per bullet** — Each `- [ ]` item should represent one testable/verifiable outcome
4. **Link code changes** — Include [filename](path#L-start-L-end) references so readers can verify implementation
5. **Explain decisions** — Include context about why an approach was chosen (not just what was done)

## Example Phase (Real)

```markdown
## Phase 2 - File Intake and Safety

**Status:** ✅ **Complete**

**Objective:** Ensure robust input handling and error resilience.

### Completed Tasks

- [x] Validate folder path input with `[ValidateScript()]` attribute.
  - Code location: \[scripts/Rename-MyFiles.ps1\]\(../../scripts/Rename-MyFiles.ps1#L40-L50\) lines 40–50.
  - Rationale: PowerShell-idiomatic parameter validation prevents runtime errors.

- [x] Handle missing or empty folders gracefully (output message, exit cleanly).
  - Code location: \[scripts/Rename-MyFiles.ps1\]\(../../scripts/Rename-MyFiles.ps1#L65-L75\) lines 65–75.

- [x] Confirm only top-level files are processed via `Get-ChildItem -File` (no recursion).
  - Rationale: MVP scope excludes recursive scanning; single-folder focus keeps complexity low.

### Why

Input validation at the script boundary prevents cascading errors downstream. By failing fast on invalid paths, we keep batch processing resilient.

**Note:** Soft-delete handling for Azure OpenAI is in Phase 5 (ADR-0004).
```
