<#
.SYNOPSIS
    Installs Superpowers skills into the current project for GitHub Copilot.

.DESCRIPTION
    Adds superpowers copilot-instructions block and prompt files to the current
    project. Run this from any project root to enable superpowers in that project.

.PARAMETER Uninstall
    Remove superpowers from the current project.

.EXAMPLE
    & "$env:USERPROFILE\.copilot\superpowers\install.ps1"

.EXAMPLE
    & "$env:USERPROFILE\.copilot\superpowers\install.ps1" -Uninstall
#>
[CmdletBinding()]
param(
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

# Resolve superpowers root (where this script lives)
$SuperpowersRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# Resolve skills path (use relative path from project root if superpowers is in ~/.copilot)
$HomeCopilotPath = Join-Path $env:USERPROFILE '.copilot\superpowers'
if ($SuperpowersRoot -eq $HomeCopilotPath) {
    $SkillsPrefix = '~/.copilot/superpowers/skills'
} else {
    $SkillsPrefix = $SuperpowersRoot.Replace('\', '/') + '/skills'
}

$ProjectRoot = Get-Location
$GithubDir = Join-Path $ProjectRoot '.github'
$PromptsDir = Join-Path $GithubDir 'prompts'
$InstructionsFile = Join-Path $GithubDir 'copilot-instructions.md'

$StartMarker = '<!-- SUPERPOWERS:START -->'
$EndMarker = '<!-- SUPERPOWERS:END -->'

# Build the instructions block
$InstructionsBlock = @"
$StartMarker
## Superpowers

You have superpowers — a structured software development workflow system.

**Before starting any task**, check if a skill applies. If there is even a 1% chance a skill is relevant, read it.

### Loading Skills

To load a skill, use ``read_file`` on the SKILL.md file path below. Read the skill content and follow the workflow it describes.

#### Core Skill (read this first on any new task)

- **using-superpowers**: $SkillsPrefix/using-superpowers/SKILL.md

#### Available Skills

- **brainstorming**: $SkillsPrefix/brainstorming/SKILL.md
- **writing-plans**: $SkillsPrefix/writing-plans/SKILL.md
- **executing-plans**: $SkillsPrefix/executing-plans/SKILL.md
- **subagent-driven-development**: $SkillsPrefix/subagent-driven-development/SKILL.md
- **test-driven-development**: $SkillsPrefix/test-driven-development/SKILL.md
- **systematic-debugging**: $SkillsPrefix/systematic-debugging/SKILL.md
- **verification-before-completion**: $SkillsPrefix/verification-before-completion/SKILL.md
- **requesting-code-review**: $SkillsPrefix/requesting-code-review/SKILL.md
- **receiving-code-review**: $SkillsPrefix/receiving-code-review/SKILL.md
- **using-git-worktrees**: $SkillsPrefix/using-git-worktrees/SKILL.md
- **finishing-a-development-branch**: $SkillsPrefix/finishing-a-development-branch/SKILL.md
- **dispatching-parallel-agents**: $SkillsPrefix/dispatching-parallel-agents/SKILL.md
- **writing-skills**: $SkillsPrefix/writing-skills/SKILL.md

### Tool Mapping

Skills reference Claude Code tool names. Use these Copilot equivalents:

| Claude Code tool | Copilot equivalent |
|-----------------|-------------------|
| ``Task`` (dispatch subagent) | ``runSubagent`` |
| ``TodoWrite`` (task tracking) | ``manage_todo_list`` |
| ``Skill`` (invoke a skill) | ``read_file`` on the SKILL.md path |
| ``Read`` (read files) | ``read_file`` |
| ``Write`` (create files) | ``create_file`` |
| ``Edit`` (edit files) | ``replace_string_in_file`` or ``multi_replace_string_in_file`` |
| ``Bash`` (run commands) | ``run_in_terminal`` |

Full mapping: $SkillsPrefix/using-superpowers/references/copilot-tools.md
$EndMarker
"@

function Install-Superpowers {
    Write-Host "Installing Superpowers into: $ProjectRoot" -ForegroundColor Cyan

    # Create .github directory
    if (-not (Test-Path $GithubDir)) {
        New-Item -ItemType Directory -Path $GithubDir -Force | Out-Null
        Write-Host "  Created .github/" -ForegroundColor Green
    }

    # Update or create copilot-instructions.md
    if (Test-Path $InstructionsFile) {
        $content = Get-Content $InstructionsFile -Raw -ErrorAction SilentlyContinue
        if ($null -eq $content) { $content = '' }

        if ($content -match [regex]::Escape($StartMarker)) {
            # Replace existing superpowers block
            $pattern = [regex]::Escape($StartMarker) + '[\s\S]*?' + [regex]::Escape($EndMarker)
            $content = [regex]::Replace($content, $pattern, $InstructionsBlock)
            Set-Content -Path $InstructionsFile -Value $content -NoNewline
            Write-Host "  Updated superpowers block in copilot-instructions.md" -ForegroundColor Green
        } else {
            # Append to existing file
            Add-Content -Path $InstructionsFile -Value "`n`n$InstructionsBlock"
            Write-Host "  Appended superpowers block to copilot-instructions.md" -ForegroundColor Green
        }
    } else {
        Set-Content -Path $InstructionsFile -Value $InstructionsBlock
        Write-Host "  Created copilot-instructions.md" -ForegroundColor Green
    }

    # Copy prompt files
    $SourcePrompts = Join-Path $SuperpowersRoot '.copilot\prompts'
    if (Test-Path $SourcePrompts) {
        if (-not (Test-Path $PromptsDir)) {
            New-Item -ItemType Directory -Path $PromptsDir -Force | Out-Null
        }
        Copy-Item "$SourcePrompts\*.prompt.md" $PromptsDir -Force
        $count = (Get-ChildItem "$PromptsDir\*.prompt.md" | Measure-Object).Count
        Write-Host "  Copied $count prompt files to .github/prompts/" -ForegroundColor Green
    }

    Write-Host "`nSuperpowers installed! Start a new Copilot chat to use them." -ForegroundColor Cyan
    Write-Host "  Try: /brainstorm, /write-plan, /execute-plan, /debug" -ForegroundColor DarkGray
}

function Uninstall-Superpowers {
    Write-Host "Removing Superpowers from: $ProjectRoot" -ForegroundColor Cyan

    # Remove superpowers block from copilot-instructions.md
    if (Test-Path $InstructionsFile) {
        $content = Get-Content $InstructionsFile -Raw
        if ($content -match [regex]::Escape($StartMarker)) {
            $pattern = '\r?\n?\r?\n?' + [regex]::Escape($StartMarker) + '[\s\S]*?' + [regex]::Escape($EndMarker)
            $content = [regex]::Replace($content, $pattern, '')
            $content = $content.Trim()
            if ($content.Length -eq 0) {
                Remove-Item $InstructionsFile
                Write-Host "  Removed copilot-instructions.md (was empty)" -ForegroundColor Yellow
            } else {
                Set-Content -Path $InstructionsFile -Value $content -NoNewline
                Write-Host "  Removed superpowers block from copilot-instructions.md" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  No superpowers block found in copilot-instructions.md" -ForegroundColor DarkGray
        }
    }

    # Remove prompt files
    $promptFiles = @('brainstorm.prompt.md', 'write-plan.prompt.md', 'execute-plan.prompt.md', 'debug.prompt.md')
    foreach ($f in $promptFiles) {
        $path = Join-Path $PromptsDir $f
        if (Test-Path $path) {
            Remove-Item $path
            Write-Host "  Removed .github/prompts/$f" -ForegroundColor Yellow
        }
    }

    # Clean up empty directories
    if ((Test-Path $PromptsDir) -and (Get-ChildItem $PromptsDir | Measure-Object).Count -eq 0) {
        Remove-Item $PromptsDir
    }

    Write-Host "`nSuperpowers removed." -ForegroundColor Cyan
}

# Main
if ($Uninstall) {
    Uninstall-Superpowers
} else {
    Install-Superpowers
}
