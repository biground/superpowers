# Superpowers for GitHub Copilot — Installation

## Prerequisites

- VS Code with GitHub Copilot extension (agent mode)
- Git

## Installation

### 1. Clone the repo

```bash
   git clone https://github.com/autovant/superpowers.git ~/.copilot/superpowers

**Windows (PowerShell):**
```powershell
git clone https://github.com/obra/superpowers.git "$env:USERPROFILE\.copilot\superpowers"
```

### 2. Add instructions to your project

In your project, create or edit `.github/copilot-instructions.md` and add:

```markdown
## Superpowers

You have superpowers — a structured software development workflow system.

### Loading Skills

Before starting any task, check if a skill applies by reading the skill index:

<!-- UPDATE THIS PATH to where you cloned superpowers -->

Read the using-superpowers skill to understand the system:
- Skill: ~/.copilot/superpowers/skills/using-superpowers/SKILL.md

Available skills (read with read_file when needed):
- brainstorming: ~/.copilot/superpowers/skills/brainstorming/SKILL.md
- writing-plans: ~/.copilot/superpowers/skills/writing-plans/SKILL.md
- executing-plans: ~/.copilot/superpowers/skills/executing-plans/SKILL.md
- subagent-driven-development: ~/.copilot/superpowers/skills/subagent-driven-development/SKILL.md
- test-driven-development: ~/.copilot/superpowers/skills/test-driven-development/SKILL.md
- systematic-debugging: ~/.copilot/superpowers/skills/systematic-debugging/SKILL.md
- verification-before-completion: ~/.copilot/superpowers/skills/verification-before-completion/SKILL.md
- requesting-code-review: ~/.copilot/superpowers/skills/requesting-code-review/SKILL.md
- receiving-code-review: ~/.copilot/superpowers/skills/receiving-code-review/SKILL.md
- using-git-worktrees: ~/.copilot/superpowers/skills/using-git-worktrees/SKILL.md
- finishing-a-development-branch: ~/.copilot/superpowers/skills/finishing-a-development-branch/SKILL.md
- dispatching-parallel-agents: ~/.copilot/superpowers/skills/dispatching-parallel-agents/SKILL.md
- writing-skills: ~/.copilot/superpowers/skills/writing-skills/SKILL.md

### Tool Mapping

Skills reference Claude Code tool names. Use these Copilot equivalents:
- Task → runSubagent
- TodoWrite → manage_todo_list
- Skill → read_file on the SKILL.md path
- Read → read_file
- Write → create_file
- Edit → replace_string_in_file
- Bash → run_in_terminal

For full mapping, read: ~/.copilot/superpowers/skills/using-superpowers/references/copilot-tools.md
```

### 3. (Optional) Copy prompt files

For quick-access slash commands, copy the prompt files to your project:

```bash
mkdir -p .github/prompts
cp ~/.copilot/superpowers/.copilot/prompts/*.prompt.md .github/prompts/
```

**Windows:**
```powershell
New-Item -ItemType Directory -Force -Path ".github\prompts"
Copy-Item "$env:USERPROFILE\.copilot\superpowers\.copilot\prompts\*.prompt.md" ".github\prompts\"
```

This gives you `/brainstorm`, `/write-plan`, and `/execute-plan` prompt commands in Copilot chat.

### 4. Verify

Start a new Copilot chat and ask: "help me plan a new feature". The agent should read the superpowers skills and follow the brainstorming workflow.

## Updating

```bash
cd ~/.copilot/superpowers && git pull
```

## Uninstalling

1. Remove the superpowers section from your `.github/copilot-instructions.md`
2. Delete the clone: `rm -rf ~/.copilot/superpowers`
