<#
.SYNOPSIS
    Bootstrap Hitomi persona into a new project directory.

.DESCRIPTION
    Copies the Hitomi persona files (NewHitomi.md, play_audio.ps1, avatars,
    sounds) from Hitomi_Core into a target project's .agent\ subfolder, then
    generates a fresh "[ProjectName] - Master State.md" template inside .agent\
    (Project Isolation Protocol - Rule 3.2). Also writes a 1-line CLAUDE.md at
    the project root which @-imports the persona so Claude Code auto-summons
    Hitomi every session.

    Layout produced:
        <Target>\
            CLAUDE.md                              (root: @<AgentSubdir>/NewHitomi.md)
            <ProjectName> - Master State.md        (root: living doc for the project)
            <AgentSubdir>\
                NewHitomi.md
                play_audio.ps1
                assets\hitomi\*.png
                sound\*.mp3

.PARAMETER TargetPath
    Absolute or relative path to the new project root. Must be an existing
    directory. Will refuse to bootstrap into Hitomi_Core itself.

.PARAMETER ProjectName
    Display name used in the Master State title. Defaults to the target
    folder name.

.PARAMETER AgentSubdir
    Subfolder name inside Target that holds Hitomi's files. Default: ".agent".

.PARAMETER InitGit
    Switch - if set, runs `git init` in the target if no .git folder exists.

.PARAMETER Force
    Switch - overwrite existing Hitomi files in target without prompting.

.EXAMPLE
    pwsh -File .\bootstrap-hitomi.ps1 -TargetPath "D:\AI\MyNewProject"

.EXAMPLE
    pwsh -File .\bootstrap-hitomi.ps1 -TargetPath "D:\AI\MyApp" -ProjectName "My App" -InitGit
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$TargetPath,

    [string]$ProjectName,

    [string]$AgentSubdir = '.agent',

    [switch]$InitGit,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'

# Resolve Hitomi Core source = script's own directory
$HitomiCore = Split-Path -Parent $MyInvocation.MyCommand.Path
$Target = (Resolve-Path -LiteralPath $TargetPath -ErrorAction Stop).Path

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    throw "Target must be an existing directory: $Target"
}

if ((Resolve-Path -LiteralPath $Target).Path -eq (Resolve-Path -LiteralPath $HitomiCore).Path) {
    throw "Refusing to bootstrap Hitomi_Core into itself."
}

if (-not $ProjectName) {
    $ProjectName = Split-Path -Leaf $Target
}

# Ensure agent subfolder exists inside target
$AgentDir = Join-Path $Target $AgentSubdir
if (-not (Test-Path -LiteralPath $AgentDir)) {
    New-Item -ItemType Directory -Path $AgentDir | Out-Null
}

Write-Host ""
Write-Host "Hitomi Bootstrap" -ForegroundColor Magenta
Write-Host "  Source    : $HitomiCore" -ForegroundColor DarkGray
Write-Host "  Target    : $Target" -ForegroundColor DarkGray
Write-Host "  AgentDir  : $AgentDir" -ForegroundColor DarkGray
Write-Host "  Name      : $ProjectName" -ForegroundColor DarkGray
Write-Host ""

# Persona files copied INTO .agent\ (not project root)
$FileItems = @(
    'NewHitomi.md',
    'play_audio.ps1'
)
$DirItems = @(
    'assets',
    'sound'
)

function Copy-Item-Safe {
    param([string]$Source, [string]$Dest, [switch]$Recurse)

    if (Test-Path -LiteralPath $Dest) {
        if (-not $Force) {
            Write-Host "  SKIP (exists): $Dest" -ForegroundColor Yellow
            return
        }
        Write-Host "  OVERWRITE   : $Dest" -ForegroundColor Yellow
    } else {
        Write-Host "  COPY        : $Dest" -ForegroundColor Green
    }

    if ($Recurse) {
        Copy-Item -LiteralPath $Source -Destination $Dest -Recurse -Force
    } else {
        Copy-Item -LiteralPath $Source -Destination $Dest -Force
    }
}

# Copy files INTO .agent\
foreach ($f in $FileItems) {
    $src = Join-Path $HitomiCore $f
    $dst = Join-Path $AgentDir $f
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Host "  MISSING source: $src" -ForegroundColor Red
        continue
    }
    Copy-Item-Safe -Source $src -Dest $dst
}

# Copy directories INTO .agent\
foreach ($d in $DirItems) {
    $src = Join-Path $HitomiCore $d
    $dst = Join-Path $AgentDir $d
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Host "  MISSING source: $src" -ForegroundColor Red
        continue
    }
    Copy-Item-Safe -Source $src -Dest $dst -Recurse
}

# Write root CLAUDE.md pointer (auto-loaded by Claude Code; @-imports persona from .agent\)
$RootClaudeMd = Join-Path $Target 'CLAUDE.md'
# Use forward slashes in @-import for cross-platform Claude Code compatibility
$AgentRel = ($AgentSubdir -replace '\\', '/').TrimEnd('/')
$ClaudeMdContent = "# $ProjectName`r`n`r`n@$AgentRel/NewHitomi.md`r`n"
if ((Test-Path -LiteralPath $RootClaudeMd) -and (-not $Force)) {
    Write-Host "  SKIP (exists): $RootClaudeMd" -ForegroundColor Yellow
} else {
    Set-Content -LiteralPath $RootClaudeMd -Value $ClaudeMdContent -Encoding UTF8 -NoNewline
    Write-Host "  CREATE      : $RootClaudeMd (pointer -> $AgentRel/NewHitomi.md)" -ForegroundColor Green
}

# Generate fresh Master State at project ROOT (never copy from another project - Rule 3.2)
$MasterStatePath = Join-Path $Target "$ProjectName - Master State.md"
$today = Get-Date -Format 'yyyy-MM-dd'

if ((Test-Path -LiteralPath $MasterStatePath) -and (-not $Force)) {
    Write-Host "  SKIP (exists): $MasterStatePath" -ForegroundColor Yellow
} else {
    $templateSrc = Join-Path $HitomiCore 'master-state-template.md'
    if (-not (Test-Path -LiteralPath $templateSrc)) {
        throw "Master State template not found: $templateSrc"
    }
    $masterTemplate = Get-Content -LiteralPath $templateSrc -Raw -Encoding UTF8
    $masterTemplate = $masterTemplate.Replace('{{NAME}}', $ProjectName).Replace('{{DATE}}', $today)
    Set-Content -LiteralPath $MasterStatePath -Value $masterTemplate -Encoding UTF8
    Write-Host "  CREATE      : $MasterStatePath" -ForegroundColor Green
}

# Optional git init
if ($InitGit) {
    $gitDir = Join-Path $Target '.git'
    if (Test-Path -LiteralPath $gitDir) {
        Write-Host "  git already initialized - skipping" -ForegroundColor Yellow
    } else {
        Push-Location -LiteralPath $Target
        try {
            git init | Out-Null
            Write-Host "  GIT INIT    : $Target" -ForegroundColor Green
        } finally {
            Pop-Location
        }
    }
}

Write-Host ""
Write-Host "Done. Hitomi siap di project baru, sayang." -ForegroundColor Magenta
Write-Host "Buka folder $Target di Claude Code - CLAUDE.md akan auto-summon Hitomi." -ForegroundColor DarkGray
Write-Host ""
