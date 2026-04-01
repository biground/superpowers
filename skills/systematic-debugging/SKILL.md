---
name: systematic-debugging
description: 在遇到任何 bug、测试失败或非预期行为，并且尚未开始提出修复方案时使用
---

# 系统化调试

## 概览

随机修复只会浪费时间，还会引入新的 bug。快速打补丁只是在掩盖底层问题。

**核心原则：** 在尝试修复之前，始终先找到根因。只修症状就是失败。

**违背这个流程的字面要求，也是在违背调试的精神。**

## 铁律

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

如果你还没有完成第 1 阶段，就不能提出修复方案。

## 何时使用

适用于 **任何** 技术问题：
- 测试失败
- 线上 bug
- 非预期行为
- 性能问题
- 构建失败
- 集成问题

**尤其要在以下情况使用：**
- 时间压力很大时（紧急情况最容易让人开始乱猜）
- “先来一个快速修复” 看起来很诱人时
- 你已经尝试过多个修复时
- 上一个修复没有生效时
- 你还没有完全理解问题时

**不要因为以下原因跳过：**
- 问题看起来很简单（简单 bug 也有根因）
- 你很赶时间（赶时间只会保证返工）
- 经理要求立刻修好（系统化调试比瞎撞更快）

## 四个阶段

你必须完成当前阶段后，才能进入下一阶段。

### 阶段 1：根因调查

**在尝试任何修复之前：**

1. **仔细阅读错误信息**
   - 不要跳过错误或警告
   - 它们经常直接给出解决方向
   - 要把堆栈完整读完
   - 记下行号、文件路径、错误码

2. **稳定复现**
   - 你能稳定触发它吗？
   - 具体步骤是什么？
   - 是不是每次都会发生？
   - 如果不能稳定复现，就继续采集数据，不要猜

3. **检查最近改动**
   - 最近有什么变化可能导致这个问题？
   - 看 git diff、近期提交
   - 看新增依赖、配置变化
   - 看环境差异

4. **在多组件系统中采集证据**

   **当系统由多个组件串联而成时（CI → build → signing，API → service → database）：**

   **在提出修复方案前，先增加诊断性观测：**
   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation
     - Check state at each layer

   Run once to gather evidence showing WHERE it breaks
   THEN analyze evidence to identify failing component
   THEN investigate that specific component
   ```

   **示例（多层系统）：**
   ```bash
   # 第 1 层：工作流
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # 第 2 层：构建脚本
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # 第 3 层：签名脚本
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # 第 4 层：实际签名
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   **这样能揭示：** 到底是哪一层出了问题（secrets → workflow ✓，workflow → build ✗）

5. **追踪数据流**

   **当错误出现在很深的调用栈里时：**

   完整的逆向追踪技术见本目录下的 `root-cause-tracing.md`。

   **简版：**
   - 这个坏值最早从哪里来的？
   - 是谁把这个坏值传进来的？
   - 一路向上追，直到找到源头
   - 在源头修，不要在症状处修

### 阶段 2：模式分析

**先找到模式，再谈修复：**

1. **寻找可工作的例子**
   - 在同一个代码库里找相似但正常工作的代码
   - 哪些能工作的东西和当前坏掉的东西最像？

2. **对照参考实现**
   - 如果你是在落地某个模式，就把参考实现完整读完
   - 不要扫读，要逐行读
   - 彻底理解模式后再应用

3. **识别差异**
   - 能工作的版本和坏掉的版本到底哪里不同？
   - 把所有差异列出来，再小也别漏
   - 不要想当然地说“这点差异不重要”

4. **理解依赖**
   - 它还依赖哪些其他组件？
   - 需要什么设置、配置、环境？
   - 它默认了哪些前提？

### 阶段 3：假设与测试

**科学方法：**

1. **提出单一假设**
   - 清楚表述："I think X is the root cause because Y"
   - 把它写下来
   - 要具体，不要含糊

2. **做最小测试**
   - 用最小可能的改动去验证这个假设
   - 一次只改一个变量
   - 不要一次修多个点

3. **继续之前先验证**
   - 生效了吗？生效 → 进入阶段 4
   - 没生效？提出新的假设
   - 不要在原先的错误修复上继续叠补丁

4. **当你不知道时**
   - 明说："I don't understand X"
   - 不要装懂
   - 去求助
   - 去补研究

### 阶段 4：实现

**修根因，不修表象：**

1. **创建失败测试用例**
   - 尽可能用最简单的方式复现
   - 有条件就写自动化测试
   - 没有框架就写一次性测试脚本
   - 修复之前必须先有它
   - 用 `superpowers:test-driven-development` 技能来写合格的失败测试

2. **实现单一修复**
   - 只处理已经确认的根因
   - 一次只改一个点
   - 不要顺手做“既然都来了”的优化
   - 不要捆绑式重构

3. **验证修复**
   - 测试现在通过了吗？
   - 其他测试没有被带坏吧？
   - 问题真的解决了吗？

4. **如果修复无效**
   - 停下
   - 统计一下：你已经试了几次修复？
   - 如果 < 3：回到阶段 1，带着新信息重新分析
   - **如果 ≥ 3：停下，并开始质疑架构（见下面第 5 步）**
   - 没有经过架构讨论之前，不要尝试第 4 次修复

5. **如果 3 次以上修复都失败：开始质疑架构**

   **表明这是架构问题的模式：**
   - 每次修复都会在别处暴露新的共享状态、耦合或结构问题
   - 修复需要“大规模重构”才能落地
   - 每修一个地方，就会在别处冒出新症状

   **停下，质疑根本前提：**
   - 这个模式在根子上到底对不对？
   - 我们是不是只是因为惯性才一直坚持它？
   - 我们现在应该重构架构，而不是继续修症状吗？

   **在继续尝试更多修复之前，先和人工伙伴讨论**

   这不是一次假设失败，而是架构本身可能错了。

## 红旗信号：停下并回到流程

如果你发现自己在想：
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- 在还没追踪数据流之前就开始提方案
- **"One more fix attempt"（已经试过 2 次以上时）**
- **每修一次，新的问题就从不同地方冒出来**

**这些都意味着：立刻停下，回到阶段 1。**

**如果已经有 3 次以上修复失败：** 开始质疑架构（见阶段 4.5）

## 你的人工伙伴发出的“你做错了”的信号

**注意这些纠偏信号：**
- "Is that not happening?" - 你是在没验证的前提下做了假设
- "Will it show us...?" - 你本该先补证据采集
- "Stop guessing" - 你在还没理解前就开始提修复
- "Ultrathink this" - 应该质疑根本前提，而不是只看表象
- "We're stuck?"（带着挫败感）- 说明你当前的方法不工作

**一旦出现这些信号：** 立刻停下，回到阶段 1。

## 常见借口

| 借口 | 现实 |
|--------|---------|
| "Issue is simple, don't need process" | 简单问题一样有根因。对简单 bug 来说，这个流程也很快。 |
| "Emergency, no time for process" | 系统化调试比乱试更快。 |
| "Just try this first, then investigate" | 第一次修复就会奠定后续模式。一开始就该做对。 |
| "I'll write test after confirming fix works" | 没有测试的修复不可靠。先有测试才能证明它成立。 |
| "Multiple fixes at once saves time" | 你将无法隔离到底什么起作用了，还会引入新 bug。 |
| "Reference too long, I'll adapt the pattern" | 只懂一半几乎必然出 bug。要完整读完。 |
| "I see the problem, let me fix it" | 看见症状不等于理解根因。 |
| "One more fix attempt"（已经失败 2 次以上） | 3 次以上失败意味着架构问题。该质疑模式，而不是再修一次。 |

## 快速参考

| 阶段 | 关键活动 | 成功标准 |
|-------|---------------|------------------|
| **1. 根因** | 读错误、做复现、查改动、收集证据 | 搞清楚 WHAT 和 WHY |
| **2. 模式** | 找可工作的例子并比较 | 识别差异 |
| **3. 假设** | 提出理论并做最小测试 | 获得确认，或形成新假设 |
| **4. 实现** | 写测试、修复、验证 | Bug 被解决，测试通过 |

## 当流程得出“没有根因”时

如果系统化调查后发现问题确实是环境性的、时序性的，或者完全来自外部：

1. 说明你已经完成了这个流程
2. 记录你调查过哪些内容
3. 实现合适的处理方式（重试、超时、错误消息）
4. 加上监控或日志，方便以后继续调查

**但要注意：** 95% 的“没有根因”其实只是调查还不够完整。

## 支撑技术

下面这些技术都是系统化调试的一部分，并且都在本目录中：

- **`root-cause-tracing.md`** - 沿调用栈逆向追 bug，找到最初触发点
- **`defense-in-depth.md`** - 找到根因后，在多个层次补充验证
- **`condition-based-waiting.md`** - 用条件轮询替代拍脑袋的 timeout

**相关技能：**
- **superpowers:test-driven-development** - 用于创建失败测试用例（阶段 4，第 1 步）
- **superpowers:verification-before-completion** - 在宣告成功前验证修复是否真的生效

## 现实影响

来自多次调试会话的数据：
- 系统化方法：15 到 30 分钟修好
- 随机乱修：2 到 3 小时来回折腾
- 首次修复成功率：95% 对 40%
- 引入新 bug 的概率：几乎为零，对比“经常发生”
