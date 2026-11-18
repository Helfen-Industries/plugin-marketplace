<#
.SYNOPSIS
    Creates the scaffold for a new customer, internal project, or Teilprojekt in the vault.

.DESCRIPTION
    Implements the AGENTS.md sections "Struktur" and "Teilprojekte". When AGENTS.md changes, update the folder lists
    below; AGENTS.md wins on any disagreement.
    Kunde:       10-Kunden/<Name>/ with all subfolders (each with an empty .gitkeep) and 00-Steckbrief.md from 90-Templates/Steckbrief.md.
    Projekt:     20-Projekte/<Name>/ with its subfolders and 00-Steckbrief.md from 90-Templates/Projektsteckbrief.md.
    Teilprojekt: <Ort>/Teilprojekte/<Name>.md from 90-Templates/Teilprojekt.md for the customer or project named by -Owner;
                 adds the section "## Teilprojekte" with the embedded overview to the fact sheet when it is missing.
    Never overwrites an existing file or folder, never touches AGENTS.md, and never commits. It reports whether the
    name is listed in the "Kunden:" or "Projekte:" line of AGENTS.md so that the caller can propose the change.
    Writes one JSON object to stdout and exits with 1 unless status is created or planned.
    -DryRun lists what would be created without writing anything. Separate several -Aliases with ';'.

.EXAMPLE
    powershell -NoProfile -File New-VaultScaffold.ps1 -Type Teilprojekt -Name FLS -Owner Assmann -Aliases "FLS;Assmann FLS"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [ValidateSet('Kunde', 'Projekt', 'Teilprojekt')] [string] $Type,
    [Parameter(Mandatory)] [string] $Name,
    [string] $Owner,
    [string[]] $Aliases = @(),
    [string] $VaultRoot,
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\..\vault-note-write\scripts\VaultTools.ps1')
Set-VaultUtf8Output

# Subfolders from AGENTS.md "Struktur"; processes exist only for customers.
$customerFolders = @('Teilprojekte', 'Aufgaben', 'Entscheidungen', 'Konzepte', 'Meetings', 'Probleme', 'Prozesse', 'Sessions')
$projectFolders = @('Teilprojekte', 'Aufgaben', 'Entscheidungen', 'Konzepte', 'Meetings', 'Probleme', 'Sessions')
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
# powershell -File passes a list as one string; several aliases are separated with ';'.
$aliasList = @($Aliases | ForEach-Object { $_ -split ';' } | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
$created = New-Object System.Collections.Generic.List[string]
$notes = New-Object System.Collections.Generic.List[string]

function Write-Result {
    param([string] $Status, [string] $Message, $Extra = $null)

    $result = [ordered]@{ status = $Status; type = $Type; name = $Name; message = $Message }
    if ($null -ne $Extra) { foreach ($key in $Extra.Keys) { $result[$key] = $Extra[$key] } }
    $result.created = $created.ToArray()
    $result | ConvertTo-Json -Depth 5
    if ($Status -in @('created', 'planned')) { exit 0 }
    exit 1
}

function Add-Directory {
    param([string] $Directory, [bool] $WithKeep)

    if (-not (Test-Path -LiteralPath $Directory -PathType Container)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $Directory -Force | Out-Null }
        $created.Add((Get-VaultRelativePath $vault $Directory) + '/')
    }

    $keep = Join-Path $Directory '.gitkeep'
    if ($WithKeep -and -not (Test-Path -LiteralPath $keep)) {
        if (-not $DryRun) { [System.IO.File]::WriteAllText($keep, '', $utf8NoBom) }
        $created.Add((Get-VaultRelativePath $vault $keep))
    }
}

function Add-TextFile {
    # UTF-8 without BOM, LF line endings (.gitattributes).
    param([string] $FilePath, [string] $Text)

    if (-not $DryRun) {
        $lf = ($Text -replace "`r`n", "`n").TrimEnd("`n") + "`n"
        [System.IO.File]::WriteAllText($FilePath, $lf, $utf8NoBom)
    }

    $created.Add((Get-VaultRelativePath $vault $FilePath))
}

function Read-Template {
    param([string] $TemplateName)

    $templatePath = Join-Path $vault "90-Templates\$TemplateName"
    if (-not (Test-Path -LiteralPath $templatePath -PathType Leaf)) {
        Write-Result 'template-missing' "Template 90-Templates/$TemplateName fehlt."
    }

    return ([System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8) -replace "`r`n", "`n")
}

function Complete-Template {
    # Replaces the date and title tokens, drops single-line <!-- hints --> with the blank line after them, and fills aliases.
    param([string] $Text, [string] $Title)

    $today = (Get-Date).ToString('yyyy-MM-dd')
    $Text = $Text.Replace('{{date:YYYY-MM-DD}}', $today).Replace('{{title}}', $Title)
    $Text = [regex]::Replace($Text, '(?m)^[ \t]*<!--.*-->[ \t]*\n\n?', '')
    if ($aliasList.Count -gt 0) {
        $items = @($aliasList | ForEach-Object {
                if ($_ -match '^[\s\-?:\[\]{}#&*!|>''"%@`]' -or $_ -match '[:#\[\]{}]') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ }
            })
        $Text = $Text.Replace('aliases: []', 'aliases: [' + ($items -join ', ') + ']')
    }

    if ($Text -match '\{\{[^}]+\}\}') {
        Write-Result 'template-remnant' "Im Template bleibt ein Platzhalter: $($Matches[0])"
    }

    return $Text
}

function Get-AgentsListState {
    # Whether the name appears in the "Kunden:" or "Projekte:" line of AGENTS.md.
    param([string] $Label)

    $lines = [System.IO.File]::ReadAllLines((Join-Path $vault 'AGENTS.md'), [System.Text.Encoding]::UTF8)
    $line = $lines | Where-Object { $_ -match ('^' + $Label + ':') } | Select-Object -First 1
    $listed = $false
    if ($line) { $listed = [regex]::IsMatch($line, '`' + [regex]::Escape($Name) + '`') }
    return [ordered]@{ agentsMdLine = $Label; agentsMdListed = $listed }
}

$vault = Get-VaultRoot $VaultRoot
if ($null -eq $vault) {
    Write-Result 'vault-not-found' 'Vault nicht gefunden (AGENTS.md und 10-Kunden/ erwartet).'
}

$Name = $Name.Trim()
if ($Name -eq '' -or $Name -match '[\\/:*?"<>|#^\[\]]' -or $Name.StartsWith('.') -or $Name.EndsWith('.')) {
    Write-Result 'invalid' 'Der Name ist leer, enthaelt verbotene Zeichen (\ / : * ? " < > | # ^ [ ]) oder beginnt bzw. endet mit einem Punkt.'
}

if ($Type -eq 'Teilprojekt' -and $Name.Contains(',')) {
    Write-Result 'invalid' 'Der Name eines Teilprojekts darf kein Komma enthalten (YAML-Liste in teilprojekt).'
}

if (@($aliasList | Where-Object { $_.Contains(',') }).Count -gt 0) {
    Write-Result 'invalid' 'Ein Alias darf kein Komma enthalten (Liste in aliases); mehrere Aliase mit ; trennen.'
}

$existingOrte = @(foreach ($area in $script:VaultAreas) {
        $areaRoot = Join-Path $vault $area.Folder
        if (Test-Path -LiteralPath $areaRoot -PathType Container) {
            Get-ChildItem -LiteralPath $areaRoot -Directory | ForEach-Object { [pscustomobject]@{ Place = "$($area.Folder)/$($_.Name)"; Name = $_.Name; Field = $area.Field; Path = $_.FullName } }
        }
    })

if ($Type -ne 'Teilprojekt') {
    $area = if ($Type -eq 'Kunde') { $script:VaultAreas[0] } else { $script:VaultAreas[1] }
    $clash = @($existingOrte | Where-Object { $_.Name -ieq $Name })
    if ($clash.Count -gt 0) {
        Write-Result 'exists' "'$Name' gibt es bereits als $($clash[0].Place)/."
    }

    $folder = Join-Path (Join-Path $vault $area.Folder) $Name
    $subfolders = if ($Type -eq 'Kunde') { $customerFolders } else { $projectFolders }
    Add-Directory $folder $false
    foreach ($subfolder in $subfolders) { Add-Directory (Join-Path $folder $subfolder) $true }

    $templateName = if ($Type -eq 'Kunde') { 'Steckbrief.md' } else { 'Projektsteckbrief.md' }
    $text = Complete-Template (Read-Template $templateName) $Name
    $text = $text.Replace('<Ordnername unter 10-Kunden/>', $Name).Replace('<Ordnername unter 20-Projekte/>', $Name)
    $text = $text.Replace('# Steckbrief <Kunde>', "# Steckbrief $Name").Replace('# Steckbrief <Projekt>', "# Steckbrief $Name")
    Add-TextFile (Join-Path $folder '00-Steckbrief.md') $text

    $label = if ($Type -eq 'Kunde') { 'Kunden' } else { 'Projekte' }
    $status = if ($DryRun) { 'planned' } else { 'created' }
    Write-Result $status "$Type '$Name' angelegt." (Get-AgentsListState $label)
}

# Teilprojekt
if ([string]::IsNullOrWhiteSpace($Owner)) {
    Write-Result 'invalid' 'Fuer ein Teilprojekt fehlt -Owner (Ordnername des Kunden oder Projekts).'
}

$owners = @($existingOrte | Where-Object { $_.Name -ieq $Owner.Trim() })
if ($owners.Count -eq 0) {
    Write-Result 'owner-not-found' "'$Owner' gibt es weder unter 10-Kunden/ noch unter 20-Projekte/."
}

if ($owners.Count -gt 1) {
    Write-Result 'ambiguous' "'$Owner' gibt es unter 10-Kunden/ und 20-Projekte/; die Ablage ist nicht eindeutig." ([ordered]@{ candidates = @($owners | ForEach-Object { $_.Place }) })
}

$ort = $owners[0]
$teilprojektFolder = Join-Path $ort.Path 'Teilprojekte'
$startPage = Join-Path $teilprojektFolder "$Name.md"
$clashes = @(Get-ChildItem -LiteralPath $teilprojektFolder -Filter '*.md' -File -ErrorAction SilentlyContinue | Where-Object { $_.BaseName -ieq $Name })
if ($clashes.Count -gt 0) {
    Write-Result 'exists' "Das Teilprojekt '$Name' gibt es bereits: $($ort.Place)/Teilprojekte/$($clashes[0].Name)."
}

Add-Directory $teilprojektFolder $true
$text = Complete-Template (Read-Template 'Teilprojekt.md') $Name
$otherField = if ($ort.Field -eq 'kunde') { 'projekt' } else { 'kunde' }
$text = $text.Replace("`n${otherField}:`n", "`n").Replace("`n$($ort.Field):`n", "`n$($ort.Field): $($ort.Name)`n")
Add-TextFile $startPage $text

$profilePath = Join-Path $ort.Path '00-Steckbrief.md'
$profileState = 'nicht vorhanden'
if (Test-Path -LiteralPath $profilePath -PathType Leaf) {
    $profile = [System.IO.File]::ReadAllText($profilePath, [System.Text.Encoding]::UTF8) -replace "`r`n", "`n"
    if ($profile -match '(?m)^##\s+Teilprojekte\s*$') {
        $profileState = 'Abschnitt vorhanden'
    }
    else {
        # Insert after the "Ueberblick" section; without it before "Offene Fragen"; otherwise at the end.
        $section = "## Teilprojekte`n`n![[Teilprojekte.base]]`n`n"
        $overview = [regex]::Match($profile, '(?ms)^##\s+\u00dcberblick\s*$.*?(?=^##\s)')
        if ($overview.Success) {
            $profile = $profile.Insert($overview.Index + $overview.Length, $section)
        }
        else {
            $open = [regex]::Match($profile, '(?m)^##\s+Offene Fragen\s*$')
            if ($open.Success) { $profile = $profile.Insert($open.Index, $section) } else { $profile = $profile.TrimEnd("`n") + "`n`n" + $section.TrimEnd("`n") }
        }

        if (-not $DryRun) { [System.IO.File]::WriteAllText($profilePath, $profile, $utf8NoBom) }
        $profileState = 'Abschnitt Teilprojekte ergaenzt'
        $notes.Add((Get-VaultRelativePath $vault $profilePath))
    }
}

$status = if ($DryRun) { 'planned' } else { 'created' }
Write-Result $status "Teilprojekt '$Name' bei $($ort.Place) angelegt." ([ordered]@{ owner = $ort.Place; steckbrief = $profileState; changedNotes = $notes.ToArray() })
