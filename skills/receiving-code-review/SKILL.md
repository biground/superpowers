---
name: receiving-code-review
description: 在收到代码评审反馈、准备实现建议之前使用，尤其当反馈含义不清或技术上值得怀疑时；要求技术上的严谨和验证，而不是表演式认同或盲目照做
---

# 接收代码评审

## 概览

代码评审需要技术判断，不需要情绪表演。

**核心原则：** 先验证，再实现。先提问，再假设。技术正确性优先于社交舒适感。

## 响应模式

```
WHEN receiving code review feedback:

1. READ: Complete feedback without reacting
2. UNDERSTAND: Restate requirement in own words (or ask)
3. VERIFY: Check against codebase reality
4. EVALUATE: Technically sound for THIS codebase?
5. RESPOND: Technical acknowledgment or reasoned pushback
6. IMPLEMENT: One item at a time, test each
```

## 禁止的回应

**绝不要：**
- "You're absolutely right!"（明确违反 CLAUDE.md）
- "Great point!" / "Excellent feedback!"（表演式赞同）
- "Let me implement that now"（尚未验证就开始承诺）

**相反，你应该：**
- 复述技术要求
- 提澄清问题
- 如果反馈不对，就用技术理由反驳
- 直接开始干活（行动大于话术）

## 处理不清晰的反馈

```
IF any item is unclear:
  STOP - do not implement anything yet
  ASK for clarification on unclear items

WHY: Items may be related. Partial understanding = wrong implementation.
```

**示例：**
```
your human partner: "Fix 1-6"
You understand 1,2,3,6. Unclear on 4,5.

❌ WRONG: Implement 1,2,3,6 now, ask about 4,5 later
✅ RIGHT: "I understand items 1,2,3,6. Need clarification on 4 and 5 before proceeding."
```

## 按反馈来源处理

### 来自你的人工伙伴
- **默认可信** - 理解后就实现
- **范围不清时仍然要问**
- **不要表演式认同**
- **直接行动**，或者只做技术性确认

### 来自外部评审者
```
BEFORE implementing:
  1. Check: Technically correct for THIS codebase?
  2. Check: Breaks existing functionality?
  3. Check: Reason for current implementation?
  4. Check: Works on all platforms/versions?
  5. Check: Does reviewer understand full context?

IF suggestion seems wrong:
  Push back with technical reasoning

IF can't easily verify:
  Say so: "I can't verify this without [X]. Should I [investigate/ask/proceed]?"

IF conflicts with your human partner's prior decisions:
  Stop and discuss with your human partner first
```

**你的人工伙伴的规则：** "External feedback - be skeptical, but check carefully"

## 对“更专业实现”的 YAGNI 检查

```
IF reviewer suggests "implementing properly":
  grep codebase for actual usage

  IF unused: "This endpoint isn't called. Remove it (YAGNI)?"
  IF used: Then implement properly
```

**你的人工伙伴的规则：** "You and reviewer both report to me. If we don't need this feature, don't add it."

## 实现顺序

```
FOR multi-item feedback:
  1. Clarify anything unclear FIRST
  2. Then implement in this order:
     - Blocking issues (breaks, security)
     - Simple fixes (typos, imports)
     - Complex fixes (refactoring, logic)
  3. Test each fix individually
  4. Verify no regressions
```

## 何时应该反驳

在以下情况应当反驳：
- 建议会破坏现有功能
- 评审者缺少完整上下文
- 违反 YAGNI（功能根本没人在用）
- 对当前技术栈来说，这个建议在技术上不成立
- 存在遗留兼容或平台兼容原因
- 与人工伙伴已经做出的架构决策冲突

**如何反驳：**
- 用技术推理，而不是防御姿态
- 问具体问题
- 引用已经通过的测试或现有代码
- 如果涉及架构，拉上人工伙伴一起判断

**如果你不方便直接说“我要反驳”，可以用这个暗号：** "Strange things are afoot at the Circle K"

## 如何确认正确反馈

当反馈确实正确时：
```
✅ "Fixed. [Brief description of what changed]"
✅ "Good catch - [specific issue]. Fixed in [location]."
✅ [Just fix it and show in the code]

❌ "You're absolutely right!"
❌ "Great point!"
❌ "Thanks for catching that!"
❌ "Thanks for [anything]"
❌ ANY gratitude expression
```

**为什么不要说谢谢：** 行动会说话。直接修。代码本身就会说明你已经听进去了。

**如果你发现自己正准备写 "Thanks"：** 删掉。直接写你改了什么。

## 如何体面地修正你之前的反驳

如果你反驳了，但后来发现自己错了：
```
✅ "You were right - I checked [X] and it does [Y]. Implementing now."
✅ "Verified this and you're correct. My initial understanding was wrong because [reason]. Fixing."

❌ Long apology
❌ Defending why you pushed back
❌ Over-explaining
```

客观说明更正即可，然后继续往前走。

## 常见错误

| 错误 | 修正方式 |
|---------|-----|
| 表演式认同 | 直接陈述需求，或者直接行动 |
| 盲目实现 | 先对照代码库验证 |
| 一次性批量改却不测 | 一次改一项，每项都测试 |
| 默认评审者一定对 | 先检查会不会把现有东西弄坏 |
| 回避反驳 | 技术正确性比舒服更重要 |
| 只实现了部分意见 | 先把所有不清楚的点问明白 |
| 无法验证却硬着头皮上 | 说明限制，并请求指示 |

## 真实示例

**表演式认同（差）：**
```
Reviewer: "Remove legacy code"
❌ "You're absolutely right! Let me remove that..."
```

**技术验证（好）：**
```
Reviewer: "Remove legacy code"
✅ "Checking... build target is 10.15+, this API needs 13+. Need legacy for backward compat. Current impl has wrong bundle ID - fix it or drop pre-13 support?"
```

**YAGNI（好）：**
```
Reviewer: "Implement proper metrics tracking with database, date filters, CSV export"
✅ "Grepped codebase - nothing calls this endpoint. Remove it (YAGNI)? Or is there usage I'm missing?"
```

**需求不清（好）：**
```
your human partner: "Fix items 1-6"
You understand 1,2,3,6. Unclear on 4,5.
✅ "Understand 1,2,3,6. Need clarification on 4 and 5 before implementing."
```

## GitHub 线程回复

在 GitHub 上回复行内 review comment 时，要在评论线程里回复（`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`），不要发成顶层 PR 评论。

## 底线

**外部反馈是需要评估的建议，不是必须照办的命令。**

先验证，再质疑，最后才实现。

不要表演式认同。始终保持技术严谨。
