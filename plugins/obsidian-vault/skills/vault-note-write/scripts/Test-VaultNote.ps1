<#
.SYNOPSIS
    Checks vault notes against the conventions in the vault's AGENTS.md.

.DESCRIPTION
    Read-only. Implements the AGENTS.md sections "Dateinamen", "Frontmatter", "Todos und offene Fragen",
    and "Verknüpfungen". When AGENTS.md changes, update this script; AGENTS.md wins on any disagreement.
    Without -Path, checks every note under Kunden/, daily/, and _inbox/. Separate several -Path values with ';'.
    Writes one JSON object to stdout and exits with 1 when errors exist.

.EXAMPLE
    powershell -NoProfile -File Test-VaultNote.ps1 -Path "C:\Dev\Knowledge\Kunden\Assmann\Meetings\2026-11-12 Abstimmung.md"
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

function Add-Finding {
    param($List, [string] $File, [string] $Rule, [string] $Message)
    $List.Add([ordered]@{ path = (Get-VaultRelativePath $vault $File); rule = $Rule; message = $Message })
}

$allowedTypes = @('steckbrief', 'meeting', 'konzept', 'entscheidung', 'prozess', 'daily', 'notiz')
$allowedStatus = @{
    steckbrief   = @('aktiv', 'ruhend', 'abgeschlossen')
    konzept      = @('entwurf', 'abgestimmt', 'umgesetzt', 'verworfen')
    entscheidung = @('vorgeschlagen', 'akzeptiert', 'abgelöst', 'verworfen')
    prozess      = @('ist', 'soll')
}
$expectedTypeByFolder = @{ Meetings = 'meeting'; Konzepte = 'konzept'; Entscheidungen = 'entscheidung'; Prozesse = 'prozess' }
$today = (Get-Date).Date

$excludedRoots = @('.git', '.obsidian', '.trash', '_templates', 'Excalidraw')
$vaultFiles = @(Get-ChildItem -LiteralPath $vault -File -Recurse | Where-Object {
        $relative = Get-VaultRelativePath $vault $_.FullName
        $top = ($relative -split '/')[0]
        $excludedRoots -notcontains $top
    })

$linkIndex = @{}
foreach ($file in $vaultFiles) {
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
    $targets = @(foreach ($entry in $paths) {
            $item = Get-Item -LiteralPath $entry
            if ($item.PSIsContainer) {
                Get-ChildItem -LiteralPath $item.FullName -Filter '*.md' -File -Recurse
            }
            else {
                $item
            }
        })
}
else {
    $targets = @($vaultFiles | Where-Object {
            $top = ((Get-VaultRelativePath $vault $_.FullName) -split '/')[0]
            $_.Extension -eq '.md' -and $top -in @('Kunden', 'daily', '_inbox')
        })
}

$targets = @($targets | Where-Object { $_.Name -notlike '*.excalidraw.md' })
$adrNumbers = @{}

foreach ($file in $targets) {
    $relative = Get-VaultRelativePath $vault $file.FullName
    $parts = $relative -split '/'
    $name = $file.Name
    $base = $file.BaseName

    $location = 'other'
    $customerFolder = $null
    if ($parts[0] -eq 'Kunden' -and $parts.Count -eq 3 -and $name -eq '00-Steckbrief.md') {
        $location = 'steckbrief'
        $customerFolder = $parts[1]
    }
    elseif ($parts[0] -eq 'Kunden' -and $parts.Count -eq 4 -and $expectedTypeByFolder.ContainsKey($parts[2])) {
        $location = $expectedTypeByFolder[$parts[2]]
        $customerFolder = $parts[1]
    }
    elseif ($parts[0] -eq 'daily' -and $parts.Count -eq 2) {
        $location = 'daily'
    }
    elseif ($parts[0] -eq '_inbox' -and $parts.Count -eq 2) {
        $location = 'inbox'
    }

    if ($location -eq 'other') {
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
    elseif ($location -notin @('inbox', 'other') -and $type -ne $location) {
        Add-Finding $errors $file.FullName 'typ' "typ '$type' passt nicht zum Ablageort ($location)."
    }

    $effectiveType = if ($allowedTypes -contains $type) { $type } else { $location }
    $customer = Get-VaultText $frontmatter 'kunde'
    if ($effectiveType -ne 'daily') {
        if ($customer -eq '') {
            $list = if ($location -eq 'inbox') { $warnings } else { $errors }
            Add-Finding $list $file.FullName 'kunde' 'kunde fehlt.'
        }
        elseif ($null -ne $customerFolder -and $customer -cne $customerFolder) {
            Add-Finding $errors $file.FullName 'kunde' "kunde '$customer' entspricht nicht dem Ordnernamen '$customerFolder'."
        }
        elseif ($location -eq 'inbox' -and -not (Test-Path -LiteralPath (Join-Path $vault "Kunden\$customer") -PathType Container)) {
            Add-Finding $warnings $file.FullName 'kunde' "kunde '$customer' hat keinen Ordner unter Kunden/."
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
            Add-Finding $warnings $file.FullName 'aliases' 'aliases ist leer; die Kundenzuordnung nutzt aliases.'
        }
    }

    if ($allowedStatus.ContainsKey($effectiveType)) {
        $status = Get-VaultText $frontmatter 'status'
        if ($allowedStatus[$effectiveType] -notcontains $status) {
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

    foreach ($id in @(Get-VaultList $frontmatter 'devops')) {
        if ($id -notmatch '^\d+$') {
            Add-Finding $warnings $file.FullName 'devops' "devops-Eintrag '$id' ist keine Work-Item-ID."
        }
    }

    switch ($location) {
        'meeting' {
            if ($name -notmatch '^(\d{4}-\d{2}-\d{2}) .+\.md$') { Add-Finding $errors $file.FullName 'filename' 'Muster: YYYY-MM-DD <Titel>.md' }
            elseif ($Matches[1] -ne $datum) { Add-Finding $warnings $file.FullName 'filename-date' "Datum im Dateinamen ($($Matches[1])) weicht von datum ($datum) ab." }
        }
        'inbox' {
            if ($name -notmatch '^(\d{4}-\d{2}-\d{2}) .+\.md$') { Add-Finding $errors $file.FullName 'filename' 'Muster: YYYY-MM-DD <Titel>.md' }
        }
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

                $key = "$customerFolder|$fileNumber"
                if ($adrNumbers.ContainsKey($key)) {
                    Add-Finding $errors $file.FullName 'adr-duplicate' "ADR-$fileNumber ist bei $customerFolder doppelt vergeben ($($adrNumbers[$key]))."
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
    errors    = $errors.ToArray()
    warnings  = $warnings.ToArray()
    info      = $info.ToArray()
}
$result | ConvertTo-Json -Depth 5
if ($errors.Count -gt 0) {
    exit 1
}
