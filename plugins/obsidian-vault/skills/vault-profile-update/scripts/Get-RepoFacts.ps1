<#
.SYNOPSIS
    Collects verifiable Business Central facts from local customer repositories for a vault fact sheet.

.DESCRIPTION
    Read-only: never fetches, checks out, or writes. Reads committed files from the remote default branch
    (origin/HEAD, origin/main, origin/master) or, when none exists, from HEAD. Accepts repository paths or
    parent folders and discovers Git repositories below them. Emits one JSON object with one entry per
    repository: remote, default ref, last commit, app.json facts, BC build artifact settings, and the
    state of an untracked plans folder. Secrets, SAS tokens, and download URLs are never emitted.

.EXAMPLE
    powershell -NoProfile -File Get-RepoFacts.ps1 -Path "C:\Dev\Customers\Assmann;C:\Dev\Customers\Spacemann\Spacemann Base App"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string[]] $Path,
    [string] $Ref,
    [int] $Depth = 3
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot '..\..\vault-note-write\scripts\VaultTools.ps1')
Set-VaultUtf8Output

function Get-Property {
    param($Object, [string] $Name)

    if ($null -ne $Object -and $Object.PSObject.Properties[$Name]) {
        return $Object.$Name
    }

    return $null
}

function Read-JsonAtRef {
    param([string] $Repository, [string] $RefName, [string] $File)

    $show = Invoke-VaultGit -RepositoryPath $Repository -Arguments @('show', "${RefName}:$File")
    if ($show.ExitCode -ne 0) {
        return $null
    }

    $json = ($show.Output -join "`n") -replace '(?m)^\s*//.*$', ''
    try {
        return $json | ConvertFrom-Json
    }
    catch {
        return [pscustomobject]@{ parseError = $_.Exception.Message }
    }
}

function Find-Repositories {
    param([string] $Root)

    $resolved = (Resolve-Path -LiteralPath $Root).ProviderPath
    $top = Invoke-VaultGit -RepositoryPath $resolved -Arguments @('rev-parse', '--show-toplevel')
    if ($top.ExitCode -eq 0 -and $top.Output.Count -gt 0) {
        return @($top.Output[0].Replace('/', '\'))
    }

    return @(Get-ChildItem -LiteralPath $resolved -Force -Recurse -Depth $Depth -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -eq '.git' } |
            ForEach-Object { Split-Path -Parent $_.FullName })
}

# powershell -File passes a list as one string; multiple paths are separated with ';'.
$roots = @($Path | ForEach-Object { $_ -split ';' } | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
$repositories = @($roots | ForEach-Object { Find-Repositories $_ } | Sort-Object -Unique)

$entries = foreach ($repository in $repositories) {
    $remoteResult = Invoke-VaultGit -RepositoryPath $repository -Arguments @('remote', 'get-url', 'origin')
    $remote = if ($remoteResult.ExitCode -eq 0 -and $remoteResult.Output.Count -gt 0) { $remoteResult.Output[0] -replace '^(https?://)[^/@]+@', '$1' } else { $null }

    $refName = $Ref
    $refSource = 'parameter'
    if (-not $refName) {
        $symbolic = Invoke-VaultGit -RepositoryPath $repository -Arguments @('symbolic-ref', '--short', 'refs/remotes/origin/HEAD')
        if ($symbolic.ExitCode -eq 0 -and $symbolic.Output.Count -gt 0) {
            $refName = $symbolic.Output[0]
            $refSource = 'origin-head'
        }
        else {
            foreach ($candidate in 'origin/main', 'origin/master') {
                if ((Invoke-VaultGit -RepositoryPath $repository -Arguments @('rev-parse', '--verify', '-q', $candidate)).ExitCode -eq 0) {
                    $refName = $candidate
                    $refSource = 'remote-default'
                    break
                }
            }
        }

        if (-not $refName) {
            $refName = 'HEAD'
            $refSource = 'local-head'
        }
    }

    $lastCommit = (Invoke-VaultGit -RepositoryPath $repository -Arguments @('log', '-1', '--format=%cs', $refName)).Output | Select-Object -First 1
    $files = (Invoke-VaultGit -RepositoryPath $repository -Arguments @('ls-tree', '-r', '--name-only', $refName)).Output |
        Where-Object { $_ -notmatch '(^|/)(\.alpackages|node_modules|\.alcache)/' }

    $apps = @(foreach ($file in @($files | Where-Object { $_ -match '(^|/)app\.json$' })) {
            $app = Read-JsonAtRef $repository $refName $file
            if ($null -eq $app) {
                continue
            }

            $dependencies = @(Get-Property $app 'dependencies' | Where-Object { $null -ne $_ } | ForEach-Object {
                    [ordered]@{ name = (Get-Property $_ 'name'); publisher = (Get-Property $_ 'publisher'); version = (Get-Property $_ 'version') }
                })
            $isTest = ($file -match '(^|/)tests?/') -or (@($dependencies | Where-Object { $_.name -in @('Test Runner', 'Library Assert') }).Count -gt 0)
            [ordered]@{
                file         = $file
                name         = Get-Property $app 'name'
                publisher    = Get-Property $app 'publisher'
                version      = Get-Property $app 'version'
                application  = Get-Property $app 'application'
                platform     = Get-Property $app 'platform'
                runtime      = Get-Property $app 'runtime'
                target       = Get-Property $app 'target'
                isTest       = $isTest
                idRanges     = @(Get-Property $app 'idRanges' | Where-Object { $null -ne $_ } | ForEach-Object { "$(Get-Property $_ 'from')-$(Get-Property $_ 'to')" })
                dependencies = $dependencies
                parseError   = Get-Property $app 'parseError'
            }
        })

    $build = @()
    if (@($files) -contains '.devops/cosmo.json') {
        $cosmo = Read-JsonAtRef $repository $refName '.devops/cosmo.json'
        $current = Get-Property (Get-Property $cosmo 'bcArtifacts') 'current'
        $build += [ordered]@{
            file    = '.devops/cosmo.json'
            version = Get-Property $current 'version'
            type    = Get-Property $current 'type'
            country = Get-Property $current 'country'
            note    = Get-Property (Get-Property $cosmo 'bcArtifacts') 'note'
        }
    }

    foreach ($file in @($files | Where-Object { $_ -eq '.github/AL-Go-Settings.json' -or $_ -match '(^|/)\.AL-Go/settings\.json$' })) {
        $settings = Read-JsonAtRef $repository $refName $file
        $build += [ordered]@{
            file        = $file
            artifact    = Get-Property $settings 'artifact'
            country     = Get-Property $settings 'country'
            repoVersion = Get-Property $settings 'repoVersion'
            type        = Get-Property $settings 'type'
        }
    }

    $plans = @(foreach ($candidate in 'plans', 'app\plans') {
            $plansPath = Join-Path $repository $candidate
            if (Test-Path -LiteralPath $plansPath -PathType Container) {
                $relativePlans = $candidate.Replace('\', '/')
                [ordered]@{
                    path    = (Get-Item -LiteralPath $plansPath).FullName
                    plans   = @(Get-ChildItem -LiteralPath $plansPath -Directory).Count
                    ignored = (Invoke-VaultGit -RepositoryPath $repository -Arguments @('check-ignore', '-q', $relativePlans)).ExitCode -eq 0
                    tracked = @((Invoke-VaultGit -RepositoryPath $repository -Arguments @('ls-files', $relativePlans)).Output).Count
                }
            }
        })

    [ordered]@{
        repository = $repository
        remote     = $remote
        ref        = $refName
        refSource  = $refSource
        lastCommit = $lastCommit
        apps       = $apps
        build      = $build
        plans      = $plans
    }
}

[ordered]@{
    readAt       = (Get-Date).ToString('yyyy-MM-dd')
    note         = 'Lokaler Stand ohne git fetch'
    repositories = @($entries)
} | ConvertTo-Json -Depth 8
