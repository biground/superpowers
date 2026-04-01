---
name: using-git-worktrees
description: 在开始需要与当前工作区隔离的功能开发，或执行实现计划之前使用；通过合理选择目录并做安全验证来创建隔离的 git worktree
---

# 使用 Git Worktrees

## 概览

Git worktree 会创建共享同一个仓库的隔离工作区，让你无需来回切分支就能同时在多个分支上工作。

**核心原则：** 系统化地选择目录，再加上安全验证，才能得到可靠的隔离。

**开始时说明：** "I'm using the using-git-worktrees skill to set up an isolated workspace."

## 目录选择流程

按下面的优先级顺序执行：

### 1. 检查现有目录

```bash
# Check in priority order
ls -d .worktrees 2>/dev/null     # Preferred (hidden)
ls -d worktrees 2>/dev/null      # Alternative
```

**如果找到了：** 就用它。如果两个都存在，优先 `.worktrees`。

### 2. 检查 CLAUDE.md

```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null
```

**如果里面已经写了偏好：** 直接用，不用再问。

### 3. 询问用户

如果既没有现成目录，CLAUDE.md 里也没写偏好：

```
No worktree directory found. Where should I create worktrees?

1. .worktrees/ (project-local, hidden)
2. ~/.config/superpowers/worktrees/<project-name>/ (global location)

Which would you prefer?
```

## 安全验证

### 对项目本地目录（.worktrees 或 worktrees）

**在创建 worktree 之前，必须确认该目录已经被忽略：**

```bash
# Check if directory is ignored (respects local, global, and system gitignore)
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**如果没有被忽略：**

按照 Jesse 的规则 "Fix broken things immediately"：
1. 在 .gitignore 中加入合适的忽略条目
2. 提交这次改动
3. 再继续创建 worktree

**为什么这很关键：** 可以防止你误把 worktree 内容提交进仓库。

### 对全局目录（~/.config/superpowers/worktrees）

不需要做 .gitignore 验证，因为它完全在项目外部。

## 创建步骤

### 1. 检测项目名

```bash
project=$(basename "$(git rev-parse --show-toplevel)")
```

### 2. 创建 Worktree

```bash
# Determine full path
case $LOCATION in
  .worktrees|worktrees)
    path="$LOCATION/$BRANCH_NAME"
    ;;
  ~/.config/superpowers/worktrees/*)
    path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"
    ;;
esac

# Create worktree with new branch
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```

### 3. 执行项目初始化

自动检测并运行合适的初始化命令：

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

### 4. 验证干净基线

运行测试，确保 worktree 一开始就是干净的：

```bash
# Examples - use project-appropriate command
npm test
cargo test
pytest
go test ./...
```

**如果测试失败：** 报告失败情况，并询问是继续还是先调查。

**如果测试通过：** 报告可以开始工作。

### 5. 报告位置

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## 快速参考

| 情况 | 动作 |
|-----------|--------|
| `.worktrees/` 存在 | 使用它（并验证已被忽略） |
| `worktrees/` 存在 | 使用它（并验证已被忽略） |
| 两者都存在 | 使用 `.worktrees/` |
| 两者都不存在 | 先查 CLAUDE.md，再问用户 |
| 目录未被忽略 | 加入 .gitignore 并提交 |
| 基线测试失败 | 报告失败并询问下一步 |
| 没有 package.json/Cargo.toml | 跳过依赖安装 |

## 常见错误

### 跳过忽略验证

- **问题：** Worktree 内容会被 Git 跟踪，污染 git status
- **修复：** 在创建项目本地 worktree 前，永远先跑 `git check-ignore`

### 擅自假定目录位置

- **问题：** 会造成不一致，也会违背项目约定
- **修复：** 遵循优先级：现有目录 > CLAUDE.md > 询问用户

### 带着失败测试继续

- **问题：** 你将无法区分新引入的 bug 和原本就存在的问题
- **修复：** 报告失败情况，并获得明确许可后再继续

### 硬编码初始化命令

- **问题：** 不同工具链的项目会直接失效
- **修复：** 根据项目文件自动检测（package.json 等）

## 工作流示例

```
You: I'm using the using-git-worktrees skill to set up an isolated workspace.

[Check .worktrees/ - exists]
[Verify ignored - git check-ignore confirms .worktrees/ is ignored]
[Create worktree: git worktree add .worktrees/auth -b feature/auth]
[Run npm install]
[Run npm test - 47 passing]

Worktree ready at /Users/jesse/myproject/.worktrees/auth
Tests passing (47 tests, 0 failures)
Ready to implement auth feature
```

## 红旗信号

**绝不要：**
- 在没有确认目录已被忽略时创建项目本地 worktree
- 跳过基线测试验证
- 测试失败却不询问就继续
- 在目录位置有歧义时擅自决定
- 跳过对 CLAUDE.md 的检查

**永远要：**
- 遵循目录优先级：现有目录 > CLAUDE.md > 询问用户
- 对项目本地目录验证其已被忽略
- 自动检测并运行项目初始化
- 验证干净的测试基线

## 集成关系

**由以下技能调用：**
- **brainstorming**（第 4 阶段）- 当设计获批并准备进入实现时必需
- **subagent-driven-development** - 在执行任何任务前必需
- **executing-plans** - 在执行任何任务前必需
- 任何需要隔离工作区的技能

**常与下列技能配合：**
- **finishing-a-development-branch** - 在工作完成后负责清理，属于必需配套技能
