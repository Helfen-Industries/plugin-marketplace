[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Condition {
    param(
        [Parameter(Mandatory)]
        [bool] $Condition,

        [Parameter(Mandatory)]
        [string] $Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Read-JsonFile {
    param(
        [Parameter(Mandatory)]
        [string] $Path
    )

    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
        throw "Invalid JSON in '$Path': $($_.Exception.Message)"
    }
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$marketplacePath = Join-Path $repositoryRoot '.github/plugin/marketplace.json'
$expectedSchema = 'https://agent-plugins.org/schemas/1.0.0/plugin.schema.json'
$semanticVersionPattern = '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$'
$skillNamePattern = '^[a-z0-9]+(?:-[a-z0-9]+)*$'

Assert-Condition (Test-Path -LiteralPath $marketplacePath -PathType Leaf) "Marketplace manifest not found: $marketplacePath"

$marketplace = Read-JsonFile $marketplacePath
Assert-Condition ($marketplace.name -match $skillNamePattern) 'Marketplace name must use kebab-case.'
Assert-Condition (-not [string]::IsNullOrWhiteSpace($marketplace.owner.name)) 'Marketplace owner name is required.'
Assert-Condition ($marketplace.plugins.Count -gt 0) 'Marketplace must contain at least one plugin.'

$repositoryPrefix = [System.IO.Path]::GetFullPath($repositoryRoot).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
$pluginNames = @{}
$skillCount = 0
$evalCount = 0

foreach ($entry in $marketplace.plugins) {
    Assert-Condition ($entry.name -match $skillNamePattern) "Invalid plugin name '$($entry.name)'."
    Assert-Condition (-not $pluginNames.ContainsKey($entry.name)) "Duplicate plugin name '$($entry.name)'."
    $pluginNames[$entry.name] = $true

    Assert-Condition ($entry.source -is [string]) "Plugin '$($entry.name)' must use a relative local source in this marketplace."
    Assert-Condition (-not [System.IO.Path]::IsPathRooted($entry.source)) "Plugin '$($entry.name)' source must be relative."
    Assert-Condition (-not ($entry.source -split '[/\\]' -contains '..')) "Plugin '$($entry.name)' source must not traverse parent directories."

    $pluginRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot $entry.source))
    Assert-Condition ($pluginRoot.StartsWith($repositoryPrefix, [System.StringComparison]::OrdinalIgnoreCase)) "Plugin '$($entry.name)' source escapes the repository."
    Assert-Condition (Test-Path -LiteralPath $pluginRoot -PathType Container) "Plugin source not found: $pluginRoot"

    $pluginManifestPath = Join-Path $pluginRoot 'plugin.json'
    Assert-Condition (Test-Path -LiteralPath $pluginManifestPath -PathType Leaf) "Plugin manifest not found: $pluginManifestPath"
    $plugin = Read-JsonFile $pluginManifestPath

    Assert-Condition ($plugin.'$schema' -eq $expectedSchema) "Plugin '$($entry.name)' must use Agent Plugins 1.0."
    Assert-Condition ($plugin.name -eq $entry.name) "Plugin name differs between marketplace and plugin manifest."
    Assert-Condition ($plugin.version -eq $entry.version) "Plugin version differs between marketplace and plugin manifest."
    Assert-Condition ($plugin.version -match $semanticVersionPattern) "Plugin '$($entry.name)' version is not semantic."
    Assert-Condition ($plugin.license -eq 'MIT') "Plugin '$($entry.name)' must declare the MIT license."

    $skillsRoot = Join-Path $pluginRoot 'skills'
    Assert-Condition (Test-Path -LiteralPath $skillsRoot -PathType Container) "Plugin '$($entry.name)' has no skills directory."
    $skillNames = @{}

    foreach ($skillFile in Get-ChildItem -LiteralPath $skillsRoot -Filter 'SKILL.md' -File -Recurse) {
        $skillContent = Get-Content -LiteralPath $skillFile.FullName -Raw -Encoding UTF8
        $frontmatter = [regex]::Match($skillContent, '(?s)^---\r?\n(?<header>.*?)\r?\n---(?:\r?\n|$)')
        Assert-Condition $frontmatter.Success "Invalid skill frontmatter: $($skillFile.FullName)"

        $header = $frontmatter.Groups['header'].Value
        $nameMatch = [regex]::Match($header, '(?m)^name: ([a-z0-9-]+)\r?$')
        $descriptionMatch = [regex]::Match($header, '(?m)^description: (.+?)\r?$')
        Assert-Condition $nameMatch.Success "Skill frontmatter has no valid name: $($skillFile.FullName)"
        Assert-Condition $descriptionMatch.Success "Skill frontmatter has no description: $($skillFile.FullName)"

        foreach ($booleanField in @('user-invocable', 'disable-model-invocation')) {
            $fieldMatch = [regex]::Match($header, "(?m)^$booleanField`: (.+?)\r?$")
            Assert-Condition (-not $fieldMatch.Success -or $fieldMatch.Groups[1].Value -in @('true', 'false')) "Skill '$($skillFile.Directory.Name)' has an invalid $booleanField value."
        }

        $skillName = $nameMatch.Groups[1].Value
        $skillCount++
        Assert-Condition ($skillName -eq $skillFile.Directory.Name) "Skill '$skillName' does not match directory '$($skillFile.Directory.Name)'."
        Assert-Condition ($skillName -match $skillNamePattern) "Invalid skill name '$skillName'."
        Assert-Condition (-not $skillNames.ContainsKey($skillName)) "Duplicate skill name '$skillName'."
        $skillNames[$skillName] = $true

        if ($entry.name -eq 'al-development-workflow') {
            $hasApprovedPrefix = $skillName -match '^(?:al-test|mcp|simplify|workflow)-'
            Assert-Condition $hasApprovedPrefix "AL workflow skill '$skillName' must use an approved domain-first prefix: al-test-, mcp-, simplify-, or workflow-."
        }

        if ($entry.name -eq 'al-development-workflow' -and $skillName -notin @('workflow-work-package-begin', 'simplify-code', 'simplify-codebase', 'al-test-document-scenarios', 'workflow-spec-estimate', 'workflow-decisions-grill', 'workflow-spec-implement', 'al-test-run-tdd', 'workflow-code-review', 'workflow-pull-request-create')) {
            $userInvocable = [regex]::Match($header, '(?m)^user-invocable: false\r?$')
            Assert-Condition $userInvocable.Success "Internal AL workflow skill '$skillName' must set user-invocable: false."
        }

        foreach ($link in [regex]::Matches($skillContent, '\]\(([^)]+)\)')) {
            $target = $link.Groups[1].Value
            if ($target -match '^(?:https?://|#)') {
                continue
            }

            $targetPath = [System.IO.Path]::GetFullPath((Join-Path $skillFile.Directory.FullName $target))
            Assert-Condition ($targetPath.StartsWith($pluginRoot, [System.StringComparison]::OrdinalIgnoreCase)) "Skill link escapes plugin root: $target"
            Assert-Condition (Test-Path -LiteralPath $targetPath) "Broken skill link in '$($skillFile.FullName)': $target"
        }

        $evalPath = Join-Path $skillFile.Directory.FullName 'evals/evals.json'
        Assert-Condition (Test-Path -LiteralPath $evalPath -PathType Leaf) "Eval suite not found for skill '$skillName': $evalPath"

        $evalSuite = Read-JsonFile $evalPath
        Assert-Condition ($evalSuite.skill_name -eq $skillName) "Eval skill name differs for '$skillName'."
        Assert-Condition ($evalSuite.evals.Count -ge 3) "Skill '$skillName' must define at least three eval cases."

        $evalIds = @{}
        foreach ($eval in $evalSuite.evals) {
            $evalCount++
            Assert-Condition ($null -ne $eval.id) "Skill '$skillName' has an eval without an ID."
            Assert-Condition (-not $evalIds.ContainsKey([string] $eval.id)) "Skill '$skillName' has duplicate eval ID '$($eval.id)'."
            $evalIds[[string] $eval.id] = $true
            Assert-Condition (-not [string]::IsNullOrWhiteSpace($eval.prompt)) "Skill '$skillName' has an eval without a prompt."
            Assert-Condition (-not [string]::IsNullOrWhiteSpace($eval.expected_output)) "Skill '$skillName' has an eval without expected behavior."
            Assert-Condition ($null -ne $eval.files) "Skill '$skillName' eval '$($eval.id)' must define a files array."
        }
    }

    Assert-Condition ($skillNames.Count -gt 0) "Plugin '$($entry.name)' contains no skills."
}

$secretPatterns = @(
    '-----BEGIN (?:RSA |OPENSSH |EC |DSA )?PRIVATE KEY-----',
    'ghp_[A-Za-z0-9]{30,}',
    'github_pat_[A-Za-z0-9_]{30,}',
    'sk-ant-[A-Za-z0-9_-]{20,}'
)
$scanExtensions = @('.json', '.md', '.ps1', '.yml', '.yaml', '.txt')
$filesToScan = Get-ChildItem -LiteralPath $repositoryRoot -File -Recurse |
    Where-Object {
        $_.FullName -notlike "$repositoryRoot\.git\*" -and
        $_.FullName -ne $PSCommandPath -and
        $scanExtensions -contains $_.Extension
    }

foreach ($file in $filesToScan) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    foreach ($pattern in $secretPatterns) {
        Assert-Condition ($content -notmatch $pattern) "Potential secret found in '$($file.FullName)'."
    }
}

Write-Output "Validation passed: $($marketplace.plugins.Count) plugin(s), $skillCount skill(s), $evalCount eval(s)."