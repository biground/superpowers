---
name: executing-plans
description: 有现成的书面实现计划，并且需要在独立会话中按检查点执行时使用
---

# 执行计划

## 概览

加载计划，做批判性审查，执行全部任务，并在完成时汇报。

**开始时说明：** "I'm using the executing-plans skill to implement this plan."

**注意：** 告诉你的人工伙伴，Superpowers 在可用子代理时效果会好得多。如果运行环境支持子代理（例如 Claude Code 或 Codex），工作质量会明显更高。只要子代理可用，就应优先使用 superpowers:subagent-driven-development，而不是本技能。

## 流程

### 步骤 1：加载并审查计划
1. 读取计划文件
2. 进行批判性审查，识别计划中的任何疑问或风险点
3. 如果有疑问：开始前先与人工伙伴沟通
4. 如果没有疑问：创建 TodoWrite，然后继续

### 步骤 2：执行任务

对于每个任务：
1. 标记为 in_progress
2. 严格按照每个步骤执行（计划已经拆成小步）
3. 按要求运行验证
4. 标记为 completed

### 步骤 3：完成开发

在所有任务完成并验证通过之后：
- 说明："I'm using the finishing-a-development-branch skill to complete this work."
- **必需子技能：** 使用 superpowers:finishing-a-development-branch
- 按该技能完成测试验证、选项展示和后续执行

## 何时停止并寻求帮助

**在以下情况出现时，立刻停止执行：**
- 遇到阻塞项（缺少依赖、测试失败、指令不清楚）
- 计划存在关键缺口，导致无法开始
- 你无法理解某条指令
- 验证反复失败

**不要猜，直接请求澄清。**

## 何时回到前面的步骤

**在以下情况下回到“审查计划”（步骤 1）：**
- 人工伙伴根据你的反馈更新了计划
- 基本实现思路需要重新审视

**不要硬顶着阻塞继续做**，停下来并发问。

## 记住
- 先批判性审查计划
- 严格按照计划步骤执行
- 不要跳过验证
- 计划要求引用技能时就照做
- 被阻塞时停下来，不要猜
- 没有用户明确同意时，绝不要在 main/master 分支上直接开始实现

## 集成关系

**必需的工作流技能：**
- **superpowers:using-git-worktrees** - 必需：开始前先准备隔离工作区
- **superpowers:writing-plans** - 负责生成本技能要执行的计划
- **superpowers:finishing-a-development-branch** - 在所有任务完成后收尾
