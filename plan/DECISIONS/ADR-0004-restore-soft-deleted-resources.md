# ADR-0004: Use Restore Flag for Soft-Deleted Azure OpenAI Resources

## Status

Accepted

## Context

Azure Cognitive Services (including Azure OpenAI) implements a **soft-delete** mechanism with a retention period of up to 48 hours. When a resource is deleted:

- The resource is not immediately purged — it enters a "soft-deleted" state
- The resource name remains reserved during the retention period
- Subsequent deployment attempts using the same name fail with error `FlagMustBeSetForRestore`

### Problem Encountered

During iterative development and testing (delete → redeploy cycles), users encountered blocking deployment errors:

```
ERROR: {"code": "FlagMustBeSetForRestore", 
        "message": "An existing resource with ID '...' has been soft-deleted. 
                    To restore the resource, you must specify 'restore' to be 
                    'true' in the property. If you don't want to restore existing 
                    resource, please purge it first."}
```

This is a poor developer experience because:
- The error requires manual intervention to resolve
- Users must either wait 48 hours or run manual `az` purge commands
- The solution is not obvious to users unfamiliar with Azure soft-delete behaviour

## Decision

**Add `restore: true` to the Azure OpenAI resource properties in the Bicep template.**

This allows the deployment to automatically restore soft-deleted resources rather than failing. The deployment script handles the common case (delete → redeploy) seamlessly without user intervention.

**Additionally**, document the soft-delete behaviour and manual purge commands in `../RUNBOOK.md` for edge cases where purging is required (e.g., changing deployment location).

## Consequences

### Positive

1. ✅ **Seamless redeploys** — Delete and redeploy workflows "just work" without errors or delays
2. ✅ **Better developer experience** — No manual intervention required for standard iterative development
3. ✅ **Faster iteration** — No waiting for 48-hour retention period or running purge commands
4. ✅ **Simple implementation** — Single-line change to Bicep template; no script logic required
5. ✅ **Preserves resource identity** — Restoring keeps the same resource ID and configuration (helpful for tracking and billing)

### Tradeoffs

1. ⚠️ **Not a clean slate** — Restoring reuses the previous resource rather than creating a fresh one
   - **Mitigation:** For most use cases (small utility processing local files), this is irrelevant; no resource-level state is accumulated
   - **For edge cases** (location changes, fresh start), manual purge is documented in RUNBOOK.md
   
2. ⚠️ **Configuration drift risk** — If the previous deployment had different settings, restore may fail or behave unexpectedly
   - **Mitigation:** The Bicep template is simple and stable; configuration changes are rare
   - **If needed:** Manual purge documented as fallback

3. ⚠️ **Requires Azure API version support** — The `restore` property requires API version `2023-10-01-preview` or later
   - **Mitigation:** Template already uses `2023-10-01-preview`; modern Azure subscriptions support this

## Alternatives Considered

### 1. Auto-Purge in Deployment Script

Pre-check for soft-deleted resources and purge them before deployment:

```powershell
az cognitiveservices account list-deleted --query "[?name=='$name']"
az cognitiveservices account purge --name $name --resource-group $rg --location $loc
```

**Rejected because:**
- Adds significant complexity to the deployment script
- Requires knowing the resource name beforehand (Bicep generates it dynamically using `uniqueString()`)
- Purge operations take time and add deployment latency
- Not necessary for 90% of use cases

### 2. Use Truly Random Resource Names

Generate resource names with GUIDs or timestamps to avoid naming conflicts entirely:

```bicep
var openAIResourceName = 'rmf-openai-${guid(resourceGroup().id, deployment().name)}'
```

**Rejected because:**
- Creates orphaned soft-deleted resources that accumulate and confuse users
- Breaks the clean "one OpenAI resource per resource group" model
- Resource names become unpredictable and harder to identify in the Azure Portal
- Does not solve the problem — just avoids it; leaves soft-deleted resources unremediated

### 3. Document Manual Steps Only

Leave the template as-is and document purge commands for users to run manually when they encounter the error.

**Rejected because:**
- Poor developer experience — users must troubleshoot and run manual commands for a common scenario
- Error-prone — users may purge the wrong resource or mistype commands
- Unnecessary friction for a problem that can be solved automatically

### 4. Hybrid: Detect Soft-Deleted + Prompt User

Deployment script detects soft-deleted resources and prompts:
```
"Found soft-deleted resource 'rmf-openai-xyz'. 
[R]estore, [P]urge, or [A]bort?"
```

**Rejected because:**
- Adds significant script complexity (detection, prompting, conditional logic)
- Breaks non-interactive / CI/CD scenarios
- Restoring is the correct choice for 90% of cases — prompting adds friction without meaningful benefit

## Implementation Details

### Bicep Template Change

Added `restore: true` to the Azure OpenAI resource properties:

```bicep
resource openAIAccount 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openAIResourceName
  location: location
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: openAIResourceName
    publicNetworkAccess: 'Enabled'
    restore: true  // ← Automatically restore soft-deleted resources
  }
}
```

### Documentation Update

Added a "Troubleshooting" section to `../RUNBOOK.md` documenting:
- The soft-delete behaviour and automatic restore handling
- Manual purge commands for edge cases (location changes, etc.)
- Expected 48-hour retention period

## References

- [Azure Cognitive Services soft-delete documentation](https://learn.microsoft.com/azure/cognitive-services/manage-resources-deletion)
- [Bicep restore property documentation](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts?pivots=deployment-language-bicep#accountproperties)

## Related ADRs

- ADR-0001: PowerShell CLI with Azure OpenAI Backend
- ADR-0002: Use Azure CLI Instead of Azure PowerShell Module
