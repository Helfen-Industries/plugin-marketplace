# Shared helpers for the obsidian-vault scripts. Dot-source this file; it has no side effects.
# Compatible with Windows PowerShell 5.1 and PowerShell 7.

Set-StrictMode -Version Latest

$script:DefaultVaultRoot = 'C:\Dev\Knowledge'

function Set-VaultUtf8Output {
    try {
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    }
    catch {
        # No console attached; output encoding is controlled by the host.
    }
}

function Get-VaultRoot {
    param([string] $VaultRoot)

    if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
        $VaultRoot = $script:DefaultVaultRoot
    }

    $fullPath = [System.IO.Path]::GetFullPath($VaultRoot)
    $hasContract = Test-Path -LiteralPath (Join-Path $fullPath 'AGENTS.md') -PathType Leaf
    $hasCustomers = Test-Path -LiteralPath (Join-Path $fullPath 'Kunden') -PathType Container
    if ($hasContract -and $hasCustomers) {
        return $fullPath
    }

    return $null
}

function Invoke-VaultGit {
    # Native stderr must not terminate the caller under ErrorActionPreference = 'Stop' in Windows PowerShell 5.1.
    param(
        [Parameter(Mandatory)] [string] $RepositoryPath,
        [Parameter(Mandatory)] [string[]] $Arguments
    )

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git -C $RepositoryPath -c core.quotepath=off @Arguments 2>$null
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output   = [string[]] @($output | ForEach-Object { [string] $_ })
    }
}

function ConvertFrom-VaultScalar {
    param([string] $Value)

    $trimmed = $Value.Trim()
    if ($trimmed.Length -ge 2) {
        $first = $trimmed[0]
        $last = $trimmed[$trimmed.Length - 1]
        if (($first -eq '"' -and $last -eq '"') -or ($first -eq "'" -and $last -eq "'")) {
            $trimmed = $trimmed.Substring(1, $trimmed.Length - 2)
        }
    }

    return $trimmed
}

function ConvertFrom-VaultFrontmatter {
    # Supports the YAML subset written by Obsidian and the vault templates:
    # scalars, inline lists [a, b], and block lists (key: followed by "  - item").
    param([string[]] $Lines)

    $result = [ordered]@{}
    $currentKey = $null
    foreach ($line in $Lines) {
        if ($line -match '^\s*#' -or $line -match '^\s*$') {
            continue
        }

        if ($line -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
            $currentKey = $Matches[1]
            $raw = $Matches[2].Trim()
            if ($raw.StartsWith('[') -and $raw.EndsWith(']')) {
                $inner = $raw.Substring(1, $raw.Length - 2).Trim()
                if ($inner -eq '') {
                    $result[$currentKey] = [string[]] @()
                }
                else {
                    $result[$currentKey] = [string[]] @($inner -split ',' | ForEach-Object { ConvertFrom-VaultScalar $_ } | Where-Object { $_ -ne '' })
                }
            }
            else {
                $result[$currentKey] = ConvertFrom-VaultScalar $raw
            }

            continue
        }

        if ($null -ne $currentKey -and $line -match '^\s+-\s*(.*)$') {
            $item = ConvertFrom-VaultScalar $Matches[1]
            $existing = @($result[$currentKey] | Where-Object { $_ -ne '' })
            $result[$currentKey] = [string[]] @($existing + $item)
        }
    }

    return $result
}

function Get-VaultValue {
    param($Frontmatter, [string] $Key)

    if ($null -eq $Frontmatter -or -not $Frontmatter.Contains($Key)) {
        return $null
    }

    return $Frontmatter[$Key]
}

function Get-VaultText {
    # Returns a scalar frontmatter value as string; lists are joined, missing keys return ''.
    param($Frontmatter, [string] $Key)

    $value = Get-VaultValue $Frontmatter $Key
    if ($null -eq $value) {
        return ''
    }

    return ((@($value) | ForEach-Object { [string] $_ }) -join ', ').Trim()
}

function Get-VaultList {
    param($Frontmatter, [string] $Key)

    $value = Get-VaultValue $Frontmatter $Key
    if ($null -eq $value) {
        return [string[]] @()
    }

    return [string[]] @(@($value) | ForEach-Object { ([string] $_).Trim() } | Where-Object { $_ -ne '' })
}

function Read-VaultNote {
    param([Parameter(Mandatory)] [string] $Path)

    $text = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    $lines = [string[]] ($text -split "\r?\n")
    $frontmatter = $null
    $bodyStart = 0

    if ($lines.Count -gt 0 -and $lines[0] -eq '---') {
        for ($index = 1; $index -lt $lines.Count; $index++) {
            if ($lines[$index] -eq '---') {
                $headerLines = if ($index -gt 1) { $lines[1..($index - 1)] } else { [string[]] @() }
                $frontmatter = ConvertFrom-VaultFrontmatter -Lines $headerLines
                $bodyStart = $index + 1
                break
            }
        }
    }

    $sections = [ordered]@{ '' = New-Object System.Collections.Generic.List[string] }
    $bodyLines = New-Object System.Collections.Generic.List[object]
    $current = ''
    $inFence = $false
    for ($index = $bodyStart; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]
        $isFenceMarker = $line -match '^\s*(```|~~~)'
        if ($isFenceMarker) {
            $inFence = -not $inFence
        }

        if (-not $inFence -and -not $isFenceMarker -and $line -match '^##\s+(.+?)\s*$') {
            $current = $Matches[1]
            if (-not $sections.Contains($current)) {
                $sections[$current] = New-Object System.Collections.Generic.List[string]
            }

            continue
        }

        $sections[$current].Add($line)
        $bodyLines.Add([pscustomobject]@{ Number = $index + 1; Text = $line; Section = $current; InFence = ($inFence -or $isFenceMarker) })
    }

    return [pscustomobject]@{
        Path        = $Path
        Text        = $text
        Frontmatter = $frontmatter
        Sections    = $sections
        BodyLines   = $bodyLines
    }
}

function Get-VaultOpenItems {
    # Returns unchecked task texts from one H2 section; empty template placeholders are ignored.
    param($Note, [string] $Section)

    if (-not $Note.Sections.Contains($Section)) {
        return [string[]] @()
    }

    return [string[]] @($Note.Sections[$Section] | Where-Object { $_ -match '^\s*- \[ \]\s+\S' } | ForEach-Object { ($_ -replace '^\s*- \[ \]\s+', '').Trim() })
}

function ConvertTo-VaultDate {
    param([string] $Value)

    $parsed = [datetime]::MinValue
    if ($Value -match '^\d{4}-\d{2}-\d{2}$' -and [datetime]::TryParseExact($Value, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::None, [ref] $parsed)) {
        return $parsed
    }

    return $null
}

function Get-VaultRelativePath {
    param([string] $VaultRoot, [string] $Path)

    $root = $VaultRoot.TrimEnd('\', '/') + '\'
    if ($Path.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $Path.Substring($root.Length).Replace('\', '/')
    }

    return $Path.Replace('\', '/')
}
