---
name: verification-before-completion
description: 在准备声称工作已经完成、修复或通过之前使用，尤其是在提交或创建 PR 之前；必须先运行验证命令并确认输出，任何成功结论都要先有证据
---

# 完成前先验证

## 概览

没有验证就声称工作完成，不是高效，而是不诚实。

**核心原则：** 先有证据，再下结论，永远如此。

**违背这条规则的字面要求，也是在违背它的精神。**

## 铁律

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

如果你没有在当前这次交互中实际运行验证命令，就不能声称它已经通过。

## 闸门函数

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## 常见失败模式

| 声明 | 需要什么 | 什么还不够 |
|-------|----------|----------------|
| 测试通过 | 测试命令输出为 0 failures | 之前跑过、"应该会过" |
| Linter 干净 | Linter 输出为 0 errors | 只跑了部分检查、靠推断外推 |
| 构建成功 | 构建命令退出码为 0 | Linter 通过、日志看起来不错 |
| Bug 已修复 | 原始症状对应的测试通过 | 代码改了、所以默认修好了 |
| 回归测试有效 | 红绿循环经过验证 | 测试只通过过一次 |
| 代理已完成 | VCS diff 里真的有对应改动 | 代理口头说了 "success" |
| 需求已满足 | 逐条 checklist 对照完成 | 仅仅测试通过 |

## 红旗信号：立刻停止

- 使用 "should"、"probably"、"seems to" 这类措辞
- 在验证之前表达满意（"Great!"、"Perfect!"、"Done!" 等）
- 没验证就准备 commit / push / 开 PR
- 直接相信代理说自己成功了
- 依赖局部验证
- 想着“就这一次”
- 因为累了只想赶快结束
- **任何在没跑验证前就暗示成功的表述**

## 反借口表

| 借口 | 现实 |
|--------|---------|
| "现在应该可以了" | 去运行验证 |
| "我很有信心" | 信心不等于证据 |
| "就这一次" | 没有例外 |
| "Linter 过了" | Linter 不等于编译器 |
| "代理说成功了" | 你必须独立验证 |
| "我太累了" | 疲惫不是借口 |
| "跑一部分就够了" | 局部验证什么都证明不了 |
| "我换个说法，这条规则就不算" | 精神比字面更重要 |

## 关键模式

**测试：**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**回归测试（TDD 红绿循环）：**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**构建：**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**需求：**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**代理委派：**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## 为什么这很重要

从 24 条失败记忆来看：
- 你的人工伙伴说过 "I don't believe you" - 信任已经被破坏
- 未定义函数被交付出去 - 运行时会直接崩
- 缺失需求的功能被交付出去 - 功能根本不完整
- 因为虚假的“已完成”而浪费时间，最后只能返工
- 这还违反了："Honesty is a core value. If you lie, you'll be replaced."

## 何时应用

**以下情况之前一律要做：**
- 任何形式的成功或完成声明
- 任何满意表达
- 任何关于工作状态的正面判断
- 提交、创建 PR、宣告任务完成之前
- 进入下一个任务之前
- 把工作委派给代理之前

**这条规则适用于：**
- 原句
- 同义改写
- 含蓄暗示成功的表达
- 任何会让人理解为“已经完成/已经正确”的沟通内容

## 底线

**验证没有捷径。**

先跑命令，读完输出，再声称结果成立。

这没有讨价还价空间。
