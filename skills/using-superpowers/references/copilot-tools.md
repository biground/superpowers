# GitHub Copilot Tool Mapping

Skills use Claude Code tool names. When you encounter these in a skill, use your Copilot equivalent:

| Skill references | Copilot equivalent |
|-----------------|-------------------|
| `Task` tool (dispatch subagent) | `runSubagent` tool |
| Multiple `Task` calls (parallel) | Multiple `runSubagent` calls |
| Task returns result | Subagent returns final message |
| `TodoWrite` (task tracking) | `manage_todo_list` tool |
| `Skill` tool (invoke a skill) | `read_file` on the skill's SKILL.md file |
| `Read` (read files) | `read_file` |
| `Write` (create files) | `create_file` |
| `Edit` (edit files) | `replace_string_in_file` or `multi_replace_string_in_file` |
| `Bash` (run commands) | `run_in_terminal` |
| `WebFetch` (fetch URLs) | `fetch_webpage` (load via tool search first) |
| `EnterPlanMode` | `switch_agent` to Plan agent |

## Subagent dispatch

Copilot supports dispatching subagents via `runSubagent`. Each subagent runs autonomously and returns a single message with its results. Subagents are stateless — you cannot send follow-up messages.

When a skill says to dispatch a `Task`, use `runSubagent` with a detailed prompt containing all context the subagent needs.

## Task tracking

When a skill says to use `TodoWrite`, use `manage_todo_list` instead. The interface is similar — create items, mark them in-progress, then completed.

## Reading skills

When a skill says to invoke another skill via the `Skill` tool, use `read_file` to read the SKILL.md file from the skills directory. For example, to invoke the brainstorming skill:

```
read_file("skills/brainstorming/SKILL.md")
```

## Key differences from Claude Code

- **No SessionStart hook** — Copilot uses `.github/copilot-instructions.md` for auto-injection
- **No native Skill tool** — Read skill files directly with `read_file`
- **Subagents are one-shot** — Cannot send follow-up messages; include all context in the prompt
- **Todo list is array-based** — Must pass the full todo list array on every update
