<#
.SYNOPSIS
    Checks vault notes against the conventions in the vault's AGENTS.md.

.DESCRIPTION
    Read-only. Implements the AGENTS.md sections "Struktur", "Dateinamen", "Frontmatter", "Todos und offene Fragen",
    "Aufgaben", and "Verknüpfungen". When AGENTS.md changes, update this script; AGENTS.md wins on any disagreement.
    Without -Path, checks every note under 00-Inbox/, 10-Kunden/, 20-Projekte/, 30-Agents/, and 80-Daily/.
    System files are never checked and are listed under "skipped" when passed explicitly: the root files
    AGENTS.md, Dashboard.md, and Task Board.base, every non-Markdown file, Excalidraw drawings, and everything under
    90-Templates/, 99-System/ (including the generated calendar), and Excalidraw/.
    Separate several -Path values with ';'. Writes one JSON object to stdout and exits with 1 when errors exist.

.EXAMPLE
    powershell -NoProfile -File Test-VaultNote.ps1 -Path "C:\Dev\Knowledge\10-Kunden\Assmann\Meetings\2026-11-12 Abstimmung.md"
#>
[CmdletBinding()]
param(
    [string] $VaultRoot,
    [string[]] $Path,
    [int] $StaleDays = 90,
    [int] $OpenItemDays = 30
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'VaultTools.ps1')
Set-VaultUtf8Output

$vault = Get-VaultRoot $VaultRoot
if ($null -eq $vault) {
    [ordered]@{ status = 'vault-not-found'; vaultRoot = $VaultRoot } | ConvertTo-Json
    exit 1
}

$errors = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[object]
$info = New-Object System.Collections.Generic.List[object]
$skipped = New-Object System.Collections.Generic.List[string]

function Add-Finding {
    param($List, [string] $File, [string] $Rule, [string] $Message)
    $List.Add([ordered]@{ path = (Get-VaultRelativePath $vault $File); rule = $Rule; message = $Message })
}

$contentRoots = @('00-Inbox', '10-Kunden', '20-Projekte', '30-Agents', '80-Daily')
$hiddenRoots = @('.git', '.obsidian', '.trash')
$systemRoots = @('90-Templates', '99-System', 'Excalidraw')
$rootSystemFiles = @('AGENTS.md', 'Dashboard.md', 'Task Board.base')

$allowedTypes = @('steckbrief', 'meeting', 'konzept', 'entscheidung', 'prozess', 'aufgabe', 'problem', 'session', 'katalog', 'anweisung', 'learning', 'daily', 'notiz')
$allowedStatus = @{
    steckbrief   = @('aktiv', 'ruhend', 'abgeschlossen')
    konzept      = @('entwurf', 'abgestimmt', 'umgesetzt', 'verworfen')
    entscheidung = @('vorgeschlagen', 'akzeptiert', 'abgelöst', 'verworfen')
    prozess      = @('ist', 'soll')
    problem      = @('offen', 'in-analyse', 'zurückgestellt', 'gelöst')
    aufgabe      = @('inbox', 'geplant', 'heute', 'archiv')
}
$placeFolderTypes = @{ Meetings = 'meeting'; Konzepte = 'konzept'; Entscheidungen = 'entscheidung'; Aufgaben = 'aufgabe'; Probleme = 'problem'; Sessions = 'session' }
$customerOnlyFolderTypes = @{ Prozesse = 'prozess' }
$agentFolderTypes = @{ Anweisungen = 'anweisung'; Learnings = 'learning'; Sessions = 'session' }
$datedFileTypes = @('meeting', 'aufgabe', 'problem', 'session')
$taskSources = @('mail', 'devops', 'meeting', 'manuell')
$mailFields = @('mail-von', 'mail-datum', 'mail-betreff', 'mail-id')
$unknownValue = 'offen'
$today = (Get-Date).Date

function Test-SystemFile {
    param([string] $Relative, [string] $Extension, [string] $Name)

    $parts = $Relative -split '/'
    if ($parts.Count -eq 1 -and $rootSystemFiles -contains $parts[0]) { return $true }
    if ($hiddenRoots -contains $parts[0] -or $systemRoots -contains $parts[0]) { return $true }
    return $Extension -ne '.md' -or $Name -like '*.excalidraw.md'
}

function Get-NoteLocation {
    # Type the folder implies, plus the owning customer or project for notes under 10-Kunden/ or 20-Projekte/.
    param([string[]] $Parts, [string] $Name)

    $location = [ordered]@{ Type = 'other'; Area = $null; Owner = $null; Place = $null }
    $area = @($script:VaultAreas | Where-Object { $_.Folder -eq $Parts[0] })
    if ($area.Count -eq 1) {
        $location.Area = $area[0].Field
        if ($Parts.Count -ge 3) {
            $location.Owner = $Parts[1]
            $location.Place = "$($Parts[0])/$($Parts[1])"
        }

        if ($Parts.Count -eq 3 -and $Name -eq '00-Steckbrief.md') {
            $location.Type = 'steckbrief'
        }
        elseif ($Parts.Count -eq 4 -and $placeFolderTypes.ContainsKey($Parts[2])) {
            $location.Type = $placeFolderTypes[$Parts[2]]
        }
        elseif ($Parts.Count -eq 4 -and $area[0].Field -eq 'kunde' -and $customerOnlyFolderTypes.ContainsKey($Parts[2])) {
            $location.Type = $customerOnlyFolderTypes[$Parts[2]]
        }
    }
    elseif ($Parts[0] -eq '30-Agents') {
        $location.Area = 'agents'
        if ($Parts.Count -eq 2 -and $Name -eq '00-Katalog.md') {
            $location.Type = 'katalog'
        }
        elseif ($Parts.Count -eq 3 -and $agentFolderTypes.ContainsKey($Parts[1])) {
            $location.Type = $agentFolderTypes[$Parts[1]]
        }
    }
    elseif ($Parts[0] -eq '80-Daily' -and $Parts.Count -eq 2) {
        $location.Type = 'daily'
        $location.Area = 'daily'
    }
    elseif ($Parts[0] -eq '00-Inbox' -and $Parts.Count -eq 2) {
        $location.Type = 'inbox'
        $location.Area = 'inbox'
    }

    return [pscustomobject] $location
}

$linkFiles = @(Get-ChildItem -LiteralPath $vault -File -Recurse | Where-Object {
        $hiddenRoots -notcontains ((Get-VaultRelativePath $vault $_.FullName) -split '/')[0]
    })

$linkIndex = @{}
foreach ($file in $linkFiles) {
    $relative = Get-VaultRelativePath $vault $file.FullName
    $keys = @($relative.ToLowerInvariant(), $file.Name.ToLowerInvariant())
    if ($file.Extension -eq '.md') {
        $keys += @(($relative -replace '\.md$', '').ToLowerInvariant(), $file.BaseName.ToLowerInvariant())
    }

    foreach ($key in $keys) {
        $linkIndex[$key] = $true
    }
}

if ($Path) {
    # powershell -File passes a list as one string; multiple paths are separated with ';'.
    $paths = @($Path | ForEach-Object { $_ -split ';' } | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    $candidates = @(foreach ($entry in $paths) {
            $item = Get-Item -LiteralPath $entry
            if ($item.PSIsContainer) {
                Get-ChildItem -LiteralPath $item.FullName -File -Recurse
            }
            else {
                $item
            }
        })
}
else {
    $candidates = @(foreach ($root in $contentRoots) {
            $rootPath = Join-Path $vault $root
            if (Test-Path -LiteralPath $rootPath -PathType Container) {
                Get-ChildItem -LiteralPath $rootPath -File -Recurse
            }
        })
}

$targets = @(foreach ($file in $candidates) {
        $relative = Get-VaultRelativePath $vault $file.FullName
        if (Test-SystemFile $relative $file.Extension $file.Name) {
            if ($Path -and $file.Name -ne '.gitkeep') {
                $skipped.Add($relative)
            }

            continue
        }

        $file
    })
$adrNumbers = @{}

foreach ($file in $targets) {
    $relative = Get-VaultRelativePath $vault $file.FullName
    $parts = $relative -split '/'
    $name = $file.Name
    $base = $file.BaseName
    $location = Get-NoteLocation $parts $name

    if ($location.Type -eq 'other') {
        Add-Finding $warnings $file.FullName 'location' 'Ablageort entspricht keiner Struktur aus AGENTS.md.'
    }

    if ($name -match '[#^\[\]]') {
        Add-Finding $errors $file.FullName 'filename-chars' 'Dateiname enthält verbotene Zeichen (# ^ [ ]).'
    }

    $note = Read-VaultNote $file.FullName
    $frontmatter = $note.Frontmatter
    if ($null -eq $frontmatter) {
        Add-Finding $errors $file.FullName 'frontmatter' 'Frontmatter fehlt.'
        continue
    }

    $type = Get-VaultText $frontmatter 'typ'
    if ($allowedTypes -notcontains $type) {
        Add-Finding $errors $file.FullName 'typ' "typ '$type' ist nicht erlaubt."
    }
    elseif ($location.Type -notin @('inbox', 'other') -and $type -ne $location.Type) {
        Add-Finding $errors $file.FullName 'typ' "typ '$type' passt nicht zum Ablageort ($($location.Type))."
    }

    $effectiveType = if ($allowedTypes -contains $type) { $type } else { $location.Type }

    $customer = Get-VaultText $frontmatter 'kunde'
    $project = Get-VaultText $frontmatter 'projekt'
    if ($customer -ne '' -and $project -ne '') {
        Add-Finding $errors $file.FullName 'zuordnung' 'kunde und projekt sind beide gesetzt; erlaubt ist genau eines.'
    }

    switch ($location.Area) {
        { $_ -in @('kunde', 'projekt') } {
            $field = $location.Area
            $other = if ($field -eq 'kunde') { 'projekt' } else { 'kunde' }
            $value = if ($field -eq 'kunde') { $customer } else { $project }
            $otherValue = if ($field -eq 'kunde') { $project } else { $customer }
            if ($otherValue -ne '' -and $value -eq '') {
                Add-Finding $errors $file.FullName $field "$other ist unter $($parts[0])/ nicht erlaubt; dort gilt $field."
            }
            elseif ($value -eq '') {
                Add-Finding $errors $file.FullName $field "$field fehlt."
            }
            elseif ($null -ne $location.Owner -and $value -cne $location.Owner) {
                Add-Finding $errors $file.FullName $field "$field '$value' entspricht nicht dem Ordnernamen '$($location.Owner)'."
            }
        }
        { $_ -in @('inbox', 'agents') } {
            if ($location.Area -eq 'inbox' -and $customer -eq '' -and $project -eq '') {
                Add-Finding $warnings $file.FullName 'zuordnung' 'kunde bzw. projekt fehlt.'
            }

            if ($customer -ne '' -and -not (Test-Path -LiteralPath (Join-Path $vault "10-Kunden\$customer") -PathType Container)) {
                Add-Finding $warnings $file.FullName 'kunde' "kunde '$customer' hat keinen Ordner unter 10-Kunden/."
            }

            if ($project -ne '' -and -not (Test-Path -LiteralPath (Join-Path $vault "20-Projekte\$project") -PathType Container)) {
                Add-Finding $warnings $file.FullName 'projekt' "projekt '$project' hat keinen Ordner unter 20-Projekte/."
            }
        }
    }

    $datum = Get-VaultText $frontmatter 'datum'
    $date = ConvertTo-VaultDate $datum
    if ($effectiveType -ne 'steckbrief' -and $null -eq $date) {
        Add-Finding $errors $file.FullName 'datum' 'datum fehlt oder ist nicht YYYY-MM-DD.'
    }

    if ($effectiveType -eq 'steckbrief') {
        $stand = ConvertTo-VaultDate (Get-VaultText $frontmatter 'stand')
        if ($null -eq $stand) {
            Add-Finding $errors $file.FullName 'stand' 'stand fehlt oder ist nicht YYYY-MM-DD.'
        }
        elseif (($today - $stand).TotalDays -gt $StaleDays) {
            Add-Finding $info $file.FullName 'stale' "Steckbrief seit $([int] ($today - $stand).TotalDays) Tagen nicht geprüft."
        }

        if (@(Get-VaultList $frontmatter 'aliases').Count -eq 0) {
            Add-Finding $warnings $file.FullName 'aliases' 'aliases ist leer; die Zuordnung zu Kunde bzw. Projekt nutzt aliases.'
        }
    }

    if ($allowedStatus.ContainsKey($effectiveType)) {
        $status = Get-VaultText $frontmatter 'status'
        if ($allowedStatus[$effectiveType] -cnotcontains $status) {
            Add-Finding $errors $file.FullName 'status' "status '$status' ist für $effectiveType nicht erlaubt ($($allowedStatus[$effectiveType] -join ', '))."
        }
    }

    $tags = @(Get-VaultList $frontmatter 'tags')
    if ($tags.Count -eq 0) {
        Add-Finding $errors $file.FullName 'tags' 'tags fehlt.'
    }
    elseif ($tags -notcontains $effectiveType) {
        Add-Finding $warnings $file.FullName 'tags' "tags enthält den typ '$effectiveType' nicht."
    }

    $devopsIds = @(Get-VaultList $frontmatter 'devops')
    foreach ($id in $devopsIds) {
        if ($id -notmatch '^\d+$' -and $id -ne $unknownValue) {
            Add-Finding $warnings $file.FullName 'devops' "devops-Eintrag '$id' ist keine Work-Item-ID."
        }
    }

    $source = Get-VaultText $frontmatter 'quelle'
    if ($effectiveType -eq 'aufgabe') {
        if ($taskSources -cnotcontains $source) {
            Add-Finding $errors $file.FullName 'quelle' "quelle '$source' ist für aufgabe nicht erlaubt ($($taskSources -join ', '))."
        }

        foreach ($field in 'faellig', 'erledigt') {
            $value = Get-VaultText $frontmatter $field
            if ($value -ne '' -and $null -eq (ConvertTo-VaultDate $value)) {
                Add-Finding $errors $file.FullName $field "$field '$value' ist nicht YYYY-MM-DD."
            }
        }

        $blockStart = $null
        foreach ($field in 'start', 'ende') {
            $value = Get-VaultText $frontmatter $field
            $parsed = ConvertTo-VaultDateTime $value
            if ($value -ne '' -and $null -eq $parsed) {
                Add-Finding $errors $file.FullName $field "$field '$value' ist nicht YYYY-MM-DDTHH:mm."
            }
            elseif ($field -eq 'start') {
                $blockStart = $parsed
            }
            elseif ($null -ne $parsed -and $null -ne $blockStart -and $parsed -le $blockStart) {
                Add-Finding $warnings $file.FullName 'ende' 'ende liegt nicht nach start.'
            }
        }

        if ($source -eq 'devops') {
            if ($devopsIds.Count -eq 0) {
                Add-Finding $errors $file.FullName 'devops' 'devops fehlt bei quelle: devops.'
            }

            if ((Get-VaultText $frontmatter 'devops-link') -eq '') {
                Add-Finding $errors $file.FullName 'devops-link' 'devops-link fehlt bei quelle: devops.'
            }
        }

        if (-not $note.Sections.Contains('Auftrag')) {
            Add-Finding $warnings $file.FullName 'auftrag' "Abschnitt '## Auftrag' fehlt."
        }
    }

    if ($source -eq 'mail') {
        foreach ($field in $mailFields) {
            if ((Get-VaultText $frontmatter $field) -eq '') {
                Add-Finding $errors $file.FullName 'mail' "$field fehlt bei quelle: mail (unbekannt: '$unknownValue')."
            }
        }

        $mailDate = Get-VaultText $frontmatter 'mail-datum'
        if ($mailDate -notin @('', $unknownValue) -and $null -eq (ConvertTo-VaultDateTime $mailDate)) {
            Add-Finding $errors $file.FullName 'mail-datum' "mail-datum '$mailDate' ist nicht YYYY-MM-DDTHH:mm."
        }
    }

    if ($location.Type -in $datedFileTypes -or $location.Type -eq 'inbox') {
        if ($name -notmatch '^(\d{4}-\d{2}-\d{2}) .+\.md$') {
            Add-Finding $errors $file.FullName 'filename' 'Muster: YYYY-MM-DD <Titel>.md'
        }
        elseif ($location.Type -ne 'inbox' -and $Matches[1] -ne $datum) {
            Add-Finding $warnings $file.FullName 'filename-date' "Datum im Dateinamen ($($Matches[1])) weicht von datum ($datum) ab."
        }
    }

    switch ($location.Type) {
        'daily' {
            if ($name -notmatch '^(\d{4}-\d{2}-\d{2})\.md$') { Add-Finding $errors $file.FullName 'filename' 'Muster: YYYY-MM-DD.md' }
            elseif ($Matches[1] -ne $datum) { Add-Finding $warnings $file.FullName 'filename-date' "Datum im Dateinamen ($($Matches[1])) weicht von datum ($datum) ab." }
        }
        'prozess' {
            if ($base -notmatch '^.+ - .+$') { Add-Finding $errors $file.FullName 'filename' 'Muster: <Bereich> - <Prozess>.md' }
        }
        'entscheidung' {
            $adr = Get-VaultText $frontmatter 'adr'
            if ($name -notmatch '^ADR-(\d{4}) .+\.md$') {
                Add-Finding $errors $file.FullName 'filename' 'Muster: ADR-NNNN <Titel>.md'
            }
            else {
                $fileNumber = $Matches[1]
                if ($adr -ne $fileNumber) {
                    Add-Finding $errors $file.FullName 'adr' "adr '$adr' entspricht nicht der Nummer im Dateinamen ($fileNumber)."
                }

                $key = "$($location.Place)|$fileNumber"
                if ($adrNumbers.ContainsKey($key)) {
                    Add-Finding $errors $file.FullName 'adr-duplicate' "ADR-$fileNumber ist bei $($location.Place) doppelt vergeben ($($adrNumbers[$key]))."
                }
                else {
                    $adrNumbers[$key] = $name
                }
            }
        }
    }

    $hasTemplateRemnant = @($note.BodyLines | Where-Object { -not $_.InFence -and ($_.Text -match '\{\{[^}]+\}\}' -or $_.Text -match '<!--') }).Count -gt 0
    if ($hasTemplateRemnant) {
        Add-Finding $warnings $file.FullName 'template' 'Vorlagenreste ({{…}} oder <!-- Hinweis -->) vorhanden.'
    }

    $openItems = 0
    foreach ($line in $note.BodyLines) {
        if ($line.InFence -or $line.Text -notmatch '^\s*- \[[ xX]\]') {
            continue
        }

        if ($line.Section -notin @('Todos', 'Offene Fragen')) {
            Add-Finding $warnings $file.FullName 'checkbox' "Checkbox außerhalb von '## Todos'/'## Offene Fragen' (Zeile $($line.Number))."
        }

        if ($line.Text -match '^\s*- \[ \]\s+\S') {
            $openItems++
        }
    }

    if ($openItems -gt 0 -and $null -ne $date -and ($today - $date).TotalDays -gt $OpenItemDays) {
        Add-Finding $info $file.FullName 'open-items' "$openItems offene Punkte in einer Notiz vom $datum."
    }

    foreach ($line in $note.BodyLines) {
        if ($line.InFence) {
            continue
        }

        foreach ($match in [regex]::Matches($line.Text, '!?\[\[([^\]]+)\]\]')) {
            # Inside Markdown tables the alias separator is escaped as \|.
            $target = ($match.Groups[1].Value -split '\\?\|')[0]
            $target = ($target -split '#')[0].Trim()
            if ($target -eq '') {
                continue
            }

            if (-not $linkIndex.ContainsKey($target.ToLowerInvariant())) {
                Add-Finding $warnings $file.FullName 'link' "Link-Ziel '$target' nicht gefunden (Zeile $($line.Number))."
            }
        }
    }
}

$result = [ordered]@{
    status    = if ($errors.Count -gt 0) { 'failed' } else { 'passed' }
    vaultRoot = $vault
    checked   = $targets.Count
    skipped   = $skipped.ToArray()
    errors    = $errors.ToArray()
    warnings  = $warnings.ToArray()
    info      = $info.ToArray()
}
$result | ConvertTo-Json -Depth 5
if ($errors.Count -gt 0) {
    exit 1
}
