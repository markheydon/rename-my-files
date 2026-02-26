@{
    # Severity levels to check (Error, Warning, Information)
    # Errors will fail the build; Warnings will be reported but not fail
    Severity = @('Error', 'Warning')
    
    # Include all default PSScriptAnalyzer rules
    IncludeDefaultRules = $true
    
    # Exclude specific rules only when justified
    # Start with an empty list; add exceptions if needed
    ExcludeRules = @(
        # Example: Uncomment if Write-Host is intentionally used for user output
        # 'PSAvoidUsingWriteHost'
    )
    
    # Additional rules can be added here
    # IncludeRules = @()
    
    # Custom rule paths (if any)
    # CustomRulePath = @()
}
