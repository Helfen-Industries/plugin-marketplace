<#
.SYNOPSIS
    Resolves the vault customer or project for a name, alias, or repository path and lists its context notes.

.DESCRIPTION
    Read-only. Searches the fact sheets under 10-Kunden/ and 20-Projekte/. Resolution order: -Customer (folder,
    kunde or projekt, aliases; exact before partial; then the exact name or alias of a Teilprojekt start page under
    <Ort>/Teilprojekte/), otherwise -Path (local repository path listed in a fact sheet, then Git remote URL, then
    DevOps project or repository name listed in aliases). Writes one JSON object
    to stdout: status = resolved | ambiguous | unresolved | vault-not-found.
    For a resolved customer or project it lists the Teilprojekt start pages, decisions, concepts, processes, recent
    meetings, open tasks (typ: aufgabe, status not archiv), and the appointments of the next -AppointmentDays days
    from the generated Outlook calendar 99-System/Kalender/outlook/outlook.ics whose subject or location names the
    folder or an alias. Appointments carry only subject and time; attendees, organizer, location, and description
    are never emitted.
    Every note carries its teilprojekt list. A Teilprojekt focus (-Teilprojekt, a Teilprojekt name or alias given as
    -Customer, or a local repository path listed in a start page) keeps the notes of that Teilprojekt and the notes
    without teilprojekt (they apply to the whole customer or project) and drops notes of other Teilprojekte.

.EXAMPLE
    powershell -NoProfile -File Get-VaultCustomerContext.ps1 -Path "C:\Dev\Customers\Spacemann\Spacemann Base App" -WorkItem 15347
#>
[CmdletBinding()]
param(
    [string] $VaultRoot,
    [string] $Customer,
    [string] $Path,
    [string] $WorkItem,
    [string] $Teilprojekt,
    [int] $Days = 30,
    [int] $AppointmentDays = 7,
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

function Test-PathListMatch {
    # True when the normalized path equals a listed path or lies below or above it.
    param([string] $NormalizedPath, [string[]] $ListedPaths)

    return @($ListedPaths | Where-Object { $NormalizedPath -eq $_ -or $NormalizedPath.StartsWith("$_\") -or $_.StartsWith("$NormalizedPath\") }).Count -gt 0
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
        query      = [ordered]@{ customer = $Customer; path = $Path; gitTopLevel = $null; remote = $null; workItem = $WorkItem; teilprojekt = $Teilprojekt }
        matchedBy  = $null
        candidates = @()
        customer   = $null
        teilprojekte = @()
        teilprojekt  = $null
        decisions  = @()
        concepts   = @()
        processes  = @()
        meetings   = @()
        tasks      = @()
        calendar   = $null
        appointments = @()
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

$profiles = foreach ($area in $script:VaultAreas) {
    $areaRoot = Join-Path $vault $area.Folder
    if (-not (Test-Path -LiteralPath $areaRoot -PathType Container)) {
        continue
    }

    foreach ($folder in Get-ChildItem -LiteralPath $areaRoot -Directory) {
        $profilePath = Join-Path $folder.FullName '00-Steckbrief.md'
        $note = if (Test-Path -LiteralPath $profilePath -PathType Leaf) { Read-VaultNote $profilePath } else { $null }
        $frontmatter = if ($note) { $note.Frontmatter } else { $null }
        $names = @($folder.Name) + @(Get-VaultText $frontmatter $area.Field) + @(Get-VaultList $frontmatter 'aliases') | Where-Object { $_ -ne '' } | Select-Object -Unique
        $urls = @()
        $localPaths = @()
        if ($note) {
            $urls = @([regex]::Matches($note.Text, 'https?://[^\s<>()|\]`]+') | ForEach-Object { ConvertTo-NormalizedUrl $_.Value } | Select-Object -Unique)
            $localPaths = @([regex]::Matches($note.Text, '`([A-Za-z]:\\[^`]+)`') | ForEach-Object { ConvertTo-NormalizedPath $_.Groups[1].Value } | Select-Object -Unique)
        }

        $teilprojekte = @()
        $teilprojektFolder = Join-Path $folder.FullName 'Teilprojekte'
        if (Test-Path -LiteralPath $teilprojektFolder -PathType Container) {
            $teilprojekte = @(Get-ChildItem -LiteralPath $teilprojektFolder -Filter '*.md' -File | Sort-Object Name | ForEach-Object {
                    $startPage = Read-VaultNote $_.FullName
                    [pscustomobject]@{
                        Name       = $_.BaseName
                        Path       = $_.FullName
                        Note       = $startPage
                        Names      = [string[]] @(@($_.BaseName) + @(Get-VaultList $startPage.Frontmatter 'aliases') | Where-Object { $_ -ne '' } | Select-Object -Unique)
                        LocalPaths = [string[]] @([regex]::Matches($startPage.Text, '`([A-Za-z]:\\[^`]+)`') | ForEach-Object { ConvertTo-NormalizedPath $_.Groups[1].Value } | Select-Object -Unique)
                    }
                })
        }

        [pscustomobject]@{ Folder = $folder.Name; Field = $area.Field; Place = "$($area.Folder)/$($folder.Name)"; FullName = $folder.FullName; Note = $note; Names = [string[]] $names; Urls = [string[]] $urls; LocalPaths = [string[]] $localPaths; Teilprojekte = $teilprojekte }
    }
}

$candidates = @()
$focusEntry = $null
$focusMatchedBy = $null
$normalizedTop = $null
if (-not [string]::IsNullOrWhiteSpace($Customer)) {
    $query = $Customer.Trim()
    $candidates = @($profiles | Where-Object { $_.Names | Where-Object { $_ -ieq $query } } | ForEach-Object { [pscustomobject]@{ Profile = $_; MatchedBy = 'name' } })
    if ($candidates.Count -eq 0) {
        $candidates = @($profiles | Where-Object { @($_.Teilprojekte | Where-Object { $_.Names -icontains $query }).Count -gt 0 } | ForEach-Object { [pscustomobject]@{ Profile = $_; MatchedBy = 'teilprojekt' } })
        if ($candidates.Count -eq 1) {
            $focusEntry = @($candidates[0].Profile.Teilprojekte | Where-Object { $_.Names -icontains $query })[0]
            $focusMatchedBy = 'name'
        }
    }

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

    if ($candidates.Count -eq 0) {
        $candidates = @($profiles | Where-Object {
                @($_.Teilprojekte | Where-Object { Test-PathListMatch $normalizedTop $_.LocalPaths }).Count -gt 0
            } | ForEach-Object { [pscustomobject]@{ Profile = $_; MatchedBy = 'teilprojekt-path' } })
    }

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

$result.candidates = @($candidates | ForEach-Object { [ordered]@{ name = $_.Profile.Folder; bereich = $_.Profile.Field; ort = $_.Profile.Place; matchedBy = $_.MatchedBy } })
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

$profileInfo = [ordered]@{ name = $selected.Folder; bereich = $selected.Field; ort = $selected.Place; folder = $selected.FullName; steckbrief = $null }
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

if (-not [string]::IsNullOrWhiteSpace($Teilprojekt)) {
    $focusEntry = @($selected.Teilprojekte | Where-Object { $_.Names -icontains $Teilprojekt.Trim() }) | Select-Object -First 1
    $focusMatchedBy = 'parameter'
}
elseif ($null -eq $focusEntry -and $null -ne $normalizedTop) {
    $pathHits = @($selected.Teilprojekte | Where-Object { Test-PathListMatch $normalizedTop $_.LocalPaths })
    if ($pathHits.Count -eq 1) {
        $focusEntry = $pathHits[0]
        $focusMatchedBy = 'repo-path'
    }
}

function ConvertTo-TeilprojektInfo {
    param($Entry)

    return [ordered]@{
        name          = $Entry.Name
        path          = $Entry.Path
        status        = Get-VaultText $Entry.Note.Frontmatter 'status'
        aliases       = @(Get-VaultList $Entry.Note.Frontmatter 'aliases')
        openQuestions = @(Get-VaultOpenItems $Entry.Note 'Offene Fragen')
    }
}

$result.teilprojekte = @($selected.Teilprojekte | ForEach-Object { ConvertTo-TeilprojektInfo $_ })
$focus = $null
if ($null -ne $focusEntry) {
    $focus = $focusEntry.Name
    $focusInfo = ConvertTo-TeilprojektInfo $focusEntry
    $focusInfo.matchedBy = $focusMatchedBy
    $focusInfo.found = $true
    $result.teilprojekt = $focusInfo
}
elseif (-not [string]::IsNullOrWhiteSpace($Teilprojekt)) {
    $result.teilprojekt = [ordered]@{ name = $Teilprojekt.Trim(); found = $false }
}

function Test-InFocus {
    # Without focus every note counts; with focus the notes of that Teilprojekt and the notes without teilprojekt count.
    param($Note)

    if ($null -eq $focus) {
        return $true
    }

    $assigned = @(Get-VaultList $Note.Frontmatter 'teilprojekt')
    return $assigned.Count -eq 0 -or $assigned -icontains $focus
}

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
        if (-not (Test-InFocus $note)) {
            continue
        }

        $status = Get-VaultText $note.Frontmatter 'status'
        [ordered]@{
            path           = $file.FullName
            teilprojekt    = @(Get-VaultList $note.Frontmatter 'teilprojekt')
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
        if (-not (Test-InFocus $note)) {
            continue
        }

        [ordered]@{
            path            = $file.FullName
            teilprojekt     = @(Get-VaultList $note.Frontmatter 'teilprojekt')
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
        if (-not (Test-InFocus $note)) {
            continue
        }

        [ordered]@{
            path            = $file.FullName
            teilprojekt     = @(Get-VaultList $note.Frontmatter 'teilprojekt')
            title           = $file.BaseName
            status          = Get-VaultText $note.Frontmatter 'status'
            datum           = Get-VaultText $note.Frontmatter 'datum'
            matchesWorkItem = Test-WorkItemMatch $note $file.BaseName
        }
    })

$cutoff = $today.AddDays(-$Days)
$meetings = @(foreach ($file in Get-FolderNotes 'Meetings') {
        $note = Read-VaultNote $file.FullName
        if (-not (Test-InFocus $note)) {
            continue
        }

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
            teilprojekt     = @(Get-VaultList $note.Frontmatter 'teilprojekt')
            title           = ($file.BaseName -replace '^\d{4}-\d{2}-\d{2}\s+', '')
            datum           = $date.ToString('yyyy-MM-dd')
            matchesWorkItem = $matchesWorkItem
            openTodos       = @(Get-VaultOpenItems $note 'Todos')
            openQuestions   = @(Get-VaultOpenItems $note 'Offene Fragen')
        }
    })
$result.meetings = @($meetings | Sort-Object { $_.datum } -Descending)

$taskStatus = @('inbox', 'geplant', 'heute', 'archiv')
$tasks = @(foreach ($file in Get-FolderNotes 'Aufgaben') {
        $note = Read-VaultNote $file.FullName
        if ((Get-VaultText $note.Frontmatter 'typ') -ne 'aufgabe' -or -not (Test-InFocus $note)) {
            continue
        }

        $status = Get-VaultText $note.Frontmatter 'status'
        if ($status -ceq 'archiv') {
            continue
        }

        [ordered]@{
            path            = $file.FullName
            teilprojekt     = @(Get-VaultList $note.Frontmatter 'teilprojekt')
            title           = ($file.BaseName -replace '^\d{4}-\d{2}-\d{2}\s+', '')
            status          = $status
            statusValid     = $taskStatus -ccontains $status
            datum           = Get-VaultText $note.Frontmatter 'datum'
            faellig         = Get-VaultText $note.Frontmatter 'faellig'
            start           = Get-VaultText $note.Frontmatter 'start'
            quelle          = Get-VaultText $note.Frontmatter 'quelle'
            devops          = @(Get-VaultList $note.Frontmatter 'devops')
            matchesWorkItem = Test-WorkItemMatch $note $file.BaseName
        }
    })
# Due tasks first by due date, then the rest by creation date.
$result.tasks = @($tasks | Sort-Object @{ Expression = { if ($_.faellig) { 0 } else { 1 } } }, @{ Expression = { $_.faellig } }, @{ Expression = { $_.datum } })

function ConvertFrom-IcsText {
    param([string] $Value)

    return ($Value -replace '\\[nN]', ' ' -replace '\\([,;\\])', '$1').Trim()
}

function ConvertFrom-IcsTime {
    # Returns local time and whether the value is a date without time (all-day).
    param([string] $Parameters, [string] $Value)

    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    if ($Parameters -match 'VALUE=DATE(;|$)' -or $Value -match '^\d{8}$') {
        return [pscustomobject]@{ Time = [datetime]::ParseExact($Value.Substring(0, 8), 'yyyyMMdd', $culture); AllDay = $true }
    }

    if ($Value -match '^(\d{8}T\d{6})Z$') {
        $utc = [datetime]::ParseExact($Matches[1], 'yyyyMMddTHHmmss', $culture, [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal)
        return [pscustomobject]@{ Time = $utc.ToLocalTime(); AllDay = $false }
    }

    if ($Value -match '^(\d{8}T\d{6})$') {
        return [pscustomobject]@{ Time = [datetime]::ParseExact($Matches[1], 'yyyyMMddTHHmmss', $culture); AllDay = $false }
    }

    return $null
}

$calendarPath = Join-Path $vault '99-System\Kalender\outlook\outlook.ics'
if ($AppointmentDays -gt 0) {
    $result.calendar = [ordered]@{ path = $calendarPath; state = 'nicht vorhanden'; updated = $null; days = $AppointmentDays }
    if (Test-Path -LiteralPath $calendarPath -PathType Leaf) {
        $result.calendar.state = 'gelesen'
        $result.calendar.updated = (Get-Item -LiteralPath $calendarPath).LastWriteTime.ToString('yyyy-MM-ddTHH:mm')

        # RFC 5545 folds long lines; a continuation line starts with a space or tab.
        $lines = New-Object System.Collections.Generic.List[string]
        foreach ($line in [System.IO.File]::ReadAllLines($calendarPath, [System.Text.Encoding]::UTF8)) {
            if ($line -match '^[ \t]' -and $lines.Count -gt 0) {
                $lines[$lines.Count - 1] += $line.Substring(1)
            }
            else {
                $lines.Add($line)
            }
        }

        $events = New-Object System.Collections.Generic.List[object]
        $current = $null
        foreach ($line in $lines) {
            if ($line -eq 'BEGIN:VEVENT') {
                $current = @{}
                continue
            }

            if ($line -eq 'END:VEVENT') {
                if ($null -ne $current) { $events.Add($current) }
                $current = $null
                continue
            }

            if ($null -ne $current -and $line -match '^(SUMMARY|LOCATION|DTSTART|DTEND)((?:;[^:]*)?):(.*)$') {
                $current[$Matches[1]] = [pscustomobject]@{ Parameters = $Matches[2]; Value = $Matches[3] }
            }
        }

        $windowStart = $today
        $windowEnd = $today.AddDays($AppointmentDays + 1)
        $otherNames = @($profiles | Where-Object { $_.Place -ne $selected.Place } | ForEach-Object { $_.Names })
        $appointments = @(foreach ($event in $events) {
                if (-not $event.ContainsKey('DTSTART') -or -not $event.ContainsKey('SUMMARY')) {
                    continue
                }

                $start = ConvertFrom-IcsTime $event['DTSTART'].Parameters $event['DTSTART'].Value
                if ($null -eq $start -or $start.Time -lt $windowStart -or $start.Time -ge $windowEnd) {
                    continue
                }

                $summary = ConvertFrom-IcsText $event['SUMMARY'].Value
                $location = if ($event.ContainsKey('LOCATION')) { ConvertFrom-IcsText $event['LOCATION'].Value } else { '' }
                $text = "$summary $location"
                $hits = @(Get-VaultTermMatches $selected.Names $text)
                # A hit that is part of a longer matching name of another entry (Envitec in "Envitec Spanien") does not count.
                $longer = @(Get-VaultTermMatches $otherNames $text)
                $hits = @($hits | Where-Object {
                        $hit = $_
                        @($longer | Where-Object { $_.Length -gt $hit.Length -and $_.IndexOf($hit, [System.StringComparison]::OrdinalIgnoreCase) -ge 0 }).Count -eq 0
                    })
                if ($hits.Count -eq 0) {
                    continue
                }

                $end = if ($event.ContainsKey('DTEND')) { ConvertFrom-IcsTime $event['DTEND'].Parameters $event['DTEND'].Value } else { $null }
                $format = if ($start.AllDay) { 'yyyy-MM-dd' } else { 'yyyy-MM-ddTHH:mm' }
                $endTime = $null
                if ($null -ne $end) {
                    # The DTEND of an all-day event is exclusive.
                    $endTime = if ($end.AllDay) { $end.Time.AddDays(-1) } else { $end.Time }
                }

                [ordered]@{
                    betreff    = $summary
                    beginn     = $start.Time.ToString($format)
                    ende       = if ($null -ne $endTime) { $endTime.ToString($format) } else { $null }
                    ganztaegig = $start.AllDay
                    sortKey    = $start.Time
                }
            })
        $result.appointments = @($appointments | Sort-Object { $_.sortKey } | ForEach-Object { $_.Remove('sortKey'); $_ })
    }
}

$result | ConvertTo-Json -Depth 8
