---
name: finishing-a-development-branch
description: 在实现已经完成、所有测试通过，并且需要决定如何集成这些工作时使用；通过结构化选项来指导合并、PR 或清理收尾
---

# 完成开发分支

## 概览

通过提供清晰的选项并执行被选中的工作流，来完成开发收尾。

**核心原则：** 验证测试 → 展示选项 → 执行选择 → 做清理。

**开始时说明：** "I'm using the finishing-a-development-branch skill to complete this work."

## 流程

### 步骤 1：验证测试

**在展示选项之前，先确认测试通过：**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**如果测试失败：**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

停下。不要进入步骤 2。

**如果测试通过：** 继续到步骤 2。

### 步骤 2：确定基础分支

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

或者直接问："This branch split from main - is that correct?"

### 步骤 3：展示选项

准确展示下面这 4 个选项：

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**不要补充解释**，选项本身要保持简洁。

### 步骤 4：执行选择

#### 选项 1：本地合并

```bash
# Switch to base branch
git checkout <base-branch>

# Pull latest
git pull

# Merge feature branch
git merge <feature-branch>

# Verify tests on merged result
<test command>

# If tests pass
git branch -d <feature-branch>
```

然后：清理 worktree（步骤 5）

#### 选项 2：推送并创建 PR

```bash
# Push branch
git push -u origin <feature-branch>

# Create PR
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<2-3 bullets of what changed>

## Test Plan
- [ ] <verification steps>
EOF
)"
```

然后：清理 worktree（步骤 5）

#### 选项 3：保持现状

汇报："Keeping branch <name>. Worktree preserved at <path>."

**不要清理 worktree。**

#### 选项 4：丢弃

**先确认：**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

等待用户给出完全一致的确认。

如果确认了：
```bash
git checkout <base-branch>
git branch -D <feature-branch>
```

然后：清理 worktree（步骤 5）

### 步骤 5：清理 Worktree

**对于选项 1、2、4：**

先检查当前是否在 worktree 中：
```bash
git worktree list | grep $(git branch --show-current)
```

如果是：
```bash
git worktree remove <worktree-path>
```

**对于选项 3：** 保留 worktree。

## 快速参考

| 选项 | 合并 | 推送 | 保留 Worktree | 清理分支 |
|--------|-------|------|---------------|----------------|
| 1. 本地合并 | ✓ | - | - | ✓ |
| 2. 创建 PR | - | ✓ | ✓ | - |
| 3. 保持现状 | - | - | ✓ | - |
| 4. 丢弃 | - | - | - | ✓（强制） |

## 常见错误

**跳过测试验证**
- **问题：** 把坏代码合并进去，或者创建一个失败的 PR
- **修复：** 在给出选项之前，永远先验证测试

**开放式提问**
- **问题：** "What should I do next?" → 太模糊
- **修复：** 只给出 4 个结构化选项

**自动清理 worktree**
- **问题：** 在后面可能还需要时就把 worktree 删掉了（选项 2、3）
- **修复：** 只在选项 1 和 4 时清理

**丢弃前不做确认**
- **问题：** 误删工作成果
- **修复：** 必须要求用户明确输入 "discard" 进行确认

## 红旗信号

**绝不要：**
- 带着失败测试继续推进
- 不验证合并结果就直接合并
- 没确认就删除工作成果
- 没有明确请求就 force-push

**永远要：**
- 在展示选项前先验证测试
- 准确展示 4 个选项
- 对选项 4 要求明确输入确认
- 只在选项 1 和 4 时清理 worktree

## 集成关系

**由以下技能调用：**
- **subagent-driven-development**（步骤 7）- 在所有任务完成之后
- **executing-plans**（步骤 5）- 在所有批次完成之后

**常与下列技能配合：**
- **using-git-worktrees** - 负责清理该技能创建的 worktree
