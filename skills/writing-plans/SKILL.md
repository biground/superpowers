---
name: writing-plans
description: 在你已经有 spec 或多步骤任务需求、并且还没开始动代码时使用
---

# 编写计划

## 概览

编写完整的实现计划，并假设执行的人对代码库几乎一无所知，审美还不太可靠。你要把他们需要知道的一切都写清楚：每个任务要碰哪些文件、要写哪些代码、要做哪些测试、可能需要查哪些文档、该怎么验证。把整份计划拆成小而清晰的任务。DRY。YAGNI。TDD。频繁提交。

假设他们是熟练开发者，但对我们的工具链和问题域几乎没有背景。也假设他们并不擅长测试设计。

**开始时说明：** "I'm using the writing-plans skill to create the implementation plan."

**上下文：** 这个技能应当在专用 worktree 中运行（由 brainstorming 技能创建）。

**计划保存路径：** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
    - （如果用户对计划存放位置另有偏好，以用户偏好为准）

## 范围检查

如果 spec 覆盖了多个相互独立的子系统，它本该在 brainstorming 阶段就被拆成多个子项目 spec。若没有拆开，就建议把它分成多个计划，每个子系统一个。每份计划都应该能单独产出可运行、可测试的软件。

## 文件结构

在定义任务之前，先列出要创建或修改哪些文件，以及每个文件负责什么。这一步会把拆分边界真正定下来。

- 设计边界清晰、接口明确的单元。每个文件都应只有一个清晰职责。
- 你对能一次装进上下文的代码推理得最好，文件越聚焦，修改也越可靠。优先选择小而专注的文件，而不是大而全的文件。
- 会一起变化的文件应该放在一起。按职责拆分，而不是按技术层拆分。
- 在现有代码库中要遵循既有模式。如果代码库本来就习惯大文件，不要擅自重构；但如果你要修改的那个文件已经膨胀到难以维护，把拆分写进计划是合理的。

这个结构会直接决定后面的任务拆分。每个任务都应当产出自洽、独立可理解的一组改动。

## 小步任务粒度

**每一步都应该是一个动作（2 到 5 分钟）：**
- "Write the failing test" - 一步
- "Run it to make sure it fails" - 一步
- "Implement the minimal code to make the test pass" - 一步
- "Run the tests and make sure they pass" - 一步
- "Commit" - 一步

## 计划文档头部

**每一份计划都必须以这个头部开始：**

```markdown
# [功能名] 实现计划

> **给 agentic workers：** 必需：用 superpowers:subagent-driven-development（如果有子代理）或 superpowers:executing-plans 来执行这份计划。步骤必须使用 checkbox（`- [ ]`）语法跟踪。

**目标：** [一句话描述这份计划要构建什么]

**架构：** [2 到 3 句话说明实现思路]

**技术栈：** [关键技术 / 库]

---
```

## 任务结构

````markdown
### 任务 N：[组件名]

**文件：**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **步骤 1：写出失败测试**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **步骤 2：运行测试，确认它确实失败**

运行：`pytest tests/path/test.py::test_name -v`
预期：FAIL，报错为 "function not defined"

- [ ] **步骤 3：写出最小实现**

```python
def function(input):
    return expected
```

- [ ] **步骤 4：运行测试，确认它通过**

运行：`pytest tests/path/test.py::test_name -v`
预期：PASS

- [ ] **步骤 5：提交**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## 记住
- 文件路径必须精确
- 计划里要写完整代码，不要只写“加校验”这种摘要
- 命令必须精确，并写清预期输出
- 用 @ 语法引用相关技能
- DRY、YAGNI、TDD、频繁提交

## 计划审查循环

每完成计划中的一个 chunk：

1. 为当前 chunk 分派 plan-document-reviewer 子代理（见 plan-document-reviewer-prompt.md）
    - 提供：chunk 内容、spec 文档路径
2. 如果 ❌ 发现问题：
    - 修复该 chunk 中的问题
    - 重新为这个 chunk 分派 reviewer
    - 重复，直到 ✅ Approved
3. 如果 ✅ Approved：继续下一个 chunk（如果已经是最后一个 chunk，就转交执行）

**Chunk 边界：** 用 `## Chunk N: <name>` 标题来分隔 chunk。每个 chunk 应不超过 1000 行，并且在逻辑上自洽。

**审查循环指导：**
- 由写计划的同一个 agent 来修计划（这样能保留上下文）
- 如果循环超过 5 轮，就升级给人工伙伴处理
- Reviewer 的意见是建议性的，如果你认为反馈有误，要明确解释原因

## 执行交接

计划保存后：

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Ready to execute?"**

**执行路径取决于运行环境能力：**

**如果运行环境支持子代理（Claude Code 等）：**
- **必需：** 使用 superpowers:subagent-driven-development
- 不要把它作为选项让用户挑，subagent-driven 才是标准路径
- 每个任务都用全新的子代理，并在每个任务后做两阶段审查

**如果运行环境不支持子代理：**
- 在当前会话里使用 superpowers:executing-plans 执行计划
- 按批次执行，并设置可审查的检查点
