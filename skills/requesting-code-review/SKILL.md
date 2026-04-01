---
name: requesting-code-review
description: 在完成任务、实现重要功能，或准备合并之前使用，以确认工作是否满足要求
---

# 请求代码评审

分派 superpowers:code-reviewer 子代理，在问题扩散之前把它们拦下来。

**核心原则：** 尽早评审，频繁评审。

## 何时请求评审

**必需：**
- 在 subagent-driven development 中，每个任务结束后
- 完成重大功能之后
- 合并到 main 之前

**可选但很有价值：**
- 卡住时（引入新的视角）
- 重构前（做基线检查）
- 修完复杂 bug 之后

## 如何请求

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 分派 code-reviewer 子代理：**

使用 Task 工具，并指定 superpowers:code-reviewer 类型，按 `code-reviewer.md` 中的模板填写。

**占位符说明：**
- `{WHAT_WAS_IMPLEMENTED}` - 你刚刚完成了什么
- `{PLAN_OR_REQUIREMENTS}` - 它原本应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交
- `{DESCRIPTION}` - 简短摘要

**3. 处理反馈：**
- 立刻修复 Critical 问题
- 在继续之前修复 Important 问题
- Minor 问题可以先记录，稍后处理
- 如果评审者判断错误，就用技术理由反驳

## 示例

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch superpowers:code-reviewer subagent]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## 与工作流的集成

**Subagent-Driven Development：**
- 每个任务后都评审
- 在问题累积前把它们拦住
- 修完再进入下一个任务

**Executing Plans：**
- 每个批次（3 个任务）后评审
- 获取反馈，应用修复，再继续

**Ad-Hoc Development：**
- 合并前评审
- 卡住时评审

## 红旗信号

**绝不要：**
- 因为“这很简单”就跳过评审
- 忽略 Critical 问题
- 带着未修复的 Important 问题继续往前走
- 对合理的技术反馈强行争辩

**如果评审者错了：**
- 用技术理由反驳
- 给出代码或测试来证明行为正确
- 请求进一步澄清

模板见：requesting-code-review/code-reviewer.md
