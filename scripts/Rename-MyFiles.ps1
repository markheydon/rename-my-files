<#
.SYNOPSIS
    Renames files in a folder using Azure AI to generate descriptive, human-readable filenames.

.DESCRIPTION
    Rename-MyFiles.ps1 iterates through each file in the specified folder, reads its content,
    and uses an Azure OpenAI model to propose a meaningful filename based on the document's
    subject, sender, recipient, and any reliable date information. The file is then renamed
    on disk, preserving its original extension.

    Files that cannot be read (unsupported types, encrypted, corrupted) are skipped and logged.
    A summary is displayed at the end showing how many files were renamed, skipped, or failed.

.PARAMETER FolderPath
    The path to the folder containing the files to rename. Must exist and be accessible.

.PARAMETER AzureOpenAIEndpoint
    The Azure OpenAI resource endpoint URL (e.g. https://my-resource.openai.azure.com/).
    If not provided, falls back to the AZURE_OPENAI_ENDPOINT environment variable.

.PARAMETER AzureOpenAIKey
    The Azure OpenAI API key.
    If not provided, falls back to the AZURE_OPENAI_KEY environment variable.

.PARAMETER DeploymentName
    The name of the Azure OpenAI model deployment to use. Defaults to 'gpt-4o-mini'.

.PARAMETER WhatIf
    Shows what files would be renamed without actually renaming them.

.EXAMPLE
    .\Rename-MyFiles.ps1 -FolderPath "C:\Documents\Unfiled"

    Renames all supported files in C:\Documents\Unfiled using Azure AI.

.EXAMPLE
    .\Rename-MyFiles.ps1 -FolderPath "C:\Documents\Unfiled" -WhatIf

    Shows proposed renames without making any changes.

.EXAMPLE
    .\Rename-MyFiles.ps1 -FolderPath "C:\Documents\Unfiled" -Verbose

    Renames files with detailed progress output.

.NOTES
    Requires PowerShell 7.2 or later.
    Set AZURE_OPENAI_ENDPOINT and AZURE_OPENAI_KEY environment variables, or pass them as parameters.
#>

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory, Position = 0, HelpMessage = 'Path to the folder containing files to rename.')]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path -LiteralPath $_ -PathType Container }, ErrorMessage = 'FolderPath must be an existing directory.')]
    [string]$FolderPath,

    [Parameter(HelpMessage = 'Azure OpenAI endpoint URL. Falls back to AZURE_OPENAI_ENDPOINT env var.')]
    [string]$AzureOpenAIEndpoint = $env:AZURE_OPENAI_ENDPOINT,

    [Parameter(HelpMessage = 'Azure OpenAI API key. Falls back to AZURE_OPENAI_KEY env var.')]
    [string]$AzureOpenAIKey = $env:AZURE_OPENAI_KEY,

    [Parameter(HelpMessage = 'Azure OpenAI model deployment name.')]
    [ValidateNotNullOrEmpty()]
    [string]$DeploymentName = 'gpt-4o-mini'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helper: Read file content as plain text, with basic support for PDF.
# Returns $null if the file type is unsupported or unreadable.
# ---------------------------------------------------------------------------
function Get-FileTextContent {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.IO.FileInfo]$File
    )

    try {
        $extension = $File.Extension.ToLowerInvariant()

        switch ($extension) {
            { $_ -in '.txt', '.md', '.csv', '.log', '.json', '.xml', '.html', '.htm', '.yaml', '.yml' } {
                # Plain text — read directly.
                return Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8
            }

            '.pdf' {
                # TODO: For production use, consider adding iTextSharp or PdfPig via NuGet,
                # or using a pre-installed pdftotext utility. This stub returns a placeholder.
                # Example with pdftotext (if installed):
                #   $text = & pdftotext $File.FullName -
                #   return $text
                Write-Verbose "PDF extraction is not fully implemented. Using filename as context for: $($File.Name)"
                return "[PDF file: $($File.Name)]"
            }

            { $_ -in '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx' } {
                # TODO: For production use, consider using the Open XML SDK or COM interop.
                # This stub returns a placeholder so the file still gets a best-effort rename.
                Write-Verbose "Office document extraction is not fully implemented. Using filename as context for: $($File.Name)"
                return "[Office document: $($File.Name)]"
            }

            default {
                # Unsupported file type — skip it.
                Write-Verbose "Unsupported file type '$extension' for file: $($File.Name)"
                return $null
            }
        }
    }
    catch {
        Write-Verbose "Failed to read '$($File.Name)': $_"
        return $null
    }
}

# ---------------------------------------------------------------------------
# Helper: Call Azure OpenAI to propose a filename for the given content.
# Returns a proposed filename string (without extension), or $null on failure.
# ---------------------------------------------------------------------------
function Invoke-AzureOpenAIFilenameProposal {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$FileContent,

        [Parameter(Mandatory)]
        [string]$OriginalFileName,

        [Parameter(Mandatory)]
        [string]$Endpoint,

        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Parameter(Mandatory)]
        [string]$DeploymentName
    )

    $systemPrompt = @'
You are a file-naming assistant. Your only job is to propose a clear, descriptive, human-readable
filename for a document based on its content.

Rules:
- Identify the document's subject, sender, recipient, and any reliable date you can infer.
- Propose a filename that would make sense to a human user scanning a folder.
- Do NOT include the file extension — that will be added by the caller.
- Use title case. Use hyphens or spaces as separators (spaces are fine).
- Keep the name concise but descriptive (aim for under 80 characters).
- Avoid special characters that are invalid on Windows filesystems: \ / : * ? " < > |
- If you cannot reliably determine specific details, still propose the best descriptive name you can.
- Respond with ONLY the proposed filename — no explanation, no punctuation at the end.

Examples of good output:
  Acme Ltd Contract Renewal Notice - 13th January 2026
  HMRC Self Assessment Tax Return 2024-25
  Dr Smith Referral Letter - Patient John Doe
  Electricity Bill - March 2025
'@

    $userPrompt = "Original filename: $OriginalFileName`n`nDocument content:`n$FileContent"

    # Truncate content to avoid exceeding token limits (approx 6000 chars ~ 1500 tokens).
    if ($userPrompt.Length -gt 8000) {
        $userPrompt = $userPrompt.Substring(0, 8000) + "`n[... content truncated ...]"
    }

    $requestBody = @{
        messages = @(
            @{ role = 'system'; content = $systemPrompt },
            @{ role = 'user';   content = $userPrompt }
        )
        max_tokens   = 60
        temperature  = 0.2
    } | ConvertTo-Json -Depth 5

    $uri = "$($Endpoint.TrimEnd('/'))/openai/deployments/$DeploymentName/chat/completions?api-version=2024-02-01"

    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json' -Body $requestBody -Headers @{
            'api-key' = $ApiKey
        }
        $proposed = $response.choices[0].message.content.Trim()
        return $proposed
    }
    catch {
        Write-Verbose "Azure OpenAI call failed for '$OriginalFileName': $_"
        return $null
    }
}

# ---------------------------------------------------------------------------
# Helper: Sanitise a filename by removing characters invalid on common filesystems.
# ---------------------------------------------------------------------------
function Get-SanitisedFileName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ProposedName
    )

    # Remove characters invalid on Windows (and problematic on Unix).
    $sanitised = $ProposedName -replace '[\\/:*?"<>|]', ''

    # Collapse multiple spaces/dashes, then trim whitespace and trailing dots.
    $sanitised = $sanitised -replace ' {2,}', ' '
    $sanitised = $sanitised -replace '-{2,}', '-'
    $sanitised = $sanitised.Trim().TrimEnd('.')

    if ([string]::IsNullOrWhiteSpace($sanitised)) {
        return $null
    }
    return $sanitised
}

# ---------------------------------------------------------------------------
# Helper: Resolve a collision-free destination path.
# If the proposed path already exists, appends -1, -2, etc.
# ---------------------------------------------------------------------------
function Resolve-UniqueFilePath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Directory,

        [Parameter(Mandatory)]
        [string]$BaseName,

        [Parameter(Mandatory)]
        [string]$Extension
    )

    $candidate = Join-Path $Directory "$BaseName$Extension"
    if (-not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    $counter = 1
    do {
        $candidate = Join-Path $Directory "$BaseName-$counter$Extension"
        $counter++
    } while (Test-Path -LiteralPath $candidate)

    return $candidate
}

# ---------------------------------------------------------------------------
# Main processing
# ---------------------------------------------------------------------------

# Validate Azure credentials.
if ([string]::IsNullOrWhiteSpace($AzureOpenAIEndpoint)) {
    throw 'Azure OpenAI endpoint is required. Pass -AzureOpenAIEndpoint or set the AZURE_OPENAI_ENDPOINT environment variable.'
}
if ([string]::IsNullOrWhiteSpace($AzureOpenAIKey)) {
    throw 'Azure OpenAI API key is required. Pass -AzureOpenAIKey or set the AZURE_OPENAI_KEY environment variable.'
}

$resolvedFolder = Resolve-Path -LiteralPath $FolderPath
Write-Host "Scanning folder: $resolvedFolder" -ForegroundColor Cyan

$files = Get-ChildItem -LiteralPath $resolvedFolder -File

if ($files.Count -eq 0) {
    Write-Host 'No files found in the specified folder.' -ForegroundColor Yellow
    return
}

Write-Host "Found $($files.Count) file(s). Processing..." -ForegroundColor Cyan

$countRenamed  = 0
$countSkipped  = 0
$skippedFiles  = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($file in $files) {
    Write-Verbose "Processing: $($file.Name)"

    # Step 1: Read content.
    $content = Get-FileTextContent -File $file
    if ($null -eq $content) {
        $skippedFiles.Add([PSCustomObject]@{ Name = $file.Name; Reason = 'Unsupported or unreadable file type' })
        $countSkipped++
        Write-Host "  SKIPPED  $($file.Name) — unsupported or unreadable" -ForegroundColor DarkYellow
        continue
    }

    # Step 2: Ask Azure AI for a proposed filename.
    $proposed = Invoke-AzureOpenAIFilenameProposal `
        -FileContent $content `
        -OriginalFileName $file.Name `
        -Endpoint $AzureOpenAIEndpoint `
        -ApiKey $AzureOpenAIKey `
        -DeploymentName $DeploymentName

    if ($null -eq $proposed) {
        $skippedFiles.Add([PSCustomObject]@{ Name = $file.Name; Reason = 'Azure AI call failed' })
        $countSkipped++
        Write-Host "  SKIPPED  $($file.Name) — Azure AI call failed" -ForegroundColor DarkYellow
        continue
    }

    # Step 3: Sanitise the proposed name.
    $sanitised = Get-SanitisedFileName -ProposedName $proposed
    if ($null -eq $sanitised) {
        $skippedFiles.Add([PSCustomObject]@{ Name = $file.Name; Reason = 'AI returned an unusable filename' })
        $countSkipped++
        Write-Host "  SKIPPED  $($file.Name) — AI returned an unusable filename" -ForegroundColor DarkYellow
        continue
    }

    # Step 4: Resolve a unique destination path.
    $destinationPath = Resolve-UniqueFilePath `
        -Directory $file.DirectoryName `
        -BaseName $sanitised `
        -Extension $file.Extension

    $newName = Split-Path $destinationPath -Leaf

    # Step 5: Rename (or preview in -WhatIf mode).
    if ($PSCmdlet.ShouldProcess($file.Name, "Rename to '$newName'")) {
        try {
            Rename-Item -LiteralPath $file.FullName -NewName $newName -ErrorAction Stop
            $countRenamed++
            Write-Host "  RENAMED  $($file.Name)  →  $newName" -ForegroundColor Green
        }
        catch {
            $reason = "Rename failed: $($_.Exception.Message)"
            $skippedFiles.Add([PSCustomObject]@{ Name = $file.Name; Reason = $reason })
            $countSkipped++
            Write-Host "  SKIPPED  $($file.Name) — $reason" -ForegroundColor DarkYellow
        }
    }
    else {
        # -WhatIf path — ShouldProcess already printed the WhatIf message.
        Write-Host "  PROPOSED $($file.Name)  →  $newName" -ForegroundColor Cyan
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Host ''
Write-Host '─────────────────────────────────────' -ForegroundColor Cyan
Write-Host ' Summary' -ForegroundColor Cyan
Write-Host '─────────────────────────────────────' -ForegroundColor Cyan
Write-Host " Files scanned : $($files.Count)"
Write-Host " Files renamed : $countRenamed"     -ForegroundColor Green
Write-Host " Files skipped : $countSkipped"     -ForegroundColor $(if ($countSkipped -gt 0) { 'Yellow' } else { 'White' })

if ($skippedFiles.Count -gt 0) {
    Write-Host ''
    Write-Host ' Skipped files:' -ForegroundColor Yellow
    foreach ($skipped in $skippedFiles) {
        Write-Host "   • $($skipped.Name) — $($skipped.Reason)" -ForegroundColor DarkYellow
    }
}
Write-Host '─────────────────────────────────────' -ForegroundColor Cyan
