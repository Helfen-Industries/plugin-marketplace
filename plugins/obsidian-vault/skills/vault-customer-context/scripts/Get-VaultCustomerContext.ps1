<#
.SYNOPSIS
    Resolves the vault customer for a name, alias, or repository path and lists that customer's context notes.

.DESCRIPTION
    Read-only. Resolution order: -Customer (folder, kunde, aliases; exact before partial), otherwise -Path
    (local repository path listed in a fact sheet, then Git remote URL, then DevOps project or repository
    name listed in aliases). Writes one JSON object to stdout:
    status = resolved | ambiguous | unresolved | vault-not-found.

.EXAMPLE
    powershell -NoProfile -File Get-VaultCustomerContext.ps1 -Path "C:\Dev\Customers\Spacemann\Spacemann Base App" -WorkItem 15347
#>
[CmdletBinding()]
param(
    [string] $VaultRoot,
    [string] $Customer,
    [string] $Path,
    [string] $WorkItem,
    [int] $Days = 30,
    [switch] $ResolveOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\..\vault-note-write\scripts\VaultTools.ps1')
Set-VaultUtf8Output

function ConvertTo-NormalizedPath {
    param([string] $Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ''
    }

    try {
        $Value = [System.IO.Path]::GetFullPath($Value)
    }
    catch {
        # Keep the raw value when it is not a valid path.
    }

    return $Value.Replace('/', '\').TrimEnd('\').ToLowerInvariant()
}

function ConvertTo-NormalizedUrl {
    param([string] $Value)

    $url = [System.Uri]::UnescapeDataString($Value.Trim())
    if ($url -match '^git@ssh\.dev\.azure\.com:v3/([^/]+)/([^/]+)/(.+)$') {
        $url = "https://dev.azure.com/$($Matches[1])/$($Matches[2])/_git/$($Matches[3])"
    }
    elseif ($url -match '^git@([^:]+):(.+)$') {
        $url = "https://$($Matches[1])/$($Matches[2])"
    }

    $url = $url -replace '^(https?://)[^/@]+@', '$1'
    $url = $url -replace '\.git$', ''
    return $url.TrimEnd('/').ToLowerInvariant()
}

function Get-RemoteNames {
    # Returns DevOps project and repository names (Azure DevOps) or the repository name (GitHub).
    param([string] $NormalizedUrl)

    if ($NormalizedUrl -match '^https://dev\.azure\.com/[^/]+/([^/]+)/_git/([^/]+)$') {
        return [string[]] @($Matches[1], $Matches[2])
    }

    if ($NormalizedUrl -match '^https://[^/.]+\.visualstudio\.com/([^/]+)/_git/([^/]+)$') {
        return [string[]] @($Matches[1], $Matches[2])
    }

    if ($NormalizedUrl -match '^https://github\.com/[^/]+/([^/]+)$') {
        return [string[]] @($Matches[1])
    }

    return [string[]] @()
}

function New-Result {
    param([string] $Status)

    return [ordered]@{
        status     = $Status
        vaultRoot  = $vault
        query      = [ordered]@{ customer = $Customer; path = $Path; gitTopLevel = $null; remote = $null; workItem = $WorkItem }
        matchedBy  = $null
        candidates = @()
        customer   = $null
        decisions  = @()
        concepts   = @()
        processes  = @()
        meetings   = @()
    }
}

function Test-WorkItemMatch {
    param($Note, [string] $FileName)

    if ([string]::IsNullOrWhiteSpace($WorkItem)) {
        return $false
    }

    $ids = @(Get-VaultList $Note.Frontmatter 'devops')
    return ($ids -contains $WorkItem) -or $FileName.StartsWith("$WorkItem ") -or ($Note.Text -match "AB#$([regex]::Escape($WorkItem))\b")
}

$vault = Get-VaultRoot $VaultRoot
if ($null -eq $vault) {
    $result = New-Result 'vault-not-found'
    $result.vaultRoot = if ($VaultRoot) { $VaultRoot } else { 'C:\Dev\Knowledge' }
    $result | ConvertTo-Json -Depth 8
    exit 0
}

$result = New-Result 'unresolved'
$customersRoot = Join-Path $vault 'Kunden'

$profiles = foreach ($folder in Get-ChildItem -LiteralPath $customersRoot -Directory) {
    $profilePath = Join-Path $folder.FullName '00-Steckbrief.md'
    $note = if (Test-Path -LiteralPath $profilePath -PathType Leaf) { Read-VaultNote $profilePath } else { $null }
    $frontmatter = if ($note) { $note.Frontmatter } else { $null }
    $names = @($folder.Name) + @(Get-VaultText $frontmatter 'kunde') + @(Get-VaultList $frontmatter 'aliases') | Where-Object { $_ -ne '' } | Select-Object -Unique
    $urls = @()
    $localPaths = @()
    if ($note) {
        $urls = @([regex]::Matches($note.Text, 'https?://[^\s<>()|\]`]+') | ForEach-Object { ConvertTo-NormalizedUrl $_.Value } | Select-Object -Unique)
        $localPaths = @([regex]::Matches($note.Text, '`([A-Za-z]:\\[^`]+)`') | ForEach-Object { ConvertTo-NormalizedPath $_.Groups[1].Value } | Select-Object -Unique)
    }

    [pscustomobject]@{ Folder = $folder.Name; FullName = $folder.FullName; Note = $note; Names = [string[]] $names; Urls = [string[]] $urls; LocalPaths = [string[]] $localPaths }
}

$candidates = @()
if (-not [string]::IsNullOrWhiteSpace($Customer)) {
    $query = $Customer.Trim()
    $candidates = @($profiles | Where-Object { $_.Names | Where-Object { $_ -ieq $query } } | ForEach-Object { [pscustomobject]@{ Profile = $_; MatchedBy = 'name' } })
    if ($candidates.Count -eq 0) {
        $candidates = @($profiles | Where-Object { $_.Names | Where-Object { $_.IndexOf($query, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 } } | ForEach-Object { [pscustomobject]@{ Profile = $_; MatchedBy = 'name-partial' } })
    }
}
elseif (-not [string]::IsNullOrWhiteSpace($Path)) {
    $topLevel = $Path
    if (Test-Path -LiteralPath $Path) {
        $git = Invoke-VaultGit -RepositoryPath $Path -Arguments @('rev-parse', '--show-toplevel')
        if ($git.ExitCode -eq 0 -and $git.Output.Count -gt 0) {
            $topLevel = $git.Output[0]
            $result.query.gitTopLevel = $topLevel.Replace('/', '\')
        }
    }

    $normalizedTop = ConvertTo-NormalizedPath $topLevel
    $candidates = @($profiles | Where-Object {
            $entry = $_
            @($entry.LocalPaths | Where-Object { $normalizedTop -eq $_ -or $normalizedTop.StartsWith("$_\") -or $_.StartsWith("$normalizedTop\") }).Count -gt 0
        } | ForEach-Object { [pscustomobject]@{ Profile = $_; MatchedBy = 'repo-path' } })

    if ($candidates.Count -eq 0 -and $null -ne $result.query.gitTopLevel) {
        $remote = Invoke-VaultGit -RepositoryPath $topLevel -Arguments @('remote', 'get-url', 'origin')
        if ($remote.ExitCode -eq 0 -and $remote.Output.Count -gt 0) {
            $normalizedRemote = ConvertTo-NormalizedUrl $remote.Output[0]
            $result.query.remote = $normalizedRemote
            $candidates = @($profiles | Where-Object { $_.Urls -contains $normalizedRemote } | ForEach-Object { [pscustomobject]@{ Profile = $_; MatchedBy = 'git-remote' } })
            if ($candidates.Count -eq 0) {
                $remoteNames = Get-RemoteNames $normalizedRemote
                $candidates = @($profiles | Where-Object {
                        $entry = $_
                        @($remoteNames | Where-Object { $entry.Names -icontains $_ }).Count -gt 0
                    } | ForEach-Object { [pscustomobject]@{ Profile = $_; MatchedBy = 'devops-project' } })
            }
        }
    }
}

$result.candidates = @($candidates | ForEach-Object { [ordered]@{ kunde = $_.Profile.Folder; matchedBy = $_.MatchedBy } })
if ($candidates.Count -gt 1) {
    $result.status = 'ambiguous'
}

if ($candidates.Count -ne 1) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

$selected = $candidates[0].Profile
$result.status = 'resolved'
$result.matchedBy = $candidates[0].MatchedBy
$today = (Get-Date).Date

$profileInfo = [ordered]@{ kunde = $selected.Folder; folder = $selected.FullName; steckbrief = $null }
if ($selected.Note) {
    $stand = Get-VaultText $selected.Note.Frontmatter 'stand'
    $standDate = ConvertTo-VaultDate $stand
    $profileInfo.steckbrief = [ordered]@{
        path          = $selected.Note.Path
        stand         = $stand
        ageDays       = if ($standDate) { [int] ($today - $standDate).TotalDays } else { $null }
        status        = Get-VaultText $selected.Note.Frontmatter 'status'
        aliases       = @(Get-VaultList $selected.Note.Frontmatter 'aliases')
        openQuestions = @(Get-VaultOpenItems $selected.Note 'Offene Fragen')
    }
}

$result.customer = $profileInfo
if ($ResolveOnly) {
    $result | ConvertTo-Json -Depth 8
    exit 0
}

function Get-FolderNotes {
    param([string] $Name)

    $folderPath = Join-Path $selected.FullName $Name
    if (-not (Test-Path -LiteralPath $folderPath -PathType Container)) {
        return @()
    }

    return @(Get-ChildItem -LiteralPath $folderPath -Filter '*.md' -File | Where-Object { $_.Name -notlike '*.excalidraw.md' } | Sort-Object Name)
}

$result.decisions = @(foreach ($file in Get-FolderNotes 'Entscheidungen') {
        $note = Read-VaultNote $file.FullName
        $status = Get-VaultText $note.Frontmatter 'status'
        [ordered]@{
            path           = $file.FullName
            adr            = Get-VaultText $note.Frontmatter 'adr'
            title          = ($file.BaseName -replace '^ADR-\d{4}\s+', '')
            status         = $status
            datum          = Get-VaultText $note.Frontmatter 'datum'
            active         = $status -in @('akzeptiert', 'vorgeschlagen')
            replacedBy     = Get-VaultText $note.Frontmatter 'ersetzt-durch'
            matchesWorkItem = Test-WorkItemMatch $note $file.BaseName
        }
    })

$result.concepts = @(foreach ($file in Get-FolderNotes 'Konzepte') {
        $note = Read-VaultNote $file.FullName
        [ordered]@{
            path            = $file.FullName
            title           = $file.BaseName
            status          = Get-VaultText $note.Frontmatter 'status'
            datum           = Get-VaultText $note.Frontmatter 'datum'
            devops          = @(Get-VaultList $note.Frontmatter 'devops')
            spec            = Get-VaultText $note.Frontmatter 'spec'
            matchesWorkItem = Test-WorkItemMatch $note $file.BaseName
            openQuestions   = @(Get-VaultOpenItems $note 'Offene Fragen')
        }
    })

$result.processes = @(foreach ($file in Get-FolderNotes 'Prozesse') {
        $note = Read-VaultNote $file.FullName
        [ordered]@{
            path            = $file.FullName
            title           = $file.BaseName
            status          = Get-VaultText $note.Frontmatter 'status'
            datum           = Get-VaultText $note.Frontmatter 'datum'
            matchesWorkItem = Test-WorkItemMatch $note $file.BaseName
        }
    })

$cutoff = $today.AddDays(-$Days)
$meetings = @(foreach ($file in Get-FolderNotes 'Meetings') {
        $note = Read-VaultNote $file.FullName
        $datum = Get-VaultText $note.Frontmatter 'datum'
        $date = ConvertTo-VaultDate $datum
        if ($null -eq $date) {
            $date = $file.LastWriteTime.Date
        }

        $matchesWorkItem = Test-WorkItemMatch $note $file.BaseName
        if ($date -lt $cutoff -and -not $matchesWorkItem) {
            continue
        }

        [ordered]@{
            path            = $file.FullName
            title           = ($file.BaseName -replace '^\d{4}-\d{2}-\d{2}\s+', '')
            datum           = $date.ToString('yyyy-MM-dd')
            matchesWorkItem = $matchesWorkItem
            openTodos       = @(Get-VaultOpenItems $note 'Todos')
            openQuestions   = @(Get-VaultOpenItems $note 'Offene Fragen')
        }
    })
$result.meetings = @($meetings | Sort-Object { $_.datum } -Descending)

$result | ConvertTo-Json -Depth 8
