# ADR-0002: Use Azure CLI Instead of Azure PowerShell Module

## Status

Accepted

## Context

The deployment script (`Deploy-RenameMyFiles.ps1`) originally used the Azure PowerShell module (`Az`) to manage Azure resources and deploy Bicep templates. However, we discovered a critical limitation:

- **The `Az` module requires a separate Bicep installation** for Bicep template deployments to work
- **Bicep support is not built into the `Az` module** — users must install Bicep independently and ensure it's in their PATH
- **This breaks cross-platform compatibility** — although PowerShell 7 is cross-platform, requiring separate Bicep installation adds friction and fails silently when Bicep is missing

### Problem Encountered

When deploying with the `Az` module, users received this error:

```
Cannot find Bicep. Please add Bicep to your PATH or visit https://aka.ms/bicep-install to install Bicep.
```

This was a blocking issue even though Bicep was already installed separately, because the error message was unclear and the fix (adding Bicep to PATH) was not obvious to non-technical users.

## Decision

- Replace all `Az` PowerShell module calls with equivalent **Azure CLI (`az`) commands**
- Use Azure CLI for all Azure resource management (authentication, resource groups, deployments)
- Parse JSON output from `az` commands using PowerShell's built-in `ConvertFrom-Json` cmdlet
- Keep the client scripts in PowerShell 7 for consistency and familiarity

**Specific mappings:**
- `Get-AzContext`, `Connect-AzAccount`, `Set-AzContext` → `az account show`, `az login`, `az account set`
- `Get-AzResourceGroup` → `az group show`
- `New-AzResourceGroup` → `az group create`
- `New-AzResourceGroupDeployment` → `az deployment group create`
- `Get-AzCognitiveServicesAccountKey` → `az cognitiveservices account keys list`
- `Remove-AzResourceGroup` → `az group delete`

## Consequences

### Positive

1. ✅ **Bicep support is built-in** — Azure CLI includes Bicep support out-of-the-box; no separate installation required
2. ✅ **True cross-platform support** — Azure CLI works identically on Windows, macOS, and Linux
3. ✅ **Reduced friction** — Single prerequisite (Azure CLI) instead of two (Az module + Bicep)
4. ✅ **Better error messages** — Azure CLI provides clearer error output for Bicep validation failures
5. ✅ **Consistent CLI experience** — Users who are familiar with `az` commands benefit from consistency
6. ✅ **No version lock-in** — Azure CLI receives updates more frequently and independently of PowerShell

### Tradeoffs

1. ⚠️ **Adds Azure CLI as a new prerequisite** — Previously only `Az` module was required; now Azure CLI must be installed separately
   - **Mitigation:** Azure CLI is simpler to install and configure than the `Az` module, and it's a single, well-documented tool
2. ⚠️ **Parsing JSON output** — We must parse JSON output from `az` commands rather than working with objects directly
   - **Mitigation:** PowerShell's `ConvertFrom-Json` handles this elegantly; output is only parsed when needed
3. ⚠️ **Less discoverability in PowerShell IDE** — `az` commands run as external processes, not PowerShell cmdlets
   - **Mitigation:** Minimal impact since most users run scripts as-is; they don't customise or extend the deployment scripts

## Alternatives Considered

### 1. Keep Az Module + Ensure Bicep is in PATH
- **Rejected:** Still requires users to install Bicep separately; doesn't solve the core problem
- **Risk:** Silent failures if Bicep is installed but not in PATH

### 2. Use Terraform Instead of Bicep
- **Rejected:** Adds another tool and language to learn; outside the scope of a simple PowerShell utility
- **Risk:** Increases dependencies and maintenance burden

### 3. Hybrid Approach (Az for some tasks, az CLI for others)
- **Rejected:** Adds complexity; users must install both tools
- **Better:** Use one consistent tool

## Implementation Details

- Deployment script updated to detect and use `az` CLI
- Added prerequisite check: `Get-Command az -ErrorAction SilentlyContinue`
- All Azure interactions (auth, resource creation, deployment) now use `az` in one-liners piped to `ConvertFrom-Json`
- Removal script updated to use `az` commands for consistency
- Documentation updated to reference Azure CLI installation instead of Az module

## References

- [Azure CLI Documentation](https://learn.microsoft.com/cli/azure/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure CLI vs Azure PowerShell](https://learn.microsoft.com/en-us/cli/azure/compare-azure-cli-to-azure-powershell)

## Related ADRs

- ADR-0001: PowerShell CLI with Azure OpenAI Backend
