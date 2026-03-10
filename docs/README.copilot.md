# Superpowers for GitHub Copilot

Guide for using Superpowers with GitHub Copilot in VS Code (agent mode).

## Quick Install

1. Clone the repo:
   ```bash
   git clone https://github.com/obra/superpowers.git ~/.copilot/superpowers
   ```

2. Add the superpowers instructions to your project's `.github/copilot-instructions.md` (see [INSTALL.md](../.copilot/INSTALL.md) for the template).

3. (Optional) Copy prompt files for slash commands:
   ```bash
   cp ~/.copilot/superpowers/.copilot/prompts/*.prompt.md .github/prompts/
   ```

## How It Works

GitHub Copilot doesn't have a plugin marketplace or skill discovery system like Claude Code. Instead, Superpowers integrates through Copilot's native customization mechanisms:

### `.github/copilot-instructions.md` (SessionStart equivalent)

This file is automatically injected into every Copilot conversation in your project. It replaces Claude Code's SessionStart hook by telling Copilot about the superpowers system and where to find skills.

### Skills as readable files

Instead of Claude Code's `Skill` tool, Copilot reads SKILL.md files directly with `read_file`. The copilot-instructions template lists all available skills with their file paths.

### Prompt files (slash command equivalent)

The `.prompt.md` files in `.copilot/prompts/` (or `.github/prompts/` in your project) provide quick-access commands:

| Prompt file | Purpose | Equivalent Claude command |
|-------------|---------|--------------------------|
| `brainstorm.prompt.md` | Start a design brainstorm | `/brainstorm` |
| `write-plan.prompt.md` | Create implementation plan | `/write-plan` |
| `execute-plan.prompt.md` | Execute a plan step by step | `/execute-plan` |
| `debug.prompt.md` | Systematic debugging | — |

### Tool mapping

Skills reference Claude Code tool names. Copilot equivalents:

| Claude Code | Copilot |
|-------------|---------|
| `Task` (subagent) | `runSubagent` |
| `TodoWrite` | `manage_todo_list` |
| `Skill` (load skill) | `read_file` on SKILL.md |
| `Read` | `read_file` |
| `Write` | `create_file` |
| `Edit` | `replace_string_in_file` |
| `Bash` | `run_in_terminal` |

Full mapping: [copilot-tools.md](../skills/using-superpowers/references/copilot-tools.md)

## Usage

### Automatic skill activation

With the copilot-instructions template in place, Copilot will be aware of the superpowers system. When you ask it to build a feature, debug an issue, or plan work, it should read and follow the relevant skill.

### Using prompt files

If you copied the prompt files to `.github/prompts/`, you can invoke them directly in Copilot chat:

- Type `/brainstorm` to start a design session
- Type `/write-plan` to create an implementation plan
- Type `/execute-plan` to work through a plan
- Type `/debug` to start systematic debugging

### Manual skill invocation

You can always tell Copilot directly:

```
Read and follow the skill at ~/.copilot/superpowers/skills/brainstorming/SKILL.md
```

## Differences from Claude Code

### What works the same
- All 14 skills work with Copilot — the workflows are platform-agnostic
- TDD, brainstorming, planning, debugging, code review workflows
- Task tracking via todo lists
- Subagent dispatch for parallel work

### What works differently
- **No auto-discovery**: Skills don't auto-activate from descriptions alone. The copilot-instructions template provides awareness, and prompt files give quick access.
- **No SessionStart hook**: Replaced by `.github/copilot-instructions.md` auto-injection.
- **Subagents are one-shot**: Copilot's `runSubagent` dispatches an agent that runs to completion and returns a single message. You can't interact with it mid-task.
- **No native skill tool**: Skills are read as files rather than loaded through a discovery mechanism.

### What's limited
- **Subagent-driven-development**: Works but subagents cannot be monitored mid-execution like Claude Code's Task tool. The dispatching agent gets results only at completion.
- **Git worktrees**: The skill works but Copilot's workspace scope may not automatically follow into new worktrees.

## Personal Skills

Create your own skills alongside superpowers:

```bash
mkdir -p ~/.copilot/skills/my-skill
```

Create `~/.copilot/skills/my-skill/SKILL.md` with the standard frontmatter:

```markdown
---
name: my-skill
description: Use when [condition] - [what it does]
---

# My Skill

[Your workflow here]
```

Then add it to your project's `.github/copilot-instructions.md`:

```markdown
- my-skill: ~/.copilot/skills/my-skill/SKILL.md
```

## Updating

```bash
cd ~/.copilot/superpowers && git pull
```

Skills update instantly since copilot-instructions references the clone path directly.

## Uninstalling

1. Remove the superpowers section from your `.github/copilot-instructions.md`
2. Remove any copied prompt files from `.github/prompts/`
3. Delete the clone:
   ```bash
   rm -rf ~/.copilot/superpowers
   ```

## Troubleshooting

### Skills not activating
- Verify `.github/copilot-instructions.md` exists in your project root
- Check that the paths in copilot-instructions point to your actual clone location
- Try invoking a skill explicitly: "Read and follow skills/brainstorming/SKILL.md"

### Wrong tool names in output
- Copilot may try to use Claude Code tool names from skill content. The tool mapping in copilot-instructions should prevent this, but you can remind it: "Use Copilot tools, not Claude Code tools"

### Subagent issues
- If `runSubagent` isn't available, check that you're using Copilot in agent mode (not just chat mode)
- Subagents need detailed prompts with all context — they can't read the conversation history
